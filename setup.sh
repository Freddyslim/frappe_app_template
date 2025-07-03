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

# Determine the script and parent directories
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
WORKFLOW_TEMPLATE_DIR="$SCRIPT_DIR/workflow_templates"

# When used as a submodule, copy workflow files (and requirements.txt) to the
# parent repository
if [ -d "$PARENT_DIR/.git" ] && [ "$PARENT_DIR" != "$SCRIPT_DIR" ]; then
    for wf in "$WORKFLOW_TEMPLATE_DIR"/*.yml; do
        [ -f "$wf" ] || continue
        target="$PARENT_DIR/.github/workflows/$(basename "$wf")"
        mkdir -p "$(dirname "$target")"
        if [ ! -f "$target" ]; then
            [ "$VERBOSE" -eq 1 ] && echo "Copy workflow $(basename "$wf")"
            cp "$wf" "$target"
        fi
    done
    if [ ! -f "$PARENT_DIR/requirements.txt" ]; then
        [ "$VERBOSE" -eq 1 ] && echo "Copy requirements.txt"
        cp "$SCRIPT_DIR/requirements.txt" "$PARENT_DIR/requirements.txt"
    fi
    if [ ! -f "$PARENT_DIR/requirements-dev.txt" ] && [ -f "$SCRIPT_DIR/requirements-dev.txt" ]; then
        [ "$VERBOSE" -eq 1 ] && echo "Copy requirements-dev.txt"
        cp "$SCRIPT_DIR/requirements-dev.txt" "$PARENT_DIR/requirements-dev.txt"
    fi
    if [ -d "$SCRIPT_DIR/scripts" ]; then
        mkdir -p "$PARENT_DIR/scripts"
        for sf in "$SCRIPT_DIR"/scripts/*; do
            [ -f "$sf" ] || continue
            target="$PARENT_DIR/scripts/$(basename "$sf")"
            if [ ! -f "$target" ]; then
                [ "$VERBOSE" -eq 1 ] && echo "Copy script $(basename "$sf")"
                cp "$sf" "$target"
            fi
        done
        chmod +x "$PARENT_DIR"/scripts/*.sh 2>/dev/null || true
    fi
    if [ "$PARENT_DIR" != "$SCRIPT_DIR" ] && [ ! -f "$PARENT_DIR/.gitignore" ] && [ -f "$SCRIPT_DIR/.gitignore" ]; then
        [ "$VERBOSE" -eq 1 ] && echo "Copy .gitignore"
        cp "$SCRIPT_DIR/.gitignore" "$PARENT_DIR/.gitignore"
    fi

    CONFIG_TARGET="$PARENT_DIR"
else
    CONFIG_TARGET="$SCRIPT_DIR"
fi

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
    APP_NAME="$(basename "$CONFIG_TARGET")"
fi

# Ensure sample_data directory exists
[ "$VERBOSE" -eq 1 ] && echo "Ensure sample_data directory"
mkdir -p "$CONFIG_TARGET/sample_data"

# Ensure vendor directory exists for workflows
[ "$VERBOSE" -eq 1 ] && echo "Ensure vendor directory"
mkdir -p "$CONFIG_TARGET/vendor"

# Ensure core instructions directory and README
[ "$VERBOSE" -eq 1 ] && echo "Ensure instructions/_core"
mkdir -p "$CONFIG_TARGET/instructions/_core"
CORE_README="$CONFIG_TARGET/instructions/_core/README.md"
if [ ! -f "$CORE_README" ]; then
    [ "$VERBOSE" -eq 1 ] && echo "Create $CORE_README"
    cat > "$CORE_README" <<'EOF'
# Instructions Overview

This folder stores the default documentation that ships with every app.
For details on how Agents load and use these files, see “agent.md” in the
repository root.
EOF
fi

# Create example configuration files if missing
if [ ! -f "$CONFIG_TARGET/vendors.txt" ]; then
    [ "$VERBOSE" -eq 1 ] && echo "Copy vendors.txt"
    cp "$SCRIPT_DIR/vendors.txt" "$CONFIG_TARGET/vendors.txt"
fi

if [ ! -f "$CONFIG_TARGET/apps.json" ]; then
    [ "$VERBOSE" -eq 1 ] && echo "Copy apps.json"
    cp "$SCRIPT_DIR/apps.json" "$CONFIG_TARGET/apps.json"
fi

if [ ! -f "$CONFIG_TARGET/custom_vendors.json" ]; then
    [ "$VERBOSE" -eq 1 ] && echo "Create custom_vendors.json"
    cat > "$CONFIG_TARGET/custom_vendors.json" <<'JSON'
{
  "example_app": {
    "repo": "https://github.com/example/example_app",
    "branch": "v1.0.0"
  }
}
JSON
fi

# Ensure app skeleton exists (matching bench new-app)
echo "ℹ️  Creating app via bench new-app"
[ "$VERBOSE" -eq 1 ] && echo "Running: bench new-app $APP_NAME"

bench new-app "$APP_NAME"
APP_DIR="$CONFIG_TARGET/apps/$APP_NAME"
[ "$VERBOSE" -eq 1 ] && echo "App directory: $APP_DIR"


echo "✅ Setup complete."
