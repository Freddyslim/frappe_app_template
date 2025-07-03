#!/bin/bash
set -euo pipefail

# Prevent execution inside the frappe_app_template submodule
toplevel=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ "$toplevel" == *"/frappe_app_template" ]]; then
  echo "⛔ ERROR: You are inside the frappe_app_template submodule."
  echo "💡 Please run this script from the root of your app repository, not from inside the template."
  exit 1
fi

if [ $# -ne 1 ]; then
    echo "Usage: $0 <template-name>" >&2
    exit 1
fi

NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VENDOR_DIR="$ROOT_DIR/vendor/$NAME"
INSTR_DIR="$ROOT_DIR/instructions/_$NAME"

# remove submodule
if grep -q "path = vendor/$NAME" "$ROOT_DIR/.gitmodules" 2>/dev/null; then
    git submodule deinit -f "vendor/$NAME" 2>/dev/null || true
    if [[ -e "vendor/$NAME" ]]; then
        git rm -f "vendor/$NAME" 2>/dev/null || true
    fi
    rm -rf "$ROOT_DIR/.git/modules/vendor/$NAME" "$VENDOR_DIR"
fi

# remove instructions directory
rm -rf "$INSTR_DIR"

echo "Removed template $NAME"
