load(
    "//reason/private/opam:ocamlrun.bzl",
    "ocamlrun",
)

package(default_visibility = ["//:__subpackages__"])

exports_files(["ocamlrun.tpl", "opam_package.tpl"])

genrule(
    name = "init_opam",
    srcs = ["@opam"],
    outs = ["opam_root.tar"],
    cmd = """\
      #!/bin/bash

      # compute this package's root directory
      pkg_root=$$(dirname $(location :opam_root.tar))
      abs_pkg_root=$$(pwd)/$$pkg_root

      opam=$(location @opam//:opam)

      # make sure the path is good
      mkdir -p $$abs_pkg_root;

      # initialize opam
      OPAMROOT=$$abs_pkg_root $$opam init --comp 4.03.0;

      # package the opam root
      tar --transform "s=$$pkg_root/==g" \
          --create $$pkg_root \
          --dereference \
          > $(location :opam_root.tar);

      """,
)

genrule(
    name = "extract_binaries",
    srcs = [":opam_root.tar"],
    outs = [
        "ocaml_stdlib.tar",
        "ocamlc.byte",
        "ocamldep.byte",
        "ocamlopt.byte",
        "ocamlrun",
    ],
    cmd = """\
      #!/bin/bash

      tar --extract \
          --file $(location :opam_root.tar) \
          --directory $(@D);

      ocaml_root=$$(pwd)/$(@D)/4.03.0

      cp -f $$ocaml_root/bin/ocamlc   $(@D)/ocamlc.byte;
      cp -f $$ocaml_root/bin/ocamldep $(@D)/ocamldep.byte;
      cp -f $$ocaml_root/bin/ocamlopt $(@D)/ocamlopt.byte;
      cp -f $$ocaml_root/bin/ocamlrun $(@D)/ocamlrun;

      # pack ml stdlib preserving paths
      tar --transform "s=$(@D)/4.03.0/==g" \
          --create $(@D)/4.03.0/lib/* \
          --dereference \
          > $(location ocaml_stdlib.tar);

      """,
)

ocamlrun(
    name = "ocamlc",
    src = ":ocamlc.byte",
)

ocamlrun(
    name = "ocamlopt",
    src = ":ocamlopt.byte",
)

ocamlrun(
    name = "ocamldep",
    src = ":ocamldep.byte",
)
