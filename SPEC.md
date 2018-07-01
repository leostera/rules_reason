# Compilation Workflow

### Compilation from ReasonML to Javascript

* ReasonML file is translated to OCaml using `refmt`
* OCaml files are compiled to Javascript using `bsc`. The `-bs-files` flag
  takes care of dependency ordering.
* Generated `.js` files are available to other rules as inputs for further
  processing (such as bundling or minification).

### Compilation from ReasonML to OCaml Packages

* ReasonML file is translated to OCaml using `refmt`
* OCaml files are compiled using `ocamlc`
* All `.cmo`, `.cmt`, and `.cmi`, as well as `.ml` and `.mli` files are then
  available for linking.

### Compilation from ReasonML to Binaries (Native and Bytecode)

* ReasonML file is translated to OCaml using `refmt`
* OCaml files are directly compiled using `ocamlc` or `ocamlopt`

----

# Dependency Handling Worfklow

All dependencies will be handled as:

* A set of external repositories, declared through repository rules specified
	by the `declare_dependencies` macro in a generated Skylark file
* A generated tree of BUILD files that will compile and make the dependencies
	accessible to the current workspace rules

### The `declare_dependencies` Macro

This macro will evaluate the repository rules needed to download and verify the
sources of the dependencies will be created, so that declaring all of these
packages has a clear interface.

The macro will live in a `deps.bzl` file within the package manager
depdendencies folder:

```sh
3rdparty/${package_manager}/deps.bzl
```

And it will be defined as:

```skylark
load("//reason:def.bzl", "${package_repository_rule}")

def deps():
  return []

def declare_dependencies(rule=${package_repository_rule}):
  for dep in deps():
    rule(dep)
```

Where `deps` will return a list of packages in a map accepted by the rule.

To declare packages at the `WORKSPACE` level, we would use it like:

```bzl
load("//3rdparty/${package_manager}:deps.bzl", "declare_dependencies")

declare_dependencies()
```

### The Generated BUILD Tree

For each package manager, a subdirectory in `3rdparty/` will be created that
will have subdirectories for each one of the declared dependencies.

The directory structure will be defined by the following rules:

```sh
3rdparty/${package_manager}/BUILD
# for each declared dependency package
3rdparty/${package_manager}/${package_name}/BUILD
```

Each one of the packages `BUILD` file will include the appropriate rules for
exposing a target of the same name that will output the desired artifact. Using
the same name for the Bazel target and the Bazel package allows us to omit it
when specifying dependencies and building it directly.

```sh
bazel build //3rdparty/${package_manager}/${package_name}
```

```bzl
ocaml_native_binary(
	# ...
	deps = [
		"//3rdparty/opam/cmdliner",
	],
)

bs_module(
	# ...
	deps = [
		"//3rdparty/node_modules/reason-future",
	]
)
```

### Generating the Dependency Tree with `retool`

Upon calling the `retool` binary, available through

```sh
bazel run @com_github_ostera_rules_reason//:retool -- sync
```

The tool will inspect the dependency files `3rdparty/package.json` and
`3rdparty/package.opam`, and generate a directory structure based on the
dependencies as we saw defined above:

```sh
sample_project λ tree -C -L 9 3rdparty
3rdparty
├── BUILD
├── load.bzl
├── node_modules
│   ├── BUILD
│   ├── deps.bzl
│   └── reason-future
│       └── BUILD
├── opam
│   ├── BUILD
│   ├── cmdliner
│   │   └── BUILD
│   ├── deps.bzl
│   ├── httpaf
│   │   └── BUILD
│   └── result
│       └── BUILD
├── package.json
└── package.opam
```
