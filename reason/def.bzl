# Repository rules
load(
    "@com_github_ostera_rules_reason//reason/toolchain:toolchains.bzl",
    "reason_register_toolchains",
    )

# Dependency rules
load(
    "@com_github_ostera_rules_reason//reason/private/opam:opam_package.bzl",
    "opam_package"
    )

# Binary/Library target rules
load(
    "@com_github_ostera_rules_reason//reason/private:reason_module.bzl",
    "reason_module",
    )

load(
    "@com_github_ostera_rules_reason//reason/private:bs_module.bzl",
    "bs_module",
    )

load(
    "@com_github_ostera_rules_reason//reason/private:ocaml_binary.bzl",
    "ocaml_native_binary",
    "ocaml_bytecode_binary",
    )
