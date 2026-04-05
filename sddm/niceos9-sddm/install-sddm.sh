#!/usr/bin/env bash
# NiceOS9 SDDM Login Screen Theme Installer (standalone)
# Run from inside the niceos9-sddm directory.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== NiceOS9 SDDM Login Screen Installer ==="
echo ""

SDDM_DEST="/usr/share/sddm/themes/niceos9-sddm"
echo "[SDDM] Installing to $SDDM_DEST (requires sudo)..."
sudo mkdir -p "$SDDM_DEST"
sudo cp -r "$SCRIPT_DIR"/. "$SDDM_DEST/"

echo ""
echo "=== SDDM theme installed to $SDDM_DEST ==="
echo ""
echo "To activate:"
echo "  System Settings > Colors & Themes > Login Screen (SDDM)"
echo "or set in /etc/sddm.conf.d/theme.conf:"
echo "  [Theme]"
echo "  Current=niceos9-sddm"
echo ""
