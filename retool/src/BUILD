package(default_visibility = ["//:__subpackages__"])

reason_module(
    name = "srcs",
    srcs = glob(["*.re", "*.rei"]),
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
        "//3rdparty/opam/angstrom",
        "//3rdparty/opam/bigstringaf",
        "//3rdparty/opam/cmdliner",
    ],
)
