# NiceOS9 KDE Plasma Theme

Two KDE Plasma look-and-feel themes inspired by classic Mac OS 9 aesthetics.

## Variants

| Theme | Color Scheme | Window Decoration | Cursor | Plasma Shell |
|---|---|---|---|---|
| **NiceOS9 dark** | ArcDark *(system package)* | Breeze | Breeze | Breeze |
| **NiceOS9 bright** | BesotHaiku | ChicagoNine (Aurorae) | XCursor-Pro-Red | Default |

Both themes use:
- **Icons:** nineicons-redux-v0.6
- **Widget style:** Fusion (built-in Qt)
- **Font:** Chicago

## What's included

```
look-and-feel/     — NiceOS9 dark + NiceOS9 bright global theme packages
color-schemes/     — BesotHaiku.colors (used by bright)
aurorae/           — ChicagoNine window decoration (used by bright)
icons/             — nineicons-redux-v0.6 icon theme
cursors/           — XCursor-Pro-Red cursor theme (used by bright)
fonts/             — Chicago.ttf
wallpapers/        — chicago-nine/ and nineos/ wallpaper sets
```

## Installation

### 1. System dependency (dark theme only)

NiceOS9 dark uses the **ArcDark** color scheme from the `arc-kde` package:

```bash
# Fedora / Nobara
sudo dnf install arc-kde

# Arch Linux
sudo pacman -S arc-kde

# Ubuntu / Debian
sudo apt install arc-kde
```

### 2. Run the installer

```bash
git clone https://github.com/huppiflupp/NiceOS9-theme.git
cd NiceOS9-theme
chmod +x install.sh
./install.sh
```

### 3. Apply the theme

Open **System Settings → Colors & Themes → Global Theme** and select
**NiceOS9 dark** or **NiceOS9 bright**.

## Manual installation

If you prefer to install components individually, copy each folder to the
corresponding location in your home directory:

| Source | Destination |
|---|---|
| `look-and-feel/NiceOS9 dark` | `~/.local/share/plasma/look-and-feel/` |
| `look-and-feel/NiceOS9 bright` | `~/.local/share/plasma/look-and-feel/` |
| `color-schemes/*.colors` | `~/.local/share/color-schemes/` |
| `aurorae/ChicagoNine` | `~/.local/share/aurorae/themes/` |
| `icons/nineicons-redux-v0.6` | `~/.local/share/icons/` |
| `cursors/XCursor-Pro-Red` | `~/.icons/` |
| `fonts/Chicago.ttf` | `~/.local/share/fonts/` |
| `wallpapers/chicago-nine` | `~/.local/share/wallpapers/` |
| `wallpapers/nineos` | `~/.local/share/wallpapers/` |

After copying fonts, run `fc-cache -f ~/.local/share/fonts/`.
