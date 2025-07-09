#!/bin/bash
# setup_codex_env.sh: prepare Codex environment for this template
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# fall back to current working directory or git root if requirements.txt is
# missing at the computed location (e.g. when the script was copied to /tmp)
REQ_FILE="$ROOT_DIR/requirements.txt"
if [ ! -f "$REQ_FILE" ]; then
  if [ -f "$(pwd)/requirements.txt" ]; then
    ROOT_DIR="$(pwd)"
    REQ_FILE="$ROOT_DIR/requirements.txt"
  elif git_root=$(git rev-parse --show-toplevel 2>/dev/null) && [ -f "$git_root/requirements.txt" ]; then
    ROOT_DIR="$git_root"
    REQ_FILE="$ROOT_DIR/requirements.txt"
  fi
fi

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

if [ -z "${SKIP_PIP_INSTALL:-}" ]; then
  python3 -m pip install --upgrade pip >/dev/null
  pip install -r "$REQ_FILE" >/dev/null
  pre-commit install >/dev/null
else
  echo "Skipping Python requirements installation" >&2
fi

"$SCRIPT_DIR/update_vendors_ci.sh"
