#!/bin/bash
# update_vendors_ci.sh: run update_vendors.sh without any prompts
set -euo pipefail

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "GITHUB_TOKEN environment variable not set" >&2
  exit 1
fi

export GIT_TERMINAL_PROMPT=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/update_vendors.sh" "$@"
