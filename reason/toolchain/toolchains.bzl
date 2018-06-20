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

def _register_toolchains():
  native.register_toolchains(
      "@com_github_ostera_rules_reason//reason/toolchain:host",
  )

def reason_register_toolchains(nixpkgs_revision, bs_version, bs_sha256):
  _declare_toolchain_repositories(nixpkgs_revision, bs_version, bs_sha256)

def declare_toolchains():
  _reason_toolchain(
      name = "bs",
      stdlib = "//reason/private/bs:stdlib.ml",
      bsc = "//reason/private/bs:bsc.exe",
      refmt = "//reason/private/bs:refmt.exe",
      )
