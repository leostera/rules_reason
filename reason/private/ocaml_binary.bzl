load(
    ":extensions.bzl",
    "CM_EXTS",
    "MLI_EXT",
    "ML_EXT",
)

load(
  ":providers.bzl",
  "ReasonModuleInfo",
	"MlModuleInfo",
)

def _ocaml_binary_impl(ctx):
  platform = ctx.attr.toolchain[platform_common.ToolchainInfo]

  stdlib = platform.ocaml_stdlib.files.to_list()
  stdlib_path = stdlib[0].dirname

  compiler = None
  if ctx.attr.target == "native":
    compiler = platform.ocamlopt
  if ctx.attr.target == "bytecode":
    compiler = platform.ocamlc

  if compiler == None:
    fail("Could not choose a compiler for target "+ctx.attr.target)

  binfile = ctx.actions.declare_file(ctx.attr.name)

  runfiles = []
  sources = []
  outputs = [binfile]
  imports = []

  for s in ctx.attr.srcs:
    mod = s[ReasonModuleInfo]
    sources.extend(mod.outs)
    for o in mod.outs:
      imports.extend([o.dirname])

  for d in ctx.attr.deps:
    dep = d[ReasonModuleInfo]
    for o in dep.outs:
      imports.extend([o.dirname])
    runfiles.extend(dep.outs)

  runfiles.extend(sources)
  runfiles.extend(stdlib)

  import_paths = []
  for i in depset(imports):
    import_paths.extend([ "-I", i ])

  sorted_sources = ctx.actions.declare_file(ctx.attr.name + "_sorted_sources")
  ctx.actions.run_shell(
      inputs=sources,
      tools=[platform.ocamldep],
      outputs=[sorted_sources],
      command="""\
          #!/bin/bash

          {ocamldep} -sort {sources} > {out}

          """.format(
             ocamldep = platform.ocamldep.path,
             sources = " ".join([ s.path for s in sources]),
             out = sorted_sources.path,
          ),
  )
  runfiles.extend([sorted_sources])

  arguments = [
      # TODO(@ostera): make this configurable by a provider
      # Better error reporting
      "-color", "always",
      "-absname",

      # TODO(@ostera): declare annotations as files as well
      "-bin-annot",

      # Imports, includes current module and pervasives
      "-I", stdlib_path,
      ] + import_paths + [

      # Output name
      "-o",
      binfile.path,
      ]

  ctx.actions.run_shell(
    inputs = runfiles,
    outputs = outputs,
    tools = [compiler],
    command = """\
        #!/bin/bash

        {compiler} {arguments} $(cat {sources})

        """.format(
          compiler = compiler.path,
          arguments = " ".join(arguments),
          sources = sorted_sources.path
        ),
    mnemonic = "OcamlCompile",
    progress_message = "Compiling ({_in}) to ({out})".format(
      _in=", ".join([ s.basename for s in sources]),
      out=", ".join([ s.basename for s in outputs]),
      ),
    )

  return [
    DefaultInfo(
      files=depset(outputs),
      runfiles=ctx.runfiles(files=runfiles),
      executable=binfile,
    ),
    MlModuleInfo(
      name=ctx.label.name,
      deps=ctx.attr.deps,
      srcs=sources,
      outs=outputs,
      target=ctx.attr.target,
      )
  ]

_ocaml_binary = rule(
    attrs = {
        "target": attr.string(
           mandatory = True,
           values = [ "native", "bytecode" ],
           ),
        "srcs": attr.label_list(
            allow_files = [ML_EXT, MLI_EXT],
            mandatory = True,
            ),
        "deps": attr.label_list(allow_files = False),
        "toolchain": attr.label(
            default = "@com_github_ostera_rules_reason//reason/toolchain:bs-platform",
            providers = [platform_common.ToolchainInfo],
            ),
        },
    executable=True,
    implementation = _ocaml_binary_impl,
    )

def ocaml_native_binary(**kwargs):
  _ocaml_binary(target="native", **kwargs)

def ocaml_bytecode_binary(**kwargs):
  _ocaml_binary(target="bytecode", **kwargs)
