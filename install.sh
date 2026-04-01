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
# Plymouth boot theme (niceos9-plymouth)
echo "[8/9] Installing NiceOS 9 Plymouth boot theme..."
if [ -d "$SCRIPT_DIR/plymouth/niceos9-plymouth" ]; then
    PLYMOUTH_THEME_DIR="$SCRIPT_DIR/plymouth/niceos9-plymouth"
    # Generate PNG assets (requires Pillow)
    echo "      Generating Plymouth assets (requires Pillow)..."
    if python3 "$PLYMOUTH_THEME_DIR/generate-assets.py"; then
        # Install to system themes directory (requires sudo)
        PLYMOUTH_DEST="/usr/share/plymouth/themes/niceos9-plymouth"
        echo "      Installing to $PLYMOUTH_DEST (requires sudo)..."
        sudo mkdir -p "$PLYMOUTH_DEST"
        sudo cp "$PLYMOUTH_THEME_DIR"/*.png \
                "$PLYMOUTH_THEME_DIR/niceos9.script" \
                "$PLYMOUTH_THEME_DIR/niceos9-plymouth.plymouth" \
                "$PLYMOUTH_DEST/"
        # Register the theme with Plymouth
        sudo update-alternatives --install \
            /usr/share/plymouth/themes/default.plymouth \
            default.plymouth \
            "$PLYMOUTH_DEST/niceos9.plymouth" 100 2>/dev/null || true
        echo "      To activate: sudo plymouth-set-default-theme niceos9-plymouth && sudo dracut -f"
    else
        echo "      WARNING: Asset generation failed. Install Pillow and re-run:"
        echo "               pip install Pillow"
        echo "      Then manually run: python3 $PLYMOUTH_THEME_DIR/generate-assets.py"
    fi
else
    echo "      Plymouth theme source not found, skipping."
fi

# SDDM login theme (niceos9-sddm)
echo "[9/9] Installing NiceOS 9 SDDM login theme..."
if [ -d "$SCRIPT_DIR/sddm/niceos9-sddm" ]; then
    SDDM_DEST="/usr/share/sddm/themes/niceos9-sddm"
    echo "      Installing to $SDDM_DEST (requires sudo)..."
    sudo mkdir -p "$SDDM_DEST"
    sudo cp -r "$SCRIPT_DIR/sddm/niceos9-sddm"/. "$SDDM_DEST/"
    echo "      To activate: set Theme=niceos9-sddm in /etc/sddm.conf.d/theme.conf"
    echo "      Or via System Settings > Colors & Themes > Login Screen (SDDM)"
else
    echo "      SDDM theme source not found, skipping."
fi

# GRUB boot menu theme (niceos9-grub)
echo "[9/10] Installing NiceOS 9 GRUB boot menu theme..."
if [ -d "$SCRIPT_DIR/grub/niceos9-grub" ]; then
    GRUB_THEME_DIR="$SCRIPT_DIR/grub/niceos9-grub"
    echo "      Generating GRUB assets (requires Pillow)..."
    if python3 "$GRUB_THEME_DIR/generate-assets.py"; then
        GRUB_DEST="/boot/grub2/themes/niceos9-grub"
        echo "      Installing to $GRUB_DEST (requires sudo)..."
        sudo mkdir -p "$GRUB_DEST"
        sudo cp "$GRUB_THEME_DIR"/*.png \
                "$GRUB_THEME_DIR/theme.txt" \
                "$GRUB_DEST/"
        # Generate PF2 font (grub-mkfont required — usually in grub2-tools)
        if command -v grub-mkfont &>/dev/null || command -v grub2-mkfont &>/dev/null; then
            MKFONT=$(command -v grub2-mkfont || command -v grub-mkfont)
            FONT_TTF="$SCRIPT_DIR/fonts/ChicagoFLF.ttf"
            echo "      Generating GRUB fonts from ChicagoFLF..."
            sudo "$MKFONT" -s 18 -n "ChicagoFLF 18" -o "$GRUB_DEST/ChicagoFLF-18.pf2" "$FONT_TTF"
            sudo "$MKFONT" -s 14 -n "ChicagoFLF 14" -o "$GRUB_DEST/ChicagoFLF-14.pf2" "$FONT_TTF"
        else
            echo "      WARNING: grub2-mkfont not found — fonts will fall back to GRUB default."
            echo "               Install with: sudo dnf install grub2-tools  (or grub-tools)"
            # Patch theme.txt to use a safe fallback font
            sudo sed -i \
                -e 's/item_font.*=.*/item_font = "Unknown Regular 16"/' \
                -e 's/font.*=.*"ChicagoFLF 14"$/font = "Unknown Regular 14"/' \
                "$GRUB_DEST/theme.txt"
        fi
        echo "      To activate: sudo grub2-set-default 0 && sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
        echo "      Then add/update GRUB_THEME in /etc/default/grub:"
        echo "        GRUB_THEME=$GRUB_DEST/theme.txt"
    else
        echo "      WARNING: Asset generation failed. Install Pillow and re-run:"
        echo "               pip install Pillow"
    fi
else
    echo "      GRUB theme source not found, skipping."
fi

echo ""
echo "=== Installation complete! ==="
echo ""
echo "To apply a theme, open System Settings > Colors & Themes > Global Theme"
echo "and select 'NiceOS9 dark' or 'NiceOS9 bright'."
echo ""
echo "Color schemes installed:"
echo "  NiceOS9 dark  → NiceOS9Dark (bundled)"
echo "  NiceOS9 bright → ChicagoNineLight (bundled)"
echo ""
echo "Boot screen:  sudo plymouth-set-default-theme niceos9-plymouth && sudo dracut -f"
echo "Boot menu:    add GRUB_THEME=/boot/grub2/themes/niceos9-grub/theme.txt to /etc/default/grub"
echo "              then: sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
echo "Login screen: set via System Settings > Login Screen (SDDM)"
