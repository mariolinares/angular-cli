"""Re-export of some bazel rules with repository-wide defaults."""

load("@npm//@angular/bazel:index.bzl", _ng_module = "ng_module", _ng_package = "ng_package")
load("@build_bazel_rules_nodejs//:index.bzl", _pkg_npm = "pkg_npm")
load("@npm//@bazel/jasmine:index.bzl", _jasmine_node_test = "jasmine_node_test")
load("@npm//@bazel/esbuild:index.bzl", "esbuild")
load(
    "@npm//@bazel/concatjs:index.bzl",
    _ts_library = "ts_library",
)

DEFAULT_TSCONFIG_BUILD = "//modules:bazel-tsconfig-build.json"
DEFAULT_TSCONFIG_TEST = "//modules:bazel-tsconfig-test"

def _getDefaultTsConfig(testonly):
    if testonly:
        return DEFAULT_TSCONFIG_TEST
    else:
        return DEFAULT_TSCONFIG_BUILD

def ts_library(
        tsconfig = None,
        testonly = False,
        deps = [],
        devmode_module = None,
        **kwargs):
    deps = deps + ["@npm//tslib", "@npm//@types/node"]
    if testonly:
        deps.append("@npm//@types/jasmine")

    if not tsconfig:
        tsconfig = _getDefaultTsConfig(testonly)

    if not devmode_module:
        devmode_module = "commonjs"

    _ts_library(
        tsconfig = tsconfig,
        testonly = testonly,
        devmode_module = devmode_module,
        devmode_target = "es2022",
        prodmode_target = "es2022",
        deps = deps,
        **kwargs
    )

# Packages which are versioned together on npm
ANGULAR_SCOPED_PACKAGES = ["@angular/%s" % p for p in [
    "ssr",
]]

PKG_GROUP_REPLACEMENTS = {
    "\"NG_UPDATE_PACKAGE_GROUP\"": """[
      %s
    ]""" % ",\n      ".join(["\"%s\"" % s for s in ANGULAR_SCOPED_PACKAGES]),
}

def ng_module(name, package_name, module_name = None, tsconfig = None, testonly = False, deps = [], **kwargs):
    deps = deps + ["@npm//tslib", "@npm//@types/node"]

    if not tsconfig:
        tsconfig = _getDefaultTsConfig(testonly)

    if not module_name:
        module_name = package_name

    _ng_module(
        name = name,
        module_name = package_name,
        package_name = package_name,
        flat_module_out_file = name,
        tsconfig = tsconfig,
        testonly = testonly,
        deps = deps,
        **kwargs
    )

def jasmine_node_test(deps = [], **kwargs):
    local_deps = [
        "@npm//source-map-support",
    ] + deps

    _jasmine_node_test(
        deps = local_deps,
        configuration_env_vars = ["compile"],
        **kwargs
    )

def ng_test_library(name, entry_point = None, deps = [], tsconfig = None, **kwargs):
    local_deps = [
        # We declare "@angular/core" as default dependencies because
        # all Angular component unit tests use the `TestBed` and `Component` exports.
        "@npm//@angular/core",
    ] + deps

    if not tsconfig:
        tsconfig = _getDefaultTsConfig(1)

    ts_library_name = name + "_ts_library"
    ts_library(
        name = ts_library_name,
        testonly = 1,
        tsconfig = tsconfig,
        deps = local_deps,
        **kwargs
    )

    esbuild(
        name,
        testonly = 1,
        args = {
            "keepNames": True,
            # ensure that esbuild prefers .mjs to .js if both are available
            # since ts_library produces both
            "resolveExtensions": [
                ".mjs",
                ".js",
            ],
        },
        output = name + "_spec.js",
        entry_point = entry_point,
        format = "iife",
        # We cannot use `ES2017` or higher as that would result in `async/await` not being downleveled.
        # ZoneJS needs to be able to intercept these as otherwise change detection would not work properly.
        target = "es2016",
        platform = "node",
        deps = [":" + ts_library_name],
    )

def ng_package(deps = [], **kwargs):
    common_substitutions = dict(kwargs.pop("substitutions", {}), **PKG_GROUP_REPLACEMENTS)
    substitutions = dict(common_substitutions, **{
        "0.0.0-PLACEHOLDER": "0.0.0",
    })
    stamped_substitutions = dict(common_substitutions, **{
        "0.0.0-PLACEHOLDER": "{STABLE_PROJECT_VERSION}",
    })

    _ng_package(
        deps = deps,
        externals = [
            "domino",
            "xhr2",
            "jsdom",
            "critters",
            "express-engine",
            "express",
        ],
        substitutions = select({
            "//:stamp": stamped_substitutions,
            "//conditions:default": substitutions,
        }),
        **kwargs
    )

def pkg_npm(name, **kwargs):
    common_substitutions = dict(kwargs.pop("substitutions", {}), **PKG_GROUP_REPLACEMENTS)
    substitutions = dict(common_substitutions, **{
        "0.0.0-PLACEHOLDER": "0.0.0",
    })
    stamped_substitutions = dict(common_substitutions, **{
        "0.0.0-PLACEHOLDER": "{STABLE_PROJECT_VERSION}",
    })

    _pkg_npm(
        name = name,
        substitutions = select({
            "//:stamp": stamped_substitutions,
            "//conditions:default": substitutions,
        }),
        **kwargs
    )
