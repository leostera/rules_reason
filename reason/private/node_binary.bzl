load(
  ":extensions.bzl",
  "JS_EXT",
)

def _node_binary_impl(ctx):
  node = ctx.attr.toolchain[platform_common.ToolchainInfo].node

  runfiles = ctx.files.deps

  executable = ctx.actions.declare_file(ctx.attr.name)

  entrypoint_name = ctx.attr.entrypoint
  entrypoint = None

  for f in runfiles:
    if "/"+entrypoint_name in f.path:
      entrypoint = f

  if entrypoint == None:
    fail("""
Could not find entrypoint script {entrypoint_name} among the
deps.

Did you mean one of:

{deps}

""".format(
            entrypoint_name = entrypoint_name,
            deps = "\n".join([ " - %s" % f.basename for f in runfiles ])
            ))

  ctx.actions.expand_template(
    template = ctx.file._runscript_node,
    output = executable,
    substitutions = {
        "{node}": node.path,
        "{entrypoint}": entrypoint.path,
        },
    is_executable = True,
    )

  return [
    DefaultInfo(
        data_runfiles=ctx.runfiles(files=runfiles),
        default_runfiles=ctx.runfiles(files=[node, executable]),
        executable=executable,
        )
  ]

node_binary = rule(
  attrs = {
    "entrypoint": attr.string(
        mandatory = True
        ),
    "deps": attr.label_list(
        allow_files = [JS_EXT],
        mandatory = True,
        ),
    "toolchain": attr.label(
        default = "@com_github_ostera_rules_reason//reason/toolchain:bs-platform",
        providers = [platform_common.ToolchainInfo],
    ),
    "_runscript_node": attr.label(
        default = "@com_github_ostera_rules_reason//reason/private:runscript_node.tpl",
        allow_single_file = True,
    ),
  },
  executable = True,
  implementation = _node_binary_impl
)
"""A node_binary is a Javascript file with a collection of necessary runtime
dependencies.

Args:
  entrypoint: The .js file to execute.

  deps: A depset of files that will be used at runtime.

  toolchain: The bs-platform that will be used to access the `node` binary.

    If no toolchain is provided, the default registered by this project will be
    chosen.
"""
