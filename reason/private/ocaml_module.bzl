load(
    ":extensions.bzl",
    "CM_EXTS",
    "MLI_EXT",
    "ML_EXT",
)

load(
  ":providers.bzl",
	"CompiledMlModuleInfo",
)

def _ocaml_module_impl(ctx):
  platform = ctx.attr.toolchain[platform_common.ToolchainInfo]

  stdlib = platform.ocaml_stdlib.files.to_list()
  stdlib_path = stdlib[0].dirname

  interpreter = platform.ocamlrun
  compiler = platform.ocamlc

  libfile = ctx.actions.declare_file(ctx.attr.name+".lib")

  sources = []
  imports = []
  outputs = [libfile]
  runfiles = []

  for s in ctx.attr.srcs:
    for f in s.files.to_list():
      name = f.basename
      if ML_EXT in name or MLI_EXT in name:
        sources.extend([f])
        # .ml -> [ .cmi, .cmt ]
        cmfiles = [
            ctx.actions.declare_file(f.basename.replace(ML_EXT, ".cmt")),
            ctx.actions.declare_file(f.basename.replace(ML_EXT, ".cmi"))
            ]
        outputs.extend(cmfiles)

  runfiles.extend(sources)

  for d in ctx.attr.deps:
    dep = d[CompiledMlModuleInfo]
    runfiles.extend(dep.outs)

  print("sources", sources)
  print("outputs", outputs)
  print("runfiles", runfiles)

  runfiles.extend(stdlib)

  import_paths = []
  for i in depset(imports):
    import_paths.extend([ "-I", i ])

  sorted_sources = ctx.actions.declare_file(ctx.attr.name + "_sorted_sources")
  ctx.actions.run_shell(
      inputs=sources,
      tools=[platform.ocamldep, interpreter],
      outputs=[sorted_sources],
      command="""\
          #!/bin/bash

          {interpreter} {ocamldep} -sort {sources} > {out}

          """.format(
              interpreter = interpreter.path,
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

      "-c",
      "-o",
      libfile.path
      ]

  ctx.actions.run_shell(
    inputs = runfiles,
    outputs = outputs,
    tools = [compiler, interpreter],
    command = """\
        #!/bin/bash

        {interpreter} {compiler} {arguments} $(cat {sources})
        echo remove_me > {lib}

        """.format(
            interpreter = interpreter.path,
            compiler = compiler.path,
            arguments = " ".join(arguments),
            sources = sorted_sources.path,
            lib = libfile.path,
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
    ),
    CompiledMlModuleInfo(
      name=ctx.label.name,
      srcs=sources,
      outs=outputs,
    ),
  ]

ocaml_module = rule(
    attrs = {
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
    implementation = _ocaml_module_impl,
    )
