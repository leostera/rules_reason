def _ocamlrun(ctx):
    executable = ctx.actions.declare_file(ctx.attr.name)

    bytecode = ctx.file.src
    ocamlrun = ctx.file._ocamlrun
    template = ctx.file._runscript

    ctx.actions.expand_template(
        template=template,
        output=executable,
        substitutions={
            "{ocamlrun}": ocamlrun.path,
            "{bytecode}": bytecode.path,
        },
        is_executable=True,
    )

    runfiles = [ocamlrun, bytecode]

    return [
        DefaultInfo(
            runfiles=ctx.runfiles(files=runfiles),
            executable=executable,
        ),
    ]


ocamlrun = rule(
    attrs={
        "src":
        attr.label(
            allow_single_file=True,
            mandatory=True,
        ),
        "_ocamlrun":
        attr.label(
            default="//reason/private/opam:ocamlrun",
            allow_single_file=True,
        ),
        "_runscript":
        attr.label(
            default="//reason/private/opam:ocamlrun.tpl",
            allow_single_file=True,
        ),
    },
    implementation=_ocamlrun,
    executable=True)


def init_opam(ocaml_version="4.03.0"):
    """
    Macro to initialize opam with the given OCaml version and extract the necessary
    binaries and archives for the toolchain.

    Args:
      ocaml_version (string): a valid ocaml version, installable with opam
    """
    native.genrule(
        name="init_opam",
        srcs=["@opam"],
        outs=["opam_root.tar"],
        cmd="""\
        #!/bin/bash

        # compute this package's root directory
        pkg_root=$$(dirname $(location :opam_root.tar))
        abs_pkg_root=$$(pwd)/$$pkg_root

        opam=$(location @opam//:opam)

        # make sure the path is good
        mkdir -p $$abs_pkg_root;

        # initialize opam
        OPAMROOT=$$abs_pkg_root $$opam init --comp {ocaml_version};

        # package the opam root
        tar --transform "s=$$pkg_root/==g" \
            --create $$pkg_root \
            --dereference \
            > $(location :opam_root.tar);

        """.format(ocaml_version=ocaml_version),
    )

    native.genrule(
        name="extract_binaries",
        srcs=[":opam_root.tar"],
        outs=[
            "ocaml_stdlib.tar",
            "ocamlc.byte",
            "ocamldep.byte",
            "ocamlopt.byte",
            "ocamlrun",
        ],
        cmd="""\
        #!/bin/bash

        tar --extract \
            --file $(location :opam_root.tar) \
            --directory $(@D);

        ocaml_root=$(@D)/{ocaml_version}
        asb_ocaml_root=$$(pwd)/$$ocaml_root

        cp -f $$abs_ocaml_root/bin/ocamlc   $(@D)/ocamlc.byte;
        cp -f $$abs_ocaml_root/bin/ocamldep $(@D)/ocamldep.byte;
        cp -f $$abs_ocaml_root/bin/ocamlopt $(@D)/ocamlopt.byte;
        cp -f $$abs_ocaml_root/bin/ocamlrun $(@D)/ocamlrun;

        # pack ml stdlib preserving paths
        tar --transform "s=$$ocaml_root/==g" \
            --create $$ocaml_root/lib/* \
            --dereference \
            > $(location ocaml_stdlib.tar);

        """.format(ocaml_version=ocaml_version),
    )
