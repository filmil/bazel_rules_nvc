<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="nvc_vhdl_test"></a>

## nvc_vhdl_test

<pre>
load("@rules_nvc//internal:nvc_vhdl_test.bzl", "nvc_vhdl_test")

nvc_vhdl_test(<a href="#nvc_vhdl_test-name">name</a>, <a href="#nvc_vhdl_test-srcs">srcs</a>, <a href="#nvc_vhdl_test-deps">deps</a>, <a href="#nvc_vhdl_test-standard">standard</a>, <a href="#nvc_vhdl_test-args">args</a>, <a href="#nvc_vhdl_test-entity">entity</a>, <a href="#nvc_vhdl_test-entities">entities</a>)
</pre>

Defines a VHDL test.

This macro combines `nvc_vhdl_library`, `nvc_vhdl_elaborate`, and internal test
execution steps into a single logical target.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="nvc_vhdl_test-name"></a>name |  The name of the base test target.   |  none |
| <a id="nvc_vhdl_test-srcs"></a>srcs |  A list of VHDL source files (`.vhdl` or `.vhd`).   |  none |
| <a id="nvc_vhdl_test-deps"></a>deps |  A list of `nvc_vhdl_library` targets that this test depends on.   |  none |
| <a id="nvc_vhdl_test-standard"></a>standard |  The VHDL standard to use (e.g., "2008", "2019"). Defaults to "2019".   |  `"2019"` |
| <a id="nvc_vhdl_test-args"></a>args |  A list of additional command-line arguments to pass to the NVC simulator.   |  `[]` |
| <a id="nvc_vhdl_test-entity"></a>entity |  A single entity to test.   |  `None` |
| <a id="nvc_vhdl_test-entities"></a>entities |  A list of entities to test. If both `entity` and `entities` are provided, all are tested.   |  `[]` |


