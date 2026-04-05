#!/usr/bin/env bash
# NiceOS9 SDDM Login Screen Theme Installer
# Can be run standalone or sourced from install.sh

set -e

# When run standalone, resolve SCRIPT_DIR relative to this file.
# When sourced from install.sh, SCRIPT_DIR is already set.
if [ -z "${SCRIPT_DIR:-}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    echo "=== NiceOS9 SDDM Login Screen Installer ==="
    echo ""
fi

# ── Install ───────────────────────────────────────────────────────────────────
echo "[SDDM] Installing NiceOS9 login screen theme..."

if [ ! -d "$SCRIPT_DIR/sddm/niceos9-sddm" ]; then
    echo "  SDDM theme source not found at $SCRIPT_DIR/sddm/niceos9-sddm"
    echo "  Skipping."
    return 0 2>/dev/null || exit 0
fi

SDDM_DEST="/usr/share/sddm/themes/niceos9-sddm"
echo "       Installing to $SDDM_DEST (requires sudo)..."
sudo mkdir -p "$SDDM_DEST"
sudo cp -r "$SCRIPT_DIR/sddm/niceos9-sddm"/. "$SDDM_DEST/"

echo ""
echo "  SDDM theme installed to $SDDM_DEST"
echo "  To activate:"
echo "    System Settings > Colors & Themes > Login Screen (SDDM)"
echo "  or set in /etc/sddm.conf.d/theme.conf:"
echo "    [Theme]"
echo "    Current=niceos9-sddm"
echo ""
