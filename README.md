# NiceOS9 KDE Plasma Theme

Two KDE Plasma look-and-feel themes inspired by classic Mac OS 9 aesthetics.

## Variants

| Theme | Color Scheme | Window Decoration | Cursor | Plasma Shell |
|---|---|---|---|---|
| **NiceOS9 dark** | NiceOS9Dark | ChicagoNineDark (Aurorae) | Breeze | Breeze Dark |
| **NiceOS9 bright** | ChicagoNineLight | ChicagoNine (Aurorae) | XCursor-Pro-Red | Default |

Both themes use:
- **Icons:** nineicons-redux-v0.6
- **Widget style:** Fusion (built-in Qt)
- **Font:** ChicagoFLF (public domain, by Robin Casady)

## What's included

```
look-and-feel/     — NiceOS9 dark + NiceOS9 bright global theme packages
color-schemes/     — NiceOS9Dark.colors, ChicagoNineLight.colors
aurorae/           — ChicagoNine (bright) + ChicagoNineDark (dark) window decorations
icons/             — nineicons-redux-v0.6 icon theme
cursors/           — XCursor-Pro-Red cursor theme (used by bright)
fonts/             — ChicagoFLF.ttf (public domain)
plymouth/          — niceos9-plymouth boot screen (Happy Mac, Plymouth Script plugin)
sddm/              — niceos9-sddm login screen (Finder Greeter, SDDM/QML)
previews/          — HTML design mockups for boot + login screen variants
```

## Installation

### From KDE Look (zip download)

1. Extract the zip archive
2. Open a terminal inside the extracted folder
3. Run the installer:

```bash
chmod +x install.sh
./install.sh
```

4. Open **System Settings → Colors & Themes → Global Theme**
5. Select **NiceOS9 dark** or **NiceOS9 bright** and click Apply

### From GitHub

```bash
git clone https://github.com/huppiflupp/NiceOS9-theme.git
cd NiceOS9-theme
chmod +x install.sh
./install.sh
```

## Manual installation

If you prefer to install components individually, copy each folder to the
corresponding location in your home directory:

| Source | Destination |
|---|---|
| `look-and-feel/NiceOS9 dark` | `~/.local/share/plasma/look-and-feel/` |
| `look-and-feel/NiceOS9 bright` | `~/.local/share/plasma/look-and-feel/` |
| `color-schemes/*.colors` | `~/.local/share/color-schemes/` |
| `aurorae/ChicagoNine` | `~/.local/share/aurorae/themes/` |
| `aurorae/ChicagoNineDark` | `~/.local/share/aurorae/themes/` |
| `icons/nineicons-redux-v0.6` | `~/.local/share/icons/` |
| `cursors/XCursor-Pro-Red` | `~/.icons/` |
| `fonts/ChicagoFLF.ttf` | `~/.local/share/fonts/` |

After copying fonts run: `fc-cache -f ~/.local/share/fonts/`

Then open **System Settings → Colors & Themes → Global Theme** and select
**NiceOS9 dark** or **NiceOS9 bright**.

> **Note:** The installer sets up wallpaper paths automatically.
> If you install manually, apply the theme once via System Settings to
> trigger the wallpaper setup.

## Boot screen (Plymouth)

The `plymouth/niceos9-plymouth/` theme shows a classic compact Mac face ("Happy Mac") on a platinum gray background with an animated candy-stripe progress bar, rendered in ChicagoFLF.

**Install requires root** (Plymouth themes are system-wide):

```bash
# Generate PNG assets (Pillow required: pip install Pillow)
python3 plymouth/niceos9-plymouth/generate-assets.py

# Copy to system and activate
sudo mkdir -p /usr/share/plymouth/themes/niceos9-plymouth
sudo cp plymouth/niceos9-plymouth/*.png \
        plymouth/niceos9-plymouth/niceos9.script \
        plymouth/niceos9-plymouth/niceos9-plymouth.plymouth \
        /usr/share/plymouth/themes/niceos9-plymouth/
sudo plymouth-set-default-theme niceos9-plymouth
sudo dracut -f
```

The `generate-assets.py` script uses the bundled ChicagoFLF font to bake text into PNGs so no font is needed inside the initramfs.

## Login screen (SDDM)

The `sddm/niceos9-sddm/` theme renders a Mac OS 9 "Finder Greeter": platinum menu bar with live clock, blue Finder desktop, and a Mac OS 9-style login dialog with beveled title bar, user avatar, and styled buttons.

**Install requires root** (SDDM themes are system-wide):

```bash
sudo cp -r sddm/niceos9-sddm /usr/share/sddm/themes/
```

**Activate** — either via System Settings → Colors & Themes → Login Screen (SDDM), or directly:

```bash
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=niceos9-sddm" | sudo tee /etc/sddm.conf.d/niceos9.conf
```
