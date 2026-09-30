"""
 Rules to build the unified ONOS Web GUI
"""

load("//tools/build/bazel:jdk_genrule.bzl", genrule = "jdk_genrule")
load("@npm//@bazel/typescript:index.bzl", "ts_config")

COMPILE_DEPS = CORE_DEPS + JACKSON + KRYO + CLI + [
    "@javax_ws_rs_api//jar",
    "@servlet_api//jar",
    "@jetty_websocket//jar",
    "@jetty_websocket_api//jar",
    "@jetty_util//jar",
    "@jersey_media_multipart//jar",
    "@jersey_server//jar",
    "@jersey_hk2//jar",
    "//utils/rest:onlab-rest",
    "//core/store/serializers:onos-core-serializers",
]

TEST_DEPS = TEST + [
    "//core/api:onos-api-tests",
    "//drivers/default:onos-drivers-default",
]

exports_files(
    ["tsconfig.json"],
    visibility = ["//visibility:public"],
)

ts_config(
    name = "tsconfig-test",
    src = "tsconfig-test.json",
    visibility = ["//visibility:public"],
    deps = [":tsconfig.json"],
)

# Export localization and core resources
genrule(
    name = "onos-gui-lion",
    srcs = glob([
        "src/main/resources/org/onosproject/ui/lion/**/*",
        "src/main/resources/core/**/*",
    ]),
    outs = ["onos-gui-lion.srcjar"],
    cmd = "jar cf $@ $(SRCS)",
    visibility = ["//visibility:public"],
)


osgi_jar_with_tests(
    name = "_onos-gui-base-jar",
    srcs = glob([
        "src/main/java/**",
    ]),
    exclude_tests = [
        "org.onosproject.ui.impl.AbstractUiImplTest",
        "org.onosproject.ui.impl.topo.model.AbstractTopoModelTest",
    ],
    karaf_command_packages = [
        "org.onosproject.ui.impl.cli",
        "org.onosproject.ui.impl.topo",
    ],
    suppress_checkstyle = True,
    test_deps = TEST_DEPS,
    web_context = "/onos/ui",
    deps = COMPILE_DEPS,
)

config_setting(
    name = "skip_gui",
    values = {"define": "skip_gui=true"},
)

config_setting(
    name = "prebuilt_gui",
    values = {"define": "prebuilt_gui=true"},
)

filegroup(
    name = "prebuilt_dist",
    srcs = glob(["dist/**/*"], allow_empty = True),
)

genrule(
    name = "onos-web-gui-prebuilt",
    srcs = [
        ":prebuilt_dist",
        ":_onos-gui-base-jar",
        ":onos-gui-lion",
        "//web/gui/src/main/webapp:WEB-INF/web.xml",
        ":_onos-gui-base-jar_cfgdef.jar",
    ],
    outs = ["onos-gui-prebuilt.jar"],
    cmd = " ROOT=`pwd` &&" +
          " mkdir -p web/gui/WEB-INF/classes/org/onosproject/ui/ &&" +
          " cd web/gui &&" +
          " jar xf $$ROOT/$(location :_onos-gui-base-jar) &&" +
          " unzip -q $$ROOT/$(location :onos-gui-lion) web/gui/src/main/resources/**/* &&" +
          " cp -R web/gui/src/main/resources/org/onosproject/ui/lion* WEB-INF/classes/org/onosproject/ui/ &&" +
          " cp -R $$ROOT/web/gui/dist/* WEB-INF/classes/ &&" +
          " mv $$ROOT/$(location //web/gui/src/main/webapp:WEB-INF/web.xml) WEB-INF &&" +
          " (cd WEB-INF/classes && jar xf $$ROOT/$(location :_onos-gui-base-jar_cfgdef.jar)) &&" +
          " find . -type f -exec touch -t 202001010001 {} \\; &&" +
          " jar cmf META-INF/MANIFEST.MF $$ROOT/$@ WEB-INF/web.xml WEB-INF/classes OSGI-INF/*.xml",
    output_to_bindir = 1,
)

genrule(
    name = "onos-web-gui-prod",
    srcs = [
        "//web/gui/src/main/webapp:prodapp",
        ":_onos-gui-base-jar",
        ":onos-gui-lion",
        "//web/gui/src/main/webapp:WEB-INF/web.xml",
        ":_onos-gui-base-jar_cfgdef.jar",
    ],
    outs = ["onos-gui-prod.jar"],
    cmd = " ROOT=`pwd` &&" +
          " mkdir -p web/gui/WEB-INF/classes/org/onosproject/ui/ &&" +
          " cd web/gui &&" +
          " jar xf $$ROOT/$(location :_onos-gui-base-jar) &&" +
          " unzip -q $$ROOT/$(location :onos-gui-lion) web/gui/src/main/resources/**/* &&" +
          " cp -R web/gui/src/main/resources/org/onosproject/ui/lion* WEB-INF/classes/org/onosproject/ui/ &&" +
          " cp -R $$ROOT/$(location //web/gui/src/main/webapp:prodapp)/* WEB-INF/classes/ &&" +
          " mv $$ROOT/$(location //web/gui/src/main/webapp:WEB-INF/web.xml) WEB-INF &&" +
          " (cd WEB-INF/classes && jar xf $$ROOT/$(location :_onos-gui-base-jar_cfgdef.jar)) &&" +
          " find . -type f -exec touch -t 202001010001 {} \\; &&" +
          " jar cmf META-INF/MANIFEST.MF $$ROOT/$@ WEB-INF/web.xml WEB-INF/classes OSGI-INF/*.xml",
    output_to_bindir = 1,
)

genrule(
    name = "onos-web-gui-headless",
    srcs = [
        ":_onos-gui-base-jar",
        ":onos-gui-lion",
        "//web/gui/src/main/webapp:WEB-INF/web.xml",
        ":_onos-gui-base-jar_cfgdef.jar",
    ],
    outs = ["onos-gui-headless.jar"],
    cmd = " ROOT=`pwd` &&" +
          " mkdir -p web/gui/WEB-INF/classes/org/onosproject/ui/ &&" +
          " cd web/gui &&" +
          " jar xf $$ROOT/$(location :_onos-gui-base-jar) &&" +
          " unzip -q $$ROOT/$(location :onos-gui-lion) web/gui/src/main/resources/**/* &&" +
          " cp -R web/gui/src/main/resources/org/onosproject/ui/lion* WEB-INF/classes/org/onosproject/ui/ &&" +
          " echo '<!DOCTYPE html><html><head><title>ONOS Headless</title></head><body><h1>ONOS Headless Mode</h1><p>Web GUI compilation was skipped (--define skip_gui=true)</p></body></html>' > WEB-INF/classes/index.html &&" +
          " mv $$ROOT/$(location //web/gui/src/main/webapp:WEB-INF/web.xml) WEB-INF &&" +
          " (cd WEB-INF/classes && jar xf $$ROOT/$(location :_onos-gui-base-jar_cfgdef.jar)) &&" +
          " find . -type f -exec touch -t 202001010001 {} \\; &&" +
          " jar cmf META-INF/MANIFEST.MF $$ROOT/$@ WEB-INF/web.xml WEB-INF/classes OSGI-INF/*.xml",
    output_to_bindir = 1,
)

alias(
    name = "onos-web-gui",
    actual = select({
        ":skip_gui": ":onos-web-gui-headless",
        ":prebuilt_gui": ":onos-web-gui-prebuilt",
        "//conditions:default": ":onos-web-gui-prod",
    }),
    visibility = ["//visibility:public"],
)

onos_app(
    category = "Graphical User Interface",
    description = "ONOS Web GUI - modern Angular-based user interface",
    title = "ONOS Web GUI",
    url = "http://onosproject.org",
)
