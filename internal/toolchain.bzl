load("//internal:providers.bzl", "NVCInfo")

NVC_TOOLCHAIN_TYPE = "@bazel_rules_nvc//build/nvc:toolchain_type"
NVC_WRAPPER = Label("@bazel_rules_nvc//build/nvc:nvc_wrapper")
VHDL_STANDARD_DEFAULT = "2008"


def _nvc_toolchain_impl(ctx):
  toolchain_info = platform_common.ToolchainInfo(
    nvc_info = NVCInfo(
      analyzer = ctx.attr.analyzer,
      artifacts_dir = ctx.attr.artifacts_dir,
    ),
  )
  return [toolchain_info]


nvc_toolchain = rule(
  implementation = _nvc_toolchain_impl,
  attrs = {
    "analyzer": attr.label(executable = True, cfg = "host"),
    "artifacts_dir": attr.label(),
    "deps": attr.label_list(
        default = [],
    ),
  }
)
