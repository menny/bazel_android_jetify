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

This will provide you with access to the `jetify` rule. Load it in the appropriate `BUILD.bazel` file:
```python
load("@bazel_jetifier//:defs.bzl", "jetify")
```

And use it to _jetify_ jar or aar files:
```python
http_file(name = 'com_facebook_yoga__yoga__1_14_0',
        urls = ['https://repo.maven.apache.org/maven2/com/facebook/yoga/yoga/1.14.0/yoga-1.14.0.aar'],
        downloaded_file_path = 'yoga-1.14.0.aar',
        sha256 = '4cf72154fad3ebd733da9093602324024d405776ae32e0286422f21f0f3da8fd',
)

jetify(
    name = 'jetified_facebook_yoga,
    srcs = ['@com_facebook_yoga__yoga__1_14_0//file']
)

aar_import(
    name = 'facebook_yoga',
    jars = ['jetified_facebook_yoga']
)

```

This will provide you with a repository target `facebook_yoga` which is a jetified version of the original repository target.

## Macros
This seems like a lot of work, so you should use a macro instead of `aar_import`. It can probably look like this:
```python
def jetify_aar_import(name, aar, deps = [], exports = []):
    jetify_aar_name = "jetify_aar_%s" % name
    jetify(name = jetify_aar_name, srcs = [aar])
    native.aar_import(name = name, aar = ":%s" % jetify_aar_name, deps = deps, exports = exports)
```