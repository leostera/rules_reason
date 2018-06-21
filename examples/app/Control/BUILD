package(default_visibility = ["//app:__subpackages__"])

reason_module(
    name = "srcs",
    srcs = glob(["*.re"]),
    )

bs_module(
    name = "Control",
    config = "//:bs_config",
    srcs = [ ":srcs" ],
    )
