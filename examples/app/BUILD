package(default_visibility = ["//app:__subpackages__"])

reason_module(
    name = "tldr",
    srcs = glob(["*.re"]),
    )

bs_module(
    name = "src",
    config = "//:bs_config",
    srcs = [ ":tldr" ],
    deps = [ "//app/Effect", "//app/Coax", "//app/Model" ],
    )
