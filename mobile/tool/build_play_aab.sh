#!/usr/bin/env bash
# Play Store release AAB with Dart obfuscation (symbols kept locally).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SYMBOLS="${ROOT}/build/symbols/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SYMBOLS"

echo "==> flutter build appbundle (obfuscated)"
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info="$SYMBOLS"

AAB="${ROOT}/build/app/outputs/bundle/release/app-release.aab"
echo "==> AAB: $AAB"
echo "==> Symbols (keep private for crash deobfuscation): $SYMBOLS"
ls -lh "$AAB"
