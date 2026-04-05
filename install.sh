#!/usr/bin/env bash
# NiceOS9 KDE Plasma Theme Installer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PANEL_HEIGHT="${NICEOS9_PANEL_HEIGHT:-32}"

# ── OS detection ─────────────────────────────────────────────────────────────
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

export is_debian_family is_fedora_family SCRIPT_DIR PANEL_HEIGHT

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
echo "=== NiceOS9 KDE Theme Installer ==="
echo ""
echo "Select components to install:"
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
echo "  Cursors: XCursor-Pro-Red is no longer bundled."
echo "           Get it from kde-look.org (search 'XCursor-Pro-Red')."
echo ""

if ! $do_kde && ! $do_icons && ! $do_sddm && ! $do_plymouth && ! $do_grub; then
    echo "Nothing selected. Exiting."
    exit 0
fi

echo "Installing selected components..."
echo ""

# ── KDE theme ─────────────────────────────────────────────────────────────────
if $do_kde; then
    echo "Removing stale KDE theme files from previous installs..."
    rm -rf "$HOME/.local/share/plasma/look-and-feel/NiceOS9 dark"
    rm -rf "$HOME/.local/share/plasma/look-and-feel/NiceOS9 bright"
    rm -rf "$HOME/.local/share/plasma/look-and-feel/niceos9-dark"
    rm -rf "$HOME/.local/share/plasma/look-and-feel/niceos9-bright"
    rm -rf "$HOME/.local/share/plasma/desktoptheme/niceos9-bright"
    rm -rf "$HOME/.local/share/plasma/desktoptheme/niceos9-dark"
    rm -rf "$HOME/.local/share/wallpapers/NiceOS9"
    rm -rf "$HOME/.local/share/aurorae/themes/ChicagoNine"
    rm -rf "$HOME/.local/share/aurorae/themes/ChicagoNineDark"

    echo "[KDE] Installing look-and-feel packages..."
    mkdir -p "$HOME/.local/share/plasma/look-and-feel"
    cp -r "$SCRIPT_DIR/look-and-feel/niceos9-dark"   "$HOME/.local/share/plasma/look-and-feel/"
    cp -r "$SCRIPT_DIR/look-and-feel/niceos9-bright" "$HOME/.local/share/plasma/look-and-feel/"

    sed -i "s|HOME_PLACEHOLDER|$HOME|g" \
        "$HOME/.local/share/plasma/look-and-feel/niceos9-dark/contents/layouts/org.kde.plasma.desktop-layout.js" \
        "$HOME/.local/share/plasma/look-and-feel/niceos9-bright/contents/layouts/org.kde.plasma.desktop-layout.js" \
        "$HOME/.local/share/plasma/look-and-feel/niceos9-dark/contents/lockscreen/LockScreenUi.qml" \
        "$HOME/.local/share/plasma/look-and-feel/niceos9-bright/contents/lockscreen/LockScreenUi.qml"

    sed -i "s|PANEL_HEIGHT_PLACEHOLDER|$PANEL_HEIGHT|g" \
        "$HOME/.local/share/plasma/look-and-feel/niceos9-dark/contents/layouts/org.kde.plasma.desktop-layout.js" \
        "$HOME/.local/share/plasma/look-and-feel/niceos9-bright/contents/layouts/org.kde.plasma.desktop-layout.js"

    echo "[KDE] Installing wallpapers..."
    mkdir -p "$HOME/.local/share/wallpapers"
    cp -r "$SCRIPT_DIR/wallpapers/NiceOS9" "$HOME/.local/share/wallpapers/"

    _KSL_WALL="file://$HOME/.local/share/wallpapers/NiceOS9/dark/Flowing_Indigo_Wave.png"
    kwriteconfig6 --file kscreenlockerrc \
        --group "Greeter" --group "Wallpaper" --group "org.kde.image" --group "General" \
        --key "Image" "$_KSL_WALL"
    kwriteconfig6 --file kscreenlockerrc \
        --group "Greeter" --group "Wallpaper" --group "org.kde.image" --group "General" \
        --key "PreviewImage" "$_KSL_WALL"
    unset _KSL_WALL

    echo "[KDE] Installing desktop themes..."
    mkdir -p "$HOME/.local/share/plasma/desktoptheme"
    cp -r "$SCRIPT_DIR/desktoptheme/niceos9-bright" "$HOME/.local/share/plasma/desktoptheme/"
    cp -r "$SCRIPT_DIR/desktoptheme/niceos9-dark"   "$HOME/.local/share/plasma/desktoptheme/"

    echo "[KDE] Installing color schemes..."
    mkdir -p "$HOME/.local/share/color-schemes"
    cp "$SCRIPT_DIR/color-schemes/"*.colors "$HOME/.local/share/color-schemes/"

    echo "[KDE] Installing ChicagoNine window decorations..."
    mkdir -p "$HOME/.local/share/aurorae/themes"
    cp -r "$SCRIPT_DIR/aurorae/ChicagoNine"     "$HOME/.local/share/aurorae/themes/"
    cp -r "$SCRIPT_DIR/aurorae/ChicagoNineDark" "$HOME/.local/share/aurorae/themes/"

    echo "[KDE] Installing ChicagoFLF font..."
    mkdir -p "$HOME/.local/share/fonts"
    cp "$SCRIPT_DIR/fonts/"*.ttf "$HOME/.local/share/fonts/"
    cp "$SCRIPT_DIR/fonts/ChicagoFLF.ttf" \
        "$HOME/.local/share/plasma/look-and-feel/niceos9-dark/contents/lockscreen/"
    cp "$SCRIPT_DIR/fonts/ChicagoFLF.ttf" \
        "$HOME/.local/share/plasma/look-and-feel/niceos9-bright/contents/lockscreen/"
    fc-cache -f "$HOME/.local/share/fonts/"

    echo "[KDE] Installing panel autostart fix..."
    mkdir -p "$HOME/.local/bin" "$HOME/.config/autostart"
    cp "$SCRIPT_DIR/autostart/panel-nofloat.sh" "$HOME/.local/bin/"
    chmod +x "$HOME/.local/bin/panel-nofloat.sh"
    sed "s|/home/seeas|$HOME|g" "$SCRIPT_DIR/autostart/panel-nofloat.desktop" \
        > "$HOME/.config/autostart/panel-nofloat.desktop"

    echo ""
    echo "  KDE theme installed."
    echo "  Apply via System Settings > Colors & Themes > Global Theme"
    echo "  and select 'NiceOS9 dark' or 'NiceOS9 bright'."
    echo "  Panel height used for new layouts: $PANEL_HEIGHT"
    echo "  Override with: NICEOS9_PANEL_HEIGHT=40 ./install.sh"
    echo ""
fi

# ── Icons ─────────────────────────────────────────────────────────────────────
if $do_icons; then
    echo "[Icons] Removing stale icon files..."
    rm -rf "$HOME/.local/share/icons/nineicons-redux-v0.6"

    echo "[Icons] Installing nineicons-redux..."
    mkdir -p "$HOME/.local/share/icons"
    cp -r "$SCRIPT_DIR/icons/nineicons-redux-v0.6" "$HOME/.local/share/icons/"
    echo ""
    echo "  Icons installed. Select 'nineicons-redux' in System Settings > Icons."
    echo ""
fi

# ── SDDM ──────────────────────────────────────────────────────────────────────
if $do_sddm; then
    echo "[SDDM] Installing login screen theme..."
    if [ -d "$SCRIPT_DIR/sddm/niceos9-sddm" ]; then
        SDDM_DEST="/usr/share/sddm/themes/niceos9-sddm"
        echo "       Installing to $SDDM_DEST (requires sudo)..."
        sudo mkdir -p "$SDDM_DEST"
        sudo cp -r "$SCRIPT_DIR/sddm/niceos9-sddm"/. "$SDDM_DEST/"
        echo ""
        echo "  SDDM theme installed."
        echo "  Activate via System Settings > Colors & Themes > Login Screen (SDDM)"
        echo "  or set Theme=niceos9-sddm in /etc/sddm.conf.d/theme.conf"
        echo ""
    else
        echo "  SDDM theme source not found, skipping."
    fi
fi

# ── Plymouth ──────────────────────────────────────────────────────────────────
if $do_plymouth; then
    # shellcheck source=install-plymouth.sh
    source "$SCRIPT_DIR/install-plymouth.sh"
fi

# ── GRUB ──────────────────────────────────────────────────────────────────────
if $do_grub; then
    # shellcheck source=install-grub.sh
    source "$SCRIPT_DIR/install-grub.sh"
fi

echo "=== Installation complete! ==="
