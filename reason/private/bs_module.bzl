load(
    ":extensions.bzl",
    "BS_CONFIG_EXT",
    "BS_EXT",
    "CM_EXTS",
    "MLI_EXT",
    "ML_EXT",
)

load(
  ":providers.bzl",
  "ReasonModuleInfo",
  "BsModuleInfo"
)

def _bs_module_impl(ctx):
  bs_platform = ctx.attr.toolchain[platform_common.ToolchainInfo]
  stdlib = bs_platform.bs_stdlib.files.to_list()
  stdlib_path = stdlib[0].dirname

  runfiles = [ctx.file.config]
  sources = []
  outputs = []
  imports = []

  for s in ctx.attr.srcs:
    mod = s[ReasonModuleInfo]

    sources.extend(mod.outs)
    for o in mod.outs:
      imports.extend([o.dirname])

      # .ml -> .bs.js
      jsfile_name = o.basename.replace(ML_EXT, BS_EXT)
      jsfile = ctx.actions.declare_file(jsfile_name)
      outputs.extend([jsfile])

      # .ml -> [ .cmi, .cmt, .cmj ]
      cmfiles = [
          ctx.actions.declare_file(o.basename.replace(ML_EXT, CM_EXT))
          for CM_EXT in CM_EXTS
          ]
      outputs.extend(cmfiles)

  for d in ctx.attr.deps:
    dep = d[BsModuleInfo]
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
      "-bs-super-errors",
      "-bs-diagnose",
      "-color", "always",
      "-absname",
      "-bs-g", # save debugging information,

      # TODO(@ostera): declare annotations as files as well
      "-bin-annot",

      # TODO(@ostera): make this configurable, we don't need it by default
      "-bs-package-name", jsfile.dirname,

      # TODO(@ostera): this should be configurable from another rule
      # in essence this modules will not determine what the full bundle
      # compiles to, but the other way around
      "-bs-package-output", "{p}".format(p = jsfile.dirname),

      # Imports, includes current module and pervasives
      "-I", stdlib_path,
      ] + import_paths + [

      # Input flags
      "-c",
      "-bs-files"
      ] + [ s.path for s in sources ]

  ctx.actions.run(
    arguments = arguments,
    env = { "HOME": ctx.workspace_name },
    executable = bs_platform.bsc,
    inputs = runfiles,
    outputs = outputs,
    mnemonic = "BuckleScriptCompile",
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
    BsModuleInfo(
      name=ctx.label.name,
      deps=ctx.attr.deps,
      srcs=sources,
      outs=outputs
      )
  ]

bs_module = rule(
    attrs = {
        "config": attr.label(
            allow_files = [BS_CONFIG_EXT],
            single_file = True,
            mandatory = True,
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
    implementation = _bs_module_impl
    )
