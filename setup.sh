#!/bin/bash
set -e

# Determine the script and parent directories
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# When used as a submodule, copy workflow files (and requirements.txt) to the
# parent repository
if [ -d "$PARENT_DIR/.git" ] && [ "$PARENT_DIR" != "$SCRIPT_DIR" ]; then
    for wf in "$SCRIPT_DIR"/.github/workflows/*.yml; do
        [ -f "$wf" ] || continue
        target="$PARENT_DIR/.github/workflows/$(basename "$wf")"
        mkdir -p "$(dirname "$target")"
        cp "$wf" "$target"
    done
    if [ ! -f "$PARENT_DIR/requirements.txt" ]; then
        cp "$SCRIPT_DIR/requirements.txt" "$PARENT_DIR/requirements.txt"
    fi
    if [ -d "$SCRIPT_DIR/scripts" ]; then
        cp -r "$SCRIPT_DIR/scripts" "$PARENT_DIR/"
        chmod +x "$PARENT_DIR"/scripts/*.sh
    fi
    if [ "$PARENT_DIR" != "$SCRIPT_DIR" ] && [ ! -f "$PARENT_DIR/.gitignore" ] && [ -f "$SCRIPT_DIR/.gitignore" ]; then
        cp "$SCRIPT_DIR/.gitignore" "$PARENT_DIR/.gitignore"
    fi
    CONFIG_TARGET="$PARENT_DIR"
else
    CONFIG_TARGET="$SCRIPT_DIR"
fi

# Ensure sample_data directory exists
mkdir -p "$CONFIG_TARGET/sample_data"

# Ensure vendor directory exists for workflows
mkdir -p "$CONFIG_TARGET/vendor"

# Create example configuration files if missing
if [ ! -f "$CONFIG_TARGET/custom_vendors.json" ]; then
    cat > "$CONFIG_TARGET/custom_vendors.json" <<'JSON'
{
  "example_app": {
    "repo": "https://github.com/example/example_app",
    "tag": "v1.0.0"
  }
}
JSON
fi

if [ ! -f "$CONFIG_TARGET/templates.txt" ]; then
    cat > "$CONFIG_TARGET/templates.txt" <<'TXT'
# Add template repository URLs here
# https://github.com/example/template-a
TXT
fi

if [ ! -f "$CONFIG_TARGET/codex.json" ]; then
    cat > "$CONFIG_TARGET/codex.json" <<'JSON'
{
  "_comment": "Directories indexed by Codex. Adjust paths as needed.",
  "sources": [
    "app/",
    "vendor/bench/",
    "vendor/frappe/",
    "instructions/",
    "sample_data/"
  ]
}
JSON
fi

echo "✅ Setup complete."
