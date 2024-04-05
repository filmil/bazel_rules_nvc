load("@bazel_gazelle//:deps.bzl", "go_repository")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")


def nvc_repositories():
    excludes = native.existing_rules().keys()

    # All of the deps below assume that the go toolchain has been downloaded
    # and installed in the WORKSPACE file.
    if "bazel_bats" not in excludes:
        git_repository(
            name = "bazel_bats",
            remote = "https://github.com/filmil/bazel-bats",
            commit = "535f03ff9effd12694ff80d252375813e7ba9ae1",
            shallow_since = "1667200603 -0700",
        )

    if "com_github_golang_glog" not in excludes:
        go_repository(
            name = "com_github_golang_glog",
            commit = "23def4e6c14b",
            importpath = "github.com/golang/glog",
        )

    if "com_github_google_go_cmp" not in excludes:
        go_repository(
            name = "com_github_google_go_cmp",
            importpath = "github.com/google/go-cmp",
            tag = "v0.2.0",
        )

    if "in_gopkg_check_v1" not in excludes:
        go_repository(
            name = "in_gopkg_check_v1",
            commit = "20d25e280405",
            importpath = "gopkg.in/check.v1",
        )

    if "in_gopkg_yaml_v2" not in excludes:
        go_repository(
            name = "in_gopkg_yaml_v2",
            importpath = "gopkg.in/yaml.v2",
            tag = "v2.2.8",
        )

    if "bazel_bats" not in excludes:
        git_repository(
            name = "bazel_bats",
            remote = "https://github.com/filmil/bazel-bats",
            commit = "78da0822ea339bd0292b5cc0b5de6930d91b3254",
            shallow_since = "1569564445 -0700",
        )

    if "gotopt2" not in excludes:
        git_repository(
            name = "gotopt2",
            remote = "https://github.com/filmil/gotopt2",
            commit = "97d6b1b0663a976eba231cac93aefbfdca52f9d6",
            shallow_since = "1672211456 -0800",
        )

    maybe(
        repo_rule = http_archive,
        name = "nvc",
        build_file = "@//third_party/nvc:nvc.BUILD.bazel",
        patch_args = ["-p1"],
        patches = [
            #"//third_party/nvc:avx.patch",
        ],
        sha256 = "192fe81768d76d90ea005dcde1ad997ec5220a5b84103c763f39758f12cbb4a3",
        strip_prefix = "nvc-1.11.0",
        urls = [
            "https://github.com/nickg/nvc/releases/download/r1.11.0/nvc-1.11.0.tar.gz",
        ],
    )

