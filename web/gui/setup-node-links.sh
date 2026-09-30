#!/usr/bin/env bash
# =============================================================================
# setup-node-links.sh — Create node_modules symlinks required for Angular CLI
# =============================================================================
# The Angular 18 build compiles source files from sibling directories:
#   web/gui-fw-lib/  web/gui-topo-lib/  apps/roadm/  apps/yang-gui/  etc.
#
# All npm packages live in web/gui/node_modules/.  Node module resolution
# walks up ancestor directories, so we create two symlinks so ALL source
# trees can resolve @angular/*, rxjs, d3, etc.:
#
#   onos-classic/node_modules  →  web/gui/node_modules
#   onos-classic/web/node_modules  →  web/gui/node_modules
#
# These symlinks are NOT committed to git (listed in .gitignore).
# Re-run this script after a fresh clone or after 'npm install' in web/gui/.
# =============================================================================

set -euo pipefail

ONOS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUI_NM="${ONOS_ROOT}/web/gui/node_modules"

if [ ! -d "${GUI_NM}" ]; then
    echo "ERROR: ${GUI_NM} does not exist. Run 'npm install' in web/gui/ first."
    exit 1
fi

echo "Creating node_modules symlinks pointing to: ${GUI_NM}"

# Root-level symlink (needed for apps/* modules)
ln -sfn "${GUI_NM}" "${ONOS_ROOT}/node_modules"
echo "  ✓ ${ONOS_ROOT}/node_modules → ${GUI_NM}"

# web/ level symlink (needed for gui-fw-lib, gui-topo-lib)
ln -sfn "${GUI_NM}" "${ONOS_ROOT}/web/node_modules"
echo "  ✓ ${ONOS_ROOT}/web/node_modules → ${GUI_NM}"

echo ""
echo "Setup complete. You can now run:"
echo "  cd web/gui && ng build --configuration development"
echo "  # or"
echo "  ./web/gui/build-standalone.sh ng"
