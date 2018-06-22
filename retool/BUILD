package(default_visibility = ["//retool:__subpackages__"])

filegroup(
    name = "bs_config",
    srcs = ["bsconfig.json"])

reason_module(
    name = "srcs",
    srcs = glob(["*.re","*.rei"]))

ocaml_native_binary(
    name = "retool",
    srcs = [":srcs"])
