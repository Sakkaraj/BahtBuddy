#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="$ROOT/Runner/MLKitBundles"
BUNDLE="$DEST/LatinOCRResources.bundle"
VERSION="9.0.3"
URL="https://github.com/d-date/google-mlkit-swiftpm/releases/download/${VERSION}/LatinOCRResources.bundle.zip"

if [ -d "$BUNDLE" ]; then
  echo "LatinOCRResources.bundle already present"
  exit 0
fi

mkdir -p "$DEST"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading LatinOCRResources.bundle (${VERSION})…"
curl -fsSL "$URL" -o "$TMP/LatinOCRResources.bundle.zip"
unzip -q "$TMP/LatinOCRResources.bundle.zip" -d "$TMP"

FOUND="$(find "$TMP" -type d -name 'LatinOCRResources.bundle' | head -n 1)"
if [ -z "$FOUND" ]; then
  echo "Downloaded zip did not contain LatinOCRResources.bundle" >&2
  exit 1
fi

cp -R "$FOUND" "$DEST/"
echo "Installed $BUNDLE"
