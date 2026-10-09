# SPDX-License-Identifier: Apache-2.0
"""An analysis test: a `vhdl_test` carries its toolchain's NVC binary."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _runfiles_test_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)
    paths = [f.short_path for f in target[DefaultInfo].default_runfiles.files.to_list()]
    found = [p for p in paths if p.endswith(ctx.attr.binary_suffix)]
    asserts.true(
        env,
        len(found) > 0,
        "no runfile ends with {}; the runfiles are: {}".format(
            ctx.attr.binary_suffix,
            paths,
        ),
    )
    return analysistest.end(env)

runfiles_test = analysistest.make(
    _runfiles_test_impl,
    attrs = {
        "binary_suffix": attr.string(
            doc = "The end of the toolchain binary's path, as a runfile.",
            mandatory = True,
        ),
    },
    config_settings = {
        "//command_line_option:extra_toolchains": [
            str(Label("//build/tests/custom_toolchain:custom_toolchain")),
        ],
    },
)
