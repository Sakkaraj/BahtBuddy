#!/usr/bin/env bash
# Run BahtBuddy on an iPhone simulator or device from a Mac.
# Usage: bash tools/mac_ios_run.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "1/4  flutter pub get"
flutter pub get

echo "2/4  ML Kit Latin bundle and libtesseract (no-op if already present)"
bash ios/download_mlkit_bundles.sh
bash ios/download_libtesseract.sh

echo "3/4  available devices"
flutter devices

echo "4/4  flutter run (pick an iOS simulator or a plugged-in iPhone)"
flutter run
