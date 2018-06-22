package(default_visibility = ["//app:__subpackages__"])

reason_module(
    name = "tldr",
    srcs = glob(["*.re"]),
)

bs_module(
    name = "src",
    srcs = [":tldr"],
    config = "//:bs_config",
    deps = [
        "//app/Coax",
        "//app/Components",
        "//app/Effect",
        "//app/Model",
    ],
)
