package(default_visibility = ["//:__subpackages__"])

reason_module(
    name = "srcs",
    srcs = ["Retool.re", "Retool_cli.re"],
)

ocaml_bytecode_binary(
    name = "byte",
    srcs = [
        ":srcs",
    ],
    deps = [
        "//3rdparty/opam/cmdliner",
    ],
)

ocaml_native_binary(
    name = "bin",
    srcs = [
        ":srcs",
    ],
    deps = [
        "//3rdparty/opam/cmdliner",
    ],
)
