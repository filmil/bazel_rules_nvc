load("//internal:utils.bzl", "get_single_file_from")
load("//internal:providers.bzl", "NVCInfo", "VHDLLibraryProvider", "ElaborateProvider")
load("//internal:toolchain.bzl",
     _NVC_TOOLCHAIN_TYPE = "NVC_TOOLCHAIN_TYPE",
     _NVC_WRAPPER = "NVC_WRAPPER",
    _VHDL_STANDARD_DEFAULT = "VHDL_STANDARD_DEFAULT",
    _nvc_toolchain = "nvc_toolchain")


def _vhdl_library(ctx):
    nvc_info = ctx.toolchains[_NVC_TOOLCHAIN_TYPE].nvc_info
    analyzer_x = nvc_info.analyzer.files.to_list()[0]
    analyzer = analyzer_x.path
    library_name = ctx.attr.name
    container_dir = ctx.actions.declare_directory(
        "{}".format(library_name)
    )

    artifacts = nvc_info.artifacts_dir.files.to_list()
    std_lib_dir = artifacts[1] # hopefully stable...
    targets = ctx.attr.srcs
    srcs = []
    for target in targets:
        files = target.files.to_list()
        srcs += files

    all_libraries = []
    flag_libraries = []
    deps_files = []
    seen = []
    for target in ctx.attr.deps:
        default_info = target[DefaultInfo]
        deps_files += default_info.files.to_list()
        vhdl_provider = target[VHDLLibraryProvider]
        all_libraries += vhdl_provider.libraries
        for name, path in vhdl_provider.libraries:
            flag_libraries += ["-L", "{path}".format(path=path.path)]
            seen += [name]


    ctx.actions.run(
        outputs = [container_dir],
        inputs = srcs + deps_files,
        executable =  analyzer, # how do I get its path?
        arguments = [
          "--std={}".format(ctx.attr.standard),
          "-L", "{}/nvc".format(std_lib_dir.path),
        ] + flag_libraries + [
          "--work={}:{}/{}".format(
            library_name,
            container_dir.path,
            library_name,
          ),
          "-a",
        ] + [f.path for f in srcs],
        tools = [analyzer_x] + artifacts,
        # Only seems to work from bazel 6.0.0 on.
        #toolchain = _NVC_TOOLCHAIN_TYPE,
        progress_message = "VHDL analyze: {}".format(library_name),
    )
    return [
        VHDLLibraryProvider(
            libraries = [(library_name, container_dir)] + all_libraries,
            entities = ctx.attr.entities,
            library_name = library_name,
            library_dir = container_dir,
        ),
        DefaultInfo(files = depset([container_dir]))
    ]

vhdl_library = rule(
    implementation = _vhdl_library,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".vhdl", ".vhd"],
        ),
        "deps": attr.label_list(),
        "entities": attr.string_list(),
        "standard": attr.string(
            default = _VHDL_STANDARD_DEFAULT,
        ),
    },
    toolchains = [
        _NVC_TOOLCHAIN_TYPE,
    ],
)

