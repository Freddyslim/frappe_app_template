#!/bin/bash
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "❌ jq is required but not installed. Please install jq and retry." >&2
  exit 1
fi
export GIT_TERMINAL_PROMPT=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VENDOR_DIR="$ROOT_DIR/vendor"
VENDORS_FILE="${VENDORS_FILE:-$ROOT_DIR/vendors.txt}"
PROFILES_DIR="${PROFILES_DIR:-$ROOT_DIR/vendor_profiles}"

# load API key from .env if present
ENV_FILE="$ROOT_DIR/.env"
API_KEY="${API_KEY:-}"
if [ -z "$API_KEY" ] && [ -f "$ENV_FILE" ]; then
  API_KEY=$(grep -E '^API_KEY=' "$ENV_FILE" | cut -d'=' -f2-)
fi
GITHUB_TOKEN="${GITHUB_TOKEN:-$API_KEY}"

with_auth_repo() {
  local url="$1"
  if [ -n "$GITHUB_TOKEN" ]; then
    if [[ "$url" =~ ^https://github.com/ ]]; then
      echo "https://${GITHUB_TOKEN}@github.com/${url#https://github.com/}"
      return
    elif [[ "$url" =~ ^git@github.com: ]]; then
      echo "https://${GITHUB_TOKEN}@github.com/${url#git@github.com:}"
      return
    fi
  fi
  echo "$url"
}

# fallback to template-provided profiles when none exist in the project
if [ ! -d "$PROFILES_DIR" ]; then
  if [ -d "$ROOT_DIR/frappe_app_template/vendor_profiles" ]; then
    PROFILES_DIR="$ROOT_DIR/frappe_app_template/vendor_profiles"
  elif [ -d "$ROOT_DIR/template/vendor_profiles" ]; then
    PROFILES_DIR="$ROOT_DIR/template/vendor_profiles"
  fi
fi

mkdir -p "$VENDOR_DIR"
cd "$ROOT_DIR"

# read vendors list
readarray -t RAW_LINES < <(grep -v '^#' "$VENDORS_FILE" 2>/dev/null | sed '/^\s*$/d')

# integration data
declare -A REPOS
declare -A BRANCHES
declare -A TAGS
declare -A APP_INFO
declare -A PATHS
declare -A KEEP

recognized=()
installed=()
updated=()
removed=()

for line in "${RAW_LINES[@]}"; do
  IFS='|' read -r part1 part2 part3 part4 <<< "$line"
  slug=""
  repo=""
  branch=""
  tag=""
  if [[ -n "$part4" ]]; then
    slug="$part1"
    repo="$part2"
    branch="$part3"
    tag="$part4"
  elif [[ -n "$part3" ]]; then
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
    if [[ -z "$profile_file" && -d "$SCRIPT_DIR/../vendor_profiles" ]]; then
      profile_file=$(find "$SCRIPT_DIR/../vendor_profiles" -name "$slug.json" -print -quit 2>/dev/null || true)
    fi
    if [[ -n "$profile_file" ]]; then
      repo=$(jq -r '.url // empty' "$profile_file" 2>/dev/null)
      branch=$(jq -r '.branch // empty' "$profile_file" 2>/dev/null)
      tag=$(jq -r '.tag // empty' "$profile_file" 2>/dev/null)
    fi
  fi

  if [[ -n "$repo" ]]; then
    REPOS[$slug]="$repo"
    BRANCHES[$slug]="$branch"
    TAGS[$slug]="$tag"
    ref="${branch:-$tag}"
    sanitized=${ref//\//_}
    path="vendor/${slug}${ref:+-$sanitized}"
    PATHS[$slug]="$path"
    KEEP[$slug]=1
  else
    echo "⚠️  Unknown vendor: $slug" >&2
  fi
done

CUSTOM_VENDORS="$ROOT_DIR/custom_vendors.json"
if [ -f "$CUSTOM_VENDORS" ]; then
  while IFS= read -r slug; do
    repo=$(jq -r ".\"$slug\".repo // empty" "$CUSTOM_VENDORS")
    branch=$(jq -r ".\"$slug\".branch // empty" "$CUSTOM_VENDORS")
    tag=$(jq -r ".\"$slug\".tag // empty" "$CUSTOM_VENDORS")
    if [[ -n "$repo" ]]; then
      REPOS[$slug]="$repo"
      BRANCHES[$slug]="$branch"
      TAGS[$slug]="$tag"
      ref="${branch:-$tag}"
      sanitized=${ref//\//_}
      path="vendor/${slug}${ref:+-$sanitized}"
      PATHS[$slug]="$path"
      KEEP[$slug]=1
    fi
  done < <(jq -r 'keys[]' "$CUSTOM_VENDORS" 2>/dev/null)
fi

# merge existing apps.json entries
if [ -f "$ROOT_DIR/apps.json" ]; then
  while IFS= read -r slug; do
    repo=$(jq -r ".\"$slug\".repo // empty" "$ROOT_DIR/apps.json")
    branch=$(jq -r ".\"$slug\".branch // empty" "$ROOT_DIR/apps.json")
    tag=$(jq -r ".\"$slug\".tag // empty" "$ROOT_DIR/apps.json")
    commit=$(jq -r ".\"$slug\".commit // empty" "$ROOT_DIR/apps.json")
    ref="${branch:-$tag}"
    sanitized=${ref//\//_}
    path="vendor/${slug}${ref:+-$sanitized}"
    PATHS[$slug]="$path"
    if [[ -n "${KEEP[$slug]:-}" ]]; then
      REPOS[$slug]="$repo"
      BRANCHES[$slug]="$branch"
      TAGS[$slug]="$tag"
      APP_INFO[$slug]="$(jq -n --arg repo "$repo" --arg branch "$branch" --arg tag "$tag" --arg commit "$commit" '{repo:$repo,branch:$branch,tag:$tag,commit:$commit}')"
    fi
  done < <(jq -r 'keys[]' "$ROOT_DIR/apps.json" 2>/dev/null)
fi

recognized=("${!KEEP[@]}")

changes=false

  for slug in "${recognized[@]}"; do
    repo="${REPOS[$slug]}"
    branch="${BRANCHES[$slug]}"
    tag="${TAGS[$slug]}"
    path="${PATHS[$slug]}"
    target="$ROOT_DIR/$path"
    ref="${branch:-$tag}"
    echo "➡️  Processing $slug ($ref)"
  auth_repo=$(with_auth_repo "$repo")
  if grep -q "path = $path" "$ROOT_DIR/.gitmodules" 2>/dev/null; then
    if git ls-files "$path" --error-unmatch >/dev/null 2>&1; then
      if [ -n "$GITHUB_TOKEN" ]; then
        git -C "$path" remote set-url origin "$auth_repo" || true
      fi
      if ! git submodule update --init "$path"; then
        echo "❌ Failed to update $slug" >&2
        if [ -n "$GITHUB_TOKEN" ]; then
          git -C "$path" remote set-url origin "$repo" || true
        fi
        continue
      fi
      pushd "$target" >/dev/null
      if [[ -n "$branch" ]]; then
        git fetch origin "$branch" --tags >/dev/null 2>&1 || git fetch --tags >/dev/null 2>&1 || true
        git checkout "$branch" >/dev/null 2>&1 || git checkout "origin/$branch" >/dev/null 2>&1 || true
      elif [[ -n "$tag" ]]; then
        git fetch origin "tag" "$tag" >/dev/null 2>&1 || git fetch --tags >/dev/null 2>&1 || true
        git checkout "tags/$tag" >/dev/null 2>&1 || git checkout "$tag" >/dev/null 2>&1 || true
      fi
      commit=$(git rev-parse HEAD)
      popd >/dev/null
      if [ -n "$GITHUB_TOKEN" ]; then
        git -C "$path" remote set-url origin "$repo" || true
      fi
      if [ ! -d "$target" ]; then
        echo "⚠️  Missing directory for $slug" >&2
        continue
      fi
      updated+=("$slug")
    else
      echo "📁 Submodule $path not registered in index – re-adding $slug"
      git submodule add -f "$auth_repo" "$path"
      git config -f .gitmodules "submodule.$path.url" "$repo"
      git config "submodule.$path.url" "$repo"
      installed+=("$slug")
      changes=true
    fi
  else
    if git submodule add -f "$auth_repo" "$path"; then
      git config -f .gitmodules "submodule.$path.url" "$repo"
      git config "submodule.$path.url" "$repo"
      pushd "$target" >/dev/null
      if [[ -n "$branch" ]]; then
        git fetch origin "$branch" --tags >/dev/null 2>&1 || git fetch --tags >/dev/null 2>&1 || true
        git checkout "$branch" >/dev/null 2>&1 || git checkout "origin/$branch" >/dev/null 2>&1 || true
      elif [[ -n "$tag" ]]; then
        git fetch origin "tag" "$tag" >/dev/null 2>&1 || git fetch --tags >/dev/null 2>&1 || true
        git checkout "tags/$tag" >/dev/null 2>&1 || git checkout "$tag" >/dev/null 2>&1 || true
      fi
      commit=$(git rev-parse HEAD)
      popd >/dev/null
      if [ -n "$GITHUB_TOKEN" ]; then
        git -C "$path" remote set-url origin "$repo" || true
      fi
      if [ ! -d "$target" ]; then
        echo "⚠️  Missing directory for $slug" >&2
        continue
      fi
      changes=true
      installed+=("$slug")
    else
      echo "❌ Failed to clone $slug from $repo" >&2
      git config --remove-section "submodule.$path" 2>/dev/null || true
      rm -rf "$target"
      continue
    fi
  fi
  APP_INFO[$slug]="$(jq -n --arg repo "$repo" --arg branch "$branch" --arg tag "$tag" --arg commit "$commit" '{repo:$repo,branch:$branch,tag:$tag,commit:$commit}')"
  if [ -d "$target/instructions" ]; then
    mkdir -p "$ROOT_DIR/instructions/_$slug"
    rsync -a --delete "$target/instructions/" "$ROOT_DIR/instructions/_$slug/"
  fi
done

recognized_paths=()
for slug in "${recognized[@]}"; do
  recognized_paths+=("${PATHS[$slug]}")
done

if [ -f "$ROOT_DIR/.gitmodules" ]; then
  while IFS= read -r path; do
    [[ "$path" == vendor/* ]] || continue
    keep=false
    for rp in "${recognized_paths[@]}"; do
      if [[ "$path" == "$rp" ]]; then
        keep=true
        break
      fi
    done
    if ! $keep; then
      echo "🗑 Removing obsolete submodule $path"
      git submodule deinit -f "$path" 2>/dev/null || true
      if [[ -e "$path" ]]; then
        git rm -f "$path" 2>/dev/null || true
      fi
      rm -rf "$ROOT_DIR/.git/modules/$path" "$ROOT_DIR/$path"
      removed+=("$(basename "$path")")
      changes=true
    fi
  done < <(git config --file "$ROOT_DIR/.gitmodules" --get-regexp path | awk '{print $2}')
fi

for dir in "$VENDOR_DIR"/*; do
  [ -d "$dir" ] || continue
  keep=false
  for rp in "${recognized_paths[@]}"; do
    if [[ "$dir" == "$ROOT_DIR/$rp" ]]; then
      keep=true
      break
    fi
  done
  if ! $keep; then
    echo "🗑 Removing obsolete directory $dir"
    rm -rf "$dir"
    removed+=("$(basename "$dir")")
    changes=true
  fi
done

jq_filter='{}'
for slug in "${recognized[@]}"; do
  jq_filter="$jq_filter | .[\"$slug\"]=${APP_INFO[$slug]}"
done
jq -n "$jq_filter" > "$ROOT_DIR/apps.json"


# rebuild documentation index after vendor changes
python3 "$SCRIPT_DIR/generate_index.py"

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
