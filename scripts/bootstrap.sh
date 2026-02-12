#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Installing Homebrew dependencies..."
brew bundle

echo "==> Generating Xcode project..."
xcodegen generate

echo "==> Resolving Swift packages..."
xcodebuild -resolvePackageDependencies \
  -project SportTracker.xcodeproj \
  -scheme SportTracker \
  -quiet

echo "==> Done. Open SportTracker.xcodeproj to get started."
