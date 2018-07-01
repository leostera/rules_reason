package(default_visibility = ["//retool:__subpackages__"])

reason_module(
    name = "srcs",
    srcs = glob([
        "*.re",
        "*.rei",
    ]),
)

ocaml_native_binary(
    name = "retool",
    srcs = [
        ":srcs",
        "//3rdparty/opam/cmdliner"
        ],
)
