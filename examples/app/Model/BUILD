package(default_visibility = ["//app:__subpackages__"])

reason_module(
    name = "srcs",
    srcs = glob(["*.re"]),
)

bs_module(
    name = "Model",
    srcs = [":srcs"],
    config = "//:bs_config",
)
