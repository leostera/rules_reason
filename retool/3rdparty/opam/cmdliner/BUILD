load(
    "@com_github_ostera_rules_reason//reason:def.bzl",
    "ocaml_module",
    )

package(default_visibility = ["//visibility:public"])

ocaml_module(
  name = "cmdliner",
  srcs = [
    "@opam.cmdliner//:srcs",
  ],
  deps = [
    "//3rdparty/opam/result",
  ]
)


