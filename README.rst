.. role:: param(kbd)
.. role:: type(emphasis)
.. role:: value(code)
.. |mandatory| replace:: **mandatory value**


ReasonML / BuckleScript Rules
==============================

.. image:: https://travis-ci.org/ostera/rules_reason.svg?branch=master
  :target: https://travis-ci.org/ostera/rules_reason

A collection of OCaml, ReasonML, and BuckleScript rules and tools for Bazel.

  Note: this is alpha software! I'm building it to properly integrate a ReasonML
  application into a bigger project that builds with Bazel.

This projet relies on two prerequisites:

1. ``nix``, the purely functional package manager, which is used for installing
  the ReasonML tooling (``refmt`` specifically), ``opam``, ``yarn`` and ``node``
  in an hermetic-ish fashion. At least you don't need to handle those yourself :)
#. ``bazel``, naturally.


If you just cloned this repo and you have both those tools installed, feel free
to start with a ``bazel build //...`` to get everything warmed up.

The examples works a separate workspace so you will need to run ``bazel build //...``
there as well if you wish to play around with them.

  WARNING: because this rules handle all of their dependencies hermetically, a
  clean install takes a good ~10 minutes on an early 2015 Macbook Pro.

.. contents:: :depth: 2

Getting Started
---------------

Begin by adding the following to your ``WORKSPACE``:

.. code:: bzl

  workspace(name = "retool")

  ###
  ### Reason Rules!
  ###

  rules_reason_version = "f8b956b147bfcf22c90480e7ebea32e6769c1fe0" # HEAD

  http_archive(
      name = "com_github_ostera_rules_reason",
      sha256 = "",
      strip_prefix = "rules_reason-%s" % (rules_reason_version,),
      urls = ["https://github.com/ostera/rules_reason/archive/%s.zip" % (rules_reason_version,)],
      )

  ###
  ### Nix Repositories
  ###

  load(
      "@com_github_ostera_rules_reason//reason/repositories:nix.bzl",
      "nix_repositories",
  )

  nix_repositories(
      nix_sha256 = "28121f6eb3d6c5b4c1fc9f716953ce8b0a793b841d0e9de095977b3ade06f92d",
      nix_version = "20a78f74f8ac70d1099ff0d214cd00b25820da03",
  )

  ###
  ### Register Reason Toolchain
  ###

  load(
      "@com_github_ostera_rules_reason//reason:def.bzl",
      "reason_register_toolchains",
  )

  reason_register_toolchains(
      bs_sha256 = "db3f37eb27bc1653c3045e97adaa83e800dff55ce093d78ddfe85e85165e2125",
      bs_version = "939ef1e1e874c80ff9df74b16dab1dbe2e2df289",
      nixpkgs_revision = "d91a8a6ece07f5a6df82aa5dc02030d9c6724c27",
      nixpkgs_sha256 = "0c5291bcf7d909cc4b18a24effef03f717d6374de377f91324725c646d494857",
  )

  ################################################################################
  #
  #   Declare dependencies
  #
  ################################################################################

  load(
      "//3rdparty:load.bzl",
      "declare_dependencies"
  )

  declare_dependencies()


Use ``reason_module`` to compile a group of ``.re`` and ``.rei`` files into their
corresponding ``.ml`` and ``.mli`` counterparts.

Further consume these outputs with ``ocaml_module``, ``bs_module``,
``ocaml_bytecode_binary``, or ``ocaml_native_binary``.

Compiling to Javascript
~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can use ``bs_module`` to turn any ML source target into Javascript, this
includes the outputs from a ``reason_module`` rule too.

Unfortunately ``bsc`` requires a ``bsconfig.json`` file at the place where you call
it. This means that you need to have that file at the root of your project.

.. code:: bzl

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

Compiling to Native and Bytecode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can use ``ocaml_native_binary`` and ``ocaml_bytecode_binary`` to compile your
ML sources into native or bytecode binaries, and yes you can use your
``reason_module`` targets as sources!

.. code:: bzl

  # BUILD file somewhere in your sources!
  reason_module(
      name = "srcs",
      srcs = glob(["*.re"]),
      )

  ocaml_native_binary(
      name = "native",
      srcs = [":srcs"],
    )

  ocaml_bytecode_binary(
      name = "bytecode",
      srcs = [":srcs"],
    )


Top-level
~~~~~~~~~~~~

You can access the ``rtop`` by running:

.. code:: bash

  ostera/rules_reasonml/examples λ bazel run @reason//:rtop
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

What's next?
------------

#. DevFlow: Dependencies
#. DevFlow: Generating Merlin and pointing IDEs to the right places
#. Rules: ``*_test``
#. DevFlow: Auto-rebuild
#. Rules: ``node_binary``
#. < your suggestion here! >

Rules
------

``reason_module``
~~~~~~~~~~~~~~~~~~

This compiles down ReasonML code into a representation that is friendly for
BuckleScript or the default Ocaml compiler.

Which one will it be compatible with is determined by how you write your
ReasonML code.

+----------------------------+-----------------------------+------------------------------------------+
| **Name**                   | **Type**                    | **Default value**                        |
+----------------------------+-----------------------------+------------------------------------------+
| :param:`name`              | :type:`string`              | |mandatory|                              |
+----------------------------+-----------------------------+------------------------------------------+
| A unique name for this rule.                                                                        |
|                                                                                                     |
+----------------------------+-----------------------------+------------------------------------------+
| :param:`srcs`              | :type:`string_list`         | |mandatory|                              |
+----------------------------+-----------------------------+------------------------------------------+
| The sources of this library.                                                                        |
|                                                                                                     |
| The name of the sources will be preserved, and the outputs will replace the ``.re`` or ``.rei``     |
| extension with ``.ml`` or ``.mli`` correspondingly.                                                 |
|                                                                                                     |
| Other ``bs_module`` rules can depend on this library to compile it down to Javascript code.         |
|                                                                                                     |
+----------------------------+-----------------------------+------------------------------------------+
| :param:`toolchain`         | :type:`label`               | :value: "//reason/toolchain:bs-platform" |
+----------------------------+-----------------------------+------------------------------------------+
| The toolchain to use when building this rule.                                                       |
|                                                                                                     |
| It should include both ``refmt``, ``bsc`` and a filegroup containing the BuckleScript stdlib.       |
|                                                                                                     |
+----------------------------+-----------------------------+------------------------------------------+

Example:

.. code:: bzl

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

``bs_module``
~~~~~~~~~~~~~~~~~~

Compile Ocaml code into Javascript.

+----------------------------+-----------------------------+-------------------------------------------+
| **Name**                   | **Type**                    | **Default value**                         |
+----------------------------+-----------------------------+-------------------------------------------+
| :param:`name`              | :type:`string`              | |mandatory|                               |
+----------------------------+-----------------------------+-------------------------------------------+
| A unique name for this rule.                                                                         |
|                                                                                                      |
+----------------------------+-----------------------------+-------------------------------------------+
| :param:`config`            | :type:`label`               | |mandatory|                               |
+----------------------------+-----------------------------+-------------------------------------------+
| The ``bsconfig.json`` file.                                                                          |
|                                                                                                      |
| The file must be located at the root of your WORKSPACE. Currently looking to work around this.       |
|                                                                                                      |
+----------------------------+-----------------------------+-------------------------------------------+
| :param:`srcs`              | :type:`string_list`         | |mandatory|                               |
+----------------------------+-----------------------------+-------------------------------------------+
| The ML sources of this library.                                                                      |
|                                                                                                      |
| The name of the sources will be preserved, and the outputs will replace the ``.ml`` by their         |
| compilation counterparts (``.cmi``, ``.cmj``, ``.cmt``, etc) and the ``.js`` output.                 |
|                                                                                                      |
| Other ``bs_module`` rules can depend on this library to compile it down to Javascript code.          |
|                                                                                                      |
+----------------------------+-----------------------------+-------------------------------------------+
| :param:`deps`              | :type:`label_list`          | :value: []                                |
+----------------------------+-----------------------------+-------------------------------------------+
| Dependencies of this library, must include ``BsModuleInfo`` providers.                               |
|                                                                                                      |
+----------------------------+-----------------------------+-------------------------------------------+
| :param:`toolchain`         | :type:`label`               | :value: "//reason/toolchain:bs-platform"  |
+----------------------------+-----------------------------+-------------------------------------------+
| The toolchain to use when building this rule.                                                        |
|                                                                                                      |
| It should include both ``refmt``, ``bsc`` and a filegroup containing the BuckleScript stdlib.        |
|                                                                                                      |
+----------------------------+-----------------------------+-------------------------------------------+

Example:

.. code:: bzl

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

``ocaml_native_binary`` and ``ocaml_bytecode_binary``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Compile ML code into bytecode or native binaries. For bytecode binaries it will
copmile them including the runtime, rather than separately. This is something
that I'd like to change in the future.

+----------------------------+-----------------------------+-------------------------------------------+
| **Name**                   | **Type**                    | **Default value**                         |
+----------------------------+-----------------------------+-------------------------------------------+
| :param:`name`              | :type:`string`              | |mandatory|                               |
+----------------------------+-----------------------------+-------------------------------------------+
| A unique name for this rule, used as the name of the output binary                                   |
|                                                                                                      |
+----------------------------+-----------------------------+-------------------------------------------+
| :param:`srcs`              | :type:`string_list`         | |mandatory|                               |
+----------------------------+-----------------------------+-------------------------------------------+
| The ML sources of this library.                                                                      |
|                                                                                                      |
|                                                                                                      |
+----------------------------+-----------------------------+-------------------------------------------+
| :param:`deps`              | :type:`label_list`          | :value: []                                |
+----------------------------+-----------------------------+-------------------------------------------+
| Dependencies of this library, must include ``ReasonModuleInfo`` providers.                           |
|                                                                                                      |
+----------------------------+-----------------------------+-------------------------------------------+
| :param:`toolchain`         | :type:`label`               | :value: "//reason/toolchain:bs-platform"  |
+----------------------------+-----------------------------+-------------------------------------------+
| The toolchain to use when building this rule.                                                        |
|                                                                                                      |
| It should include both ``ocamlc``, ``ocamlopt``, ``ocamldep``, ``ocamlrun``,  and a filegroup        |
| containing the Ocaml stdlib.                                                                         |
|                                                                                                      |
+----------------------------+-----------------------------+-------------------------------------------+

Example:

.. code:: bzl

  load(
      "@com_github_ostera_rules_reason//reason:def.bzl",
      "reason_module",
      "ocaml_native_binary",
  )

  # BUILD file somewhere in your sources!
  reason_module(
      name = "srcs",
      srcs = glob(["*.re"]),
      )

  # replace native with bytecode in the rule name and you get a bytecode binary
  ocaml_native_binary(
      name = "my_bin_name",
      srcs = [":srcs"],
    )


Toolchain
--------

There is a ToolchainInfo that describes the fields required throughout the build
rules to successfully compile from ReasonML down to Javascript.

Feel free to register your own toolchain or use the default toolchain
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
| :param:`bs_stdlib`             | :type:`Filegroup`                          |
+--------------------------------+--------------------------------------------+
| A Filegroup with all the source and compiled files for the BuckleScript     |
| standard library that will be used for compiling Ocaml into Javascript      |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`ocamlc`                | :type:`File`                               |
+--------------------------------+--------------------------------------------+
| The Ocaml bytecode compiler.                                                |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`ocamlopt`              | :type:`File`                               |
+--------------------------------+--------------------------------------------+
| The Ocaml native compiler.                                                  |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`ocamldep`              | :type:`File`                               |
+--------------------------------+--------------------------------------------+
| The Ocaml dependency tool.                                                  |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`ocamlrun`              | :type:`File`                               |
+--------------------------------+--------------------------------------------+
| The Ocaml bytecode interpreter.                                             |
|                                                                             |
+--------------------------------+--------------------------------------------+
+--------------------------------+--------------------------------------------+
| :param:`ocaml_stdlib`          | :type:`Filegroup`                          |
+--------------------------------+--------------------------------------------+
| A Filegroup with Ocaml standard library.                                    |
|                                                                             |
+--------------------------------+--------------------------------------------+

Providers
---------

There are 2 providers included, that will carry information for the different
stages of the build process.

``ReasonModuleInfo``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This provider is the output of the ``reason_module`` rule, and it represents a
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
| A ``depset`` of all the ReasonML files that will be compiled to ML          |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`outs`                  | :type:`depset(File)`                       |
+--------------------------------+--------------------------------------------+
| A ``depset`` of all the target ML files that will be generated              |
|                                                                             |
+--------------------------------+--------------------------------------------+

``BsModuleInfo``
~~~~~~~~~~~~~~~~~~~

This provider is the output of the ``bs_module`` rule, and it represents a
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
| A ``depset`` of all the Ocaml files that will be compiled to Javascript     |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`outs`                  | :type:`depset(File)`                       |
+--------------------------------+--------------------------------------------+
| A ``depset`` of all the target ML and Js files that will be generated       |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`deps`                  | :type:`depset(File)`                       |
+--------------------------------+--------------------------------------------+
| A ``depset`` of all the BuckleScript modules files that the ``srcs`` depend |
| on                                                                          |
|                                                                             |
+--------------------------------+--------------------------------------------+

``MlModuleInfo``
~~~~~~~~~~~~~~~~~~~

This provider is the output of the ``bs_module`` rule, and it represents a
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
| A ``depset`` of all the Ocaml files that will to be compiled.               |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`outs`                  | :type:`depset(File)`                       |
+--------------------------------+--------------------------------------------+
| A ``depset`` of all the target binary files.                                |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`deps`                  | :type:`depset(File)`                       |
+--------------------------------+--------------------------------------------+
| A ``depset`` of all the Ocaml modules files that the ``srcs`` depend        |
| on                                                                          |
|                                                                             |
+--------------------------------+--------------------------------------------+
| :param:`target`                | :type:`"native" | "bytecode"`              |
+--------------------------------+--------------------------------------------+
| Whether this module is being compiled natively or as bytecode.              |
|                                                                             |
+--------------------------------+--------------------------------------------+

