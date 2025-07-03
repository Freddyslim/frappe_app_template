#!/bin/bash
set -euo pipefail

VERBOSE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    *)
      APP_NAME="${APP_NAME:-$1}"
      shift
      ;;
  esac
done

if [ "$VERBOSE" -eq 1 ]; then
  echo "🔎 Verbose mode enabled"
  set -x
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "❌ jq is required but not installed. Please install jq and retry." >&2
  exit 1
fi

# Prevent execution inside the frappe_app_template submodule
# `git rev-parse` fails when the current directory isn't a git repo. We don't
# want the script to exit silently because of `set -e`, so ignore the error.
toplevel=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ -n "$toplevel" && "$toplevel" == *"/frappe_app_template" ]]; then
  echo "⛔ ERROR: You are inside the frappe_app_template submodule."
  echo "💡 Please run this script from the root of your app repository, not from inside the template."
  exit 1
fi

# Determine directories
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BENCH_DIR="$(pwd)"
WORKFLOW_TEMPLATE_DIR="$SCRIPT_DIR/workflow_templates"

# Default to bench root for configuration
CONFIG_TARGET="$BENCH_DIR"

# Ensure .gitmodules exists so that workflows using submodules don't fail
if [ ! -f "$CONFIG_TARGET/.gitmodules" ]; then
    git submodule init 2>/dev/null || touch "$CONFIG_TARGET/.gitmodules"
fi

# Setup .env file and GitHub API key
ENV_FILE="$CONFIG_TARGET/.env"
if [ ! -f "$ENV_FILE" ]; then
    [ "$VERBOSE" -eq 1 ] && echo "Create $ENV_FILE"
    touch "$ENV_FILE"
fi

existing_key=$(grep -E '^API_KEY=' "$ENV_FILE" | cut -d'=' -f2- || true)
if [[ -z "$existing_key" || ! "$existing_key" =~ ^[A-Za-z0-9._-]{20,}$ ]]; then
    user_key="${API_KEY:-}"
    if [ -z "$user_key" ] && [ -t 0 ]; then
        read -p "Enter GitHub API key (leave blank to skip): " user_key
    fi
    if [ -n "$user_key" ]; then
        grep -v '^API_KEY=' "$ENV_FILE" > "$ENV_FILE.tmp" 2>/dev/null || true
        echo "API_KEY=$user_key" >> "$ENV_FILE.tmp"
        mv "$ENV_FILE.tmp" "$ENV_FILE"
        echo "🔐 API key stored in $ENV_FILE"
    else
        echo "ℹ️  No API key provided. Add it manually to $ENV_FILE if needed."
    fi
fi

# Determine app name if not already set via arguments
if [ -z "${APP_NAME:-}" ]; then
    echo "Usage: $0 <app_name>"
    exit 1
fi

# Ensure app skeleton exists (matching bench new-app)
echo "ℹ️  Creating app via bench new-app"
[ "$VERBOSE" -eq 1 ] && echo "Running: bench new-app $APP_NAME"

bench new-app "$APP_NAME"
APP_DIR="$BENCH_DIR/apps/$APP_NAME"
[ "$VERBOSE" -eq 1 ] && echo "App directory: $APP_DIR"

# After app creation use APP_DIR as config target
CONFIG_TARGET="$APP_DIR"
if [ ! -f "$CONFIG_TARGET/.gitmodules" ]; then
    git submodule init 2>/dev/null || touch "$CONFIG_TARGET/.gitmodules"
fi

# Link the template repository as a submodule
if [ ! -d "$APP_DIR/frappe_app_template" ] && git -C "$SCRIPT_DIR" rev-parse --git-dir >/dev/null 2>&1 && git -C "$SCRIPT_DIR" rev-parse HEAD >/dev/null 2>&1; then
    [ "$VERBOSE" -eq 1 ] && echo "Add frappe_app_template submodule"
    git -c protocol.file.allow=always submodule add "$SCRIPT_DIR" "$APP_DIR/frappe_app_template"
fi

# Copy template files and directories
copy_items=(
    AGENTS.md .pre-commit-config.yaml requirements.txt requirements-dev.txt
    vendors.txt apps.json custom_vendors.json scripts doc .github instructions
)
for item in "${copy_items[@]}"; do
    src="$SCRIPT_DIR/$item"
    dest="$APP_DIR/$item"
    [ -e "$src" ] || continue
    if [ -d "$src" ]; then
        [ "$VERBOSE" -eq 1 ] && echo "Copy directory $item"
        cp -r "$src" "$dest"
    else
        [ "$VERBOSE" -eq 1 ] && echo "Copy file $item"
        cp "$src" "$dest"
    fi
done

# Ensure supporting folders exist
mkdir -p "$APP_DIR/vendor" "$APP_DIR/instructions" "$APP_DIR/.config" "$APP_DIR/sample_data"

# Create placeholder config file
if [ ! -f "$APP_DIR/.config/github_api.json" ]; then
    echo '{}' > "$APP_DIR/.config/github_api.json"
fi

echo "✅ Setup complete."
