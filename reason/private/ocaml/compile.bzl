load(
    "//reason/private:extensions.bzl",
    "CMXA_EXT",
    "CMI_EXT",
    "CMO_EXT",
    "CMX_EXT",
    "C_EXT",
    "H_EXT",
    "MLI_EXT",
    "ML_EXT",
    "O_EXT",
)

load(
    "//reason/private:providers.bzl",
    "MlCompiledModule",
)

load(
    ":utils.bzl",
    "TARGET_BYTECODE",
    "TARGET_NATIVE",
    "select_compiler",
)


def ocaml_compile_library(
        ctx,
        arguments,
        c_sources,
        ml_sources,
        outputs,
        runfiles,
        sorted_sources,
        toolchain,
):
    """
    Compile a given set of OCaml .ml and .mli sources to their .cmo, .cmi, and
    .cmx counterparts.
  """

    ctx.actions.run_shell(
        inputs=runfiles,
        outputs=outputs,
        tools=[
            toolchain.ocamlc,
            toolchain.ocamlopt,
        ],
        command="""\
        #!/bin/bash

        # Compile .cmi and .cmo files
        {_ocamlc} {arguments} $(cat {ml_sources})

        # Compile .cmx files
        {_ocamlopt} {arguments} $(cat {ml_sources}) {c_sources}

        mkdir -p {output_dir}

        # C sources will be compiled and put at the top level
        find . -maxdepth 1 \
            -name "*.o" \
            -exec cp {{}} {output_dir}/ \;

        find {source_dir} \
            -name "*.cm*" \
            -exec cp {{}} {output_dir}/ \;

        find {source_dir} \
            -name "*.o" \
            -exec cp {{}} {output_dir}/ \;

        cp -f $(cat {ml_sources}) {output_dir}/;

        """.format(
            _ocamlc=toolchain.ocamlc.path,
            _ocamlopt=toolchain.ocamlopt.path,
            arguments=" ".join(arguments),
            c_sources=" ".join([c.path for c in c_sources]),
            ml_sources=sorted_sources.path,
            output_dir=outputs[0].dirname,
            source_dir=ml_sources[0].dirname,
        ),
        mnemonic="OCamlCompileLib",
        progress_message="Compiling ({_in}) to ({out})".format(
            _in=", ".join([s.basename for s in ml_sources] +
                          [c.basename for c in c_sources]),
            out=", ".join([s.basename for s in outputs]),
        ),
    )


def ocaml_compile_binary(
        ctx,
        arguments,
        base_libs,
        binfile,
        c_deps,
        c_sources,
        deps,
        ml_sources,
        runfiles,
        sorted_sources,
        target,
        toolchain,
):
    """
    Compile a given set of OCaml .ml and .mli sources to a single binary file

    Args:
      ctx: the context argument from the rule invoking this macro

      arguments: a list of string representing the compiler flags

      base_libs: a list of target objects from the OCaml stdlib to link against

      binfile: the binary file target

      c_deps: a list of transitive C dependency targets

      c_sources: depset of C sources for this binary

      deps: a list of transitive ML dependency targets

      ml_sources: a depset of ML sources for this binary

      runfiles: list of all the files that need to be present at runtime

      sorted_sources: a file target with ML sources in topological order

      target: whether to compile to a native or bytecode binary

      toolchain: the OCaml toolchain
    """

    compiler = select_compiler(toolchain, target)

    # Native binaries expect .cmx files while bytecode binaries expect .cmo
    expected_object_ext = CMX_EXT
    if target == TARGET_BYTECODE:
        expected_object_ext = CMO_EXT

    dep_libs = []
    for d in deps:
        name = d.basename
        if ML_EXT in name or MLI_EXT in name:
            dep_libs.extend([d])

    # Extract all .cmxa baselib dependencies to include in linking
    stdlib_libs = []
    for baselib in base_libs:
        if CMXA_EXT in baselib.basename:
            stdlib_libs += [baselib]

    ctx.actions.run_shell(
        inputs=runfiles,
        outputs=[binfile],
        tools=[
            toolchain.ocamlc,
            toolchain.ocamlopt,
            toolchain.ocamldep,
        ],
        command="""\
        #!/bin/bash

        # Run ocamldep on all of the ml and mli dependencies for this binary
        {_ocamldep} \
            -sort \
            $(echo {dep_libs} | tr " " "\n" | grep ".ml*") \
            > .depend.all

        # Extract only the compiled cmx files to use as input for the compiler
        cat .depend.all \
            | tr " " "\n" \
            | grep ".ml$" \
            | sed "s/\.ml.*$/{expected_object_ext}/g" \
            | xargs \
            > .depend.cmx

        {_compiler} {arguments} \
            {c_objs} \
            {base_libs} \
            $(cat .depend.cmx) $(cat {ml_sources}) {c_sources}

        mkdir -p {output_dir}

        find {source_dir} -name "{pattern}" -exec cp {{}} {output_dir}/ \;

        """.format(
            _compiler=compiler.path,
            _ocamldep=toolchain.ocamldep.path,
            arguments=" ".join(arguments),
            base_libs=" ".join([b.path for b in stdlib_libs]),
            c_objs=" ".join([o.path for o in c_deps]),
            c_sources=" ".join([c.path for c in c_sources]),
            expected_object_ext=expected_object_ext,
            dep_libs=" ".join([l.path for l in dep_libs]),
            ml_sources=sorted_sources.path,
            output_dir=binfile.dirname,
            pattern=binfile.basename,
            source_dir=ml_sources[0].dirname,
        ),
        mnemonic="OCamlCompileBin",
        progress_message="Compiling ({_in}) to ({out})".format(
            _in=", ".join([s.basename for s in ml_sources] +
                          [c.basename for c in c_sources]),
            out=binfile.basename),
    )
