#!/bin/bash
# setup_codex_env.sh: prepare Codex environment for this template

set -euo pipefail
echo "SETUP STARTED"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Ensure GitHub token is set for private submodules
if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "GITHUB_TOKEN not set. Export it before running." >&2
  exit 1
fi

# Use the token for GitHub submodule URLs
git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"

# Initialize all submodules
if [ -f "$ROOT_DIR/.gitmodules" ]; then
  git -C "$ROOT_DIR" submodule update --init --recursive
fi

echo "✅ Submodules initialized"

# Prepare Codex-accessible cache
CACHE_DIR="$ROOT_DIR/_codex_submodules_cache"
mkdir -p "$CACHE_DIR"

# Loop through all submodules listed in .gitmodules
while read -r sub_path; do
  sub_dir="$ROOT_DIR/$sub_path"
  sub_name="$(basename "$sub_path")"

  if [ -d "$sub_dir" ]; then
    # Optional: Ensure it's checked out (fallback for detached HEAD or empty state)
    git -C "$sub_dir" checkout HEAD >/dev/null 2>&1 || echo "⚠️ Could not checkout HEAD in $sub_path"

    # Only copy if content exists
    if [ "$(ls -A "$sub_dir" 2>/dev/null)" ]; then
      echo "🔄 Caching submodule: $sub_path"
      cp -r "$sub_dir" "$CACHE_DIR/$sub_name"
    else
      echo "⚠️ Skipping empty submodule: $sub_path"
    fi
  else
    echo "❌ Submodule not found at: $sub_dir"
  fi
done < <(git config --file "$ROOT_DIR/.gitmodules" --get-regexp path | awk '{print $2}')

echo "✅ Submodules copied to $CACHE_DIR"
