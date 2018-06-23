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
};
```

And it will invoke `yarn` and `opam` to download and verify the dependencies
accordingly.
