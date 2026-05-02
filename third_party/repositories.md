<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="repositories"></a>

## repositories

<pre>
load("@rules_nvc//third_party:repositories.bzl", "repositories")

repositories()
</pre>

Declares the external repositories required by the `rules_nvc` module.

This function sets up the `http_archive` for third-party tools like `m4` and `flex`.



<a id="extension"></a>

## extension

<pre>
extension = use_extension("@rules_nvc//third_party:repositories.bzl", "extension")
</pre>



