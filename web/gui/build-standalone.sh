#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Standalone Web GUI build script for ONOS
# Allows frontend engineers to build and test the unified Angular GUI easily.
# -----------------------------------------------------------------------------

set -euo pipefail

GUI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ONOS_ROOT="$(cd "${GUI_DIR}/../.." && pwd)"

function usage() {
    echo "Usage: $0 [ng|ng-prod|prod|prebuilt|headless|package|export-dist|test|clean]"
    echo ""
    echo "Commands:"
    echo "  ng           Build Web GUI with Angular CLI (development mode) + Bazel WAB packaging"
    echo "  ng-prod      Build Web GUI with Angular CLI (production mode) + Bazel WAB packaging"
    echo "  prod         Build full production Web GUI (Bazel Angular + Java backend) [deprecated]"
    echo "  prebuilt     Build Web GUI using pre-compiled dist/ assets (--define prebuilt_gui=true)"
    echo "  headless     Build headless Web GUI (Java backend only, skips Angular)"
    echo "  package      Build complete .oar application archive"
    echo "  export-dist  Export compiled Angular assets to web/gui/dist/"
    echo "  test         Run Web GUI test suite (ng test)"
    echo "  clean        Clean Web GUI Bazel build cache"
    exit 1
}

MODE="${1:-prod}"

cd "${ONOS_ROOT}"

case "${MODE}" in
    ng)
        echo "Building Web GUI with Angular CLI (development) + Bazel WAB packaging..."
        cd web/gui && node_modules/.bin/ng build --configuration development && cd "${ONOS_ROOT}"
        bazel build --define prebuilt_gui=true //web/gui:onos-web-gui
        echo "Build complete: bazel-bin/web/gui/onos-gui-prebuilt.jar"
        ;;
    ng-prod)
        echo "Building Web GUI with Angular CLI (production) + Bazel WAB packaging..."
        cd web/gui && node_modules/.bin/ng build && cd "${ONOS_ROOT}"
        bazel build --define prebuilt_gui=true //web/gui:onos-web-gui
        echo "Build complete: bazel-bin/web/gui/onos-gui-prebuilt.jar"
        ;;
    prod)
        echo "Building unified production Web GUI (Angular + Java WAB)..."
        bazel build //web/gui:onos-web-gui-prod
        echo "Build complete: bazel-bin/web/gui/onos-gui-prod.jar"
        ;;
    prebuilt)
        echo "Building Web GUI from prebuilt dist/ (--define prebuilt_gui=true)..."
        bazel build --define prebuilt_gui=true //web/gui:onos-web-gui
        echo "Build complete: bazel-bin/web/gui/onos-gui-prebuilt.jar"
        ;;
    headless)
        echo "Building headless Web GUI (--define skip_gui=true)..."
        bazel build --define skip_gui=true //web/gui:onos-web-gui
        echo "Build complete: bazel-bin/web/gui/onos-gui-headless.jar"
        ;;
    export-dist)
        echo "Exporting compiled assets to web/gui/dist/..."
        mkdir -p web/gui/dist
        bazel build //web/gui/src/main/webapp:prodapp
        cp -r bazel-bin/web/gui/src/main/webapp/prodapp/* web/gui/dist/
        echo "Export complete: web/gui/dist/"
        ;;
    package)
        echo "Building unified Web GUI OAR package..."
        bazel build //web/gui:onos-web-gui-oar
        echo "Package complete: bazel-bin/web/gui/onos-web-gui-oar.oar"
        ;;
    test)
        echo "Running Web GUI unit tests..."
        bazel test //web/gui/...
        ;;
    clean)
        echo "Cleaning Bazel output for web/gui..."
        bazel clean
        ;;
    *)
        usage
        ;;
esac
