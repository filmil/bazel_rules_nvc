<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="extract_file"></a>

## extract_file

<pre>
load("@rules_nvc//internal:extract_file.bzl", "extract_file")

extract_file(<a href="#extract_file-name">name</a>, <a href="#extract_file-src">src</a>, <a href="#extract_file-filter">filter</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="extract_file-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="extract_file-src"></a>src |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="extract_file-filter"></a>filter |  -   | String | optional |  `""`  |


