workspace(name = "com_github_ostera_rules_reason")

###
### Bazel Tools!
###

load(
    "@com_github_ostera_rules_reason//reason/repositories:bazel.bzl",
    "bazel_repositories",
)

bazel_repositories(
    bazel_version = "0.15.0",
    bazel_sha256 = "",
    rules_go_version = "436452edc29a2f1e0edc22d180fbb57c27e6d0af",
    rules_go_sha256 = "09669ffc724b21ab3ee8fd58c8b52b27dd216552add9098daf16e0f1d3654626",
    buildtools_version = "49a6c199e3fbf5d94534b2771868677d3f9c6de9",
    buildtools_sha256 = "edf39af5fc257521e4af4c40829fffe8fba6d0ebff9f4dd69a6f8f1223ae047b",
    )

load(
    "@com_github_ostera_rules_reason//reason/repositories:tools.bzl",
    "setup_repo_tools",
)

setup_repo_tools()

###
### Nix Repositories
###

load(
    "@com_github_ostera_rules_reason//reason/repositories:nix.bzl",
    "nix_repositories",
)

nix_repositories(
    nix_sha256 = "",
    nix_version = "20a78f74f8ac70d1099ff0d214cd00b25820da03",
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
    nixpkgs_sha256 = "0c5291bcf7d909cc4b18a24effef03f717d6374de377f91324725c646d494857",
)

local_repository(
    name = "examples",
    path = "examples",
)
