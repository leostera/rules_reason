def bazel_repositories(
        bazel_version,
        bazel_sha256,
        rules_go_version,
        rules_go_sha256,
        buildtools_version,
        buildtools_sha256,
):
    native.http_archive(
        name="io_bazel",
        sha256=bazel_sha256,
        strip_prefix="bazel-%s" %
        bazel_version,  # Should match current Bazel version
        urls=[
            "http://bazel-mirror.storage.googleapis.com/github.com/bazelbuild/bazel/archive/%s.tar.gz"
            % bazel_version,
            "https://github.com/bazelbuild/bazel/archive/%s.tar.gz" %
            bazel_version,
        ],
    )

    native.http_archive(
        name="io_bazel_rules_go",
        sha256=rules_go_sha256,
        strip_prefix="rules_go-%s" % rules_go_version,  # branch master
        urls=[
            "https://github.com/bazelbuild/rules_go/archive/%s.zip" %
            rules_go_version
        ],
    )

    native.http_archive(
        name="com_github_bazelbuild_buildtools",
        sha256=buildtools_sha256,
        strip_prefix="buildtools-%s" % buildtools_version,  # branch master
        urls=[
            "https://github.com/bazelbuild/buildtools/archive/%s.zip" %
            buildtools_version
        ],
    )
