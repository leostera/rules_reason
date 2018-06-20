# Repository rules
load(
    "@com_github_ostera_rules_reason//reason/toolchain:toolchains.bzl",
    "reason_register_toolchains",
)

# Library Targets
load(
    "@com_github_ostera_rules_reason//reason/private:reason_module.bzl",
    "reason_module",
)

load(
    "@com_github_ostera_rules_reason//reason/private:bs_module.bzl",
    "bs_module",
)
