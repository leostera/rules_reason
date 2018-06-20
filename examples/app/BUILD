package(default_visibility = ["//examples:__subpackages__"])

load(
    "@com_github_ostera_rules_reason//reason:def.bzl",
    "reason_module",
    "bs_module"
)

filegroup(
    name = "bs_config",
    srcs = ["bsconfig.json"],
    )

reason_module(
    name = "tldr",
    srcs = glob(["*.re"]),
    )

bs_module(
    name = "src",
    config = "//examples/app:bs_config",
    srcs = [ ":tldr" ],
    deps = [ "//examples/app/Effect", "//examples/app/Coax", "//examples/app/Model" ],
    )
