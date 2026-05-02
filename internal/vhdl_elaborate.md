<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="vhdl_elaborate"></a>

## vhdl_elaborate

<pre>
load("@rules_nvc//internal:vhdl_elaborate.bzl", "vhdl_elaborate")

vhdl_elaborate(<a href="#vhdl_elaborate-name">name</a>, <a href="#vhdl_elaborate-library">library</a>, <a href="#vhdl_elaborate-standard">standard</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="vhdl_elaborate-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="vhdl_elaborate-library"></a>library |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="vhdl_elaborate-standard"></a>standard |  -   | String | optional |  `"2019"`  |


