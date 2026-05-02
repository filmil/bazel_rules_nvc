<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="produce_waveform"></a>

## produce_waveform

<pre>
load("@rules_nvc//internal:produce_waveform.bzl", "produce_waveform")

produce_waveform(<a href="#produce_waveform-name">name</a>, <a href="#produce_waveform-data">data</a>, <a href="#produce_waveform-args">args</a>, <a href="#produce_waveform-simulation">simulation</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="produce_waveform-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="produce_waveform-data"></a>data |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="produce_waveform-args"></a>args |  -   | List of strings | optional |  `[]`  |
| <a id="produce_waveform-simulation"></a>simulation |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


