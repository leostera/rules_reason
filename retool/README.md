# retool

## Overview

The problem that this tool solves is dependency handling for ReasonML.

The ideal tool would let you:

* specify Javascript deps in a `package.json` that is managed by `yarn`
* specify BuckleScript configuration in your `bsconfig.json`
* specify Ocaml deps in `.opam` files that are managed by `opam`

The outcome is that all dependencies will be:

* downloaded
* integrity checked 
* get their BUILD files generated

Notice that at no point we mention downloading your dependencies' _dependencies_,
transitive dependencies, which means that the dependency graph must be flattened.

This is a very unpopular decision for starting up projects quickly, so we should
make sure that running `bazel run @retool -- sync` will output the missing
packages in a `package.json` or `.opam` friendly syntax to allow for quickly
adding them in.

## How does it do it?

It parses a dependency file (`package.json`/`*.opam`) and it builds a set of
dependencies that need to be worked with.

```reason
type dependency = {
  name: string; 
  version: string;
  checksum: string;
  archive: string;
};
```

It will proceed to create a tree of folders and BUILD files representing the dependency tree:

```
3rdparty
├── node_modules
│   └── isomorphic-fetch
└── opam
    ├── cmdliner
    └── result
```

And it will create `BUILD` files in each of the leaves.

These `BUILD` files will reference the targets that will ultimately:

* Pull sources from the appropriate repository
* Build and package the sources accordingly

#### JS Deps

Js Module will be pulled directly from the npm registry:
`https://registry.npmjs.com/mindeavor/reason-future/-/reason-future-2.2.1.tgz` 

by an `npm_package` that has access to `yarn`.

If the source code has any Reason files, the BUILD file should include `reason_module` rules.

If the source code has any ML files, it should include both a `bs_module` rule
to compile them all to javascript, and a `ocaml_module` rule to compile them
down to native/bytecode.

If it has both Reason and ML files, the `reason_module` rules should be
included as sources for the `bs_module` and `ocaml_module` ones.

Javascript code should use filegroup rules.

#### Ocaml Deps

Ocaml Modules will be pulled directly from github's opam repo:
`https://raw.githubusercontent.com/ocaml/opam-repository/master/packages/result/result.1.3/url`

by an `opam_package` rule that has access to `opam`.

If the module has a `jbuild` file, it should use the internally managed
`jbuilder` to build the module, and check in the built library files (.cm\*)

If the module has no `jbuild` file, it will list group all ML sources in a
`ocaml_module` rule.

Any dependency listed in `jbuild` or `opam` file will be included in the `deps`
attribute of the `ocaml_module` rule.
