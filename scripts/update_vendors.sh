#!/bin/bash
set -euo pipefail
export GIT_TERMINAL_PROMPT=0

# Detect whether we are running from the template repository itself
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
in_template_repo=false
if [[ "$(basename "$repo_root")" == "frappe_app_template" ]]; then
  in_template_repo=true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VENDOR_DIR="$ROOT_DIR/vendor"
VENDORS_FILE="${VENDORS_FILE:-$ROOT_DIR/vendors.txt}"
PROFILES_DIR="${PROFILES_DIR:-$ROOT_DIR/vendor_profiles}"
CODEX_JSON="$ROOT_DIR/codex.json"

mkdir -p "$VENDOR_DIR"
cd "$ROOT_DIR"

# ensure frappe_app_template submodule exists and is up to date
TEMPLATE_DIR="$ROOT_DIR/frappe_app_template"
TEMPLATE_URL="${TEMPLATE_URL:-https://github.com/seclution/frappe_app_template}"

check_template() {
  if grep -q "path = $(basename "$TEMPLATE_DIR")" "$ROOT_DIR/.gitmodules" 2>/dev/null; then
    git submodule update --init "$TEMPLATE_DIR" >/dev/null 2>&1 || true
  fi

  if [ ! -d "$TEMPLATE_DIR/.git" ]; then
    if [[ "${GIT_ALLOW_PROTOCOL:-https}" != *"https"* ]]; then
      echo "⚠️  Template missing and HTTPS disallowed. Skipping clone." >&2
      return
    fi
    echo "➕ Adding template submodule" >&2
    git submodule add "$TEMPLATE_URL" "$TEMPLATE_DIR" || return
    git submodule update --init "$TEMPLATE_DIR" >/dev/null 2>&1 || true
  else
    if [[ "${GIT_ALLOW_PROTOCOL:-https}" == *"https"* ]]; then
      pushd "$TEMPLATE_DIR" >/dev/null
      git fetch origin >/dev/null 2>&1 || true
      local_head=$(git rev-parse HEAD)
      remote_head=$(git rev-parse origin/HEAD 2>/dev/null || git rev-parse origin/master 2>/dev/null || echo "")
      popd >/dev/null
      if [ -n "$remote_head" ] && [ "$local_head" != "$remote_head" ]; then
        echo "⬆️  Updating template submodule" >&2
        git submodule update --remote "$TEMPLATE_DIR" >/dev/null 2>&1 || true
      fi
    fi
  fi
}

if [ "$in_template_repo" = false ]; then
  check_template
fi

# read vendors list
readarray -t RAW_LINES < <(grep -v '^#' "$VENDORS_FILE" 2>/dev/null | sed '/^\s*$/d')

# load integration profiles and manual entries
declare -A REPOS
declare -A BRANCHES
# track vendor slugs
recognized=()
installed=()
updated=()
removed=()
for line in "${RAW_LINES[@]}"; do
  IFS='|' read -r part1 part2 part3 <<< "$line"
  slug=""
  repo=""
  branch=""
  if [[ -n "$part3" ]]; then
    slug="$part1"
    repo="$part2"
    branch="$part3"
  elif [[ -n "$part2" ]]; then
    if [[ "$part1" =~ ^(https?|file):// || "$part1" =~ ^git@ ]]; then
      slug="$(basename "$part1" .git)"
      repo="$part1"
      branch="$part2"
    else
      slug="$part1"
      repo="$part2"
    fi
  else
    slug="$part1"
    profile_file=$(find "$PROFILES_DIR" -name "$slug.json" -print -quit 2>/dev/null || true)
    if [[ -n "$profile_file" ]]; then
      repo=$(jq -r '.url // empty' "$profile_file" 2>/dev/null)
      branch=$(jq -r '.branch // .tag // ""' "$profile_file" 2>/dev/null)
    fi
  fi
  if [[ -n "$repo" ]]; then
    REPOS[$slug]="$repo"
    BRANCHES[$slug]="$branch"
    recognized+=("$slug")
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
    updated+=("$slug")
  else
    if git submodule add "$repo" "vendor/$slug"; then
      changes=true
      installed+=("$slug")
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
      git submodule deinit -f "$path" 2>/dev/null || true
      if [[ -e "$path" ]]; then
        git rm -f "$path" 2>/dev/null || true
      fi
      rm -rf "$ROOT_DIR/.git/modules/$path" "$VENDOR_DIR/$name"
      removed+=("$name")
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
    removed+=("$name")
    changes=true
  fi
done

# build apps.json
jq_filter='{}'
for slug in "${!APP_INFO[@]}"; do
  jq_filter="$jq_filter | .[\"$slug\"]=${APP_INFO[$slug]}"
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

summary_parts=()
if [ ${#installed[@]} -gt 0 ]; then
  summary_parts+=("Installed: ${installed[*]}")
fi
if [ ${#updated[@]} -gt 0 ]; then
  summary_parts+=("Updated: ${updated[*]}")
fi
if [ ${#removed[@]} -gt 0 ]; then
  summary_parts+=("Removed: ${removed[*]}")
fi
if [ ${#recognized[@]} -gt 0 ]; then
  summary_parts+=("Recognized: ${recognized[*]}")
fi
summary="$(IFS=' | '; echo "${summary_parts[*]}")"
echo "$summary"
