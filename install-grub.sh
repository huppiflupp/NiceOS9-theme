#!/usr/bin/env bash
# NiceOS9 GRUB Boot Menu Theme Installer
# Can be run standalone or sourced from install.sh

set -e

# When run standalone, resolve SCRIPT_DIR relative to this file.
# When sourced from install.sh, SCRIPT_DIR is already set.
if [ -z "${SCRIPT_DIR:-}" ]; then
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
fi

# ── Install ───────────────────────────────────────────────────────────────────
echo "[GRUB] Installing NiceOS9 boot menu theme..."

if [ ! -d "$SCRIPT_DIR/grub/niceos9-grub" ]; then
    echo "  GRUB theme source not found at $SCRIPT_DIR/grub/niceos9-grub"
    echo "  Skipping."
    return 0 2>/dev/null || exit 0
fi

GRUB_THEME_DIR="$SCRIPT_DIR/grub/niceos9-grub"

echo "       Generating GRUB assets (requires Pillow)..."
if ! python3 "$GRUB_THEME_DIR/generate-assets.py"; then
    echo ""
    echo "  WARNING: Asset generation failed. Install Pillow first:"
    echo "    pip install Pillow"
    echo "  Then re-run this script."
    return 1 2>/dev/null || exit 1
fi

if [ "$is_debian_family" = true ]; then
    GRUB_DEST="/boot/grub/themes/niceos9-grub"
else
    GRUB_DEST="/boot/grub2/themes/niceos9-grub"
fi

echo "       Installing to $GRUB_DEST (requires sudo)..."
sudo mkdir -p "$GRUB_DEST"
sudo cp "$GRUB_THEME_DIR"/*.png \
        "$GRUB_THEME_DIR/theme.txt" \
        "$GRUB_DEST/"

# Generate PF2 fonts (grub-mkfont required)
if command -v grub-mkfont &>/dev/null || command -v grub2-mkfont &>/dev/null; then
    MKFONT=$(command -v grub2-mkfont 2>/dev/null || command -v grub-mkfont)
    FONT_TTF="$SCRIPT_DIR/fonts/ChicagoFLF.ttf"
    echo "       Generating GRUB fonts from ChicagoFLF..."
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
echo "  GRUB theme installed to $GRUB_DEST"
echo "  To activate, add/update in /etc/default/grub:"
echo "    GRUB_THEME='$GRUB_DEST/theme.txt'"
echo "  Then rebuild the GRUB config:"
if [ "$is_debian_family" = true ]; then
    echo "    sudo update-grub"
else
    echo "    sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
fi
echo ""
