<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="vhdl_run"></a>

## vhdl_run

<pre>
load("@rules_nvc//internal:vhdl_run.bzl", "vhdl_run")

vhdl_run(<a href="#vhdl_run-name">name</a>, <a href="#vhdl_run-deps">deps</a>, <a href="#vhdl_run-args">args</a>, <a href="#vhdl_run-entity">entity</a>, <a href="#vhdl_run-standard">standard</a>, <a href="#vhdl_run-use_vcd">use_vcd</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="vhdl_run-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="vhdl_run-deps"></a>deps |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="vhdl_run-args"></a>args |  A list of added command line args to use   | List of strings | optional |  `[]`  |
| <a id="vhdl_run-entity"></a>entity |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="vhdl_run-standard"></a>standard |  -   | String | optional |  `"2019"`  |
| <a id="vhdl_run-use_vcd"></a>use_vcd |  -   | Boolean | optional |  `True`  |


