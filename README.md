# Android Jetify Rule for Bazel

With the migration from the support-library to AndroidX, Google also provides a tool called Jetify which re-writes your dependecies to use the androidx namespaces and classes instead of the support-library's. This is useful when depending on third-party aritfacts that use the support-library namespace and have not been converted yet.</br>
Read more here: https://developer.android.com/jetpack/androidx/migrate

## Usage

# WORKSPACE import:
In your `WORKSPACE` file, load this repository:
```python
mabel_version = "0.0.1" #latest version from 
http_archive(
    name = "bazel_jetifier",
    urls = ["https://github.com/menny/bazel_android_jetify/archive/%s.zip" % mabel_version],
    type = "zip",
    strip_prefix = "bazel_android_jetify-%s" % mabel_version
)

load("@bazel_jetifier//thirdparty/main_deps:dependencies.bzl", bazel_jetifier_main_deps_rules = "generate_workspace_rules")
bazel_jetifier_main_deps_rules()
```

And then, instead of using `java_import` or `aar_import`, use `jetify_java` and `jetify_aar`.