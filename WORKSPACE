workspace(name = "com_github_ostera_rules_reason")

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
    bs_sha256 = "8a1c9fa6f6385708b5cc6fe162a6db2b971ee5ebbe2614e3a1062b6f25d8be27",
    bs_version = "2ae5ef1ebb94466f7e0e52d21efa337af4b1dba4",
    nixpkgs_revision = "d91a8a6ece07f5a6df82aa5dc02030d9c6724c27",
    )
