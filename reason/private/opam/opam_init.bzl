def _opam_init(ctx):
    opam_root = ctx.actions.declare_directory()

    ctx.action.run_shell(
        command="""\
          #!/bin/bash
        # compute this package's root directory
        pkg_root=$$(dirname $(location :opam_root.tar))
        abs_pkg_root=$$(pwd)/$$pkg_root

        opam=$(location @opam//:opam)

        # make sure the path is good
        mkdir -p $$abs_pkg_root;

        # initialize opam
        OPAMROOT=$$abs_pkg_root $$opam init --comp {ocaml_version};
        """,)


opam_init = rule(
    attrs={
        "ocaml_version": attr.string(mandatory=True),
        "_opam": attr.label(default="@opam//:opam",),
    },
    implementation=_opam_init)
