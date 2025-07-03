#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 [dev-stable|test-stable|major]" >&2
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

LEVEL="$1"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not a git repository" >&2
  exit 1
fi

if ! git diff-index --quiet HEAD --; then
  echo "❌ Working tree has uncommitted changes" >&2
  exit 1
fi

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
VER=${LAST_TAG#v}
IFS='.' read -r MAJOR MINOR PATCH <<<"$VER"
MAJOR=${MAJOR:-0}
MINOR=${MINOR:-0}
PATCH=${PATCH:-0}
case "$LEVEL" in
  dev-stable)
    PATCH=$((PATCH + 1))
    ;;
  test-stable)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  *)
    usage
    exit 1
    ;;
esac
NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}"

echo "Creating release commit for $NEW_TAG"
DEV_PATHS=("instructions" "vendor_profiles" "sample_data" "tests")
for p in "${DEV_PATHS[@]}"; do
  if [ -e "$p" ]; then
    git rm -r --cached "$p" >/dev/null 2>&1 || true
  fi
done

if git diff --cached --quiet; then
  echo "No changes to commit for release" >&2
else
  git commit -m "chore: release $NEW_TAG"
fi

git tag -a "$NEW_TAG" -m "Release $NEW_TAG"

if git remote get-url origin >/dev/null 2>&1; then
  echo "Pushing tag $NEW_TAG"
  git push origin "$NEW_TAG"
fi

if command -v gh >/dev/null 2>&1 && git remote get-url origin >/dev/null 2>&1; then
  gh pr create --title "Release $NEW_TAG" --body "Release $NEW_TAG" --base main || true
fi

