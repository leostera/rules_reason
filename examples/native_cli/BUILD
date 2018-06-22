package(default_visibility = ["//native_cli:__subpackages__"])

reason_module(
    name = "srcs",
    srcs = glob(["*.re"]),
    )

ocaml_native_binary(
    name = "native_cli",
    srcs = [":srcs"]
    )
