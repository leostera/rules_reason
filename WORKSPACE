workspace(name = "com_github_ostera_rules_reason")

local_repository(
  name = "docs",
  path = "docs",
)

local_repository(
  name = "examples",
  path = "examples",
)

###
### Nix Packages for deterministic toolchains!
###
load("@com_github_ostera_rules_reason//reason/repositories:nix.bzl", "nix_repositories")
nix_repositories(
  nix_version = "cd2ed701127ebf7f8f21d37feb1d678e4fdf85e5",
  nix_sha256 = "084d0560c96bbfe5c210bd83b8df967ab0b1fcb330f2e2f30da75a9c46da0554",
)

###
### Register Reason Toolchain
###
load("@com_github_ostera_rules_reason//reason:def.bzl", "reason_register_toolchains")
reason_register_toolchains(
    bs_sha256 = "3072a709d831285ab5e16eb906aaa4e56821321adc4c7f7c0eb7aa1df7bad7a6",
    bs_version = "493c4c45b5c248a39962af60cba913f425d57420",
    nixpkgs_revision = "d91a8a6ece07f5a6df82aa5dc02030d9c6724c27",
    )

###
### Enable Skydocs
###
git_repository(
    name = "io_bazel_rules_sass",
    remote = "https://github.com/bazelbuild/rules_sass.git",
    tag = "0.0.3",
)
load("@io_bazel_rules_sass//sass:sass.bzl", "sass_repositories")
sass_repositories()

git_repository(
    name = "io_bazel_skydoc",
    remote = "https://github.com/bazelbuild/skydoc.git",
    tag = "0.1.4",
)
load("@io_bazel_skydoc//skylark:skylark.bzl", "skydoc_repositories")
skydoc_repositories()
