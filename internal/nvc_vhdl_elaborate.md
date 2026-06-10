<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="nvc_vhdl_elaborate"></a>

## nvc_vhdl_elaborate

<pre>
load("@rules_nvc//internal:nvc_vhdl_elaborate.bzl", "nvc_vhdl_elaborate")

nvc_vhdl_elaborate(<a href="#nvc_vhdl_elaborate-name">name</a>, <a href="#nvc_vhdl_elaborate-library">library</a>, <a href="#nvc_vhdl_elaborate-standard">standard</a>)
</pre>

Elaborates a VHDL design using NVC.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nvc_vhdl_elaborate-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nvc_vhdl_elaborate-library"></a>library |  The `nvc_vhdl_library` target to elaborate.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="nvc_vhdl_elaborate-standard"></a>standard |  The VHDL standard to use for elaboration (e.g., '2019').   | String | optional |  `"2019"`  |


