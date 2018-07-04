load(
    "//reason/private:providers.bzl",
    "ReasonModuleInfo",
    "MlCompiledModule",
    "CCompiledModule",
)

load(
    "//reason/private:extensions.bzl",
    "CMI_EXT",
    "CMO_EXT",
    "CMX_EXT",
    "C_EXT",
    "H_EXT",
    "MLI_EXT",
    "ML_EXT",
    "O_EXT",
)

TARGET_BYTECODE = "bytecode"
TARGET_NATIVE = "native"


def find_base_libs(stdlib, lib_names):
    base_libs = []

    for lib in stdlib:
        name = "".join(lib.basename.split('.')[:-1])
        if name in lib_names:
            base_libs.extend([lib])

    return depset(base_libs)


def group_sources_by_language(sources):
    c_srcs = []
    ml_srcs = []

    for s in sources:
        name = s.basename
        if C_EXT in name or H_EXT in name:
            c_srcs.extend([s])
        else:
            ml_srcs.extend([s])

    return (
        ml_srcs,
        c_srcs,
    )


def build_import_paths(imports, stdlib_path):
    """
    Given a list of import files, return the list of strings to import all the
    build modules.
    """
    paths = [i.dirname for i in imports]

    import_paths = ["-I", stdlib_path]
    for p in depset(paths):
        import_paths.extend(["-I", p])

    return import_paths


def stdlib(toolchain):
    """
    Extract standard library file list and file path from toolchain
    """

    stdlib = toolchain.ocaml_stdlib.files.to_list()
    stdlib_path = stdlib[0].dirname
    return (stdlib, stdlib_path)


def select_compiler(toolchain, target):
    """
    Return the appropriate compiler from the toolchain based on the target
    """

    if target == TARGET_NATIVE:
        return toolchain.ocamlopt
    if target == TARGET_BYTECODE:
        return toolchain.ocamlc

    fail("Could not select a compiler for target %s" % target)


def declare_outputs(ctx, sources):
    """
    Given a context and a set of sources, declare all the compiled files.

    For each .ml file, declare a .cmo file
    For each .mli file, declare a .cmi file
    For each .c file, declare a .o file

    """

    ml_outputs = []
    c_outputs = []

    for s in sources:
        name = s.basename

        # declare compiled interface files
        if MLI_EXT in name:
            ml_outputs.extend([
                ctx.actions.declare_file(name),
                ctx.actions.declare_file(name.replace(MLI_EXT, CMI_EXT))
            ])

        # declare compiled source files
        if ML_EXT in name and not MLI_EXT in name:
            ml_outputs.extend([
                # Source
                ctx.actions.declare_file(name),

                # Not obvious: a .ml file should be compiled to a .cmi as well
                # in case that there isn't a .mli with it, because other .mli
                # files will look for the .cmi file instead of the .cmo file
                # this duplication is harmless
                ctx.actions.declare_file(name.replace(ML_EXT, CMI_EXT)),

                # Bytecode outputs
                ctx.actions.declare_file(name.replace(ML_EXT, CMO_EXT)),

                # Binary outputs
                ctx.actions.declare_file(name.replace(ML_EXT, CMX_EXT)),
                ctx.actions.declare_file(name.replace(ML_EXT, O_EXT)),
            ])

        # declare c source artifacts
        if C_EXT in name:
            c_outputs.extend([
                ctx.actions.declare_file(name.replace(C_EXT, O_EXT)),
            ])

    return (
        ml_outputs,
        c_outputs,
    )


def gather_files(ctx):
    sources = []
    imports = []
    deps = []
    dep_c_objs = []
    stdlib_deps = depset([])

    for d in ctx.attr.deps:
        if MlCompiledModule in d:
            mod = d[MlCompiledModule]
            stdlib_deps = depset([], transitive=[stdlib_deps, mod.base_libs])
            deps.extend(mod.deps)
            deps.extend(mod.outs)
            imports.extend(mod.outs)
        if CCompiledModule in d:
            mod = d[CCompiledModule]
            dep_c_objs.extend(mod.outs)

    for s in ctx.attr.srcs:
        if ReasonModuleInfo in s:
            mod = s[ReasonModuleInfo]
            sources.extend(mod.outs)
            imports.extend(mod.outs)
        elif OutputGroupInfo in s:
            files = s.files.to_list()
            sources.extend(files)
            imports.extend(files)
        else:
            sources.extend([s])
            imports.extend([s.dirname])

    return (
        depset(sources).to_list(),
        depset(imports).to_list(),
        depset(deps).to_list(),
        depset(dep_c_objs).to_list(),
        stdlib_deps,
    )
