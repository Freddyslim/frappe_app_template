#!/bin/bash
# generate_diagrams.sh: render all .mmd files under doc/ to images
set -euo pipefail

SRC_DIR="${1:-doc}"
FORMAT="${FORMAT:-svg}"

command -v mmdc >/dev/null 2>&1 || {
  echo "mmdc not found. Install with: npm install -g @mermaid-js/mermaid-cli" >&2
  exit 1
}

find "$SRC_DIR" -name '*.mmd' | while read -r file; do
  out="${file%.mmd}.$FORMAT"
  echo "Rendering $file -> $out"
  mmdc -i "$file" -o "$out" -t default -b transparent
done
