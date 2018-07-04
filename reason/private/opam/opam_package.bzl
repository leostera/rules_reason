def _opam_package(repo_ctx):
  archive = repo_ctx.attr.archive
  pkg_name = repo_ctx.attr.pkg_name
  pkg_version = repo_ctx.attr.pkg_version
  sha256 = repo_ctx.attr.sha256
  type = repo_ctx.attr.type

  prefix = "{name}-{version}".format(name=pkg_name, version=pkg_version)

  build_file_path = "BUILD"
  build_file_template = repo_ctx.attr._build_template

  # Create BUILD file
  repo_ctx.template(
      build_file_path,
      build_file_template,
      executable = False,
  )

  # Download and Verify Package
  repo_ctx.download_and_extract(
      url = archive,
      sha256 = sha256,
      stripPrefix = prefix,
      type = type,
      )

  return None

opam_package = repository_rule(
  _opam_package,
  local = True,
  attrs = {
      "archive": attr.string(mandatory=True),
      "deps": attr.string_list(default = []),
      "pkg_name": attr.string(mandatory=True),
      "pkg_version": attr.string(mandatory=True),
      "sha256": attr.string(mandatory=True),
      "type": attr.string(
          mandatory = True,
          values = [ "zip", "jar", "war", "tar.gz", "tgz", "tar.bz2", "tar.xz" ],
      ),
      "_build_template": attr.label(
        allow_single_file = True,
        default = "//reason/private/opam:opam_package.tpl",
      )
    },
)
