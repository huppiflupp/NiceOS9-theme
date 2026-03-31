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

# Color schemes
echo "[2/7] Installing color schemes..."
mkdir -p "$HOME/.local/share/color-schemes"
cp "$SCRIPT_DIR/color-schemes/"*.colors "$HOME/.local/share/color-schemes/"

# Aurorae window decoration (used by NiceOS9 bright)
echo "[3/7] Installing ChicagoNine window decoration..."
mkdir -p "$HOME/.local/share/aurorae/themes"
cp -r "$SCRIPT_DIR/aurorae/ChicagoNine" "$HOME/.local/share/aurorae/themes/"

# Icon theme
echo "[4/7] Installing nineicons-redux icon theme..."
mkdir -p "$HOME/.local/share/icons"
cp -r "$SCRIPT_DIR/icons/nineicons-redux-v0.6" "$HOME/.local/share/icons/"

# Cursor theme (XCursor-Pro-Red, used by NiceOS9 bright)
echo "[5/7] Installing XCursor-Pro-Red cursor theme..."
mkdir -p "$HOME/.icons"
cp -r "$SCRIPT_DIR/cursors/XCursor-Pro-Red" "$HOME/.icons/"

# Font
echo "[6/7] Installing Chicago font..."
mkdir -p "$HOME/.local/share/fonts"
cp "$SCRIPT_DIR/fonts/"*.ttf "$HOME/.local/share/fonts/"
fc-cache -f "$HOME/.local/share/fonts/"

# Wallpapers
echo "[7/7] Installing wallpapers..."
mkdir -p "$HOME/.local/share/wallpapers"
cp -r "$SCRIPT_DIR/wallpapers/chicago-nine" "$HOME/.local/share/wallpapers/"
cp -r "$SCRIPT_DIR/wallpapers/nineos" "$HOME/.local/share/wallpapers/"

echo ""
echo "=== Installation complete! ==="
echo ""
echo "To apply a theme, open System Settings > Colors & Themes > Global Theme"
echo "and select 'NiceOS9 dark' or 'NiceOS9 bright'."
echo ""
echo "Color schemes installed:"
echo "  NiceOS9 dark  → NiceOS9Dark (bundled)"
echo "  NiceOS9 bright → ChicagoNineLight (bundled)"
