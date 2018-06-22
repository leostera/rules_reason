package(default_visibility = ["//cli:__subpackages__"])

reason_module(
    name = "srcs",
    srcs = glob(["*.re"]),
    )

ocaml_native_binary(
    name = "native",
    srcs = [":srcs"]
    )

ocaml_bytecode_binary(
    name = "bytecode",
    srcs = [":srcs"]
    )
