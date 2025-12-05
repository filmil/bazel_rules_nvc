load("//internal:utils.bzl", "get_single_file_from")
load("//internal:providers.bzl", "NVCInfo", "VHDLLibraryProvider", "ElaborateProvider")
load("//internal:toolchain.bzl",
     _NVC_TOOLCHAIN_TYPE = "NVC_TOOLCHAIN_TYPE",
     _NVC_WRAPPER = "NVC_WRAPPER",
    _VHDL_STANDARD_DEFAULT = "VHDL_STANDARD_DEFAULT",
    _nvc_toolchain = "nvc_toolchain")


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

