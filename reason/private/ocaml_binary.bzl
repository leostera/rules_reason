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
  stdlib = platform.stdlib.files.to_list()
  stdlib_path = stdlib[0].dirname

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
      ctx.attr.name,

      # Input flags
      ] + [ s.path for s in sources ]

  ctx.actions.run(
    arguments = arguments,
    env = { "HOME": ctx.workspace_name },
    executable = platform.ocamlc,
    inputs = runfiles,
    outputs = outputs,
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
    MlModuleInfo(
      name=ctx.label.name,
      deps=ctx.attr.deps,
      srcs=sources,
      outs=outputs,
      type="binary"
      )
  ]

_ocaml_binary = rule(
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
    implementation = _ocaml_binary_impl
    )

def ocaml_native_binary(**kwargs):
  _ocaml_binary(**kwargs)
