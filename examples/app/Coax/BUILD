package(default_visibility = ["//app:__subpackages__"])

reason_module(
    name = "srcs",
    srcs = glob(["*.re"]),
    )

bs_module(
    name = "Coax",
    config = "//:bs_config",
    srcs = [ ":srcs" ],
    deps = [ "//app/Control" ],
    )
