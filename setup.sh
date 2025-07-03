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

# Copy workflow templates and helper files
for wf in "$WORKFLOW_TEMPLATE_DIR"/*.yml; do
    [ -f "$wf" ] || continue
    target="$APP_DIR/.github/workflows/$(basename "$wf")"
    mkdir -p "$(dirname "$target")"
    if [ ! -f "$target" ]; then
        [ "$VERBOSE" -eq 1 ] && echo "Copy workflow $(basename "$wf")"
        cp "$wf" "$target"
    fi
done

for f in requirements.txt requirements-dev.txt; do
    src="$SCRIPT_DIR/$f"
    [ -f "$src" ] || continue
    target="$APP_DIR/$f"
    if [ ! -f "$target" ]; then
        [ "$VERBOSE" -eq 1 ] && echo "Copy $f"
        cp "$src" "$target"
    fi
done

if [ -d "$SCRIPT_DIR/scripts" ]; then
    mkdir -p "$APP_DIR/scripts"
    for sf in "$SCRIPT_DIR"/scripts/*; do
        [ -f "$sf" ] || continue
        target="$APP_DIR/scripts/$(basename "$sf")"
        if [ ! -f "$target" ]; then
            [ "$VERBOSE" -eq 1 ] && echo "Copy script $(basename "$sf")"
            cp "$sf" "$target"
        fi
    done
    chmod +x "$APP_DIR"/scripts/*.sh 2>/dev/null || true
fi

if [ ! -f "$APP_DIR/.gitignore" ] && [ -f "$SCRIPT_DIR/.gitignore" ]; then
    [ "$VERBOSE" -eq 1 ] && echo "Copy .gitignore"
    cp "$SCRIPT_DIR/.gitignore" "$APP_DIR/.gitignore"
fi

# Create required directories inside the new app
mkdir -p "$APP_DIR/sample_data" "$APP_DIR/vendor" "$APP_DIR/instructions"

# Copy configuration templates
if [ ! -f "$APP_DIR/vendors.txt" ]; then
    cp "$SCRIPT_DIR/vendors.txt" "$APP_DIR/vendors.txt"
fi
if [ ! -f "$APP_DIR/apps.json" ]; then
    cp "$SCRIPT_DIR/apps.json" "$APP_DIR/apps.json"
fi
if [ ! -f "$APP_DIR/custom_vendors.json" ]; then
    cat > "$APP_DIR/custom_vendors.json" <<'JSON'
{
  "example_app": {
    "repo": "https://github.com/example/example_app",
    "branch": "v1.0.0"
  }
}
JSON
fi


echo "✅ Setup complete."
