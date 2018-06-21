workspace( name = "com_github_ostera_rules_reason" )

local_repository(
    name = "examples",
    path = "examples",
    )

###
### Nix Repositories
###

load(
    "@com_github_ostera_rules_reason//reason/repositories:nix.bzl",
    "nix_repositories",
    )

nix_repositories(
    nix_version = "cd2ed701127ebf7f8f21d37feb1d678e4fdf85e5",
    nix_sha256 = "084d0560c96bbfe5c210bd83b8df967ab0b1fcb330f2e2f30da75a9c46da0554",
    )

###
### Register Reason Toolchain
###

load(
    "@com_github_ostera_rules_reason//reason:def.bzl",
    "reason_register_toolchains"
    )

reason_register_toolchains(
    bs_sha256 = "3072a709d831285ab5e16eb906aaa4e56821321adc4c7f7c0eb7aa1df7bad7a6",
    bs_version = "493c4c45b5c248a39962af60cba913f425d57420",
    nixpkgs_revision = "d91a8a6ece07f5a6df82aa5dc02030d9c6724c27",
    )
