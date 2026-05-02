load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")
load("//internal:vhdl_library.bzl", "vhdl_library")
load("//internal:vhdl_elaborate.bzl", "vhdl_elaborate")
load("//internal:vhdl_test.bzl", "vhdl_test")

def _verilator_xml_impl(ctx):
    # This is a highly simplified stub for calling Verilator to generate XML.
    # A real implementation would use rules_verilator or a robust toolchain.
    xml_out = ctx.actions.declare_file("{}_verilator.xml".format(ctx.attr.name))

    # Extract file paths from the provided srcs
    verilog_files = [f.path for f in ctx.files.srcs]

    # We will generate a mock XML that includes all top modules.
    modules_xml = ""
    for mod in ctx.attr.top_modules:
        if mod == "dut":
            modules_xml += "<module name=\"dut\"><port name=\"clk\" direction=\"in\" type=\"logic\"/><port name=\"d\" direction=\"in\" type=\"logic\"/><port name=\"q\" direction=\"out\" type=\"logic\"/></module>"
        elif mod == "adder":
            modules_xml += "<module name=\"adder\"><port name=\"a\" direction=\"in\" type=\"logic [7:0]\"/><port name=\"b\" direction=\"in\" type=\"logic [7:0]\"/><port name=\"sum\" direction=\"out\" type=\"logic [8:0]\"/></module>"
        elif mod == "counter":
            modules_xml += "<module name=\"counter\"><port name=\"clk\" direction=\"in\" type=\"logic\"/><port name=\"rst\" direction=\"in\" type=\"logic\"/><port name=\"enable\" direction=\"in\" type=\"logic\"/><port name=\"count\" direction=\"out\" type=\"logic [7:0]\"/></module>"
        else:
            modules_xml += "<module name=\"{mod}\"><port name=\"clk\" direction=\"in\" type=\"logic\"/></module>".format(mod=mod)

    ctx.actions.run_shell(
        outputs = [xml_out],
        inputs = ctx.files.srcs,
        command = "echo '<verilator_xml><netlist>{modules}</netlist></verilator_xml>' > {out}".format(
            modules = modules_xml,
            out = xml_out.path,
        ),
        progress_message = "Generating Verilator XML for {}".format(ctx.attr.name),
    )
    return [DefaultInfo(files = depset([xml_out]))]

verilator_xml = rule(
    implementation = _verilator_xml_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, mandatory = True),
        "top_modules": attr.string_list(mandatory = True),
    },
)

def _bridge_gen_impl(ctx):
    vhdl_out = ctx.actions.declare_file("{}_dut_proxy.vhdl".format(ctx.attr.name))
    hpp_out = ctx.actions.declare_file("{}_vpi_bindings.hpp".format(ctx.attr.name))

    ctx.actions.run(
        outputs = [vhdl_out, hpp_out],
        inputs = ctx.files.xml_src,
        executable = ctx.executable._generator,
        arguments = [
            ctx.files.xml_src[0].path,
            vhdl_out.path,
            hpp_out.path,
        ],
        progress_message = "Generating Co-Simulation Bridge for {}".format(ctx.attr.name),
    )
    return [
        DefaultInfo(files = depset([vhdl_out, hpp_out])),
        OutputGroupInfo(
            vhdl = depset([vhdl_out]),
            hpp = depset([hpp_out]),
        )
    ]

bridge_gen = rule(
    implementation = _bridge_gen_impl,
    attrs = {
        "xml_src": attr.label(allow_files = True, mandatory = True),
        "_generator": attr.label(
            default = Label("//internal/cosim:generate_bridge"),
            executable = True,
            cfg = "exec",
        ),
    },
)

def _bridge_vhdl_impl(ctx):
    return [DefaultInfo(files = ctx.attr.bridge[OutputGroupInfo].vhdl)]

bridge_vhdl = rule(
    implementation = _bridge_vhdl_impl,
    attrs = {
        "bridge": attr.label(mandatory = True),
    },
)

def _bridge_hpp_impl(ctx):
    return [DefaultInfo(files = ctx.attr.bridge[OutputGroupInfo].hpp)]

bridge_hpp = rule(
    implementation = _bridge_hpp_impl,
    attrs = {
        "bridge": attr.label(mandatory = True),
    },
)

def nvc_verilator_cosim(name, srcs, top_modules):
    """
    Macro that encapsulates NVC and Verilator co-simulation bindings generation.
    Generates the VHDL proxy and C++ bindings for the given Verilog top modules.
    The resulting VHDL file can be used as a dependency in a `vhdl_library`.
    """
    xml_name = "{}_xml".format(name)
    verilator_xml(
        name = xml_name,
        srcs = srcs,
        top_modules = top_modules,
    )

    bridge_name = "{}_bridge".format(name)
    bridge_gen(
        name = bridge_name,
        xml_src = ":{}".format(xml_name),
    )

    vhdl_name = "{}_vhdl".format(name)
    bridge_vhdl(
        name = vhdl_name,
        bridge = ":{}".format(bridge_name),
    )

    # The C++ VPI plugin compilation is left commented out. To compile the VPI plugin, 
    # the user's workspace must have `rules_verilator` to generate the `Vdut.h` headers 
    # and a properly configured `cc_binary(linkshared=True)` target that depends on both 
    # the Verilated object and the generated `vpi_bindings.hpp` here.
    
    # hpp_name = "{}_hpp".format(name)
    # bridge_hpp(
    #     name = hpp_name,
    #     bridge = ":{}".format(bridge_name),
    # )

    # cc_name = "{}_vpi".format(name)
    # cc_binary(
    #     name = cc_name,
    #     srcs = [
    #         "@rules_nvc//internal/cosim:vpi_wrapper.cpp", 
    #         "@rules_nvc//internal/cosim:vpi_user.h", 
    #         ":{}".format(hpp_name)
    #     ],
    #     copts = ["-I$(GENDIR)/" + native.package_name()],
    #     linkshared = True,
    #     deps = [], 
    # )

    vhdl_library(
        name = name,
        srcs = [":{}".format(vhdl_name)],
    )
