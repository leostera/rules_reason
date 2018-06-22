load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def github_archive(org, repo, version, ext):
  return "https://github.com/{org}/{repo}/archive/{version}.{ext}".format(
      org=org,
      repo=repo,
      version=version,
      ext=ext
      )

def github_prefix(repo, version):
  return "{repo}-{version}".format(repo=repo, version=version)

def download(pkg, org, repo, version, sha256, ext):
  http_archive(
      name = pkg,
      sha256 = sha256,
      strip_prefix = github_prefix(repo=repo, version=version),
      url = github_archive(org=org, repo=repo, version=version, ext=ext),
      )

def new_download(pkg, org, repo, version, sha256, ext, build_file=None, build_file_content=None):
  native.new_http_archive(
      name = pkg,
      sha256 = sha256,
      strip_prefix = github_prefix(repo=repo, version=version),
      url = github_archive(org=org, repo=repo, version=version, ext=ext),
      build_file = build_file,
      build_file_content = build_file_content,
      )

def unpack_filegroup(name, tar, files, **kwargs):
  """
  A macro to unpack a tar file and export the complete sources as a filegroup.
  """
  native.genrule(
      name = "unpack_"+name,
      cmd = """\
          #!/bin/bash

          tar --extract \
              --file $$(pwd)/$(location {tar}) \
              --directory $(@D);

          """.format(tar=tar),
      srcs = [ tar ],
      outs = files,
      **kwargs
      )

  native.filegroup(
      name = name,
      srcs = [ ":{name}".format(name=f) for f in files ],
      **kwargs
      )
