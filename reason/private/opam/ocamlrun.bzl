def _ocamlrun(ctx):
    executable = ctx.actions.declare_file(ctx.attr.name)

    bytecode = ctx.file.src
    ocamlrun = ctx.file._ocamlrun
    template = ctx.file._runscript

    ctx.actions.expand_template(
        template=template,
        output=executable,
        substitutions={
            "{ocamlrun}": ocamlrun.short_path,
            "{bytecode}": bytecode.short_path,
        },
        is_executable=True,
    )

    runfiles = [ocamlrun, bytecode, executable]

    return [
        DefaultInfo(
            default_runfiles=ctx.runfiles(files=runfiles),
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
