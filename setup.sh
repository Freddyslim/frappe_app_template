#!/bin/bash
set -e

# Prevent execution inside the frappe_app_template submodule
toplevel=$(git rev-parse --show-toplevel 2>/dev/null)
if [[ "$toplevel" == *"/frappe_app_template" ]]; then
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
        cp "$wf" "$target"
    done
    if [ ! -f "$PARENT_DIR/requirements.txt" ]; then
        cp "$SCRIPT_DIR/requirements.txt" "$PARENT_DIR/requirements.txt"
    fi
    if [ ! -f "$PARENT_DIR/requirements-dev.txt" ] && [ -f "$SCRIPT_DIR/requirements-dev.txt" ]; then
        cp "$SCRIPT_DIR/requirements-dev.txt" "$PARENT_DIR/requirements-dev.txt"
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

# Ensure core instructions directory and README
mkdir -p "$CONFIG_TARGET/instructions/_core"
CORE_README="$CONFIG_TARGET/instructions/_core/README.md"
if [ ! -f "$CORE_README" ]; then
    cat > "$CORE_README" <<'EOF'
# 📚 Codex Instructions System

Dies ist die zentrale, nie löschbare Anleitungsbasis für Codex-gestützte Entwicklung.

## Funktionsweise

- Jedes App-Template enthält ein eigenes `instructions/`-Verzeichnis
- Beim Clonen eines Templates (siehe `vendors.txt`) werden diese nach `instructions/_<slug>/` kopiert
- Beim Entfernen eines Templates wird auch `instructions/_<template-name>/` gelöscht

## Ziel

Anhand dieser Anleitungen kann Codex automatisch passende Prompt-Ketten generieren, z. B.:

> „Erstelle eine App mit Website zur Eingabe von Projektdaten, die in ERPNext gespeichert werden“

→ Erkennt Schlüsselwörter (`website`, `erpnext`)
→ nutzt passende Inhalte aus:
`_core/`, `_erpnext-website-template/`, `_erpnext-template/`

## Beispielstruktur

```
instructions/
├── _core/                     # Zentrale Hinweise (nie löschen)
├── _erpnext-template/        # Von Template eingebracht
├── _erpnext-website-template/
│   ├── 00_overview.md
│   └── prompts/
│       ├── generate_webform.md
│       └── sync_with_erpnext.md
```

Diese Dateien werden später von Codex ausgelesen, um automatisch die passenden Entwicklungs-Prompts zu generieren.
EOF
fi

# Create example configuration files if missing
if [ ! -f "$CONFIG_TARGET/vendors.txt" ]; then
    echo "example_app" > "$CONFIG_TARGET/vendors.txt"
fi

if [ ! -f "$CONFIG_TARGET/vendor_profiles/examples/example_app.json" ]; then
    mkdir -p "$CONFIG_TARGET/vendor_profiles/examples"
    cat > "$CONFIG_TARGET/vendor_profiles/examples/example_app.json" <<'JSON'
{
  "url": "https://github.com/example/example_app",
  "branch": "v1.0.0"
}
JSON
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
  ],
  "templates": []
}
JSON
fi

# ensure templates field exists
if ! jq -e '.templates' "$CONFIG_TARGET/codex.json" >/dev/null 2>&1; then
    tmp=$(mktemp)
    jq '. + {templates: []}' "$CONFIG_TARGET/codex.json" > "$tmp"
    mv "$tmp" "$CONFIG_TARGET/codex.json"
fi

# clone templates to provide instructions
if [ -f "$CONFIG_TARGET/scripts/update_templates.sh" ]; then
    bash "$CONFIG_TARGET/scripts/update_templates.sh"
fi

echo "✅ Setup complete."
