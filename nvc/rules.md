<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="extract_file"></a>

## extract_file

<pre>
load("@rules_nvc//nvc:rules.bzl", "extract_file")

extract_file(<a href="#extract_file-name">name</a>, <a href="#extract_file-src">src</a>, <a href="#extract_file-filter">filter</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="extract_file-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="extract_file-src"></a>src |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="extract_file-filter"></a>filter |  -   | String | optional |  `""`  |


<a id="nvc_toolchain"></a>

## nvc_toolchain

<pre>
load("@rules_nvc//nvc:rules.bzl", "nvc_toolchain")

nvc_toolchain(<a href="#nvc_toolchain-name">name</a>, <a href="#nvc_toolchain-deps">deps</a>, <a href="#nvc_toolchain-analyzer">analyzer</a>, <a href="#nvc_toolchain-artifacts_dir">artifacts_dir</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nvc_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nvc_toolchain-deps"></a>deps |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nvc_toolchain-analyzer"></a>analyzer |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="nvc_toolchain-artifacts_dir"></a>artifacts_dir |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="produce_waveform"></a>

## produce_waveform

<pre>
load("@rules_nvc//nvc:rules.bzl", "produce_waveform")

produce_waveform(<a href="#produce_waveform-name">name</a>, <a href="#produce_waveform-data">data</a>, <a href="#produce_waveform-args">args</a>, <a href="#produce_waveform-simulation">simulation</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="produce_waveform-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="produce_waveform-data"></a>data |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="produce_waveform-args"></a>args |  -   | List of strings | optional |  `[]`  |
| <a id="produce_waveform-simulation"></a>simulation |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="vhdl_elaborate"></a>

## vhdl_elaborate

<pre>
load("@rules_nvc//nvc:rules.bzl", "vhdl_elaborate")

vhdl_elaborate(<a href="#vhdl_elaborate-name">name</a>, <a href="#vhdl_elaborate-library">library</a>, <a href="#vhdl_elaborate-standard">standard</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="vhdl_elaborate-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="vhdl_elaborate-library"></a>library |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="vhdl_elaborate-standard"></a>standard |  -   | String | optional |  `"2019"`  |


<a id="vhdl_library"></a>

## vhdl_library

<pre>
load("@rules_nvc//nvc:rules.bzl", "vhdl_library")

vhdl_library(<a href="#vhdl_library-name">name</a>, <a href="#vhdl_library-deps">deps</a>, <a href="#vhdl_library-srcs">srcs</a>, <a href="#vhdl_library-entities">entities</a>, <a href="#vhdl_library-library_name">library_name</a>, <a href="#vhdl_library-standard">standard</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="vhdl_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="vhdl_library-deps"></a>deps |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="vhdl_library-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="vhdl_library-entities"></a>entities |  -   | List of strings | optional |  `[]`  |
| <a id="vhdl_library-library_name"></a>library_name |  If the target name is not appropriate as a library name, provide one here   | String | optional |  `""`  |
| <a id="vhdl_library-standard"></a>standard |  -   | String | optional |  `"2019"`  |


<a id="vhdl_run"></a>

## vhdl_run

<pre>
load("@rules_nvc//nvc:rules.bzl", "vhdl_run")

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


<a id="vhdl_test"></a>

## vhdl_test

<pre>
load("@rules_nvc//nvc:rules.bzl", "vhdl_test")

vhdl_test(<a href="#vhdl_test-name">name</a>, <a href="#vhdl_test-srcs">srcs</a>, <a href="#vhdl_test-deps">deps</a>, <a href="#vhdl_test-standard">standard</a>, <a href="#vhdl_test-args">args</a>, <a href="#vhdl_test-entity">entity</a>, <a href="#vhdl_test-entities">entities</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="vhdl_test-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="vhdl_test-srcs"></a>srcs |  <p align="center"> - </p>   |  none |
| <a id="vhdl_test-deps"></a>deps |  <p align="center"> - </p>   |  none |
| <a id="vhdl_test-standard"></a>standard |  <p align="center"> - </p>   |  `"2019"` |
| <a id="vhdl_test-args"></a>args |  <p align="center"> - </p>   |  `[]` |
| <a id="vhdl_test-entity"></a>entity |  <p align="center"> - </p>   |  `None` |
| <a id="vhdl_test-entities"></a>entities |  <p align="center"> - </p>   |  `[]` |


<a id="wave_view"></a>

## wave_view

<pre>
load("@rules_nvc//nvc:rules.bzl", "wave_view")

wave_view(<a href="#wave_view-name">name</a>, <a href="#wave_view-vhdl_run">vhdl_run</a>, <a href="#wave_view-args">args</a>, <a href="#wave_view-deps">deps</a>, <a href="#wave_view-viewer">viewer</a>, <a href="#wave_view-testonly">testonly</a>, <a href="#wave_view-save_file">save_file</a>)
</pre>

Generates a sh_binary viewer.

# Args

- name: the target name.
- vhdl_run: the target name for the `vhdl_run` target to
  use the output from.
- args: any additional arguments to add to invoke the viewer.
- viewer: the viewer to invoke. The viewer must be compatible
  with the file format to view, and must be installed on the
  host.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="wave_view-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="wave_view-vhdl_run"></a>vhdl_run |  <p align="center"> - </p>   |  none |
| <a id="wave_view-args"></a>args |  <p align="center"> - </p>   |  `[]` |
| <a id="wave_view-deps"></a>deps |  <p align="center"> - </p>   |  `[]` |
| <a id="wave_view-viewer"></a>viewer |  <p align="center"> - </p>   |  `"gtkwave"` |
| <a id="wave_view-testonly"></a>testonly |  <p align="center"> - </p>   |  `None` |
| <a id="wave_view-save_file"></a>save_file |  <p align="center"> - </p>   |  `None` |


