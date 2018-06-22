package(default_visibility = ["//app:__subpackages__"])

reason_module(
    name = "srcs",
    srcs = glob(["*.re"]),
)

bs_module(
    name = "Control",
    srcs = [":srcs"],
    config = "//:bs_config",
)
