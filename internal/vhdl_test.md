<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="vhdl_test"></a>

## vhdl_test

<pre>
load("@rules_nvc//internal:vhdl_test.bzl", "vhdl_test")

vhdl_test(<a href="#vhdl_test-name">name</a>, <a href="#vhdl_test-srcs">srcs</a>, <a href="#vhdl_test-deps">deps</a>, <a href="#vhdl_test-standard">standard</a>, <a href="#vhdl_test-args">args</a>, <a href="#vhdl_test-generics">generics</a>, <a href="#vhdl_test-data">data</a>, <a href="#vhdl_test-entity">entity</a>, <a href="#vhdl_test-entities">entities</a>, <a href="#vhdl_test-tags">tags</a>)
</pre>

Defines a VHDL test.

This macro combines `vhdl_library`, `vhdl_elaborate`, and internal test
execution steps into a single logical target.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="vhdl_test-name"></a>name |  The name of the base test target.   |  none |
| <a id="vhdl_test-srcs"></a>srcs |  A list of VHDL source files (`.vhdl` or `.vhd`).   |  none |
| <a id="vhdl_test-deps"></a>deps |  A list of `vhdl_library` targets that this test depends on.   |  none |
| <a id="vhdl_test-standard"></a>standard |  The VHDL standard to use (e.g., "2008", "2019"). Defaults to "2019".   |  `"2019"` |
| <a id="vhdl_test-args"></a>args |  A list of additional command-line arguments to pass to the NVC simulator.   |  `[]` |
| <a id="vhdl_test-generics"></a>generics |  Top-level VHDL generics to set at elaboration, as a name -> value map (emitted as -gNAME=VALUE). Values undergo $(location)/$(rootpath) expansion over `data`, so a generic can reference a build artifact (e.g. a memory init file the testbench reads at elaboration time).   |  `{}` |
| <a id="vhdl_test-data"></a>data |  Files made available to the elaboration action (e.g. the memory init files referenced by `generics`).   |  `[]` |
| <a id="vhdl_test-entity"></a>entity |  A single entity to test.   |  `None` |
| <a id="vhdl_test-entities"></a>entities |  A list of entities to test. If both `entity` and `entities` are provided, all are tested.   |  `[]` |
| <a id="vhdl_test-tags"></a>tags |  A list of tags to apply to the generated test target (e.g., ["manual"]).   |  `[]` |


