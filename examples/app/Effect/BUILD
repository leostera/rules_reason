package(default_visibility = ["//app:__subpackages__"])

reason_module(
    name = "srcs",
    srcs = glob(["*.re"]),
)

bs_module(
    name = "Effect",
    srcs = [":srcs"],
    config = "//:bs_config",
    deps = [
        "//app/Coax",
        "//app/Model",
    ],
)
