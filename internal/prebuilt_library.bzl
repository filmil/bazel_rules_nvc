load("//internal:utils.bzl", "get_single_file_from")
load("//internal:providers.bzl", "VHDLLibraryProvider")
load("//internal:toolchain.bzl",
     #_NVC_TOOLCHAIN_TYPE = "NVC_TOOLCHAIN_TYPE",
     #_NVC_WRAPPER = "NVC_WRAPPER",
    _VHDL_STANDARD_DEFAULT = "VHDL_STANDARD_DEFAULT",
    #_nvc_toolchain = "nvc_toolchain",
)


def _impl(ctx):
    library_name = ctx.attr.library_name or ctx.attr.name
    runfiles = ctx.runfiles(files=[])

    # Find the container directory.
    transitive_deps = []
    library_dir = ctx.file.library_dir
    libraries = [(library_name, library_dir)]

    seen_libraries = [library_name]
    transitive_runfiles = []
    for target in ctx.attr.deps:
        transitive_runfiles += [target[DefaultInfo].default_runfiles]
        transitive_deps += [target.files]
        provider = target[VHDLLibraryProvider]
        target_libraries = provider.libraries
        for name, path in provider.libraries:
            print(name, path)
            if name not in seen_libraries:
                libraries += [(name, path)]
                seen += [name]

    # Find all depset files.
    files = depset([], transitive=transitive_deps)
    runfiles = runfiles.merge_all(transitive_runfiles)
    return [
        DefaultInfo(
            files=files,
            runfiles=runfiles,
        ),
        VHDLLibraryProvider(
            libraries=libraries,
            entities = [],
            library_name=library_name,
            library_dir=library_dir,
        ),
    ]


prebuilt_library = rule(
    implementation = _impl,
    attrs = {
        "library_name": attr.string(
            doc = "The official library name, in case target name is not appropriate. Target name is used if not specified.",
        ),
        "library_dir": attr.label(
            doc = "The library directory, used to short-circuit directory detection",
            mandatory = True,
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            allow_files = True,
            doc = "The list of source targets that comprise this prebuilt library.",
        ),
        "deps": attr.label_list(
            doc = "The dependency libraries, if any",
            providers = [VHDLLibraryProvider],
        ),
        "entities": attr.string_list(
            doc = "The list of entities emphasized in thsi library, for elaboration purposes",
            default = [],
        ),
        "standard": attr.string(
            doc = "The HDL language standard to use. For VHDL it is the standard version, such as 1993, or 2008, or 2019",
        ),
    },
)

