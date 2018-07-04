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
