load(
  ":extensions.bzl",
  "REI_EXT", "MLI_EXT", "RE_EXT", "ML_EXT",
)

load(
  ":providers.bzl",
  "ReasonModuleInfo"
)

load(
  ":reason_compile.bzl",
  _reason_compile = "reason_compile"
)

def _reason_module_impl(ctx):
  outputs = []

  for reason_file in ctx.files.srcs:
    ml_file = ctx.actions.declare_file(
      reason_file.basename
        .replace(REI_EXT, MLI_EXT) # for interfaces
        .replace(RE_EXT, ML_EXT)
    )

    _reason_compile(
        ctx=ctx,
        refmt=ctx.attr.toolchain[platform_common.ToolchainInfo].refmt,
        src=reason_file,
        out=ml_file,
        )

    outputs.extend([ml_file])

  return [
      DefaultInfo(
          files=depset(outputs),
          ),
      ReasonModuleInfo(
          name=ctx.label.name,
          srcs=ctx.attr.srcs,
          outs=outputs,
          )
      ]

reason_module = rule(
  attrs = {
    "srcs": attr.label_list(
        allow_files = [RE_EXT, REI_EXT],
        mandatory = True
        ),
    "toolchain": attr.label(
        default = "@com_github_ostera_rules_reason//reason/toolchain:bs-platform",
        providers = [platform_common.ToolchainInfo],
    ),
  },
  implementation = _reason_module_impl
)
"""A reason_module is a ReasonML file that will be compiled down to a ML file
for further processing. This allows us to reuse BuckleScript or the Ocaml
toolchain afterwards.

You can think of this as a very tiny compilation step where we go from ReasonML
to Ocaml by calling `refmt` on every source file and saving the output code for
further compilation.

Args:
  srcs: The list of .re or .rei files, typically `glob(["*.re", "*.rei"])`
  toolchain: The bs-platform that will be used to call `refmt` on files.

    If no toolchain is provided, the default registered by this project will be
    chosen.
"""
