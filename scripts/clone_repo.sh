#!/bin/bash
set -euo pipefail

# Prevent execution inside the frappe_app_template directory itself
toplevel=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ "$toplevel" == *"/frappe_app_template" ]]; then
  echo "⛔ ERROR: You are inside the frappe_app_template directory."
  echo "💡 Please run this script from the root of your app repository."
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

    if git -C "$ROOT_DIR" ls-files --stage "$target" 2>/dev/null | grep -q '^160000'; then
        git -C "$target" fetch origin --tags >/dev/null 2>&1 || true
    else
        rm -rf "$target"
        git -C "$ROOT_DIR" submodule add -f "$url" "$target" >/dev/null 2>&1 || true
    fi
    git -C "$target" checkout "$ref" >/dev/null 2>&1 || \
        git -C "$target" checkout "origin/$ref" >/dev/null 2>&1 || true
    git -C "$ROOT_DIR" add "$target" >/dev/null 2>&1 || true

    if [ -d "$target/instructions" ]; then
        mkdir -p "$INSTRUCTIONS_DIR/_$name"
        rsync -a "$target/instructions/" "$INSTRUCTIONS_DIR/_$name/"
    fi

done < "$TEMPLATE_FILE"

echo "Templates cloned and instructions synced."
