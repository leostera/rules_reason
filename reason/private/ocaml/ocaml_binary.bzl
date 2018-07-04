load(
    "//reason/private:extensions.bzl",
    "CM_EXTS",
    "CMX_EXT",
    "MLI_EXT",
    "ML_EXT",
)

load(
    "//reason/private:providers.bzl",
    "MlBinary",
)

load(
    ":utils.bzl",
    "TARGET_NATIVE",
    "TARGET_BYTECODE",
    _build_import_paths="build_import_paths",
    _declare_outputs="declare_outputs",
    _gather_files="gather_files",
    _ocaml_compile_binary="ocaml_compile_binary",
    _ocamldep="ocamldep",
    _stdlib="stdlib",
)


def _ocaml_binary_impl(ctx):
    name = ctx.attr.name

    toolchain = ctx.attr.toolchain[platform_common.ToolchainInfo]

    # Declare binary file
    binfile = ctx.actions.declare_file(ctx.attr.name)

    # Get standard library files and path
    (stdlib, stdlib_path) = _stdlib(toolchain)

    # Get all sources needed for compilation
    (sources, imports, deps) = _gather_files(ctx)

    # Run ocamldep on the sources to compile in right order
    sorted_sources = _ocamldep(ctx, name, sources, toolchain)

    # Declare outputs
    outputs = [binfile]

    # Build runfiles
    runfiles = []
    runfiles.extend([sorted_sources])
    runfiles.extend(sources)
    runfiles.extend(deps)
    runfiles.extend(stdlib)

    # Compute import paths
    import_paths = _build_import_paths(imports, stdlib_path)

    special_flags = []
    if ctx.attr.target == TARGET_BYTECODE:
        special_flags = ["-custom"]

    arguments = ["-color", "always", "-bin-annot"] + \
        special_flags + import_paths + ["-o", binfile.path]

    _ocaml_compile_binary(
        ctx=ctx,
        arguments=arguments,
        binfile=binfile,
        deps=deps,
        runfiles=runfiles,
        sorted_sources=sorted_sources,
        sources=sources,
        target=ctx.attr.target,
        toolchain=toolchain,
    )

    return [
        DefaultInfo(
            files=depset(outputs),
            runfiles=ctx.runfiles(files=runfiles),
            executable=binfile,
        ),
        MlBinary(
            name=ctx.label.name,
            deps=ctx.attr.deps,
            srcs=sources,
            bin=binfile,
            target=ctx.attr.target,
        )
    ]


_ocaml_binary = rule(
    attrs={
        "target":
        attr.string(
            mandatory=True,
            values=[TARGET_NATIVE, TARGET_BYTECODE],
        ),
        "srcs":
        attr.label_list(
            allow_files=[ML_EXT, MLI_EXT],
            mandatory=True,
        ),
        "deps":
        attr.label_list(allow_files=False),
        "toolchain":
        attr.label(
            default="//reason/toolchain:bs-platform",
            providers=[platform_common.ToolchainInfo],
        ),
    },
    executable=True,
    implementation=_ocaml_binary_impl,
)


def ocaml_native_binary(**kwargs):
    _ocaml_binary(target=TARGET_NATIVE, **kwargs)


def ocaml_bytecode_binary(**kwargs):
    _ocaml_binary(target=TARGET_BYTECODE, **kwargs)
