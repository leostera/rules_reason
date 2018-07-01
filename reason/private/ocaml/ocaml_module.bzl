load(
    "//reason/private:extensions.bzl",
    "CM_EXTS",
    "CMA_EXT",
    "CMXA_EXT",
    "MLI_EXT",
    "ML_EXT",
)

load(
  "//reason/private:providers.bzl",
  "MlCompiledModule"
)

load(
    ":utils.bzl",
    "TARGET_BYTECODE",
    _build_import_paths = "build_import_paths",
    _declare_outputs = "declare_outputs",
    _gather_files = "gather_files",
    _ocaml_compile_library = "ocaml_compile_library",
    _ocamldep = "ocamldep",
    _stdlib = "stdlib",
    )

def _ocaml_module_impl(ctx):
  name = ctx.attr.name

  toolchain = ctx.attr.toolchain[platform_common.ToolchainInfo]

  # Get standard library files and path
  (stdlib, stdlib_path) = _stdlib(toolchain)

  # Get all sources needed for compilation
  (sources, imports, deps) = _gather_files(ctx)

  # Run ocamldep on the sources to compile in right order
  sorted_sources = _ocamldep(ctx, name, sources, toolchain)

  # Declare outputs
  outputs = _declare_outputs(ctx, sources)

  # Build runfiles
  runfiles = []
  runfiles.extend([sorted_sources])
  runfiles.extend(sources)
  runfiles.extend(deps)
  runfiles.extend(stdlib)

  # Compute import paths
  import_paths = _build_import_paths(imports, stdlib_path)

  arguments = [ "-color", "always" ] + import_paths + [ "-c" ]

  _ocaml_compile_library(
    ctx = ctx,
    arguments = arguments,
    outputs = outputs,
    runfiles = runfiles,
    sorted_sources = sorted_sources,
    sources = sources,
    target = TARGET_BYTECODE,
    toolchain = toolchain,
  )

  return [
      DefaultInfo(
          files = depset(outputs),
          runfiles = ctx.runfiles(files = runfiles),
          ),
      MlCompiledModule(
        name = ctx.attr.name,
        srcs = sources,
        deps = deps,
        outs = outputs
      )
    ]


ocaml_module = rule(
  attrs = {
      "srcs": attr.label_list(
          allow_files = [ML_EXT, MLI_EXT],
          mandatory = True,
          ),
      "deps": attr.label_list(
          allow_files = False,
          default = [],
          ),
      "toolchain": attr.label(
          # TODO(@ostera): rename this target to managed-platform
          default = "//reason/toolchain:bs-platform",
          providers = [platform_common.ToolchainInfo],
          ),
      },
  implementation = _ocaml_module_impl,
  )
