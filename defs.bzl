def _jetify_impl(ctx):
    srcs = ctx.attr.srcs
    outfiles = []
    jetifing_commands = []
    
    for src in srcs:
        for artifact in src.files.to_list():
            jetified_outfile = ctx.actions.declare_file("jetified_{}_{}".format(ctx.attr.name, artifact.basename))
            ctx.actions.run_shell(
                mnemonic = "Jetify",
                inputs = [artifact],
                tools = ctx.files._jetifier_jars,
                outputs = [jetified_outfile],
                progress_message = "Jetifying {} to create {}.".format(artifact.path, jetified_outfile.path),
                command = 'java -classpath "{jetifier_tool}:{classpath_arg}" com.android.tools.build.jetifier.standalone.Main -l error -i {artifact} -o {jetified_outfile}'.format(
                    jetifier_tool = ctx.file._jetifier_tool.path,
                    jetified_outfile = jetified_outfile.path,
                    artifact = artifact.path,
                    classpath_arg = ':'.join([tool.path for tool in ctx.files._jetifier_jars]))
            )
            outfiles.append(jetified_outfile)

    return [DefaultInfo(files = depset(outfiles))]

jetify = rule(
    attrs = {
        "srcs": attr.label_list(allow_files = [".jar", ".aar"]),
        "_jetifier_tool": attr.label(
            allow_single_file = True,
            default = Label("//thirdparty:jetifier-standalone.jar"),
            cfg = "host"),
        "_jetifier_jars": attr.label_list(
            allow_files = True,
            default = [
                Label("@org_ow2_asm__asm__6_0//file"),
                Label("@org_ow2_asm__asm_commons__6_0//file"),
                Label("@org_ow2_asm__asm_tree__6_0//file"),
                Label("@org_ow2_asm__asm_util__6_0//file"),
                Label("@org_jdom__jdom2__2_0_6//file"),
                Label("@commons_cli__commons_cli__1_3_1//file"),
                Label("@com_google_code_gson__gson__2_8_0//file"),
                Label("@com_android_tools_build_jetifier__jetifier_core__1_0_0_beta05//file"),
                Label("@com_android_tools_build_jetifier__jetifier_processor__1_0_0_beta05//file"),
                Label("@org_jetbrains_kotlin__kotlin_stdlib__1_3_31//file"),
                Label("@org_jetbrains_kotlin__kotlin_stdlib_common__1_3_31//file"),
            ],
            cfg = "host",
        ),
    },
    implementation = _jetify_impl,
)


# This is a sample implementation of `aar_import` with `jetify`
def jetify_aar(name, aar, deps = [], exports = []):
    if (name.find('androidx') >= 0 or
        name.find('com_android_support') >= 0):
        native.aar_import(name = name, aar = aar, deps = deps, exports = exports)
    else:
        jetify_aar_name = "jetify_aar_%s" % name
        jetify(name = jetify_aar_name, srcs = [aar])
        native.aar_import(name = name, aar = ":%s" % jetify_aar_name, deps = deps, exports = exports)

# This is a sample implementation of `java_import` with `jetify`
def jetify_jar(name, jars, deps = [], runtime_deps = [], exports = [], tags = [], licenses = []):
    if (name.find('org_robolectric__shadows_supportv4') >= 0 or
        name.find('org_eclipse') >= 0 or
        name.find('androidx') >= 0 or
        name.find('com_android_support') >= 0):
        native.java_import(name = name, 
            jars = jars,
            deps = deps, 
            exports = exports,
            runtime_deps = runtime_deps,
            tags = tags,
            licenses = licenses)
    else:
        jetify_jar_name = "jetify_jar_%s" % name
        jetify(name = jetify_jar_name, srcs = jars)
        native.java_import(name = name, 
            jars = [":%s" % jetify_jar_name], 
            deps = deps, 
            exports = exports,
            runtime_deps = runtime_deps,
            tags = tags,
            licenses = licenses)