#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="$ROOT/vendor/libtesseract"
FRAMEWORK="$DEST/libtesseract.xcframework"
VERSION="0.2.0"
URL="https://github.com/SwiftyTesseract/libtesseract/releases/download/${VERSION}/libtesseract-${VERSION}.xcframework.zip"

if [ -d "$FRAMEWORK" ]; then
  echo "libtesseract.xcframework already present"
  exit 0
fi

mkdir -p "$DEST"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading libtesseract.xcframework (${VERSION}, ~209 MB)…"
curl -fL --retry 3 --retry-delay 2 "$URL" -o "$TMP/libtesseract.xcframework.zip"
unzip -q "$TMP/libtesseract.xcframework.zip" -d "$TMP"

FOUND="$(find "$TMP" -type d -name 'libtesseract.xcframework' | head -n 1)"
if [ -z "$FOUND" ]; then
  echo "Downloaded zip did not contain libtesseract.xcframework" >&2
  exit 1
fi

cp -R "$FOUND" "$DEST/"
echo "Installed $FRAMEWORK"
