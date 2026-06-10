<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="nvc_vhdl_library"></a>

## nvc_vhdl_library

<pre>
load("@rules_nvc//internal:nvc_vhdl_library.bzl", "nvc_vhdl_library")

nvc_vhdl_library(<a href="#nvc_vhdl_library-name">name</a>, <a href="#nvc_vhdl_library-deps">deps</a>, <a href="#nvc_vhdl_library-srcs">srcs</a>, <a href="#nvc_vhdl_library-entities">entities</a>, <a href="#nvc_vhdl_library-library_name">library_name</a>, <a href="#nvc_vhdl_library-standard">standard</a>, <a href="#nvc_vhdl_library-vpi_plugins">vpi_plugins</a>)
</pre>

Compiles VHDL source files into a library using NVC.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="nvc_vhdl_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="nvc_vhdl_library-deps"></a>deps |  A list of other `nvc_vhdl_library` targets that this library depends on.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nvc_vhdl_library-srcs"></a>srcs |  A list of VHDL source files.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="nvc_vhdl_library-entities"></a>entities |  A list of VHDL entities provided by this library.   | List of strings | optional |  `[]`  |
| <a id="nvc_vhdl_library-library_name"></a>library_name |  If the target name is not appropriate as a library name, provide one here   | String | optional |  `""`  |
| <a id="nvc_vhdl_library-standard"></a>standard |  The VHDL standard to use for compilation (e.g., '2008', '2019'). Defaults to '2019'.   | String | optional |  `"2019"`  |
| <a id="nvc_vhdl_library-vpi_plugins"></a>vpi_plugins |  List of VPI plugins required for simulation.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


<a id="nvc_compile_aspect"></a>

## nvc_compile_aspect

<pre>
load("@rules_nvc//internal:nvc_vhdl_library.bzl", "nvc_compile_aspect")

nvc_compile_aspect()
</pre>



**ASPECT ATTRIBUTES**


| Name | Type |
| :------------- | :------------- |
| deps| String |


**ATTRIBUTES**



