package(default_visibility = ["//retool:__subpackages__"])

filegroup(
  name = "bs_config",
  srcs = ["bsconfig.json"])

reason_module(
    name = "srcs",
    srcs = glob(["*.re","*.rei"]))

bs_module(
    name="retool",
    config=":bs_config",
    srcs=[":srcs"])
