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
    "MlCompiledModule",
    "CCompiledModule",
)

load(
    ":ocamldep.bzl",
    _ocamldep="ocamldep",
)

load(
    ":utils.bzl",
    _build_import_paths="build_import_paths",
    _declare_outputs="declare_outputs",
    _find_base_libs="find_base_libs",
    _gather_files="gather_files",
    _group_sources_by_language="group_sources_by_language",
    _stdlib="stdlib",
)

load(
    ":compile.bzl",
    _ocaml_compile_library="ocaml_compile_library",
)


def _ocaml_module_impl(ctx):
    name = ctx.attr.name

    toolchain = ctx.attr.toolchain[platform_common.ToolchainInfo]

    # Get standard library files and path
    (stdlib, stdlib_path) = _stdlib(toolchain)
    base_libs = _find_base_libs(stdlib, ctx.attr.base_libs)

    # Get all sources needed for compilation
    (sources, imports, deps, c_deps, stdlib_deps) = _gather_files(ctx)

    # Split sources for sorting
    (ml_sources, c_sources) = _group_sources_by_language(sources)

    # Run ocamldep on the ML sources to compile in right order
    sorted_sources = _ocamldep(ctx, name, ml_sources, toolchain)

    # Declare outputs
    (ml_outputs, c_outputs) = _declare_outputs(ctx, sources)
    outputs = ml_outputs + c_outputs

    # Build runfiles
    runfiles = []
    runfiles.extend([sorted_sources])
    runfiles.extend(sources)
    runfiles.extend(deps)
    runfiles.extend(stdlib)

    # Compute import paths
    import_paths = _build_import_paths(imports, stdlib_path)

    arguments = ["-color", "always"] + import_paths + ["-c"]

    _ocaml_compile_library(
        ctx=ctx,
        arguments=arguments,
        outputs=outputs,
        runfiles=runfiles,
        sorted_sources=sorted_sources,
        ml_sources=ml_sources,
        c_sources=c_sources,
        toolchain=toolchain,
    )

    return [
        DefaultInfo(
            files=depset(outputs),
            runfiles=ctx.runfiles(files=runfiles),
        ),
        MlCompiledModule(
            name=ctx.attr.name,
            srcs=ml_sources,
            deps=deps,
            base_libs=base_libs,
            outs=ml_outputs,
        ),
        CCompiledModule(
            name=ctx.attr.name,
            srcs=c_sources,
            outs=c_outputs,
        ),
    ]


ocaml_module = rule(
    attrs={
        "srcs":
        attr.label_list(
            allow_files=[ML_EXT, MLI_EXT],
            mandatory=True,
        ),
        "deps":
        attr.label_list(
            allow_files=False,
            default=[],
        ),
        "base_libs":
        attr.string_list(default=[]),
        "toolchain":
        attr.label(
            # TODO(@ostera): rename this target to managed-platform
            default="//reason/toolchain:bs-platform",
            providers=[platform_common.ToolchainInfo],
        ),
    },
    implementation=_ocaml_module_impl,
)
