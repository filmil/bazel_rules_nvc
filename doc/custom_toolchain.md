<!-- LICENSE sha256: c71d239df91726fc519c6eb72d318ec65820627232b2f796219e87dcf35d0ab4 -->

# Bringing Your Own NVC Toolchain

By default, rules_nvc builds NVC from source, from the `nvc` module, and runs
that binary. Another module can supply a different NVC instead, such as a
prebuilt binary, by registering a toolchain of the type
`@rules_nvc//build/nvc:toolchain_type`. The rules then run that NVC in every
action and test.

## Why you would

The `nvc` module builds NVC without its LLVM code generator. Such an NVC
interprets every design. An NVC built with LLVM compiles the design to machine
code, which runs large designs ten or more times faster. A prebuilt binary also
skips building NVC from source.

## How

Declare the toolchain with `nvc_toolchain`, and register it in your
`MODULE.bazel`. A toolchain that the root module registers takes precedence
over the one rules_nvc registers.

```python
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")
load("@rules_nvc//build/nvc:rules.bzl", "nvc_toolchain")

# `analyzer` must be a rule that outputs an executable, not a source file.
native_binary(
    name = "nvc_bin",
    src = "bin/nvc",
    out = "prebuilt/bin/nvc",
)

# The standard libraries: the directory that holds `std`, `ieee` and `nvc`,
# compiled by this same NVC.
filegroup(
    name = "std",
    srcs = ["lib/nvc"],
)

nvc_toolchain(
    name = "nvc",
    analyzer = ":nvc_bin",
    artifacts_dir = ":std",
)

toolchain(
    name = "toolchain",
    exec_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
    target_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
    toolchain = ":nvc",
    toolchain_type = "@rules_nvc//build/nvc:toolchain_type",
)
```

```python
register_toolchains("@my_nvc//:toolchain")
```

The standard libraries must come from the same NVC as the binary: NVC reads
only libraries compiled by its own version.

## What the rules guarantee

* Every action that runs NVC takes the toolchain's `analyzer` as a tool.
* A `vhdl_test` carries the `analyzer`, the `artifacts_dir` and the
  toolchain's `deps` in its runfiles. The NVC wrapper script does not depend on
  any NVC itself, so a test runs exactly the NVC the toolchain names.

`//build/tests/custom_toolchain` holds a toolchain defined this way and an
analysis test that checks the second guarantee. To run a VHDL test under that
toolchain:

```sh
bazel test //build/tests/custom_toolchain/... \
    --extra_toolchains=//build/tests/custom_toolchain:custom_toolchain
```
