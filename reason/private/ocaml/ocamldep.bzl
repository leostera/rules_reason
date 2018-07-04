def ocamldep(ctx, name, sources, toolchain):
    sorted_sources = ctx.actions.declare_file(name + "_sorted_sources")

    ctx.actions.run_shell(
        inputs=sources,
        tools=[toolchain.ocamldep],
        outputs=[sorted_sources],
        command="""\
          #!/bin/bash

          {ocamldep} -sort {sources} > {out}

          """.format(
            ocamldep=toolchain.ocamldep.path,
            sources=" ".join([s.path for s in sources]),
            out=sorted_sources.path,
        ),
        mnemonic="OCamlDep",
        progress_message="Sorting ({_in})".format(
            _in=", ".join([s.basename for s in sources]),),
    )
    return sorted_sources
