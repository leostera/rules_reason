load(
    "@com_github_ostera_rules_reason//reason:def.bzl",
    "opam_package",
)


def declare_opam(dep):
    opam_package(
        archive=dep["archive"],
        name="opam.%s" % dep["name"],
        pkg_name=dep["pkg_name"],
        pkg_version=dep["pkg_version"],
        sha256=dep["sha256"],
        type=dep["type"],
    )


def deps():
    return [
        {
            "name":
            "bigstringaf",
            "archive":
            "https://github.com/inhabitedtype/bigstringaf/archive/0.2.0.tar.gz",
            "deps": [],
            "pkg_name":
            "bigstringaf",
            "pkg_version":
            "0.2.0",
            "sha256":
            "98102997fbb3acc8f70fbfb4fb864a5bcc8964ab605d115307f1e6c49334fac8",
            "type":
            "tar.gz",
        },
        {
            "name":
            "angstrom",
            "archive":
            "https://github.com/inhabitedtype/angstrom/archive/0.10.0.tar.gz",
            "deps": ["result", "bigstringaf"],
            "pkg_name":
            "angstrom",
            "pkg_version":
            "0.10.0",
            "sha256":
            "d73384483e8a2d9c6665acf0a4d6fa09e35075da0692e10183cb5589e1c9cf50",
            "type":
            "tar.gz",
        },
        {
            "name":
            "cmdliner",
            "archive":
            "http://erratique.ch/software/cmdliner/releases/cmdliner-1.0.2.tbz",
            "deps": ["result"],
            "pkg_name":
            "cmdliner",
            "pkg_version":
            "1.0.2",
            "sha256":
            "414ea2418fca339590abb3c18b95e7715c1086a1f7a32713a492ba1825bc58a2",
            "type":
            "tar.bz2",
        },
    ]


def declare_dependencies(rule=declare_opam):
    for d in deps():
        rule(d)
