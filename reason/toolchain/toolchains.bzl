"""Toolchain

Find below macros to register toolchains for ReasonML and BuckleScript.

A default `declare_default_toolchain()` macro is included. It requires `nix` to
be installed in your system.
"""

load(
    "//reason/private:toolchain.bzl",
    _reason_toolchain="reason_toolchain",
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

OPAM_BUILD_FILE = """
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
  cp external/opam/bin/opam $$(dirname $(location :opam))/;

  \"\"\",
  srcs = [ ":srcs" ],
  outs = [
        "opam",
      ]
  )
"""

BS_BUILD_FILE = """
filegroup(
    visibility = ["//visibility:public"],
    name = "srcs",
    srcs = glob([
        "*",
        "scripts/**/*",
        "lib/**/*",
        "jscomp/**/*",
        "vendor/**/*",
        ]),
    )
"""

SINGLE_BIN_BUILD_FILE = """
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
        nixpkgs_sha256,
        bs_version,
        bs_sha256,
):
    """
    Make ReasonML/BuckleScript available in the WORKSPACE file.
    """

    nixpkgs_git_repository(
        name="reason-nixpkgs",
        revision=nixpkgs_revision,
        sha256=nixpkgs_sha256,
    )

    nixpkgs_package(
        name="yarn",
        attribute_path="yarn",
        build_file_content=SINGLE_BIN_BUILD_FILE.format(
            bin_path="yarn/bin/yarn",
            bin_name="yarn",
        ),
        repository="@reason-nixpkgs",
    )

    nixpkgs_package(
        name="node",
        # TODO(@ostera): let me change the node version
        attribute_path="nodejs-slim-9_x",
        build_file_content=SINGLE_BIN_BUILD_FILE.format(
            bin_path="node/bin/node",
            bin_name="node",
        ),
        repository="@reason-nixpkgs",
    )

    nixpkgs_package(
        name="opam",
        attribute_path="opam",
        build_file_content=OPAM_BUILD_FILE,
        repository="@reason-nixpkgs",
    )

    new_download(
        pkg="bs",
        org="BuckleScript",
        repo="bucklescript",
        sha256=bs_sha256,
        version=bs_version,
        ext="zip",
        build_file_content=BS_BUILD_FILE)


def reason_register_toolchains(nixpkgs_revision, nixpkgs_sha256, bs_version,
                               bs_sha256):
    """
    Declares a ReasonML/BuckleScript toolchain to use, downloads dependencies and
    initializes other repositories (such as `@nixpkgs`, `@reason`, and `@bs`).

    Args:
      nixpkgs_revision: a tag or commit sha256 for the specific version of nixpkgs
                        from where to install the appropriate ReasonML binaries
      nixpkgs_sha256: the integrity checksum to verify the nixpkgs repository
      bs_version: a commit sha256 for the specific version of BuckleScript code
      bs_sha256: the integrity checksum to verify the BuckleScript source
    """
    _declare_toolchain_repositories(nixpkgs_revision, nixpkgs_sha256,
                                    bs_version, bs_sha256)


def declare_default_toolchain():
    """The default ReasonML/BuckleScript toolchain.

    This toolchain will register as `bs-platform` and will include the `nix`
    managed ReasonML tools (such as `refmt`) and the `bazel` compiled BuckleScript
    and patched Ocaml compilers.

    It defaults to:

    * `bs_stdlib = "//reason/private/bs:stdlib.ml"`
    * `bsc = "//reason/private/bs:bsc.exe"`
    * `ocamlc = "//reason/private/opam:ocamlc.opt"`
    * `ocamlopt = "//reason/private/opam:ocamlopt.opt"`
    * `ocamldep = "//reason/private/opam:ocamldep.opt"`
    * `ocamlrun = "//reason/private/opam:ocamlrun"`
    * `ocaml_stdlib = "//reason/private/ocaml:stdlib.ml"`
    * `refmt = "//reason/private/bs:refmt.exe"`

  """
    _reason_toolchain(
        name="bs",
        bs_stdlib="//reason/private/bs:stdlib.ml",
        bsc="//reason/private/bs:bsc.exe",
        ocamlc="//reason/private/opam:ocamlc.opt",
        ocamlopt="//reason/private/opam:ocamlopt.opt",
        ocamldep="//reason/private/opam:ocamldep.opt",
        ocamlrun="//reason/private/opam:ocamlrun",
        ocaml_stdlib="//reason/private/ocaml:stdlib.ml",
        refmt="//reason/private/bs:refmt.exe",
    )
