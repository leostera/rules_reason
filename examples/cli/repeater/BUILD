package(default_visibility = ["//native-cli:__subpackages__"])

reason_module(
  name = "srcs",
  srcs = glob(["*.re", "*.rei"]),
)

ocaml_native_binary(
  name = "bin",
  srcs = [":srcs"],
  deps = [
    "//3rdparty/opam/cmdliner",   
  ],
)
