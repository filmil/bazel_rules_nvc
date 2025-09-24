workspace(name = "bazel_rules_nvc")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

#http_archive(
    #name = "bazel_skylib",
    #sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
    #urls = [
        #"https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
        #"https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
    #],
#)

#load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

#bazel_skylib_workspace()

## Using from git directly because latest release 0.9.0 has a visibility bug.
#git_repository(
    #name = "rules_foreign_cc",
    #commit = "6ecc134b114f6e086537f5f0148d166467042226",
    #remote = "https://github.com/bazelbuild/rules_foreign_cc",
    #shallow_since = "1686730970 +0000",
#)

#load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

#rules_foreign_cc_dependencies()

#http_archive(
    #name = "io_bazel_rules_go",
    #sha256 = "099a9fb96a376ccbbb7d291ed4ecbdfd42f6bc822ab77ae6f1b5cb9e914e94fa",
    #urls = [
        #"https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.35.0/rules_go-v0.35.0.zip",
        #"https://github.com/bazelbuild/rules_go/releases/download/v0.35.0/rules_go-v0.35.0.zip",
    #],
#)

#load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

#go_rules_dependencies()

#go_register_toolchains(version = "1.18.3")

#http_archive(
    #name = "bazel_gazelle",
    #sha256 = "efbbba6ac1a4fd342d5122cbdfdb82aeb2cf2862e35022c752eaddffada7c3f3",
    #urls = [
        #"https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.27.0/bazel-gazelle-v0.27.0.tar.gz",
        #"https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.27.0/bazel-gazelle-v0.27.0.tar.gz",
    #],
#)

#load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies", "go_repository")

#go_repository(
    #name = "in_gopkg_check_v1",
    #importpath = "gopkg.in/check.v1",
    #sum = "h1:yhCVgyC4o1eVCa2tZl7eS0r+SDo693bJlVdllGtEeKM=",
    #version = "v0.0.0-20161208181325-20d25e280405",
#)

#go_repository(
    #name = "in_gopkg_yaml_v3",
    #importpath = "gopkg.in/yaml.v3",
    #sum = "h1:fxVm/GzAzEWqLHuvctI91KS9hhNmmWOoWu0XTYJS7CA=",
    #version = "v3.0.1",
#)

#gazelle_dependencies()

#load("@bazel_rules_nvc//build/nvc:repositories.bzl", "nvc_repositories")

#nvc_repositories()

register_toolchains("//build/nvc:nvc_linux_toolchain")

#load("@gotopt2//build:deps.bzl", "gotopt2_dependencies")

#gotopt2_dependencies()

http_archive(
    name = "com_grail_bazel_toolchain",
    sha256 = "ddad1bde0eb9d470ea58500681a7deacdf55c714adf4b89271392c4687acb425",
    strip_prefix = "toolchains_llvm-7e7c7cf1f965f348861085183d79b6a241764390",
    urls = ["https://github.com/grailbio/bazel-toolchain/archive/7e7c7cf1f965f348861085183d79b6a241764390.tar.gz"],
)

load("@com_grail_bazel_toolchain//toolchain:deps.bzl", "bazel_toolchain_dependencies")

bazel_toolchain_dependencies()

load("@com_grail_bazel_toolchain//toolchain:rules.bzl", "llvm_toolchain")

llvm_toolchain(
    name = "llvm_toolchain",
    llvm_version = "10.0.1",
    sha256 = {
        "linux": "02a73cfa031dfe073ba8d6c608baf795aa2ddc78eed1b3e08f3739b803545046",
    },
    strip_prefix = {
        "linux": "clang+llvm-10.0.1-x86_64-pc-linux-gnu",
    },
    urls = {
        "linux": [
            # Use a custom built Clang+LLVM binary distribution that is more portable than
            # the official builds because it's built against an older glibc and does not have
            # dynamic library dependencies to tinfo, gcc_s or stdlibc++.
            #
            # For more details, see the files under toolchains/clang.
            "https://github.com/retone/deps/releases/download/na5/clang+llvm-10.0.1-x86_64-pc-linux-gnu.tar.xz",
        ],
    },
    # Disabled for now waiting on https://github.com/pybind/pybind11_bazel/pull/29
    # sysroot = {
    #     "linux": "@org_chromium_sysroot_linux_x64//:sysroot",
    # },
)

register_toolchains(
    "@llvm_toolchain//:cc-toolchain-linux",
    "@llvm_toolchain//:cc-toolchain-darwin",
)

