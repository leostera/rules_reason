load(
    "@com_github_ostera_rules_reason//reason:def.bzl",
    "opam_package",
    )

def declare_opam(dep):
  opam_package(
    archive = dep["archive"],
    name = "opam.%s" % dep["name"],
    pkg_name = dep["pkg_name"],
    pkg_version = dep["pkg_version"],
    sha256 = dep["sha256"],
  )

def deps():
  return [
    {
        "name": "cmdliner",
        "archive": "http://erratique.ch/software/cmdliner/releases/cmdliner-1.0.2.tbz",
        "deps": [ "result" ],
        "pkg_name": "cmdliner",
        "pkg_version": "1.0.2",
        "sha256": "414ea2418fca339590abb3c18b95e7715c1086a1f7a32713a492ba1825bc58a2",
    },
  ]

def declare_dependencies(rule=declare_opam):
  for d in deps():
    rule(d)
