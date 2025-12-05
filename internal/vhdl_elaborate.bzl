load("//internal:utils.bzl", "get_single_file_from")
load("//internal:providers.bzl", "NVCInfo", "VHDLLibraryProvider", "ElaborateProvider")
load("//internal:toolchain.bzl",
     _NVC_TOOLCHAIN_TYPE = "NVC_TOOLCHAIN_TYPE",
     _NVC_WRAPPER = "NVC_WRAPPER",
    _VHDL_STANDARD_DEFAULT = "VHDL_STANDARD_DEFAULT",
    _nvc_toolchain = "nvc_toolchain")


def _vhdl_elaborate(ctx):
    nvc_info = ctx.toolchains[_NVC_TOOLCHAIN_TYPE].nvc_info
    analyzer_x = nvc_info.analyzer.files.to_list()[0]
    analyzer = analyzer_x.path

    vhdl_provider = ctx.attr.library[VHDLLibraryProvider]
    library_name = vhdl_provider.library_name
    out_dir = ctx.actions.declare_directory("{}_out".format(library_name))

    artifacts = nvc_info.artifacts_dir.files.to_list()
    std_lib_dir = artifacts[1] # hopefully stable...

    all_libraries = []
    flag_libraries = []
    deps_paths = []
    seen = []

    vhdl_provider = ctx.attr.library[VHDLLibraryProvider]
    all_libraries += vhdl_provider.libraries
    for name, path in vhdl_provider.libraries:
        if name != vhdl_provider.library_name and name not in seen:
            flag_libraries += ["-L", path.path]
            deps_paths += [path]
            seen += [name]

    runfiles = ctx.runfiles(files=deps_paths + [out_dir])

    runfiles.merge_all([ctx.attr.library[DefaultInfo].default_runfiles])

    work_library_file = get_single_file_from(ctx.attr.library)
    ctx.actions.run(
        outputs = [out_dir],
        inputs = [vhdl_provider.library_dir, std_lib_dir] + deps_paths,
        executable = ctx.executable._script.path,
        arguments = [
            "--vhdl-standard={}".format(ctx.attr.standard),
            "--nvc-binary-path={}".format(analyzer),
            "--library-name={}".format(library_name),
            "--library-paths={}".format(" ".join(flag_libraries)),
            "--stdlib-dir={}".format(std_lib_dir.path),
            "--entity={}".format(ctx.attr.name),
            "--library-dir-in-path={}".format(work_library_file.path),
            "--library-dir-out-path={}".format(out_dir.path),
        ],
        tools = [analyzer_x, ctx.executable._script] + artifacts,
        # Only seems to work from bazel 6.0.0 on.
        #toolchain = _NVC_TOOLCHAIN_TYPE,
        progress_message = "Elaborating VHDL: {}.{} at {}".format(
            vhdl_provider.library_name, ctx.attr.name, work_library_file.path),
    )
    return  [
        VHDLLibraryProvider(
            libraries = vhdl_provider.libraries + all_libraries,
            entities = vhdl_provider.entities,
            library_name = library_name,
            library_dir = out_dir,
        ),
        ElaborateProvider(entity=ctx.attr.name),
        DefaultInfo(
            files=depset([out_dir]),
            runfiles=runfiles,
        ),
    ]

vhdl_elaborate = rule(
    implementation = _vhdl_elaborate,
    attrs = {
        "library": attr.label(),
        "_script": attr.label(
            default = _NVC_WRAPPER,
            executable = True,
            cfg = "host",
        ),
        "standard": attr.string(
            default = _VHDL_STANDARD_DEFAULT,
        ),
    },
    toolchains = [
        _NVC_TOOLCHAIN_TYPE
    ],
)
