#!/bin/bash
set -euo pipefail

LATEST_TAG=$(git tag --list 'v*' --sort=-v:refname | head -n 1 || true)
if [ -z "$LATEST_TAG" ]; then
  NEXT_TAG="v0.1.0"
else
  ver="${LATEST_TAG#v}"
  IFS='.' read -r major minor patch <<< "$ver"
  patch=$((patch + 1))
  NEXT_TAG="v${major}.${minor}.${patch}"
fi

git tag "$NEXT_TAG"
BRANCH="publish-${NEXT_TAG}"
git checkout -b "$BRANCH"

echo "Created tag $NEXT_TAG and branch $BRANCH" >&2
