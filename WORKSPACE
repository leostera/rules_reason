workspace(name = "com_github_ostera_rules_reason")

local_repository(
    name = "examples",
    path = "examples",
)

###
### Bazel Tools Repositories
###
http_archive(
    name = "io_bazel",
    sha256 = "",
    strip_prefix = "bazel-0.14.1",  # Should match current Bazel version
    urls = [
        "http://bazel-mirror.storage.googleapis.com/github.com/bazelbuild/bazel/archive/0.14.1.tar.gz",
        "https://github.com/bazelbuild/bazel/archive/0.14.1.tar.gz",
    ],
)

http_archive(
    name = "io_bazel_rules_go",
    sha256 = "4f95bc867830231b3fa0ab5325632f7865cbe8cef842d2b5a269b59a7df95279",
    strip_prefix = "rules_go-f668026feec298887e7114b01edf72b229829ec9",  # branch master
    urls = ["https://github.com/bazelbuild/rules_go/archive/f668026feec298887e7114b01edf72b229829ec9.zip"],
)

http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = "1a0500deaa51c9dd2c1b7f42b2307e8b9ac4e2e27c0a9877ebaed015b97ed644",
    strip_prefix = "buildtools-405641a50b8583dc9fe254b7a22ebc2002722d17",  # branch master
    urls = ["https://github.com/bazelbuild/buildtools/archive/405641a50b8583dc9fe254b7a22ebc2002722d17.zip"],
)

load("@io_bazel_rules_go//go:def.bzl", "go_rules_dependencies", "go_register_toolchains")

go_rules_dependencies()

go_register_toolchains()

###
### Nix Repositories
###

load(
    "@com_github_ostera_rules_reason//reason/repositories:nix.bzl",
    "nix_repositories",
)

nix_repositories(
    nix_sha256 = "084d0560c96bbfe5c210bd83b8df967ab0b1fcb330f2e2f30da75a9c46da0554",
    nix_version = "cd2ed701127ebf7f8f21d37feb1d678e4fdf85e5",
)

###
### Register Reason Toolchain
###

load(
    "@com_github_ostera_rules_reason//reason:def.bzl",
    "reason_register_toolchains",
)

reason_register_toolchains(
    bs_sha256 = "db3f37eb27bc1653c3045e97adaa83e800dff55ce093d78ddfe85e85165e2125",
    bs_version = "939ef1e1e874c80ff9df74b16dab1dbe2e2df289",
    nixpkgs_revision = "d91a8a6ece07f5a6df82aa5dc02030d9c6724c27",
)
