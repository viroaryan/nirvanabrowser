#!/usr/bin/env bash
# ==============================================================================
# Nirvana Browser - Release Build Script (Linux/macOS/MSYS2)
# ==============================================================================
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <path_to_firefox_source>"
    exit 1
fi

TARGET_DIR="$(cd "$1" && pwd)"
cd "${TARGET_DIR}"

echo "==> PHASE 1: Building GeckoView Core Engine..."
./mach build

echo "==> PHASE 2: Building Nirvana Release APK and AAB..."
./gradlew :fenix:assembleRelease :fenix:bundleRelease -PdisableDebugSigning

echo "==> Nirvana Build Complete!"
echo "Outputs generated in obj/gradle/build/mobile/android/fenix/app/outputs/"
