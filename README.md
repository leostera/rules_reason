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

