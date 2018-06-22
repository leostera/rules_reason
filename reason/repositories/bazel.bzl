def bazel_repositories():
  native.http_archive(
      name = "io_bazel",
      sha256 = "",
      strip_prefix = "bazel-0.14.1",  # Should match current Bazel version
      urls = [
          "http://bazel-mirror.storage.googleapis.com/github.com/bazelbuild/bazel/archive/0.14.1.tar.gz",
          "https://github.com/bazelbuild/bazel/archive/0.14.1.tar.gz",
          ],
      )

  native.http_archive(
      name = "io_bazel_rules_go",
      sha256 = "4f95bc867830231b3fa0ab5325632f7865cbe8cef842d2b5a269b59a7df95279",
      strip_prefix = "rules_go-f668026feec298887e7114b01edf72b229829ec9",  # branch master
      urls = ["https://github.com/bazelbuild/rules_go/archive/f668026feec298887e7114b01edf72b229829ec9.zip"],
      )

  native.http_archive(
      name = "com_github_bazelbuild_buildtools",
      sha256 = "1a0500deaa51c9dd2c1b7f42b2307e8b9ac4e2e27c0a9877ebaed015b97ed644",
      strip_prefix = "buildtools-405641a50b8583dc9fe254b7a22ebc2002722d17",  # branch master
      urls = ["https://github.com/bazelbuild/buildtools/archive/405641a50b8583dc9fe254b7a22ebc2002722d17.zip"],
      )
