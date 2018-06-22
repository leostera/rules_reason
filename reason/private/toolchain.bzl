def _reason_toolchain_impl(ctx):
  return [
      platform_common.ToolchainInfo(
          bs_stdlib = ctx.attr.bs_stdlib,
          bsc = ctx.file.bsc,
          ocamlc = ctx.file.ocamlc,
          ocamlopt = ctx.file.ocamlopt,
          ocaml_stdlib = ctx.attr.ocaml_stdlib,
          refmt = ctx.file.refmt,
          )
      ]

_reason_toolchain = rule(
    implementation = _reason_toolchain_impl,
    attrs = {
        "bs_stdlib": attr.label(
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
        "ocamlc": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "target",
            ),
        "ocamlopt": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "target",
            ),
        "ocaml_stdlib": attr.label(
            mandatory = True,
            allow_files = True,
            executable = False,
            ),
        "refmt": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "target",
            ),
        },
    )

def reason_toolchain(
    name,
    bs_stdlib,
    bsc,
    ocaml_stdlib,
    ocamlc,
    ocamlopt,
    refmt,
    **kwargs
    ):
  """The minimum ReasonML toolchain.

  Args:
    bs_stdlib: a filegroup with the standard library compiled for BuckleScript
    bsc: the BuckleScript compiler
    ocamlc: the Ocaml compiler
    ocaml_stdlib: a filegroup with the standard library compiled for Ocaml
    refmt: the standard ReasonML reformatting tool
  """

  impl_name = name + "-platform"

  _reason_toolchain(
      name = impl_name,
      bs_stdlib = bs_stdlib,
      bsc = bsc,
      ocaml_stdlib = ocaml_stdlib,
      ocamlc = ocamlc,
      ocamlopt = ocamlopt,
      refmt = refmt,
  )

  native.toolchain(
      name = name,
      toolchain_type = "@com_github_ostera_rules_reason//reason/toolchain:toolchain",
      toolchain = ":{name}".format(name = impl_name),
      **kwargs
  )
