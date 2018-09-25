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
      OPAMROOT=$$abs_pkg_root $$opam init --comp 4.02.3+buckle-master;

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
        "ocamlc.opt",
        "ocamldep.opt",
        "ocamlopt.opt",
        "ocamlrun",
    ],
    cmd = """\
      #!/bin/bash

      tar --extract \
          --file $(location :opam_root.tar) \
          --directory $(@D);

      ocaml_root=$$(pwd)/$(@D)/4.02.3+buckle-master

      cp -f $$ocaml_root/bin/ocamlc.opt   $(@D)/ocamlc.opt;
      cp -f $$ocaml_root/bin/ocamldep.opt $(@D)/ocamldep.opt;
      cp -f $$ocaml_root/bin/ocamlopt.opt $(@D)/ocamlopt.opt;
      cp -f $$ocaml_root/bin/ocamlrun $(@D)/ocamlrun;

      # pack ml stdlib preserving paths
      tar --transform "s=$(@D)/4.02.3+buckle-master/==g" \
          --create $(@D)/4.02.3+buckle-master/lib/* \
          --dereference \
          > $(location ocaml_stdlib.tar);

      """,
)
