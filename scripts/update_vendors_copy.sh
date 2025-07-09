#!/bin/bash
# update_vendors_copy.sh: sync vendor directories by copying repository contents (no submodules)
set -euo pipefail

VERBOSE=false
for arg in "$@"; do
  case "$arg" in
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
  esac
done

if $VERBOSE; then
  set -x
fi

trap 'echo "❌ Error on line $LINENO" >&2' ERR

log() {
  if $VERBOSE; then
    echo "[debug] $*"
  fi
}

if ! command -v jq >/dev/null 2>&1; then
  echo "❌ jq is required but not installed. Please install jq and retry." >&2
  exit 1
fi
export GIT_TERMINAL_PROMPT=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VENDOR_DIR="$ROOT_DIR/vendor"
VENDORS_FILE="${VENDORS_FILE:-$ROOT_DIR/vendors.txt}"
PROFILES_DIR="${PROFILES_DIR:-$ROOT_DIR/instructions/vendor_profiles}"

ENV_FILE="$ROOT_DIR/.env"
BENCH_ENV_FILE="$(dirname "$ROOT_DIR")/.env"
if [ ! -f "$BENCH_ENV_FILE" ] && [ -f "$(dirname "$ROOT_DIR")/../.env" ]; then
  BENCH_ENV_FILE="$(dirname "$ROOT_DIR")/../.env"
fi
CONFIG_FILE="$ROOT_DIR/.config/github_api.json"
API_KEY="${API_KEY:-}"
if [ -z "$API_KEY" ] && [ -f "$ENV_FILE" ]; then
  API_KEY=$(grep -E '^API_KEY=' "$ENV_FILE" | cut -d'=' -f2- || true)
fi
if [ -z "$API_KEY" ] && [ -f "$BENCH_ENV_FILE" ]; then
  API_KEY=$(grep -E '^API_KEY=' "$BENCH_ENV_FILE" | cut -d'=' -f2- || true)
fi
if [ -z "$API_KEY" ] && [ -f "$CONFIG_FILE" ]; then
  API_KEY=$(jq -r '.API_KEY // .GITHUB_TOKEN // empty' "$CONFIG_FILE" 2>/dev/null)
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

if [ ! -d "$PROFILES_DIR" ]; then
  if [ -d "$ROOT_DIR/frappe_app_template/instructions/vendor_profiles" ]; then
    PROFILES_DIR="$ROOT_DIR/frappe_app_template/instructions/vendor_profiles"
  elif [ -d "$ROOT_DIR/template/instructions/vendor_profiles" ]; then
    PROFILES_DIR="$ROOT_DIR/template/instructions/vendor_profiles"
  fi
fi

mkdir -p "$VENDOR_DIR"
cd "$ROOT_DIR"

if [ ! -f "$VENDORS_FILE" ]; then
  echo "⚠️  $VENDORS_FILE not found. Skipping vendor update." >&2
  exit 0
fi
readarray -t RAW_LINES < <(grep -v '^#' "$VENDORS_FILE" | sed '/^\s*$/d')
if [ ${#RAW_LINES[@]} -eq 0 ]; then
  echo "ℹ️  No active vendors listed in $VENDORS_FILE"
else
  log "Found ${#RAW_LINES[@]} vendor entries"
fi

declare -A REPOS
declare -A BRANCHES
declare -A TAGS
declare -A APP_INFO
declare -A PATHS
declare -A KEEP
declare -A PROFILE_BASES
declare -A PROFILE_RELPATHS

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
  log "Parsing line: $line"
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
    profile_file=$(find "$PROFILES_DIR" -path "*/$slug/apps.json" -print -quit 2>/dev/null || true)
    profile_base="$PROFILES_DIR"
    if [[ -z "$profile_file" && -d "$SCRIPT_DIR/../vendor_profiles" ]]; then
      profile_base="$SCRIPT_DIR/../vendor_profiles"
      profile_file=$(find "$profile_base" -path "*/$slug/apps.json" -print -quit 2>/dev/null || true)
    fi
    if [[ -n "$profile_file" ]]; then
      repo=$(jq -r '.url // empty' "$profile_file" 2>/dev/null)
      branch=$(jq -r '.branch // empty' "$profile_file" 2>/dev/null)
      tag=$(jq -r '.tag // empty' "$profile_file" 2>/dev/null)
      profile_dir="$(dirname "$profile_file")"
      relpath="${profile_dir#$profile_base/}"
      PROFILE_BASES[$slug]="$profile_base"
      PROFILE_RELPATHS[$slug]="$relpath"
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
    log "Vendor $slug -> repo=$repo branch=$branch tag=$tag path=$path"
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
  log "Using repository URL: $auth_repo"
  rm -rf "$target"
  clone_args=("--depth" "1")
  if [[ -n "$branch" ]]; then
    clone_args+=("--branch" "$branch")
  elif [[ -n "$tag" ]]; then
    clone_args+=("--branch" "$tag")
  fi
  if git clone "${clone_args[@]}" "$auth_repo" "$target" >/dev/null 2>&1; then
    installed+=("$slug")
    changes=true
  else
    echo "❌ Failed to clone $slug from $repo" >&2
    continue
  fi
  commit=$(git -C "$target" rev-parse HEAD)
  rm -rf "$target/.git"
  updated+=("$slug")

  APP_INFO[$slug]="$(jq -n --arg repo "$repo" --arg branch "$branch" --arg tag "$tag" --arg commit "$commit" '{repo:$repo,branch:$branch,tag:$tag,commit:$commit}')"
  if [ -d "$target/instructions" ]; then
    mkdir -p "$ROOT_DIR/instructions/_$slug"
    rsync -a --delete "$target/instructions/" "$ROOT_DIR/instructions/_$slug/"
  fi
  profile_base="${PROFILE_BASES[$slug]-}"
  profile_rel="${PROFILE_RELPATHS[$slug]-}"
  if [[ -n "$profile_base" && -n "$profile_rel" ]]; then
    src="$profile_base/$profile_rel"
    if [ -d "$src" ]; then
      top_dest="$ROOT_DIR/instructions/$slug"
      mkdir -p "$top_dest"
      rsync -a --delete "$src/" "$top_dest/"
    fi
  fi
done

recognized_paths=()
for slug in "${recognized[@]}"; do
  recognized_paths+=("${PATHS[$slug]}")
done

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

for dir in "$ROOT_DIR/instructions"/*; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  [[ "$name" == _* ]] && continue
  if [[ "$name" == "vendor_profiles" ]]; then
    echo "🗑 Removing obsolete directory $dir"
    rm -rf "$dir"
    changes=true
    continue
  fi
  keep=false
  for slug in "${recognized[@]}"; do
    if [[ "$name" == "$slug" ]]; then
      keep=true
      break
    fi
  done
  if ! $keep; then
    echo "🗑 Removing obsolete instructions $dir"
    rm -rf "$dir"
    changes=true
  fi
done

jq_filter='{}'
for slug in "${recognized[@]}"; do
  jq_filter="$jq_filter | .[\"$slug\"]=${APP_INFO[$slug]}"
done
jq -n "$jq_filter" > "$ROOT_DIR/apps.json"

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
if [ -n "$summary" ]; then
  echo "$summary"
else
  echo "No vendors processed"
fi
log "Changes flag: $changes"

