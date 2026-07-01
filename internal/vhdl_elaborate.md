<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="vhdl_elaborate"></a>

## vhdl_elaborate

<pre>
load("@rules_nvc//internal:vhdl_elaborate.bzl", "vhdl_elaborate")

vhdl_elaborate(<a href="#vhdl_elaborate-name">name</a>, <a href="#vhdl_elaborate-data">data</a>, <a href="#vhdl_elaborate-generics">generics</a>, <a href="#vhdl_elaborate-library">library</a>, <a href="#vhdl_elaborate-standard">standard</a>)
</pre>

Elaborates a VHDL design using NVC.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="vhdl_elaborate-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="vhdl_elaborate-data"></a>data |  Files made available to the elaboration action, e.g. memory init files referenced by a generic value.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="vhdl_elaborate-generics"></a>generics |  Top-level VHDL generics to set at elaboration, as a name -> value map (emitted as -gNAME=VALUE after the top unit).  Values undergo $(location)/$(rootpath) expansion over `data`.   | <a href="https://bazel.build/rules/lib/core/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="vhdl_elaborate-library"></a>library |  The `vhdl_library` target to elaborate.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="vhdl_elaborate-standard"></a>standard |  The VHDL standard to use for elaboration (e.g., '2019').   | String | optional |  `"2019"`  |


