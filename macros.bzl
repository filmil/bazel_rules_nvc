load("//build/nvc:rules.bzl", "nvc_vhdl_run", "nvc_vhdl_elaborate", "nvc_vhdl_library")

def nvc_vhdl_testbench(name, srcs, deps, entity=None, args=[]):
    nvc_vhdl_library_name = "{}_lib".format(name)
    nvc_vhdl_library(
        name = nvc_vhdl_library_name,
        srcs = srcs,
        deps = deps,
    )
    e = "{}_tb".format(name)
    if entity:
        e = entity
    nvc_vhdl_elaborate(
        name = e,
        library = ":{}".format(nvc_vhdl_library_name)
    )
    nvc_vhdl_run(
        name = name,
        entity = ":{}".format(e),
        args = args,
    )
