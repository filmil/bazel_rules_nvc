<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="nvc_toolchain"></a>

## nvc_toolchain

<pre>
load("@rules_nvc//internal:toolchain.bzl", "nvc_toolchain")

nvc_toolchain(<a href="#nvc_toolchain-name">name</a>, <a href="#nvc_toolchain-deps">deps</a>, <a href="#nvc_toolchain-analyzer">analyzer</a>, <a href="#nvc_toolchain-artifacts_dir">artifacts_dir</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nvc_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nvc_toolchain-deps"></a>deps |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nvc_toolchain-analyzer"></a>analyzer |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="nvc_toolchain-artifacts_dir"></a>artifacts_dir |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


