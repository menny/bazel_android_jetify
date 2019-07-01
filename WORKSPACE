workspace(name="bazel_jetify")

### http_archive
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file", "http_archive")

# Mabel - maven deps (https://github.com/menny/mabel)
mabel_version = "0.6.0"
http_archive(
    name = "mabel",
    urls = ["https://github.com/menny/mabel/archive/%s.zip" % mabel_version],
    type = "zip",
    strip_prefix = "mabel-%s" % mabel_version,
    sha256 = "0d290abbef38803ca32f31ebfa5e2a1695718c356c886a485640b03b4c882bcf"
)

load("@mabel//resolver/main_deps:dependencies.bzl", generate_mabel_workspace_rules = "generate_workspace_rules")
generate_mabel_workspace_rules()

load("//thirdparty/main_deps:dependencies.bzl", main_deps_rules = "generate_workspace_rules")
main_deps_rules()
