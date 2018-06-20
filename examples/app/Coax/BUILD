package(default_visibility = ["//examples:__subpackages__"])

load(
    "@com_github_ostera_rules_reason//reason:def.bzl",
    "reason_module",
    "bs_module"
)

reason_module(
    name = "srcs",
    srcs = glob(["*.re"]),
    )

bs_module(
    visibility = ["//examples/app:__subpackages__"],
    name = "Coax",
    config = "//examples/app:bs_config",
    srcs = [ ":srcs" ],
    deps = [ "//examples/app/Control" ],
    )
