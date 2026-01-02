#!/bin/bash
# Build SZR35 Miryoku firmware using Docker
# Requires: Docker installed and running
# Uses the vial-qmk-szr35 repository as the QMK base

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIAL_QMK="/home/draxel/Downloads/vial-qmk-szr35"
OUTPUT_DIR="${SCRIPT_DIR}/firmware"

echo "Building SZR35 Miryoku firmware..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if vial-qmk-szr35 exists
if [ ! -d "${VIAL_QMK}" ]; then
    echo "Error: vial-qmk-szr35 not found at ${VIAL_QMK}"
    echo "Clone it first: git clone https://github.com/vial-kb/vial-qmk ${VIAL_QMK}"
    exit 1
fi

# Create output directory if needed
mkdir -p "${OUTPUT_DIR}"

# Copy our Miryoku keymap to vial-qmk
echo "Copying Miryoku keymap..."
cp "${SCRIPT_DIR}/qmk/szrkbd/szr35/keymaps/vial/keymap.c" "${VIAL_QMK}/keyboards/szrkbd/szr35/keymaps/vial/keymap.c"
cp "${SCRIPT_DIR}/qmk/szrkbd/szr35/keymaps/vial/rules.mk" "${VIAL_QMK}/keyboards/szrkbd/szr35/keymaps/vial/rules.mk"

echo "Running QMK build in Docker..."

# Run the build
docker run --rm \
    -v "${VIAL_QMK}:/qmk_firmware" \
    -w /qmk_firmware \
    qmkfm/qmk_cli:latest \
    make szrkbd/szr35:vial

# Copy the compiled firmware
if [ -f "${VIAL_QMK}/szrkbd_szr35_vial.bin" ]; then
    cp "${VIAL_QMK}/szrkbd_szr35_vial.bin" "${OUTPUT_DIR}/"
    echo ""
    echo "Success! Firmware built: firmware/szrkbd_szr35_vial.bin"
    echo "Flash with: flash (in nix develop shell)"
else
    # Check .build subdirectory
    FIRMWARE=$(find "${VIAL_QMK}/.build" -name "*.bin" -type f 2>/dev/null | head -1)
    if [ -n "${FIRMWARE}" ]; then
        cp "${FIRMWARE}" "${OUTPUT_DIR}/szrkbd_szr35_vial.bin"
        echo ""
        echo "Success! Firmware built: firmware/szrkbd_szr35_vial.bin"
        echo "Flash with: flash (in nix develop shell)"
    else
        echo "Error: Firmware binary not found after build"
        echo "Check Docker output above for build errors"
        exit 1
    fi
fi
