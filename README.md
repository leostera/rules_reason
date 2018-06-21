# ReasonML / BuckleScript Rules
[![Build Status](https://travis-ci.org/ostera/rules_reason.svg?branch=master)](https://travis-ci.org/ostera/rules_reason)

A collection of ReasonML and BuckleScript rules and tools for [Bazel](https://bazel.build).

> Note: this is alpha software! I'm building it to properly integrate a ReasonML
> application into a bigger project that builds with Bazel.

This projet relies on `nix` being installed in your system to pull in the
ReasonML tooling. BuckleScript will be compiled _from scratch_ so expect about
~5 minutes for your first `bazel build //...` to complete.

## Getting Started

Begin by adding `reason_register_toolchains` to your `WORKSPACE`:

```python
# pick this revision from the repo 
rules_reason_revision = "c2baf995e52727110bc5408eb896ea518bf267f6"

http_archive(
    name = "com_github_ostera_rules_reason",
    # fill this in with the sha256 bazel gives you for proper hermeticity
    sha256 = "",
    strip_prefix = "rules_reason-%s" %s (rules_reason_revision, ),
    urls = [
      "https://github.com/ostera/rules_reason/archive/%s.tar.gz" % (
        rules_reason_revision,
      ),
    ],
)

load("@com_github_ostera_rules_reason//reason:def.bzl", "reason_register_toolchains")

reason_register_toolchains()
```

Use `reason_module` to compile a group of `.re` and `.rei` files into their
corresponding `.ml` and `.mli` counterparts.

Then you can use `bs_module` to turn that target into Javascript!

Unfortunately `bsc` requires a `bsconfig.json` file _at the place where you call
it_. This means that you need to have that file at the root of your project.

```python
# BUILD file at //...
filegroup(
  name = "bsconfig",
  srcs = ["bsconfig.json"],
)

# BUILD file somewhere in your sources!
reason_module(
  name = "srcs.re",
  srcs = glob(["*.re"]),
)

bs_module(
  name = "srcs.js",
  config = ["//:bsconfig"],
  srcs = [":srcs.re"],
  deps = [":deps"],
)
```

You can access the `rtop` by running:

```bash
ostera/rules_reasonml λ bazel run @reason//:rtop
(23:54:08) INFO: Current date is 2018-06-20
(23:54:08) INFO: Analysed target @reason//:rtop (0 packages loaded).
(23:54:08) INFO: Found 1 target...
Target @reason//:rtop up-to-date:
  bazel-genfiles/external/reason/rtop
(23:54:09) INFO: Elapsed time: 0.241s, Critical Path: 0.00s
(23:54:09) INFO: 0 processes.
(23:54:09) INFO: Build completed successfully, 1 total action
(23:54:09) INFO: Build completed successfully, 1 total action
──────────────┬──────────────────────────────────────────────────────────────┬──────────────
              │ Welcome to utop version 1.19.3 (using OCaml version 4.05.0)! │
              └──────────────────────────────────────────────────────────────┘

                   ___  _______   ________  _  __
                  / _ \/ __/ _ | / __/ __ \/ |/ /
                 / , _/ _// __ |_\ \/ /_/ /    /
                /_/|_/___/_/ |_/___/\____/_/|_/

  Execute statements/let bindings. Hit <enter> after the semicolon. Ctrl-d to quit.

        >   let myVar = "Hello Reason!";
        >   let myList: list(string) = ["first", "second"];
        >   #use "./src/myFile.re"; /* loads the file into here */

Type #utop_help for help about using utop.

Reason #
```

## What's next?

1. Better `rtop` support
1. DevFlow: Generating Merlin and pointing IDEs to the right places
1. DevFlow: Dependencies
1. Rules: `*_test` 
1. DevFlow: Auto-rebuild
1. Rules: `*_binary` with Native Ocaml / Ocaml Bytecode compilation
1. 10k
1. < your suggestion here! >

## Rules


### `reason_module`

This compiles down ReasonML code into a representation that is friendly for
BuckleScript or the default Ocaml compiler.

Which one will it be compatible with is determined by how you write your
ReasonML code.

+----------------------------+-----------------------------+---------------------------------------+
| **Name**                   | **Type**                    | **Default value**                     |
+----------------------------+-----------------------------+---------------------------------------+
| :param:`name`              | :type:`string`              | |mandatory|                           |
+----------------------------+-----------------------------+---------------------------------------+
| A unique name for this rule.                                                                     |
|                                                                                                  |
+----------------------------+-----------------------------+---------------------------------------+
| :param:`srcs`              | :type:`string_list`         | |mandatory|                           |
+----------------------------+-----------------------------+---------------------------------------+
| The sources of this library.                                                                     |
|                                                                                                  |
| The name of the sources will be preserved, and the outputs will replace the `.re` or `.rei`      |
| extension with `.ml` or `.mli` correspondingly.                                                  |
|                                                                                                  |
| Other `bs_module` rules can depend on this library to compile it down to Javascript code.        |
|                                                                                                  |
+----------------------------+-----------------------------+---------------------------------------+
| :param:`toolchain`         | :type:`label`               | :value: "//reason/toolchain:bs-platform" |
+----------------------------+-----------------------------+---------------------------------------+
| The toolchain to use when building this rule.                                                    |
|                                                                                                  |
| It should include both `refmt`, `bsc` and a filegroup containing the BuckleScript stdlib.        |
|                                                                                                  |
+----------------------------+-----------------------------+---------------------------------------+

Example:

```bzl
# //my_app/BUILD
load(
    "@com_github_ostera_rules_reason//reason:def.bzl",
    "reason_module",
)

reason_module(
    name = "my_app",
    srcs = glob(["*.re", "*.rei"])
    visibility = ["//my_app:__subpackages__"],
  )
```

### `bs_module`

Compile Ocaml code into Javascript.

+----------------------------+-----------------------------+---------------------------------------+
| **Name**                   | **Type**                    | **Default value**                     |
+----------------------------+-----------------------------+---------------------------------------+
| :param:`name`              | :type:`string`              | |mandatory|                           |
+----------------------------+-----------------------------+---------------------------------------+
| A unique name for this rule.                                                                     |
|                                                                                                  |
+----------------------------+-----------------------------+---------------------------------------+
| :param:`config`            | :type:`label`               | |mandatory|                           |
+----------------------------+-----------------------------+---------------------------------------+
| The `bsconfig.json` file.                                                                        |
|                                                                                                  |
| The file must be located at the root of your WORKSPACE. Currently looking to work around this.   |
|                                                                                                  |
+----------------------------+-----------------------------+---------------------------------------+
| :param:`srcs`              | :type:`string_list`         | |mandatory|                           |
+----------------------------+-----------------------------+---------------------------------------+
| The ML sources of this library.                                                                  |
|                                                                                                  |
| The name of the sources will be preserved, and the outputs will replace the `.ml` by their       |
| compilation counterparts (`.cmi`, `.cmj`, `.cmt`, etc) and the `.js` output.                     |
|                                                                                                  |
| Other `bs_module` rules can depend on this library to compile it down to Javascript code.        |
|                                                                                                  |
+----------------------------+-----------------------------+---------------------------------------+
| :param:`deps`              | :type:`label_list`          | :value: []                            |
+----------------------------+-----------------------------+---------------------------------------+
| Dependencies of this library, must include `BsModuleInfo` providers.                             |
|                                                                                                  |
+----------------------------+-----------------------------+---------------------------------------+
| :param:`toolchain`         | :type:`label`               | :value: "//reason/toolchain:bs-platform" |
+----------------------------+-----------------------------+---------------------------------------+
| The toolchain to use when building this rule.                                                    |
|                                                                                                  |
| It should include both `refmt`, `bsc` and a filegroup containing the BuckleScript stdlib.        |
|                                                                                                  |
+----------------------------+-----------------------------+---------------------------------------+

Example:

```bzl
load(
    "@com_github_ostera_rules_reason//reason:def.bzl",
    "reason_module",
    "bs_module"
)

reason_module(
    name = "my_app",
    srcs = glob(["*.re", "*.rei"]),
    )

bs_module(
    visibility = ["//examples/app:__subpackages__"],
    name = "my_app.js",
    config = "//:bs_config",
    srcs = [ ":my_app" ],
    deps = [ "//examples/some/dependency" ],
    )
```

## Toolchain

There is a ToolchainInfo that describes the fields required throughout the build
rules to successfully compile from ReasonML down to Javascript.

Feel free to register your own toolchain using ``, or use the default toolchain
that will be managed completely within Bazel.

+--------------------------------+--------------------------------------------+
| **Name**                       | **Type**                                   |
+--------------------------------+--------------------------------------------+
| :param:`bsc`                   | :type:`File`                               |
+--------------------------------+--------------------------------------------+
| The BuckleScript compiler file.                                             |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`refmt`                 | :type:`File`                               |
+--------------------------------+--------------------------------------------+
| The ReasonML Formatter file.                                                |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`stdlib`                | :type:`Filegroup`                          |
+--------------------------------+--------------------------------------------+
| A Filegroup with all the source and compiled files for the BuckleScript     |
| standard library that will be used for compiling Ocaml into Javascript      |
|                                                                             |
+--------------------------------+--------------------------------------------+

## Providers

There are 2 providers included, that will carry information for the different
stages of the build process.

### `ReasonModuleInfo`

This provider is the output of the `reason_module` rule, and it represents a 
compilation unit from ReasonML to Ocaml.

+--------------------------------+--------------------------------------------+
| **Name**                       | **Type**                                   |
+--------------------------------+--------------------------------------------+
| :param:`name`                  | :type:`string`                             |
+--------------------------------+--------------------------------------------+
| The name of your the colletion of files                                     |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`srcs`                  | :type:`depset(File)`                       |
+--------------------------------+--------------------------------------------+
| A `depset` of all the ReasonML files that will be compiled to ML            |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`outs`                  | :type:`depset(File)`                       |
+--------------------------------+--------------------------------------------+
| A `depset` of all the target ML files that will be generated                |
|                                                                             |
+--------------------------------+--------------------------------------------+

### `BsModuleInfo`

This provider is the output of the `bs_module` rule, and it represents a 
compilation unit from Ocaml to Javascript.

+--------------------------------+--------------------------------------------+
| **Name**                       | **Type**                                   |
+--------------------------------+--------------------------------------------+
| :param:`name`                  | :type:`string`                             |
+--------------------------------+--------------------------------------------+
| The name of your the colletion of files                                     |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`srcs`                  | :type:`depset(File)`                       |
+--------------------------------+--------------------------------------------+
| A `depset` of all the Ocaml files that will be compiled to Javascript       |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`outs`                  | :type:`depset(File)`                       |
+--------------------------------+--------------------------------------------+
| A `depset` of all the target ML and Js files that will be generated         |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`deps`                  | :type:`depset(File)`                       |
+--------------------------------+--------------------------------------------+
| A `depset` of all the BuckleScript modules files that the `srcs` depend on  |
|                                                                             |
+--------------------------------+--------------------------------------------+
