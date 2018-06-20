def reason_compile(ctx, refmt, src, out):
  """
  Helper function used to print a source ReasonML file into the ML representation.

  This ML representation can then be used to compile back to Reason, compile to
  Javascript, straight into Ocaml bytecode, optimized native code, or even web
  assembly.

  @ctx    is a context object
  @refmt  is the refmt tool
  @src    is the source ReasonML file
  @out    is the output ML file
  """
  command = "{refmt} --print ml {src} > {out}".format(
      refmt = refmt.path,
      src = src.path,
      out = out.path,
      )

  ctx.actions.run_shell(
    env = { "HOME": ctx.workspace_name },
    command = command,
    inputs = depset([src]),
    outputs = [out],
    tools = [refmt],
    mnemonic = "ReasonCompile",
    progress_message = "Compiling {src} to {out}".format(
      src=src.path,
      out=out.path
      ),
    )

