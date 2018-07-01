load(
    "@com_github_ostera_rules_reason//reason:def.bzl",
    "opam_package",
    )

def deps():
  return [
    {
        "pkg_name": "cmdliner",
        "pkg_version": "1.0.2",
        "archive": "http://erratique.ch/software/cmdliner/releases/cmdliner-1.0.2.tbz",
        "sha256": "",
        "depends": [
          "result",
        ]
    },
  ]

def declare_dependencies(rule=opam_package):
  for d in deps():
    rule(d)
