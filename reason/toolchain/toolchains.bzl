"""Toolchain

Find below macros to register toolchains for ReasonML and BuckleScript.

A default `declare_default_toolchain()` macro is included. It requires `nix` to
be installed in your system.
"""

load(
    "//reason/private:toolchain.bzl",
    _reason_toolchain = "reason_toolchain",
    )

load(
    "//reason/private:utils.bzl",
    "new_download",
    )

load(
    "@io_tweag_rules_nixpkgs//nixpkgs:nixpkgs.bzl",
    "nixpkgs_git_repository",
    "nixpkgs_package",
    )

OCAML_BUILD_FILE="""
filegroup(
    name = "srcs",
    srcs = glob([ "**/*" ]),
    )

genrule(
  visibility = ["//visibility:public"],
  name = "unpack_binaries",
  cmd = \"\"\"\
  #!/bin/bash

  # Copy binaries to the output location
  cp external/ocaml/bin/ocamlc $$(dirname $(location :ocamlc))/;
  cp external/ocaml/bin/ocamlopt $$(dirname $(location :ocamlopt))/;
  cp external/ocaml/bin/ocamldep $$(dirname $(location :ocamldep))/;

  # Pack library files
  tar --transform "s@external/ocaml/@@g" \
      --create external/ocaml/lib \
      --dereference \
      > $(location :stdlib.ml.tar);

  \"\"\",
  srcs = [ ":srcs" ],
  outs = [
        "ocamlc",
        "ocamlopt",
        "ocamldep",
        "stdlib.ml.tar",
      ]
  )
"""

REASON_BUILD_FILE="""
filegroup(
    name = "bin",
    srcs = glob([ "**/bin/*" ]),
    )

genrule(
  visibility = ["//visibility:public"],
  name = "unpack_binaries",
  cmd = \"\"\"\
  #!/bin/bash

  # Copy binaries to the output location
  cp external/reason-cli/bin/* $$(dirname $(location :refmt));

  \"\"\",
  srcs = [ ":bin" ],
  outs = [
        "menhir_error_processor",
        "reactjs_jsx_ppx_v2",
        "refmt",
        "rtop_init.ml",
        "ocamlmerlin-reason",
        "reactjs_jsx_ppx_v3",
        "refmttype",
        "testOprint",
        "ppx_react",
        "rebuild",
        "rtop",
      ]
  )
"""

BS_BUILD_FILE="""
filegroup(
    visibility = ["//visibility:public"],
    name = "bs_srcs",
    srcs = glob([
        "*",
        "scripts/**/*",
        "lib/**/*",
        "jscomp/**/*",
        ]),
    )

filegroup(
    visibility = ["//visibility:public"],
    name = "ocaml_srcs",
    srcs = glob([
        "vendor/ocaml/**/*",
        "vendor/ocaml/**/.*",
        ]),
    )
"""

SINGLE_BIN_BUILD_FILE="""
filegroup(
    name = "bin",
    srcs = glob([ "**/bin/*" ]),
    )

genrule(
  visibility = ["//visibility:public"],
  name = "unpack_binaries",
  cmd = \"\"\"\
  #!/bin/bash

  # Copy binaries to the output location
  cp external/{bin_path} $(location :{bin_name});

  \"\"\",
  srcs = [ ":bin" ],
  outs = [ "{bin_name}" ],
  )
"""

def _declare_toolchain_repositories(
    nixpkgs_revision,
    bs_version,
    bs_sha256,
    ):
  """
  Make ReasonML/BuckleScript available in the WORKSPACE file.
  """

  nixpkgs_git_repository(
      name = "reason-nixpkgs",
      revision = nixpkgs_revision,
      )

  nixpkgs_package(
      name = "yarn",
      attribute_path = "yarn",
      build_file_content = SINGLE_BIN_BUILD_FILE.format(
          bin_path = "yarn/bin/yarn",
          bin_name = "yarn",
          ),
      repository = "@reason-nixpkgs",
      )

  nixpkgs_package(
      name = "node",
      # TODO(@ostera): let me change the node version
      attribute_path = "nodejs-slim-9_x",
      build_file_content = SINGLE_BIN_BUILD_FILE.format(
          bin_path = "node/bin/node",
          bin_name = "node",
          ),
      repository = "@reason-nixpkgs",
      )

  nixpkgs_package(
      name = "reason-cli",
      attribute_path = "ocamlPackages.reason",
      build_file_content = REASON_BUILD_FILE,
      repository = "@reason-nixpkgs",
      )

  nixpkgs_package(
      name = "ocaml",
      # TODO(@ostera): let me change the ocaml version
      attribute_path = "ocaml_4_03",
      build_file_content = OCAML_BUILD_FILE,
      repository = "@reason-nixpkgs",
      )

  new_download(
    pkg = "bs",
    org = "BuckleScript",
    repo = "bucklescript",
    sha256 = bs_sha256,
    version = bs_version,
    ext = "zip",
    build_file_content = BS_BUILD_FILE
    )

def reason_register_toolchains(nixpkgs_revision, bs_version, bs_sha256):
  """
  Declares a ReasonML/BuckleScript toolchain to use, downloads dependencies and
  initializes other repositories (such as `@nixpkgs`, `@reason`, and `@bs`).

  Args:
    nixpkgs_revision: a tag or commit sha256 for the specific version of nixpkgs
                      from where to install the appropriate ReasonML binaries
    bs_version: a commit sha256 for the specific version of BuckleScript code
    bs_sha256: the integrity checksum to verify the BuckleScript source
  """
  _declare_toolchain_repositories(nixpkgs_revision, bs_version, bs_sha256)

def declare_default_toolchain():
  """The default ReasonML/BuckleScript toolchain.

  This toolchain will register as `bs-platform` and will include the `nix`
  managed ReasonML tools (such as `refmt`) and the `bazel` compiled BuckleScript
  and patched Ocaml compilers.

  It defaults to:

  * `bs_stdlib = "//reason/private/bs:stdlib.ml"`
  * `bsc = "//reason/private/bs:bsc.exe"`
  * `ocamlc = "@ocaml//:ocamlc",
  * `ocamlopt = "@ocaml//:ocamlopt",
  * `ocamldep = "@ocaml//:ocamldep",
  * `ocaml_stdlib = "@ocaml//:stdlib.ml",
  * `refmt = "//reason/private/bs:refmt.exe"`

  """
  _reason_toolchain(
      name = "bs",
      bs_stdlib = "//reason/private/bs:stdlib.ml",
      bsc = "//reason/private/bs:bsc.exe",
      ocamlc = "@ocaml//:ocamlc",
      ocamlopt = "@ocaml//:ocamlopt",
      ocamldep = "@ocaml//:ocamldep",
      ocaml_stdlib = "//reason/private/ocaml:stdlib.ml",
      refmt = "//reason/private/bs:refmt.exe",
      )
