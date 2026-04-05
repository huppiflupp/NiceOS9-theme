#!/usr/bin/env bash
# NiceOS9 KDE Plasma Theme Uninstaller

set -e

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

if [ "$is_debian_family" = true ]; then
    GRUB_DEST="/boot/grub/themes/niceos9-grub"
else
    GRUB_DEST="/boot/grub2/themes/niceos9-grub"
fi

# ── Helpers ───────────────────────────────────────────────────────────────────
ask() {
    local answer
    while true; do
        printf '%s [y/N]: ' "$1"
        read -r answer
        case "${answer,,}" in
            y|yes) return 0 ;;
            n|no|'') return 1 ;;
        esac
    done
}

# ── Banner ────────────────────────────────────────────────────────────────────
echo "=== NiceOS9 KDE Theme Uninstaller ==="
echo ""
echo "Select components to remove:"
echo ""

# ── Component selection ───────────────────────────────────────────────────────
do_kde=false
do_icons=false
do_sddm=false
do_plymouth=false
do_grub=false

ask "  KDE theme  (look-and-feel, desktop themes, colors, decorations, fonts, wallpapers)" \
    && do_kde=true || true
ask "  Icons  (nineicons-redux)" \
    && do_icons=true || true
ask "  SDDM login screen  (requires sudo)" \
    && do_sddm=true || true
ask "  Plymouth boot splash  (requires sudo)" \
    && do_plymouth=true || true
ask "  GRUB boot menu  (requires sudo)" \
    && do_grub=true || true

echo ""

if ! $do_kde && ! $do_icons && ! $do_sddm && ! $do_plymouth && ! $do_grub; then
    echo "Nothing selected. Exiting."
    exit 0
fi

# ── KDE theme ─────────────────────────────────────────────────────────────────
if $do_kde; then
    echo "[KDE] Removing theme files..."
    rm -rf "$HOME/.local/share/plasma/look-and-feel/NiceOS9 dark"
    rm -rf "$HOME/.local/share/plasma/look-and-feel/NiceOS9 bright"
    rm -rf "$HOME/.local/share/plasma/look-and-feel/niceos9-dark"
    rm -rf "$HOME/.local/share/plasma/look-and-feel/niceos9-bright"
    rm -rf "$HOME/.local/share/plasma/look-and-feel/niceos9-charcoal"
    rm -rf "$HOME/.local/share/plasma/desktoptheme/niceos9-bright"
    rm -rf "$HOME/.local/share/plasma/desktoptheme/niceos9-dark"
    rm -rf "$HOME/.local/share/plasma/desktoptheme/niceos9-charcoal"
    rm -rf "$HOME/.local/share/wallpapers/NiceOS9"
    rm -rf "$HOME/.local/share/aurorae/themes/ChicagoNine"
    rm -rf "$HOME/.local/share/aurorae/themes/ChicagoNineDark"
    rm -rf "$HOME/.local/share/aurorae/themes/ChicagoEight"
    rm -f  "$HOME/.local/share/color-schemes/NiceOS9Dark.colors"
    rm -f  "$HOME/.local/share/color-schemes/ChicagoNineLight.colors"
    rm -f  "$HOME/.local/share/color-schemes/BesotHaiku.colors"
    rm -f  "$HOME/.local/share/color-schemes/NiceOS8Charcoal.colors"
    rm -f  "$HOME/.local/share/fonts/ChicagoFLF.ttf"
    rm -f  "$HOME/.local/bin/panel-nofloat.sh"
    rm -f  "$HOME/.config/autostart/panel-nofloat.desktop"
    fc-cache -f "$HOME/.local/share/fonts/" >/dev/null 2>&1 || true
    echo "  Done. Switch to a different Global Theme in System Settings."
    echo ""
fi

# ── Icons ─────────────────────────────────────────────────────────────────────
if $do_icons; then
    echo "[Icons] Removing nineicons-redux..."
    rm -rf "$HOME/.local/share/icons/nineicons-redux-v0.6"
    echo "  Done."
    echo ""
fi

# ── SDDM ──────────────────────────────────────────────────────────────────────
if $do_sddm; then
    echo "[SDDM] Removing login screen theme (requires sudo)..."
    sudo rm -rf /usr/share/sddm/themes/niceos9-sddm
    echo "  Done. Switch SDDM back to another theme in System Settings or /etc/sddm.conf.d/."
    echo ""
fi

# ── Plymouth ──────────────────────────────────────────────────────────────────
if $do_plymouth; then
    echo "[Plymouth] Removing boot splash theme (requires sudo)..."
    sudo rm -rf /usr/share/plymouth/themes/niceos9-plymouth
    echo "  Done. Restore a Plymouth theme and rebuild:"
    echo "    sudo plymouth-set-default-theme bgrt"
    if [ "$is_debian_family" = true ]; then
        echo "    sudo update-initramfs -u"
    else
        echo "    sudo dracut -f"
    fi
    echo ""
fi

# ── GRUB ──────────────────────────────────────────────────────────────────────
if $do_grub; then
    echo "[GRUB] Removing boot menu theme (requires sudo)..."
    sudo rm -rf "$GRUB_DEST"
    echo "  Done. Remove the GRUB_THEME line from /etc/default/grub and rebuild:"
    if [ "$is_debian_family" = true ]; then
        echo "    sudo update-grub"
    else
        echo "    sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
    fi
    echo ""
fi

echo "=== Uninstall complete ==="
