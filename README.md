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
```

## Installation

```bash
git clone https://github.com/huppiflupp/NiceOS9-theme.git
cd NiceOS9-theme
chmod +x install.sh
./install.sh
```

Then open **System Settings → Colors & Themes → Global Theme** and select
**NiceOS9 dark** or **NiceOS9 bright**.

## Manual installation

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
After copying fonts, run `fc-cache -f ~/.local/share/fonts/`.
