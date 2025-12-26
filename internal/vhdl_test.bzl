load("//internal:utils.bzl", "get_single_file_from")
load("//internal:providers.bzl", "NVCInfo", "VHDLLibraryProvider", "ElaborateProvider")
load("//internal:toolchain.bzl",
     _NVC_TOOLCHAIN_TYPE = "NVC_TOOLCHAIN_TYPE",
     _NVC_WRAPPER = "NVC_WRAPPER",
    _VHDL_STANDARD_DEFAULT = "VHDL_STANDARD_DEFAULT",
    _nvc_toolchain = "nvc_toolchain")


load("//internal:vhdl_library.bzl", "vhdl_library")
load("//internal:vhdl_elaborate.bzl", "vhdl_elaborate")


def _vhdl_test(ctx):
    """
    Mostly copied from _vhdl_run
    """
    nvc_info = ctx.toolchains[_NVC_TOOLCHAIN_TYPE].nvc_info
    analyzer_x = nvc_info.analyzer.files.to_list()[0]
    analyzer = analyzer_x.short_path
    library_name = ctx.attr.name

    artifacts = nvc_info.artifacts_dir.files.to_list()
    std_lib_dir = artifacts[1] # hopefully stable...

    vhdl_provider = ctx.attr.entity[VHDLLibraryProvider]

    all_libraries = []
    flag_libraries = []
    deps_paths = []
    seen = []
    all_libraries += vhdl_provider.libraries
    for name, path in all_libraries:
        if name != vhdl_provider.library_name and name not in seen:
            flag_libraries += [
                "--map={}:{}/{}".format(name, path.short_path, name)]
            deps_paths += [path]
            seen += [name]


    work_library_file = get_single_file_from(ctx.attr.entity)

    elaborate_provider = ctx.attr.entity[ElaborateProvider]

    runfiles = ctx.runfiles(
        files=[vhdl_provider.library_dir] + ctx.attr._script.files.to_list(),
        transitive_files=depset(artifacts + deps_paths))

    runfiles = runfiles.merge_all([ctx.attr._script[DefaultInfo].default_runfiles])
    inputs = deps_paths + [vhdl_provider.library_dir, std_lib_dir]
    i_runfiles = ctx.runfiles(files = inputs)

    tools = [analyzer_x, ctx.executable._script, ] + artifacts
    t_runfiles = ctx.runfiles(files = tools)

    runfiles.merge_all([t_runfiles, i_runfiles, ctx.attr._script[DefaultInfo].default_runfiles])
    ctx.actions.expand_template(
        template = ctx.file._template,
        output = ctx.outputs.executable,
        substitutions = {
            "{{EXECUTABLE}}": ctx.executable._script.short_path,
            "{{VHDL_STANDARD}}": ctx.attr.standard,
            "{{ANALYZER}}": analyzer,
            "{{LIBRARY_NAME}}": vhdl_provider.library_name,
            "{{LIBRARY_PATHS}}": " ".join(flag_libraries),
            "{{STDLIB_DIR}}": std_lib_dir.short_path,
            "{{ENTITY}}": elaborate_provider.entity,
            "{{LIB_DIR_IN_PATH}}": vhdl_provider.library_dir.short_path,
            "{{LIB_DIR_OUT_PATH}}": work_library_file.short_path,
            "{{WAVE_FILE}}": "{}.gtkwave".format(ctx.attr.name),
        },
    )
    return [DefaultInfo(runfiles=runfiles)]


_vhdl_internal_test = rule(
    test = True,
    implementation = _vhdl_test,
    attrs = {
        "entity": attr.label(),
        "deps": attr.label_list(
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
        "_template": attr.label(
            default = Label("//build/nvc:unittest.tpl.sh"),
            allow_single_file = True,
        ),
    },
    toolchains = [
      _NVC_TOOLCHAIN_TYPE,
    ],
)


def vhdl_test(name, srcs, deps, args=[], entity=None, entities=[]):
    entity_list = []
    if entity:
        entity_list += [entity]
    entity_list += entities

    for entity in entity_list:
        # Strictly speaking this is not correct, since we're compiling the same
        # library twice.
        vhdl_library_name = "{name}_{entity}_lib".format(name=name,entity=entity)
        vhdl_library(
            name = vhdl_library_name,
            srcs = srcs,
            deps = deps,
        )
        e = "{entity}".format(entity=entity)
        vhdl_elaborate(
            name = e,
            library = ":{}".format(vhdl_library_name)
        )
        _vhdl_internal_test(
            name = "{name}_{entity}_test".format(name=name,entity=entity),
            entity = ":{}".format(e),
            args = args,
        )

