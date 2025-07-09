#!/bin/bash
# setup_codex_env.sh: prepare Codex environment for this template
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "GITHUB_TOKEN not set. Export it before running." >&2
  exit 1
fi

# use token to authenticate any submodule URLs pointing to GitHub
git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"

# initialize submodules if present in the repository
if [ -f "$ROOT_DIR/.gitmodules" ]; then
  git -C "$ROOT_DIR" submodule update --init --recursive
fi

"$SCRIPT_DIR/update_vendors_ci.sh"
