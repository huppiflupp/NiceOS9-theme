#!/usr/bin/env bash
# NiceOS9 KDE Plasma Theme Installer
# Installs both NiceOS9 dark and NiceOS9 bright look-and-feel packages
# along with all required assets.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== NiceOS9 KDE Theme Installer ==="
echo ""

# Look and Feel packages
echo "[1/7] Installing look-and-feel packages..."
mkdir -p "$HOME/.local/share/plasma/look-and-feel"
cp -r "$SCRIPT_DIR/look-and-feel/NiceOS9 dark" "$HOME/.local/share/plasma/look-and-feel/"
cp -r "$SCRIPT_DIR/look-and-feel/NiceOS9 bright" "$HOME/.local/share/plasma/look-and-feel/"

# Inject actual home path into layout.js wallpaper paths
sed -i "s|HOME_PLACEHOLDER|$HOME|g" \
    "$HOME/.local/share/plasma/look-and-feel/NiceOS9 dark/contents/layouts/org.kde.plasma.desktop-layout.js" \
    "$HOME/.local/share/plasma/look-and-feel/NiceOS9 bright/contents/layouts/org.kde.plasma.desktop-layout.js"

# Color schemes
echo "[2/7] Installing color schemes..."
mkdir -p "$HOME/.local/share/color-schemes"
cp "$SCRIPT_DIR/color-schemes/"*.colors "$HOME/.local/share/color-schemes/"

# Aurorae window decoration (used by NiceOS9 bright)
echo "[3/7] Installing ChicagoNine window decorations..."
mkdir -p "$HOME/.local/share/aurorae/themes"
cp -r "$SCRIPT_DIR/aurorae/ChicagoNine" "$HOME/.local/share/aurorae/themes/"
cp -r "$SCRIPT_DIR/aurorae/ChicagoNineDark" "$HOME/.local/share/aurorae/themes/"

# Icon theme
echo "[4/7] Installing nineicons-redux icon theme..."
mkdir -p "$HOME/.local/share/icons"
cp -r "$SCRIPT_DIR/icons/nineicons-redux-v0.6" "$HOME/.local/share/icons/"

# Cursor theme (XCursor-Pro-Red, used by NiceOS9 bright)
echo "[5/7] Installing XCursor-Pro-Red cursor theme..."
mkdir -p "$HOME/.icons"
cp -r "$SCRIPT_DIR/cursors/XCursor-Pro-Red" "$HOME/.icons/"

# Font
echo "[6/7] Installing ChicagoFLF font (public domain by Robin Casady)..."
mkdir -p "$HOME/.local/share/fonts"
cp "$SCRIPT_DIR/fonts/"*.ttf "$HOME/.local/share/fonts/"
fc-cache -f "$HOME/.local/share/fonts/"

# Autostart: keep panel non-floating (Plasma 6 resets this on each restart)
echo "[7/7] Installing panel non-floating autostart fix..."
mkdir -p "$HOME/.local/bin" "$HOME/.config/autostart"
cp "$SCRIPT_DIR/autostart/panel-nofloat.sh" "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/panel-nofloat.sh"
sed "s|/home/seeas|$HOME|g" "$SCRIPT_DIR/autostart/panel-nofloat.desktop" \
    > "$HOME/.config/autostart/panel-nofloat.desktop"

echo ""
echo "=== Installation complete! ==="
echo ""
echo "To apply a theme, open System Settings > Colors & Themes > Global Theme"
echo "and select 'NiceOS9 dark' or 'NiceOS9 bright'."
echo ""
echo "Color schemes installed:"
echo "  NiceOS9 dark  → NiceOS9Dark (bundled)"
echo "  NiceOS9 bright → ChicagoNineLight (bundled)"
