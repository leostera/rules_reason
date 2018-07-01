load(
  "//reason/private:providers.bzl",
  "ReasonModuleInfo",
  "MlCompiledModule",
)

load(
  "//reason/private:extensions.bzl",
  "MLI_EXT",
  "ML_EXT",
  "CMI_EXT",
  "CMX_EXT",
  "CMO_EXT",
  "O_EXT",
)

TARGET_BYTECODE="bytecode"
TARGET_NATIVE="native"

def build_import_paths(imports, stdlib_path):
  """
  Given a list of import files, return the list of strings to import all the
  build modules.
  """
  paths = [ i.dirname for i in imports]

  import_paths = [ "-I", stdlib_path ]
  for p in depset(paths):
    import_paths.extend([ "-I", p ])

  return import_paths


def stdlib(toolchain):
  """
  Extract standard library file list and file path from toolchain
  """

  stdlib = toolchain.ocaml_stdlib.files.to_list()
  stdlib_path = stdlib[0].dirname
  return (stdlib, stdlib_path)


def select_compiler(toolchain, target):
  """
  Return the appropriate compiler from the toolchain based on the target
  """

  if target == TARGET_NATIVE:
    return toolchain.ocamlopt
  if target == TARGET_BYTECODE:
    return toolchain.ocamlc

  fail("Could not select a compiler for target %s" % target)


def declare_outputs(ctx, sources):
  """
  Given a context and a set of sources, declare all the compiled files.

  For each .ml file, declare a .cmo file
  For each .mli file, declare a .cmi file

  """

  outputs = []

  for s in sources:
    name = s.basename

    # declare compiled interface files
    if MLI_EXT in name:
      outputs.extend([
          ctx.actions.declare_file(name),
          ctx.actions.declare_file(
              name.replace(MLI_EXT, CMI_EXT))])

    # declare compiled source filesc:w
    if ML_EXT in name and not MLI_EXT in name:
      outputs.extend([
          # Source
          ctx.actions.declare_file(name),

          # Not obvious: a .ml file should be compiled to a .cmi as well
          # in case that there isn't a .mli with it, because other .mli
          # files will look for the .cmi file instead of the .cmo file
          # this duplication is harmless
          ctx.actions.declare_file(
              name.replace(ML_EXT, CMI_EXT)),

          # Bytecode outputs
          ctx.actions.declare_file(
              name.replace(ML_EXT, CMO_EXT)),

          # Binary outputs
          ctx.actions.declare_file(
              name.replace(ML_EXT, CMX_EXT)),
          ctx.actions.declare_file(
              name.replace(ML_EXT, O_EXT)),
          ])

  return depset(outputs).to_list()


def gather_files(ctx):
  sources = []
  imports = []
  deps = []

  for d in ctx.attr.deps:
    if MlCompiledModule in d:
      mod = d[MlCompiledModule]
      deps.extend(mod.deps)
      deps.extend(mod.outs)
      imports.extend(mod.outs)

  for s in ctx.attr.srcs:
    if ReasonModuleInfo in s:
      mod = s[ReasonModuleInfo]
      sources.extend(mod.outs)
      imports.extend(mod.outs)
    elif OutputGroupInfo in s:
      files = s.files.to_list()
      sources.extend(files)
      imports.extend(files)
    else:
      sources.extend([s])
      imports.extend([s.dirname])

  return (
      depset(sources).to_list(),
      depset(imports).to_list(),
      depset(deps).to_list(),
      )


def ocamldep(ctx, name, sources, toolchain):
  sorted_sources = ctx.actions.declare_file(name + "_sorted_sources")

  ctx.actions.run_shell(
      inputs=sources,
      tools=[toolchain.ocamldep, toolchain.ocamlrun],
      outputs=[sorted_sources],
      command="""\
          #!/bin/bash

          {ocamlrun} {ocamldep} -sort {sources} > {out}

          """.format(
              ocamlrun = toolchain.ocamlrun.path,
              ocamldep = toolchain.ocamldep.path,
              sources = " ".join([ s.path for s in sources]),
              out = sorted_sources.path,
              ),
    mnemonic = "OCamlDep",
    progress_message = "Sorting ({_in})".format(
        _in=", ".join([ s.basename for s in sources]),
      ),
  )
  return sorted_sources


def ocaml_compile_library(
    ctx,
    arguments,
    outputs,
    runfiles,
    sorted_sources,
    sources,
    target,
    toolchain,
    ):
  """
  Compile a given set of OCaml .ml and .mli sources to their .cmo, .cmi, and
  .cmx counterparts.
  """

  ctx.actions.run_shell(
    inputs = runfiles,
    outputs = outputs,
    tools = [
        toolchain.ocamlc,
        toolchain.ocamlopt,
        toolchain.ocamlrun,
    ],
    command = """\
        #!/bin/bash

        # Compile .cmi and .cmo files
        {ocamlrun} {ocamlc} {arguments} $(cat {sources})

        # Compile .cmx files
        {ocamlrun} {ocamlopt} {arguments} $(cat {sources})

        mkdir -p {output_dir}

        find {source_dir} \
            -name "*.cm*" \
            -exec cp {{}} {output_dir}/ \;

        find {source_dir} \
            -name "*.o" \
            -exec cp {{}} {output_dir}/ \;

        cp -f $(cat {sources}) {output_dir}/;

        """.format(
            arguments = " ".join(arguments),
            ocamlc = toolchain.ocamlc.path,
            ocamlopt = toolchain.ocamlopt.path,
            ocamlrun = toolchain.ocamlrun.path,
            output_dir = outputs[0].dirname,
            source_dir = sources[0].dirname,
            sources = sorted_sources.path,
            ),
    mnemonic = "OCamlCompileLib",
    progress_message = "Compiling ({_in}) to ({out})".format(
      _in=", ".join([ s.basename for s in sources]),
      out=", ".join([ s.basename for s in outputs]),
      ),
    )

def ocaml_compile_binary(
    ctx,
    arguments,
    binfile,
    deps,
    runfiles,
    sorted_sources,
    sources,
    target,
    toolchain,
    ):
  """
  Compile a given set of OCaml .ml and .mli sources to a single binary file
  """

  compiler = select_compiler(toolchain, target)

  libs = []
  for d in deps:
    name = d.basename
    if ML_EXT in name or MLI_EXT in name:
      libs.extend([d])

  ctx.actions.run_shell(
    inputs = runfiles,
    outputs = [binfile],
    tools = [
        toolchain.ocamlc,
        toolchain.ocamlopt,
        toolchain.ocamldep,
        toolchain.ocamlrun,
    ],
    command = """\
        #!/bin/bash

        {ocamlrun} {ocamldep} \
            -sort \
            $(echo {libs} | tr " " "\n" | grep ".ml*") \
            > .depend.all

        cat .depend.all \
            | tr " " "\n" \
            | grep ".ml$" \
            | sed "s/ml$/cmx/g" \
            | xargs \
            > .depend.cmx

        {ocamlrun} {compiler} {arguments} $(cat .depend.cmx) $(cat {sources})

        mkdir -p {output_dir}

        find {source_dir} -name "{pattern}" -exec cp {{}} {output_dir}/ \;

        """.format(
            arguments = " ".join(arguments),
            compiler = compiler.path,
            libs = " ".join([l.path for l in libs]),
            ocamldep = toolchain.ocamldep.path,
            ocamlrun = toolchain.ocamlrun.path,
            output_dir = binfile.dirname,
            pattern = binfile.basename,
            source_dir = sources[0].dirname,
            sources = sorted_sources.path,
            ),
    mnemonic = "OCamlCompileLib",
    progress_message = "Compiling ({_in}) to ({out})".format(
      _in=", ".join([ s.basename for s in sources]),
      out=binfile.basename
      ),
    )

