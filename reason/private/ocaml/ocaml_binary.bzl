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
    ":ocamldep.bzl",
    _ocamldep="ocamldep",
)

load(
    ":utils.bzl",
    "TARGET_NATIVE",
    "TARGET_BYTECODE",
    _build_import_paths="build_import_paths",
    _declare_outputs="declare_outputs",
    _find_base_libs="find_base_libs",
    _gather_files="gather_files",
    _group_sources_by_language="group_sources_by_language",
    _stdlib="stdlib",
)

load(
    ":compile.bzl",
    _ocaml_compile_binary="ocaml_compile_binary",
)


def _ocaml_binary_impl(ctx):
    name = ctx.attr.name

    toolchain = ctx.attr.toolchain[platform_common.ToolchainInfo]

    # Get standard library files and path
    (stdlib, stdlib_path) = _stdlib(toolchain)
    base_libs = _find_base_libs(stdlib, ctx.attr.base_libs)

    # Get all sources needed for compilation
    (sources, imports, deps, c_deps, stdlib_deps) = _gather_files(ctx)

    # Split sources for sorting
    (ml_sources, c_sources) = _group_sources_by_language(sources)

    # Run ocamldep on the sources to compile in right order
    sorted_sources = _ocamldep(ctx, name, ml_sources, toolchain)

    # Declare binary file
    binfile = ctx.actions.declare_file(ctx.attr.name)

    # Build runfiles
    runfiles = []
    runfiles.extend([sorted_sources])
    runfiles.extend(sources)
    runfiles.extend(deps)
    runfiles.extend(c_deps)
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
        base_libs=base_libs + stdlib_deps.to_list(),
        binfile=binfile,
        c_deps=c_deps,
        c_sources=c_sources,
        deps=deps,
        ml_sources=ml_sources,
        runfiles=runfiles,
        sorted_sources=sorted_sources,
        target=ctx.attr.target,
        toolchain=toolchain,
    )

    return [
        DefaultInfo(
            files=depset([binfile]),
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
        "base_libs":
        attr.string_list(default=[]),
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
