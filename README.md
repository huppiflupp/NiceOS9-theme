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
grub/              — niceos9-grub boot menu (Mac OS 9 Platinum desktop background)
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

### Applying changes after editing the theme

Plymouth is embedded into the initramfs, so editing source files has no effect until you reinstall and rebuild it. After any change to files in `plymouth/niceos9-plymouth/`:

```bash
python3 plymouth/niceos9-plymouth/generate-assets.py
sudo cp plymouth/niceos9-plymouth/*.png \
        plymouth/niceos9-plymouth/niceos9.script \
        plymouth/niceos9-plymouth/niceos9-plymouth.plymouth \
        /usr/share/plymouth/themes/niceos9-plymouth/
sudo plymouth-set-default-theme niceos9-plymouth && sudo dracut -f
```

`dracut -f` rebuilds the initramfs and takes 30–60 seconds. The updated animation appears on the next reboot.

## GRUB boot menu

The `grub/niceos9-grub/` theme shows a 1920×1080 platinum Mac OS 9 desktop as the GRUB background: a menu bar at the top, a large Happy Mac centred on screen, the "NiceOS 9" title, and a "Select a startup volume:" prompt — with the boot entry list appearing below as a Mac OS 9-style dialog window.

**Install requires root** (GRUB themes are system-wide):

```bash
# Generate PNG assets (Pillow required: pip install Pillow)
python3 grub/niceos9-grub/generate-assets.py

# Copy to system
sudo mkdir -p /boot/grub2/themes/niceos9-grub
sudo cp grub/niceos9-grub/*.png \
        grub/niceos9-grub/theme.txt \
        /boot/grub2/themes/niceos9-grub/

# Generate PF2 fonts from ChicagoFLF (grub2-tools required)
sudo grub2-mkfont -s 18 -n "ChicagoFLF 18" \
    -o /boot/grub2/themes/niceos9-grub/ChicagoFLF-18.pf2 fonts/ChicagoFLF.ttf
sudo grub2-mkfont -s 14 -n "ChicagoFLF 14" \
    -o /boot/grub2/themes/niceos9-grub/ChicagoFLF-14.pf2 fonts/ChicagoFLF.ttf
```

**Activate** — add the theme line to `/etc/default/grub`, then rebuild:

```bash
# Add or update this line in /etc/default/grub:
GRUB_THEME=/boot/grub2/themes/niceos9-grub/theme.txt

# Rebuild grub config
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

> **Fedora / Nobara note:** the config file is `/boot/grub2/grub.cfg` on BIOS and
> `/boot/efi/EFI/fedora/grub.cfg` on UEFI. Use whichever matches your system.

### Applying changes after editing the theme

GRUB themes are read at boot time from disk, so there is **no initramfs rebuild** needed — but you must re-run `grub2-mkconfig` whenever you change `theme.txt`, and re-copy the PNGs (and re-run `generate-assets.py`) whenever you change the artwork:

```bash
python3 grub/niceos9-grub/generate-assets.py
sudo cp grub/niceos9-grub/*.png /boot/grub2/themes/niceos9-grub/
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

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
