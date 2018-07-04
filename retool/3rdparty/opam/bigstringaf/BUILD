load(
    "@com_github_ostera_rules_reason//reason:def.bzl",
    "ocaml_module",
    )

package(default_visibility = ["//visibility:public"])

ocaml_module(
  name = "bigstringaf",
  srcs = [
    "@opam.bigstringaf//:srcs",
  ],
  deps = [
  ],
  base_libs = [
      "bigarray",
  ],
)
