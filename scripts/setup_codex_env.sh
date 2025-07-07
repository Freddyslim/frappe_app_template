#!/bin/bash
# setup_codex_env.sh: prepare Codex environment for this template
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "GITHUB_TOKEN not set. Export it before running." >&2
  exit 1
fi

python3 -m pip install --upgrade pip >/dev/null
pip install -r "$ROOT_DIR/requirements.txt" >/dev/null
pre-commit install >/dev/null

"$SCRIPT_DIR/update_vendors_ci.sh"
