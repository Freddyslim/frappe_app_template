#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$ROOT_DIR/frappe_app_template"

# Allow running inside the template repository by falling back to ROOT_DIR
if [ ! -f "$TEMPLATE_DIR/setup.sh" ]; then
  TEMPLATE_DIR="$ROOT_DIR"
fi

cp "$TEMPLATE_DIR/setup.sh" "$ROOT_DIR/setup.sh"
chmod +x "$ROOT_DIR/setup.sh"

pushd "$ROOT_DIR" >/dev/null
./setup.sh
popd >/dev/null

rm -f "$ROOT_DIR/setup.sh"
