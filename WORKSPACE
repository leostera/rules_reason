workspace(name = "com_github_ostera_rules_reason")

###
### Nix Repositories
###

load(
    "@com_github_ostera_rules_reason//reason/repositories:bazel.bzl",
    "bazel_repositories",
)

bazel_repositories()

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

local_repository(
    name = "examples",
    path = "examples",
)
