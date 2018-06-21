def _reason_toolchain_impl(ctx):
  return [
      platform_common.ToolchainInfo(
          stdlib = ctx.attr.stdlib,
          bsc = ctx.file.bsc,
          refmt = ctx.file.refmt,
          node = ctx.file.node,
          )
      ]

_reason_toolchain = rule(
    implementation = _reason_toolchain_impl,
    attrs = {
        "stdlib": attr.label(
            mandatory = True,
            allow_files = True,
            executable = False,
            ),
        "bsc": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "target",
            ),
        "refmt": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "target",
            ),
        "node": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "target",
            ),
        },
    )

def reason_toolchain(name, stdlib, bsc, refmt, node, **kwargs):
  """The minimum ReasonML toolchain.

  Args:
    stdlib: a filegroup with the standard library the compiler is using
    bsc: the BuckleScript compiler
    refmt: the standard ReasonML reformatting tool
    node: the NodeJS binary
  """

  impl_name = name + "-platform"

  _reason_toolchain(
      name = impl_name,
      stdlib = stdlib,
      bsc = bsc,
      refmt = refmt,
      node = node,
  )

  native.toolchain(
      name = name,
      toolchain_type = "@com_github_ostera_rules_reason//reason/toolchain:toolchain",
      toolchain = ":{name}".format(name = impl_name),
      **kwargs
  )
