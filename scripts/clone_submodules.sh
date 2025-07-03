#!/bin/bash
set -euo pipefail

# Prevent execution inside the frappe_app_template submodule
toplevel=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ "$toplevel" == *"/frappe_app_template" ]]; then
  echo "⛔ ERROR: You are inside the frappe_app_template submodule."
  echo "💡 Please run this script from the root of your app repository, not from inside the template."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE_FILE="${TEMPLATE_FILE:-$ROOT_DIR/vendors.txt}"
VENDOR_DIR="$ROOT_DIR/vendor"
INSTRUCTIONS_DIR="$ROOT_DIR/instructions"

mkdir -p "$VENDOR_DIR" "$INSTRUCTIONS_DIR"

sanitize() {
    echo "$1" | sed 's/#.*//' | sed 's/^\s*//;s/\s*$//'
}

while IFS= read -r raw_line || [ -n "$raw_line" ]; do
    repo="$(sanitize "$raw_line")"
    [ -z "$repo" ] && continue

    if [[ "$repo" == *@* ]]; then
        url="${repo%@*}"
        ref="${repo#*@}"
        [ -z "$ref" ] && ref="main"
    else
        url="$repo"
        ref="main"
    fi

    name="$(basename "$url" .git)"
    target="vendor/$name"
    echo "--> processing $name@$ref"

    if ! grep -q "path = $target" "$ROOT_DIR/.gitmodules" 2>/dev/null; then
        git submodule add -b "$ref" "$url" "$target" || true
    fi

    # ensure correct ref is checked out
    if [ -d "$target/.git" ]; then
        git -C "$target" fetch --tags origin || true
        git -C "$target" checkout "$ref" || git -C "$target" checkout "origin/$ref" || true
    fi

    if [ -d "$target/instructions" ]; then
        mkdir -p "$INSTRUCTIONS_DIR/_$name"
        rsync -a "$target/instructions/" "$INSTRUCTIONS_DIR/_$name/"
    fi

done < "$TEMPLATE_FILE"

echo "Templates cloned and instructions synced."
