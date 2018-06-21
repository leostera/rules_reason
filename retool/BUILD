package(default_visibility = ["//retool:__subpackages__"])

reason_module(
    name = "srcs",
    srcs = glob(["*.re","*.rei"]))

bs_module(
    name="js",
    config="//:bsconfig",
    srcs=[":srcs"])

node_binary(
   name="retool",
   entrypoint="Retool.bs.js",
   deps=[":js"]
   )
