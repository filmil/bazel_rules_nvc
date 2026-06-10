<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="nvc_vhdl_run"></a>

## nvc_vhdl_run

<pre>
load("@rules_nvc//internal:nvc_vhdl_run.bzl", "nvc_vhdl_run")

nvc_vhdl_run(<a href="#nvc_vhdl_run-name">name</a>, <a href="#nvc_vhdl_run-deps">deps</a>, <a href="#nvc_vhdl_run-args">args</a>, <a href="#nvc_vhdl_run-entity">entity</a>, <a href="#nvc_vhdl_run-standard">standard</a>, <a href="#nvc_vhdl_run-use_fst">use_fst</a>, <a href="#nvc_vhdl_run-use_vcd">use_vcd</a>)
</pre>

Simulates an elaborated VHDL design using NVC.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nvc_vhdl_run-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nvc_vhdl_run-deps"></a>deps |  A list of other `nvc_vhdl_library` targets that this simulation depends on.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nvc_vhdl_run-args"></a>args |  A list of added command line args to use   | List of strings | optional |  `[]`  |
| <a id="nvc_vhdl_run-entity"></a>entity |  The elaborated VHDL entity to simulate. This should be a `nvc_vhdl_elaborate` target.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="nvc_vhdl_run-standard"></a>standard |  The VHDL standard to use for simulation. Defaults to '2019'.   | String | optional |  `"2019"`  |
| <a id="nvc_vhdl_run-use_fst"></a>use_fst |  A boolean indicating whether to generate a FST file for waveform viewing. Defaults to `False`. Takes precedence over `use_vcd`.   | Boolean | optional |  `False`  |
| <a id="nvc_vhdl_run-use_vcd"></a>use_vcd |  A boolean indicating whether to generate a VCD (Value Change Dump) file for waveform viewing. Defaults to `True`.   | Boolean | optional |  `True`  |


