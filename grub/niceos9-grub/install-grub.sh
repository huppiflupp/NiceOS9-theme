#!/usr/bin/env bash
# NiceOS9 GRUB Boot Menu Theme Installer (standalone)
# Run from inside the niceos9-grub directory.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OS_ID="" OS_LIKE=""
if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-}"
    OS_LIKE="${ID_LIKE:-}"
fi

is_debian_family=false
is_fedora_family=false
case " $OS_ID $OS_LIKE " in
    *" ubuntu "*|*" debian "*|*" neon "*) is_debian_family=true ;;
esac
case " $OS_ID $OS_LIKE " in
    *" fedora "*|*" nobara "*|*" rhel "*) is_fedora_family=true ;;
esac

echo "=== NiceOS9 GRUB Boot Menu Theme Installer ==="
echo ""

echo "[GRUB] Generating boot menu assets (requires Pillow)..."
if ! python3 "$SCRIPT_DIR/generate-assets.py"; then
    echo ""
    echo "  ERROR: Asset generation failed. Install Pillow first:"
    echo "    pip install Pillow"
    echo "  Then re-run this script."
    exit 1
fi

if [ "$is_debian_family" = true ]; then
    GRUB_DEST="/boot/grub/themes/niceos9-grub"
else
    GRUB_DEST="/boot/grub2/themes/niceos9-grub"
fi

echo "[GRUB] Installing to $GRUB_DEST (requires sudo)..."
sudo mkdir -p "$GRUB_DEST"
sudo cp "$SCRIPT_DIR"/*.png \
        "$SCRIPT_DIR/theme.txt" \
        "$GRUB_DEST/"

# Generate PF2 fonts from bundled ChicagoFLF.ttf
FONT_TTF="$SCRIPT_DIR/ChicagoFLF.ttf"
if command -v grub-mkfont &>/dev/null || command -v grub2-mkfont &>/dev/null; then
    MKFONT=$(command -v grub2-mkfont 2>/dev/null || command -v grub-mkfont)
    echo "[GRUB] Generating GRUB fonts from ChicagoFLF..."
    sudo "$MKFONT" -s 18 -n "ChicagoFLF 18" -o "$GRUB_DEST/ChicagoFLF-18.pf2" "$FONT_TTF"
    sudo "$MKFONT" -s 14 -n "ChicagoFLF 14" -o "$GRUB_DEST/ChicagoFLF-14.pf2" "$FONT_TTF"
else
    echo "  WARNING: grub font generator not found — fonts will fall back to GRUB default."
    if [ "$is_debian_family" = true ]; then
        echo "           Install with: sudo apt install grub-common"
    else
        echo "           Install with: sudo dnf install grub2-tools"
    fi
    sudo sed -i \
        -e 's/item_font.*=.*/item_font = "Unknown Regular 16"/' \
        -e 's/font.*=.*"ChicagoFLF 14"$/font = "Unknown Regular 14"/' \
        "$GRUB_DEST/theme.txt"
fi

echo ""
echo "=== GRUB theme installed to $GRUB_DEST ==="
echo ""
echo "To activate, add/update in /etc/default/grub:"
echo "  GRUB_THEME='$GRUB_DEST/theme.txt'"
echo "Then rebuild the GRUB config:"
if [ "$is_debian_family" = true ]; then
    echo "  sudo update-grub"
else
    echo "  sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
fi
echo ""
