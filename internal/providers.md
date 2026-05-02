<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="ElaborateProvider"></a>

## ElaborateProvider

<pre>
load("@rules_nvc//internal:providers.bzl", "ElaborateProvider")

ElaborateProvider(<a href="#ElaborateProvider-entity">entity</a>)
</pre>

TBD

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="ElaborateProvider-entity"></a>entity |  -    |


<a id="NVCInfo"></a>

## NVCInfo

<pre>
load("@rules_nvc//internal:providers.bzl", "NVCInfo")

NVCInfo(<a href="#NVCInfo-analyzer">analyzer</a>, <a href="#NVCInfo-artifacts_dir">artifacts_dir</a>)
</pre>

Information on how to run NVC for VHDL analysis, elaboration and sim

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="NVCInfo-analyzer"></a>analyzer |  -    |
| <a id="NVCInfo-artifacts_dir"></a>artifacts_dir |  -    |


<a id="VHDLLibraryProvider"></a>

## VHDLLibraryProvider

<pre>
load("@rules_nvc//internal:providers.bzl", "VHDLLibraryProvider")

VHDLLibraryProvider(<a href="#VHDLLibraryProvider-libraries">libraries</a>, <a href="#VHDLLibraryProvider-entities">entities</a>, <a href="#VHDLLibraryProvider-library_name">library_name</a>, <a href="#VHDLLibraryProvider-library_dir">library_dir</a>, <a href="#VHDLLibraryProvider-includes">includes</a>, <a href="#VHDLLibraryProvider-hdrs">hdrs</a>)
</pre>

Contains the information about the binary files in this library.

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="VHDLLibraryProvider-libraries"></a>libraries |  List[(string, File)]: a mapping from a library name to dir location, contains both this library and deps and does not repeat keys    |
| <a id="VHDLLibraryProvider-entities"></a>entities |  List[string]: The entities emmphasized in this library.    |
| <a id="VHDLLibraryProvider-library_name"></a>library_name |  string: The name of the library such as `ieee`    |
| <a id="VHDLLibraryProvider-library_dir"></a>library_dir |  string: The container directory where library is located. Due to the way nvc works - it won't create a library in a dir that already exists, we have to have a container dir, which contains the library instead. So the actual library directory would be $library_dir/$library_name. Sigh.    |
| <a id="VHDLLibraryProvider-includes"></a>includes |  List[string]: list of directories to include for verilog    |
| <a id="VHDLLibraryProvider-hdrs"></a>hdrs |  depset[string]: list of include files for verilog    |


