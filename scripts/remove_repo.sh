#!/bin/bash
# remove_repo.sh: delete a vendor repository directory and its instructions
set -euo pipefail

# Prevent execution inside the frappe_app_template directory
toplevel=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ "$toplevel" == *"/frappe_app_template" ]]; then
  echo "⛔ ERROR: You are inside the frappe_app_template directory."
  echo "💡 Please run this script from the root of your app repository."
  exit 1
fi

if [ $# -ne 1 ]; then
    echo "Usage: $0 <repo-name>" >&2
    exit 1
fi

NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
# target paths
VENDOR_DIR="$ROOT_DIR/vendor/$NAME"
INSTR_DIR="$ROOT_DIR/instructions/_$NAME"

# remove repository directory
rm -rf "$VENDOR_DIR"

# remove instructions directory
rm -rf "$INSTR_DIR"

echo "Removed vendor $NAME"
