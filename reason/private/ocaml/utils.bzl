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
  "CMO_EXT",
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
          ctx.actions.declare_file(
              name.replace(MLI_EXT, CMI_EXT))])

    # declare compiled source filesc:w
    if ML_EXT in name and not MLI_EXT in name:
      outputs.extend([
          ctx.actions.declare_file(
              name.replace(ML_EXT, CMO_EXT)),
          # Not obvious: a .ml file should be compiled to a .cmi as well
          # in case that there isn't a .mli with it, because other .mli
          # files will look for the .cmi file instead of the .cmo file
          # this duplication is harmless
          ctx.actions.declare_file(
              name.replace(ML_EXT, CMI_EXT)),
          ])

  return depset(outputs).to_list()


def gather_files(ctx):
  sources = []
  imports = []
  deps = []

  for d in ctx.attr.deps:
    if MlCompiledModule in d:
      mod = d[MlCompiledModule]
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


def ocamldep(ctx, sources, toolchain):
  sorted_sources = ctx.actions.declare_file(ctx.attr.name + "_sorted_sources")

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


def ocaml_compile(
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
  Compile a given set of OCaml sources.
  """

  compiler = select_compiler(toolchain, target)

  ctx.actions.run_shell(
    inputs = runfiles,
    outputs = outputs,
    tools = [
        compiler,
        toolchain.ocamlrun,
    ],
    command = """\
        #!/bin/bash

        cat {sources}

        {ocamlrun} {compiler} {arguments} $(cat {sources})

        mkdir -p {output_dir}

        find {source_dir} -name "*.cm*" -exec cp {{}} {output_dir}/ \;

        """.format(
            ocamlrun = toolchain.ocamlrun.path,
            compiler = compiler.path,
            arguments = " ".join(arguments),
            sources = sorted_sources.path,
            source_dir = sources[0].dirname,
            output_dir = outputs[0].dirname,
            ),
    mnemonic = "OCamlCompile",
    progress_message = "Compiling ({_in}) to ({out})".format(
      _in=", ".join([ s.basename for s in sources]),
      out=", ".join([ s.basename for s in outputs]),
      ),
    )

