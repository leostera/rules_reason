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
  cp external/reason/bin/* $$(dirname $(location :refmt));

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

BIN_BUILD_FILE="""
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
  cp external/{bin_path} $$(dirname $(location :{bin_name}));

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
      build_file_content = BIN_BUILD_FILE.format(
          bin_path = "yarn/bin/yarn",
          bin_name = "yarn",
          ),
      repository = "@reason-nixpkgs",
      )

  nixpkgs_package(
      name = "node",
      attribute_path = "nodejs-slim-9_x",
      build_file_content = BIN_BUILD_FILE.format(
          bin_path = "node/bin/node",
          bin_name = "node",
          ),
      repository = "@reason-nixpkgs",
      )

  nixpkgs_package(
      name = "reason",
      attribute_path = "ocamlPackages.reason",
      build_file_content = REASON_BUILD_FILE,
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

  * `stdlib = "//reason/private/bs:stdlib.ml"`
  * `bsc = "//reason/private/bs:bsc.exe"`
  * `refmt = "//reason/private/bs:refmt.exe"`

  """
  _reason_toolchain(
      name = "bs",
      stdlib = "//reason/private/bs:stdlib.ml",
      bsc = "//reason/private/bs:bsc.exe",
      refmt = "//reason/private/bs:refmt.exe",
      )
