NVCInfo = provider(
    doc = "Information on how to run NVC for VHDL analysis, elaboration and sim",
    fields = [
      "analyzer",
      "artifacts_dir",
    ]
)

_NVC_TOOLCHAIN_TYPE = "@bazel_rules_nvc//build/nvc:toolchain_type"

_NVC_WRAPPER = Label("@bazel_rules_nvc//build/nvc:nvc_wrapper")

_VHDL_STANDARD_DEFAULT = "2019"

def _nvc_toolchain_impl(ctx):
  toolchain_info = platform_common.ToolchainInfo(
    nvc_info = NVCInfo(
      analyzer = ctx.attr.analyzer,
      artifacts_dir = ctx.attr.artifacts_dir,
    ),
  )
  return [toolchain_info]


nvc_toolchain = rule(
  implementation = _nvc_toolchain_impl,
  attrs = {
    "analyzer": attr.label(executable = True, cfg = "host"),
    "artifacts_dir": attr.label(),
    "deps": attr.label_list(
        default = [],
    ),
  }
)

VHDLLibraryProvider = provider(
    doc = "",
    fields = [
        "libraries",
        "entities",
        "library_name",
        "library_dir"
    ]
)

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
    deps_paths = []
    seen = []
    for dep in ctx.attr.deps:
        # dep is a Target
        vhdl_provider = dep[VHDLLibraryProvider]
        all_libraries += vhdl_provider.libraries
        for name, path in vhdl_provider.libraries:
            flag_libraries += ["-L", "{}".format(path.path, name)]
            deps_paths += [path]
            seen += [name]


    ctx.actions.run(
        outputs = [container_dir],
        inputs = srcs + deps_paths,
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


def get_single_file_from(target):
    file_list = target.files.to_list()
    # assert 1 file
    return file_list[0]


ElaborateProvider = provider(
    doc = "TBD",
    fields = [
        "entity",
    ]
)


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
        "{}.gtkwave".format(ctx.attr.name))

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
        ],
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
        "args": attr.string_list(
            doc = "A list of added command line args to use",
        ),
    },
    toolchains = [
      _NVC_TOOLCHAIN_TYPE,
    ],
)

def wave_view(name, vhdl_run, args=[], deps=[], viewer="gtkwave", testonly=None):
    """
    Generates a sh_binary viewer.

    Args:
    - name: the target name.
    - vhdl_run: the target name for the `vhdl_run` target to
      use the output from.
    - args: any additional arguments to add to invoke the viewer.
    - viewer: the viewer to invoke. The viewer must be compatible
      with the file format to view, and must be installed on the
      host.
    """
    native.sh_binary(
        testonly = testonly,
        name = name,
        srcs = [Label("//build/nvc:run_wave_view.sh")],
        deps = ["@bazel_tools//tools/bash/runfiles"],
        args = [
          "--viewer-binary={}".format(viewer),
          "--wave-file=$(location {})".format(vhdl_run),
          "--",
        ] + args,
        visibility = ["//visibility:public"],
        data = [
          "@gotopt2//cmd/gotopt2:gotopt2",
          vhdl_run,
        ] + deps,
    )


def _produce_waveform(ctx):
    data_files = []
    for target in ctx.attr.data:
        for file in target.files.to_list():
            data_files += [file]
    output_file = ctx.actions.declare_file("{}.vcd".format(ctx.attr.name))
    runfiles = ctx.runfiles(files=[output_file] + data_files)
    sim = ctx.executable.simulation
    ctx.actions.run(
        outputs = [output_file],
        inputs = data_files,
        executable = sim.path,
        arguments = [
            output_file.path,
        ] + ctx.attr.args,
        tools = [
            sim,
        ],
    )
    return [
        DefaultInfo(
            files=depset([output_file]),
            runfiles=runfiles,
        ),
    ]


produce_waveform = rule(
    implementation = _produce_waveform,
    attrs = {
        "simulation": attr.label(
            executable = True,
            cfg = "host",
        ),
        "data": attr.label_list(),
        "args": attr.string_list(),
    },
)

def _extract_file(ctx):
    filter = []
    for file in ctx.attr.src.files.to_list():
        if ctx.attr.filter in file.path:
            filter += [file]
    return [
        DefaultInfo(files=depset(filter),
        runfiles=ctx.runfiles(files=filter)),
    ]


extract_file = rule(
    implementation = _extract_file,
    attrs = {
        "filter": attr.string(),
        "src" : attr.label(),
    },
)


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


def vhdl_test(name, srcs, deps, args=[], entity=None):
    vhdl_library_name = "{}_lib".format(name)
    vhdl_library(
        name = vhdl_library_name,
        srcs = srcs,
        deps = deps,
    )
    e = "{}_tb".format(name)
    if entity:
        e = entity
    vhdl_elaborate(
        name = e,
        library = ":{}".format(vhdl_library_name)
    )
    _vhdl_internal_test(
        name = name,
        entity = ":{}".format(e),
        args = args,
    )
