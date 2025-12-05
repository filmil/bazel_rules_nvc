load("//internal:utils.bzl", "get_single_file_from")
load("//internal:providers.bzl", "NVCInfo", "VHDLLibraryProvider", "ElaborateProvider")
load("//internal:toolchain.bzl",
     _NVC_TOOLCHAIN_TYPE = "NVC_TOOLCHAIN_TYPE",
     _NVC_WRAPPER = "NVC_WRAPPER",
    _VHDL_STANDARD_DEFAULT = "VHDL_STANDARD_DEFAULT",
    _nvc_toolchain = "nvc_toolchain")


def _vhdl_run(ctx):
    nvc_info = ctx.toolchains[_NVC_TOOLCHAIN_TYPE].nvc_info
    analyzer_x = nvc_info.analyzer.files.to_list()[0]
    analyzer = analyzer_x.path
    library_name = ctx.attr.name

    artifacts = nvc_info.artifacts_dir.files.to_list()
    std_lib_dir = artifacts[1] # hopefully stable...

    vhdl_provider = ctx.attr.entity[VHDLLibraryProvider]

    all_libraries = []
    flag_libraries = []
    deps_paths = []
    seen = []
    all_libraries += vhdl_provider.libraries
    for name, path in vhdl_provider.libraries:
        if name != vhdl_provider.library_name and name not in seen:
            flag_libraries += [
                "--map={}:{}/{}".format(name, path.path, name)]
            deps_paths += [path]
            seen += [name]


    work_library_file = get_single_file_from(ctx.attr.entity)

    wave_file = ctx.actions.declare_file(
        "{}.vcd".format(ctx.attr.name))

    format = []
    if ctx.attr.use_vcd:
        format = [ "--format=vcd" ]

    elaborate_provider = ctx.attr.entity[ElaborateProvider]
    runfiles = ctx.runfiles(files = [wave_file])
    ctx.actions.run(
        outputs = [wave_file],
        inputs = deps_paths + [
            vhdl_provider.library_dir, std_lib_dir],
        executable = ctx.executable._script.path,
        arguments = [
            "-cmd=-r",
            "--vhdl-standard={}".format(ctx.attr.standard),
            "--nvc-binary-path={}".format(analyzer),
            "--library-name={}".format(vhdl_provider.library_name),
            "--library-paths={}".format(" ".join(flag_libraries)),
            "--stdlib-dir={}".format(std_lib_dir.path),
            "--entity={}".format(elaborate_provider.entity),
            "--library-dir-in-path={}".format(work_library_file.path),
            "--library-dir-out-path={}".format(work_library_file.path),
            "--",
        ] + ctx.attr.args + [
            "--wave={}".format(wave_file.path),
        ] + format,
        tools = [analyzer_x, ctx.executable._script] + artifacts,
        # Only seems to work from bazel 6.0.0 on.
        #toolchain = _NVC_TOOLCHAIN_TYPE,
        progress_message = "Simulating VHDL: {}.{} at {}".format(
            vhdl_provider.library_name,
            elaborate_provider.entity,
            work_library_file.path),
    )
    return [
        DefaultInfo(
            files=depset([wave_file]),
            runfiles=runfiles,
        ),
    ]

vhdl_run = rule(
    implementation = _vhdl_run,
    attrs = {
        "entity": attr.label(), "deps": attr.label_list(
            default = [],
        ),
        "_script": attr.label(
            default = _NVC_WRAPPER,
            executable = True,
            cfg = "host",
        ),
        "standard": attr.string(
            default = _VHDL_STANDARD_DEFAULT,
        ),
        "use_vcd": attr.bool(
            default = True,
        ),
        "args": attr.string_list(
            doc = "A list of added command line args to use",
        ),
    },
    toolchains = [
      _NVC_TOOLCHAIN_TYPE,
    ],
)
