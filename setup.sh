#!/bin/bash
set -euo pipefail

VERBOSE=0
DEFAULT_BRANCH="develop"
AUTOGEN_CREDS=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    --autogencreds)
      AUTOGEN_CREDS=1
      shift
      ;;
    *)
      APP_NAME="${APP_NAME:-$1}"
      shift
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BENCH_DIR="$(pwd)"
WORKFLOW_TEMPLATE_DIR="$SCRIPT_DIR/workflow_templates"
APP_NAME="${APP_NAME:-}"
if [ -z "$APP_NAME" ]; then
  APP_NAME="$(basename "$BENCH_DIR")"
fi
APP_TITLE="$(tr _- ' ' <<< "$APP_NAME" | sed 's/\b\(\.\)/\u\1/g')"

APP_FOLDER="$APP_NAME"
CONFIG_TARGET="apps/$APP_FOLDER"

BENCH_ENV_FILE="$BENCH_DIR/.env"
APP_ENV_FILE=""

get_env_val() {
  local key="$1"
  local file="$2"
  grep -E "^$key=" "$file" 2>/dev/null | cut -d'=' -f2- || true
}
set_env_val() {
  local key="$1"
  local val="$2"
  local file="$3"
  grep -v "^$key=" "$file" > "$file.tmp" 2>/dev/null || true
  echo "$key=$val" >> "$file.tmp"
  mv "$file.tmp" "$file"
  chmod 600 "$file"
  vlog "$key set in $(basename "$file")"
}
set_bench_val() {
  set_env_val "$1" "$2" "$BENCH_ENV_FILE"
}
set_app_val() {
  set_env_val "$1" "$2" "$APP_ENV_FILE"
}
get_bench_val() {
  get_env_val "$1" "$BENCH_ENV_FILE"
}
get_app_val() {
  get_env_val "$1" "$APP_ENV_FILE"
}

unset_bench_val() {
  local key="$1"
  grep -v "^$key=" "$BENCH_ENV_FILE" > "$BENCH_ENV_FILE.tmp" 2>/dev/null || true
  mv "$BENCH_ENV_FILE.tmp" "$BENCH_ENV_FILE"
  chmod 600 "$BENCH_ENV_FILE"
}

migrate_repo_env_values() {
  for key in REPO_NAME REPO_PATH SSH_KEY_PATH DEPLOY_KEY_ADDED; do
    local val
    val=$(get_bench_val "$key")
    if [ -n "$val" ]; then
      set_app_val "$key" "$val"
      unset_bench_val "$key"
    fi
  done
}

log() {
  echo "$1"
}
vlog() {
  if [ "$VERBOSE" -eq 1 ]; then echo "   ⮑ $1"; fi
}

log "Checking requirements..."
if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed. Please install jq and retry." >&2
  exit 1
fi

toplevel=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ -n "$toplevel" && "$toplevel" == */frappe_app_template ]]; then
  echo "ERROR: Do not run this inside the frappe_app_template submodule."
  exit 1
fi

ALT_NAME="${APP_NAME//-/_}"
if [ -d "apps/$APP_NAME" ] || [ -d "apps/$ALT_NAME" ]; then
  log "ERROR: App directory already exists for $APP_NAME. Aborting to avoid overwrite."
  exit 1
fi

log "Creating new Frappe app: $APP_NAME"
bench new-app "$APP_NAME" <<EOF
$APP_TITLE
Auto-generated app $APP_NAME
Seclution
dev@seclution.io
mit
n
EOF

  # Versuche den tatsächlichen App-Ordner zu erkennen
  ALT_NAME="${APP_NAME//-/_}"
  if [ -d "apps/$APP_NAME" ]; then
    CONFIG_TARGET="apps/$APP_NAME"
  elif [ -d "apps/$ALT_NAME" ]; then
    CONFIG_TARGET="apps/$ALT_NAME"
    APP_NAME="$ALT_NAME"
  else
    echo "App directory not found at apps/$APP_NAME or apps/$ALT_NAME. Aborting."
    exit 1
  fi

log "App directory detected: $CONFIG_TARGET"

mkdir -p "$CONFIG_TARGET"
[ -f "$BENCH_ENV_FILE" ] || touch "$BENCH_ENV_FILE"
chmod 600 "$BENCH_ENV_FILE"
APP_ENV_FILE="$CONFIG_TARGET/.env"
[ -f "$APP_ENV_FILE" ] || touch "$APP_ENV_FILE"
chmod 600 "$APP_ENV_FILE"

migrate_repo_env_values


env_api_key="${API_KEY:-}"
API_KEY=$(get_bench_val "API_KEY")
GITHUB_USER=$(get_bench_val "GITHUB_USER")
REPO_NAME=$(get_app_val "REPO_NAME")
REPO_PATH=$(get_app_val "REPO_PATH")

# always align repository name with the app name to avoid leftovers from
# previous runs
REPO_NAME="$APP_NAME"
set_app_val "REPO_NAME" "$REPO_NAME"
if [ -n "$GITHUB_USER" ]; then
  REPO_PATH="github.com:$GITHUB_USER/$REPO_NAME.git"
  set_app_val "REPO_PATH" "$REPO_PATH"
fi

if [ -z "$API_KEY" ] && [ -n "$env_api_key" ]; then
  API_KEY="$env_api_key"
  set_bench_val "API_KEY" "$API_KEY"
fi

  if [ $AUTOGEN_CREDS -eq 1 ]; then
    if [ -z "$API_KEY" ] || ! [[ "$API_KEY" =~ ^[A-Za-z0-9._-]{20,}$ ]]; then
      read -p "GitHub API key: " API_KEY
      set_bench_val "API_KEY" "$API_KEY"
    fi

    if [ -z "$GITHUB_USER" ]; then
      read -p "GitHub username or org (target owner): " GITHUB_USER
      set_bench_val "GITHUB_USER" "$GITHUB_USER"
    fi

    # ensure repo path matches the chosen owner and repo name
    REPO_PATH="github.com:$GITHUB_USER/$REPO_NAME.git"
    set_app_val "REPO_PATH" "$REPO_PATH"
  fi

SSH_KEY_PATH="$HOME/.ssh/id_deploy_$REPO_NAME"
SSH_PUBKEY_PATH="$SSH_KEY_PATH.pub"
REMOTE_ALIAS="github.com-$REPO_NAME"
REMOTE_URL="$REMOTE_ALIAS:$GITHUB_USER/$REPO_NAME.git"

if [ ! -f "$SSH_PUBKEY_PATH" ]; then
  log "Generating SSH key for $REPO_NAME..."
  ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N "" -C "$REPO_NAME@frappe-auto" >/dev/null
  ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null || true
fi

set_app_val "SSH_KEY_PATH" "$SSH_KEY_PATH"

try_create_repo() {
  local key="$1"
  local api_url="https://api.github.com/user/repos"
  local fallback_url="https://api.github.com/orgs/$GITHUB_USER/repos"

  log "Attempting to create GitHub repo '$REPO_NAME' under user '$GITHUB_USER'..."
  response=$(curl -s -w "%{http_code}" -o response.json \
    -H "Authorization: token $key" \
    -d "{\"name\":\"$REPO_NAME\", \"private\": true}" \
    "$api_url")

  status_code="${response: -3}"
  body=$(<response.json)

  if [[ "$status_code" == "201" ]]; then
    log "Repo successfully created: $REMOTE_URL"
    rm -f response.json
    return 0
  elif [[ "$status_code" == "404" ]]; then
    log "User endpoint returned 404. Trying org endpoint..."
    response=$(curl -s -w "%{http_code}" -o response.json \
      -H "Authorization: token $key" \
      -d "{\"name\":\"$REPO_NAME\", \"private\": true}" \
      "$fallback_url")
    status_code="${response: -3}"
    body=$(<response.json)
  fi

  rm -f response.json

  if [[ "$status_code" == "201" ]]; then
    log "Repo successfully created in org: $REMOTE_URL"
    return 0
  elif [[ "$status_code" == "422" && "$body" == *"name already exists"* ]]; then
    log "Repository already exists: $REMOTE_URL"
    read -p "Do you want to push your local app to this existing repo? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      return 0
    else
      log "Skipping push to existing repository."
      REMOTE_URL=""
      return 1
    fi
  else
    message=$(echo "$body" | jq -r '.message // empty')
    log "GitHub repo creation failed (HTTP $status_code)"
    [ -n "$message" ] && echo "   ⮑ $message"
    REMOTE_URL=""
    return 1
  fi
}

add_deploy_key() {
  local pubkey=$(<"$SSH_PUBKEY_PATH")

  if [[ -z "$pubkey" ]]; then
    log "Error reading public SSH key"
    return 1
  fi

  log "Uploading public key as GitHub Deploy Key..."
  local data
  data=$(jq -nc --arg title "auto-deploy-key-$(date +%s)" --arg key "$pubkey" '{"title":$title,"key":$key,"read_only":false}')
  response=$(curl -s -w "%{http_code}" -o response.json \
    -H "Authorization: token $API_KEY" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "$data" \
    "https://api.github.com/repos/$GITHUB_USER/$REPO_NAME/keys")

  status_code="${response: -3}"
  body=$(<response.json)
  rm -f response.json

  if [[ "$status_code" == "201" ]]; then
    log "Deploy key successfully added to $REPO_NAME"
    set_app_val "DEPLOY_KEY_ADDED" "1"
  elif [[ "$status_code" == "422" && "$body" == *"key is already in use"* ]]; then
    log "Deploy key already exists."
    set_app_val "DEPLOY_KEY_ADDED" "1"
  else
    message=$(echo "$body" | jq -r '.message // empty')
    log "Failed to add Deploy Key (HTTP $status_code)"
    [ -n "$message" ] && echo "   ⮑ $message"
  fi
}

configure_ssh_for_repo() {
  local ssh_config="$HOME/.ssh/config"
  local alias="github.com-$REPO_NAME"

  mkdir -p "$HOME/.ssh"
  touch "$ssh_config"
  chmod 600 "$ssh_config"

  if ! grep -q "Host $alias" "$ssh_config"; then
    {
      echo "Host $alias"
      echo "  HostName github.com"
      echo "  User git"
      echo "  IdentityFile $SSH_KEY_PATH"
      echo "  IdentitiesOnly yes"
    } >> "$ssh_config"
    log "SSH config entry added for Host $alias"
  fi

  REMOTE_URL="$alias:$GITHUB_USER/$REPO_NAME.git"
}

  if try_create_repo "$API_KEY"; then
  DEPLOY_KEY_ADDED=$(get_app_val "DEPLOY_KEY_ADDED")
  if [ "$AUTOGEN_CREDS" -eq 1 ] && [ "$DEPLOY_KEY_ADDED" != "1" ]; then
    add_deploy_key
  fi
else
  log "GitHub repo not available – continuing without push or Deploy Key."
  REMOTE_URL=""
fi

configure_ssh_for_repo

log "Creating standard files & folders..."

mkdir -p "$CONFIG_TARGET/.github/workflows"
mkdir -p "$CONFIG_TARGET/scripts"
mkdir -p "$CONFIG_TARGET/sample_data"
mkdir -p "$CONFIG_TARGET/vendor"
mkdir -p "$CONFIG_TARGET/instructions"
mkdir -p "$CONFIG_TARGET/doc"
mkdir -p "$CONFIG_TARGET/.config"

touch "$CONFIG_TARGET/.config/github_api.json"
touch "$CONFIG_TARGET/apps.json"
touch "$CONFIG_TARGET/custom_vendors.json"
touch "$CONFIG_TARGET/vendors.txt"
touch "$CONFIG_TARGET/.pre-commit-config.yaml"
touch "$CONFIG_TARGET/README.md"
touch "$CONFIG_TARGET/AGENTS.md"
touch "$CONFIG_TARGET/instructions/AGENTS.md"
touch "$CONFIG_TARGET/license.txt"
touch "$CONFIG_TARGET/pyproject.toml"
touch "$CONFIG_TARGET/.gitignore"


# Submodul einbinden
if [ ! -d "$CONFIG_TARGET/frappe_app_template/.git" ]; then
  git -C "$CONFIG_TARGET" submodule add https://github.com/Freddyslim/frappe_app_template frappe_app_template || true
  log "Submodule hinzugefügt: frappe_app_template"
fi

# 🔁 vendors.txt aus Template kopieren
if [ -f "$CONFIG_TARGET/frappe_app_template/vendors.txt" ]; then
  cp "$CONFIG_TARGET/frappe_app_template/vendors.txt" "$CONFIG_TARGET/vendors.txt"
  log "vendors.txt aus frappe_app_template kopiert"
else
  log "⚠️ Keine vendors.txt in frappe_app_template gefunden"
fi

# 🔁 .gitignore aus Template kopieren
if [ -f "$CONFIG_TARGET/frappe_app_template/.gitignore" ]; then
  cp "$CONFIG_TARGET/frappe_app_template/.gitignore" "$CONFIG_TARGET/.gitignore"
  log ".gitignore aus frappe_app_template kopiert"
else
  log "⚠️ Keine .gitignore in frappe_app_template gefunden"
fi

for wf in "$WORKFLOW_TEMPLATE_DIR"/*.yml; do
  [ -f "$wf" ] && cp "$wf" "$CONFIG_TARGET/.github/workflows/"
done

cp -n "$SCRIPT_DIR/scripts/"*.sh "$CONFIG_TARGET/scripts/" 2>/dev/null || true
chmod +x "$CONFIG_TARGET/scripts/"*.sh 2>/dev/null || true

log "Initializing Git repo..."
cd "$CONFIG_TARGET"
if [ ! -d .git ]; then
  git init
  git checkout -b "$DEFAULT_BRANCH"
  git add .
  git commit -m "Initial commit for $APP_NAME"
else
  log "Existing .git directory detected – skipping init."
fi

if [ -n "${REMOTE_URL:-}" ]; then
  git remote remove origin 2>/dev/null || true
  git remote add origin "$REMOTE_URL"
log "Remote 'origin' set to $REMOTE_URL"
else
  log "No remote URL set – skipping remote setup."
fi

# run vendor update before optional initial push
if [ -x "./scripts/update_vendors.sh" ]; then
  log "Running update_vendors.sh to fetch vendor apps..."
  ./scripts/update_vendors.sh
  git add .gitmodules apps.json vendors.txt 2>/dev/null || true
  if [ -d vendor ]; then
    git add vendor
  fi
  if [ -d instructions ]; then
    git add instructions
  fi
  if git diff --cached --quiet; then
    vlog "No vendor changes to commit"
  else
    git commit -m "chore: update vendor apps"
  fi
else
  log "No update_vendors.sh script found – skipping vendor sync"
fi

if [ -n "${REMOTE_URL:-}" ]; then
  if [ -t 0 ]; then
    read -p "Do you want to push to $REMOTE_URL now? [Y/n]: " do_push
  else
    do_push="n"
  fi
  if [[ "$do_push" =~ ^[Nn]$ ]]; then
    log "Push skipped by user."
  else
    git fetch origin "$DEFAULT_BRANCH" 2>/dev/null || true
    git pull --rebase origin "$DEFAULT_BRANCH" 2>/dev/null || true
    if git push -u origin "$DEFAULT_BRANCH"; then
      log "Initial push to GitHub completed."
    else
      if [ -t 0 ]; then
        read -p "Push failed. Force push? [y/N]: " do_force
      else
        do_force="n"
      fi
      if [[ "$do_force" =~ ^[Yy]$ ]]; then
        if git push --force -u origin "$DEFAULT_BRANCH"; then
          log "Force push succeeded."
        else
          log "Force push failed."
        fi
      else
        log "Initial push to GitHub failed."
      fi
    fi
  fi
else
  log "No remote to push to – push skipped."
fi

log "Setup complete for $APP_NAME"
