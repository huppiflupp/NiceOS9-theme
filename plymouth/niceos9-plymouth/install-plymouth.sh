#!/usr/bin/env bash
# NiceOS9 Plymouth Boot Splash Installer (standalone)
# Run from inside the niceos9-plymouth directory.

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

echo "=== NiceOS9 Plymouth Boot Splash Installer ==="
echo ""

echo "[Plymouth] Generating boot splash assets (requires Pillow)..."
if ! python3 "$SCRIPT_DIR/generate-assets.py"; then
    echo ""
    echo "  ERROR: Asset generation failed. Install Pillow first:"
    echo "    pip install Pillow"
    echo "  Then re-run this script."
    exit 1
fi

PLYMOUTH_DEST="/usr/share/plymouth/themes/niceos9-plymouth"
echo "[Plymouth] Installing to $PLYMOUTH_DEST (requires sudo)..."
sudo mkdir -p "$PLYMOUTH_DEST"
sudo cp "$SCRIPT_DIR"/*.png \
        "$SCRIPT_DIR/niceos9.script" \
        "$SCRIPT_DIR/niceos9-plymouth.plymouth" \
        "$PLYMOUTH_DEST/"

sudo update-alternatives --install \
    /usr/share/plymouth/themes/default.plymouth \
    default.plymouth \
    "$PLYMOUTH_DEST/niceos9.plymouth" 100 2>/dev/null || true

echo ""
echo "=== Plymouth theme installed to $PLYMOUTH_DEST ==="
echo ""
echo "To activate:"
echo "  sudo plymouth-set-default-theme niceos9-plymouth"
if [ "$is_debian_family" = true ]; then
    echo "  sudo update-initramfs -u"
else
    echo "  sudo dracut -f"
fi
echo ""
