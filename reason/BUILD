load("@io_bazel_skydoc//skylark:skylark.bzl", "skylark_doc", "skylark_library")

skylark_library(
  name = "rules",
  srcs = glob(["**/*.bzl"]),
)

skylark_doc(
    name = "docs",
    deps = [":rules"],
)

