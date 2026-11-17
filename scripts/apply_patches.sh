#!/usr/bin/env bash
# ==============================================================================
# Nirvana Browser - Patch Application Script (Linux/macOS/MSYS2)
# Applies Nirvana Browser patches and assets on top of upstream Firefox Android.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <path_to_firefox_source>"
    echo "Example: $0 ./firefox-android"
    exit 1
fi

TARGET_DIR="$(cd "$1" && pwd)"

echo "==> Target source directory: ${TARGET_DIR}"
echo "==> Nirvana repository root: ${REPO_ROOT}"

cd "${TARGET_DIR}"

# 1. Check if Git working tree is available
if [ -d ".git" ]; then
    echo "==> Verifying clean state in target repository..."
    if ! git diff-index --quiet HEAD --; then
        echo "WARNING: Target repository has uncommitted changes. Stashing or cleaning recommended."
    fi
fi

# 2. Apply Unified Patch
PATCH_FILE="${REPO_ROOT}/patches/nirvana-160.0.0-unified.patch"
if [ ! -f "${PATCH_FILE}" ]; then
    echo "ERROR: Patch file not found at ${PATCH_FILE}"
    exit 1
fi

echo "==> Applying Nirvana 160.0.0 unified patch..."
git apply --verbose --ignore-whitespace "${PATCH_FILE}"

# 3. Synchronize assets (Extensions and Icons)
echo "==> Synchronizing Nirvana assets..."

# Extension: uBlock Origin
EXT_DIR="${TARGET_DIR}/mobile/android/fenix/app/src/main/assets/extensions"
mkdir -p "${EXT_DIR}"
if [ -f "${REPO_ROOT}/assets/extensions/ublock_origin.xpi" ]; then
    cp -v "${REPO_ROOT}/assets/extensions/ublock_origin.xpi" "${EXT_DIR}/ublock_origin.xpi"
fi

# Resource assets: drawables and icons
if [ -d "${REPO_ROOT}/assets/res" ]; then
    cp -rfv "${REPO_ROOT}/assets/res/"* "${TARGET_DIR}/"
fi

echo "==> Nirvana patches and assets applied successfully!"
echo "==> Ready to build with: ./scripts/build_nirvana.sh ${TARGET_DIR}"
