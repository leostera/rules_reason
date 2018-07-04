package(default_visibility = ["//visibility:public"])

filegroup(
  name = "srcs",
  srcs = glob([
    "src/**/*.ml",
    "src/**/*.mli",
    "lib/**/*.ml",
    "lib/**/*.mli",
  ]),
)

filegroup(
  name = "c_srcs",
  srcs = glob([
    "src/**/*.c",
    "src/**/*.h",
    "lib/**/*.c",
    "lib/**/*.h",
  ]),
)

filegroup(
  name = "js_srcs",
  srcs = glob([
    "src/**/*.js",
    "lib/**/*.js",
  ]),
)

dune_library(
  name = "{name}",
  jbuildfile = "jbuild",
  srcs = [":srcs", ":c_srcs", ":js_srcs"],
)
