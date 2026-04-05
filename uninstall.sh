#!/usr/bin/env bash
# NiceOS9 KDE Plasma Theme Uninstaller
# Removes user-local assets and the optional system-wide themes installed by this project.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_ID=""
OS_LIKE=""

if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-}"
    OS_LIKE="${ID_LIKE:-}"
fi

is_debian_family=false
case " $OS_ID $OS_LIKE " in
    *" ubuntu "*|*" debian "*|*" neon "*)
        is_debian_family=true
        ;;
esac

if [ "$is_debian_family" = true ]; then
    GRUB_THEME_DIR="/boot/grub/themes/niceos9-grub"
else
    GRUB_THEME_DIR="/boot/grub2/themes/niceos9-grub"
fi

echo "=== NiceOS9 KDE Theme Uninstaller ==="
echo ""
echo "Removing user-local NiceOS9 files..."

rm -rf "$HOME/.local/share/plasma/look-and-feel/NiceOS9 dark"
rm -rf "$HOME/.local/share/plasma/look-and-feel/NiceOS9 bright"
rm -rf "$HOME/.local/share/plasma/look-and-feel/niceos9-dark"
rm -rf "$HOME/.local/share/plasma/look-and-feel/niceos9-bright"
rm -rf "$HOME/.local/share/plasma/desktoptheme/niceos9-bright"
rm -rf "$HOME/.local/share/plasma/desktoptheme/niceos9-dark"
rm -rf "$HOME/.local/share/wallpapers/NiceOS9"
rm -rf "$HOME/.local/share/aurorae/themes/ChicagoNine"
rm -rf "$HOME/.local/share/aurorae/themes/ChicagoNineDark"
rm -rf "$HOME/.local/share/icons/nineicons-redux-v0.6"
rm -rf "$HOME/.icons/XCursor-Pro-Red"
rm -f "$HOME/.local/share/color-schemes/NiceOS9Dark.colors"
rm -f "$HOME/.local/share/color-schemes/ChicagoNineLight.colors"
rm -f "$HOME/.local/share/fonts/ChicagoFLF.ttf"
rm -f "$HOME/.local/bin/panel-nofloat.sh"
rm -f "$HOME/.config/autostart/panel-nofloat.desktop"

echo "Refreshing font cache..."
fc-cache -f "$HOME/.local/share/fonts/" >/dev/null 2>&1 || true

echo ""
echo "Removing optional system-wide NiceOS9 themes..."

if [ -d "$SCRIPT_DIR/sddm/niceos9-sddm" ] || [ -d /usr/share/sddm/themes/niceos9-sddm ]; then
    sudo rm -rf /usr/share/sddm/themes/niceos9-sddm
fi

if [ -d "$SCRIPT_DIR/plymouth/niceos9-plymouth" ] || [ -d /usr/share/plymouth/themes/niceos9-plymouth ]; then
    sudo rm -rf /usr/share/plymouth/themes/niceos9-plymouth
fi

if [ -d "$SCRIPT_DIR/grub/niceos9-grub" ] || [ -d "$GRUB_THEME_DIR" ]; then
    sudo rm -rf "$GRUB_THEME_DIR"
fi

echo ""
echo "=== Uninstall complete ==="
echo ""
echo "Local theme files have been removed."
echo "If NiceOS9 was active, switch back to a different Global Theme in System Settings."
echo ""
if [ "$is_debian_family" = true ]; then
    echo "If you had enabled the boot screen, restore a different Plymouth theme and rebuild initramfs:"
    echo "  sudo plymouth-set-default-theme bgrt && sudo update-initramfs -u"
    echo "If you had enabled the GRUB theme, remove the GRUB_THEME line from /etc/default/grub and run:"
    echo "  sudo update-grub"
else
    echo "If you had enabled the boot screen, restore a different Plymouth theme and rebuild initramfs:"
    echo "  sudo plymouth-set-default-theme bgrt && sudo dracut -f"
    echo "If you had enabled the GRUB theme, remove the GRUB_THEME line from /etc/default/grub and run:"
    echo "  sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
fi
echo "If you had enabled the SDDM theme, switch SDDM back to another theme in System Settings or /etc/sddm.conf.d/."
