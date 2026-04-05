#!/usr/bin/env bash
# NiceOS9 Plymouth Boot Splash Installer
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

    echo "=== NiceOS9 Plymouth Boot Splash Installer ==="
    echo ""
fi

# ── Install ───────────────────────────────────────────────────────────────────
echo "[Plymouth] Installing NiceOS9 boot splash theme..."

if [ ! -d "$SCRIPT_DIR/plymouth/niceos9-plymouth" ]; then
    echo "  Plymouth theme source not found at $SCRIPT_DIR/plymouth/niceos9-plymouth"
    echo "  Skipping."
    return 0 2>/dev/null || exit 0
fi

PLYMOUTH_THEME_DIR="$SCRIPT_DIR/plymouth/niceos9-plymouth"

echo "         Generating Plymouth assets (requires Pillow)..."
if ! python3 "$PLYMOUTH_THEME_DIR/generate-assets.py"; then
    echo ""
    echo "  WARNING: Asset generation failed. Install Pillow first:"
    echo "    pip install Pillow"
    echo "  Then re-run this script."
    return 1 2>/dev/null || exit 1
fi

PLYMOUTH_DEST="/usr/share/plymouth/themes/niceos9-plymouth"
echo "         Installing to $PLYMOUTH_DEST (requires sudo)..."
sudo mkdir -p "$PLYMOUTH_DEST"
sudo cp "$PLYMOUTH_THEME_DIR"/*.png \
        "$PLYMOUTH_THEME_DIR/niceos9.script" \
        "$PLYMOUTH_THEME_DIR/niceos9-plymouth.plymouth" \
        "$PLYMOUTH_DEST/"

sudo update-alternatives --install \
    /usr/share/plymouth/themes/default.plymouth \
    default.plymouth \
    "$PLYMOUTH_DEST/niceos9.plymouth" 100 2>/dev/null || true

echo ""
echo "  Plymouth theme installed to $PLYMOUTH_DEST"
echo "  To activate:"
echo "    sudo plymouth-set-default-theme niceos9-plymouth"
if [ "$is_debian_family" = true ]; then
    echo "    sudo update-initramfs -u"
else
    echo "    sudo dracut -f"
fi
echo ""
