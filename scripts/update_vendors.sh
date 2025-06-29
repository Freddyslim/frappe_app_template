#!/bin/bash
set -euo pipefail
export GIT_TERMINAL_PROMPT=0

# Prevent execution inside the template submodule
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ "$repo_root" == *"/frappe_app_template" ]]; then
  echo "⛔ ERROR: Run this script from your app repository, not inside the template." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VENDOR_DIR="$ROOT_DIR/vendor"
VENDORS_FILE="${VENDORS_FILE:-$ROOT_DIR/vendors.txt}"
PROFILES_DIR="${PROFILES_DIR:-$ROOT_DIR/vendor_profiles}"
CODEX_JSON="$ROOT_DIR/codex.json"

mkdir -p "$VENDOR_DIR"

# read vendors list
readarray -t VENDORS < <(grep -v '^#' "$VENDORS_FILE" 2>/dev/null | xargs -r)

# load integration profiles
declare -A REPOS
declare -A BRANCHES
for slug in "${VENDORS[@]}"; do
  profile_file=$(find "$PROFILES_DIR" -name "$slug.json" -print -quit 2>/dev/null || true)
  if [[ -n "$profile_file" ]]; then
    repo=$(jq -r '.url // empty' "$profile_file" 2>/dev/null)
    branch=$(jq -r '.branch // .tag // ""' "$profile_file" 2>/dev/null)
  else
    repo=""
    branch=""
  fi
  if [[ -n "$repo" ]]; then
    REPOS[$slug]="$repo"
    BRANCHES[$slug]="$branch"
  else
    echo "⚠️  Unknown vendor: $slug" >&2
  fi
done

# track resulting apps.json entries
declare -A APP_INFO
changes=false

for slug in "${!REPOS[@]}"; do
  repo="${REPOS[$slug]}"
  branch="${BRANCHES[$slug]}"
  target="$VENDOR_DIR/$slug"
  echo "➡️  Processing $slug ($branch)"
  if grep -q "path = vendor/$slug" "$ROOT_DIR/.gitmodules" 2>/dev/null; then
    if ! git submodule update --init "vendor/$slug"; then
      echo "❌ Failed to update $slug" >&2
      continue
    fi
  else
    if git submodule add "$repo" "vendor/$slug"; then
      changes=true
    else
      echo "❌ Failed to clone $slug from $repo" >&2
      git config --remove-section "submodule.vendor/$slug" 2>/dev/null || true
      rm -rf "$target"
      continue
    fi
  fi
  if [ ! -d "$target" ]; then
    echo "⚠️  Missing directory for $slug" >&2
    continue
  fi
  pushd "$target" >/dev/null
  git fetch --tags >/dev/null 2>&1 || true
  git checkout "$branch" >/dev/null 2>&1 || git checkout "$branch" || true
  commit=$(git rev-parse HEAD)
  popd >/dev/null
  APP_INFO[$slug]="$(jq -n --arg repo "$repo" --arg branch "$branch" --arg commit "$commit" '{repo:$repo,branch:$branch,commit:$commit}')"
  # sync instructions
  if [ -d "$target/instructions" ]; then
    mkdir -p "$ROOT_DIR/instructions/_$slug"
    rsync -a --delete "$target/instructions/" "$ROOT_DIR/instructions/_$slug/"
  fi
done

# prune removed vendors
if [ -f "$ROOT_DIR/.gitmodules" ]; then
  while IFS= read -r path; do
    [[ "$path" == vendor/* ]] || continue
    name="$(basename "$path")"
    if [[ -z "${REPOS[$name]+x}" ]]; then
      echo "🗑 Removing obsolete submodule $name"
      git submodule deinit -f "$path" || true
      git rm -f "$path" || true
      rm -rf "$ROOT_DIR/.git/modules/$path" "$VENDOR_DIR/$name"
      changes=true
    fi
  done < <(git config --file "$ROOT_DIR/.gitmodules" --get-regexp path | awk '{print $2}')
fi

for dir in "$VENDOR_DIR"/*; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  if [[ -z "${REPOS[$name]+x}" ]]; then
    echo "🗑 Removing obsolete directory $dir"
    rm -rf "$dir"
    changes=true
  fi
done

# build apps.json
jq_filter='{}'
for slug in "${!APP_INFO[@]}"; do
  jq_filter="$jq_filter | .[\"$slug\"]=${APP_INFO[$slug]}"
  SOURCES+=("vendor/$slug/")
done
jq -n "$jq_filter" > "$ROOT_DIR/apps.json"

# update codex.json
sources=("app/")
for slug in "${!APP_INFO[@]}"; do
  sources+=("vendor/$slug/")
 done
sources+=("instructions/" "sample_data/")
existing_templates="[]"
if [ -f "$CODEX_JSON" ]; then
  existing_templates=$(jq -r 'if (.templates|type=="array") then .templates else [] end' "$CODEX_JSON" 2>/dev/null || echo "[]")
fi
sources_json=$(printf '%s\n' "${sources[@]}" | jq -R '.' | jq -s '.')
jq -n --argjson s "$sources_json" --argjson t "$existing_templates" '{"_comment":"Directories indexed by Codex. Adjust paths as needed.","sources":$s,"templates":$t}' > "$CODEX_JSON"

echo "✅ Vendor repositories updated."
