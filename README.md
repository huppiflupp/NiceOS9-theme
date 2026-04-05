# NiceOS9 KDE Plasma Theme — v5.1.0

Two KDE Plasma look-and-feel themes inspired by classic Mac OS 9 aesthetics.

## Variants

| Theme | Color Scheme | Window Decoration | Cursor | Plasma Shell |
|---|---|---|---|---|
| **NiceOS9 dark** | NiceOS9Dark | ChicagoNineDark (Aurorae) | Breeze | niceos9-dark |
| **NiceOS9 bright** | ChicagoNineLight | ChicagoNine (Aurorae) | XCursor-Pro-Red | niceos9-bright |

Both themes use:
- **Icons:** nineicons-redux-v0.6
- **Widget style:** Fusion (built-in Qt)
- **Font:** ChicagoFLF (public domain, by Robin Casady)

## What's included

```
look-and-feel/     — NiceOS9 dark + NiceOS9 bright global theme packages
  contents/
    lockscreen/    — Mac OS 9 Finder Greeter for kscreenlocker (plasmalogin)
wallpapers/        — shared wallpaper assets, generated variants, and wallpaper roadmap
    layouts/       — desktop layout JS
desktoptheme/      — niceos9-dark + niceos9-bright Plasma desktop themes (panel/taskbar assets + colors)
plasma/            — legacy shell theme sources kept for compatibility
color-schemes/     — NiceOS9Dark.colors, ChicagoNineLight.colors
aurorae/           — ChicagoNine (bright) + ChicagoNineDark (dark) window decorations
icons/             — nineicons-redux-v0.6 icon theme
cursors/           — XCursor-Pro-Red cursor theme (used by bright)
fonts/             — ChicagoFLF.ttf (public domain)
plymouth/          — niceos9-plymouth boot screen (Happy Mac, Plymouth Script plugin)
grub/              — niceos9-grub boot menu (Mac OS 9 Platinum desktop background)
sddm/              — niceos9-sddm login screen (Finder Greeter, for systems using SDDM)
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

## Uninstall / stale-file cleanup

To remove the NiceOS9 files installed by this project:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

This removes the local Plasma theme assets, the old stale `look-and-feel/NiceOS9 ...`
package directories, and the optional system-wide SDDM, Plymouth, and GRUB theme
directories if they were installed.

## Manual installation

If you prefer to install components individually, copy each folder to the
corresponding location in your home directory:

| Source | Destination |
|---|---|
| `look-and-feel/niceos9-dark` | `~/.local/share/plasma/look-and-feel/` |
| `look-and-feel/niceos9-bright` | `~/.local/share/plasma/look-and-feel/` |
| `desktoptheme/niceos9-dark` | `~/.local/share/plasma/desktoptheme/` |
| `desktoptheme/niceos9-bright` | `~/.local/share/plasma/desktoptheme/` |
| `wallpapers/NiceOS9` | `~/.local/share/wallpapers/` |
| `color-schemes/*.colors` | `~/.local/share/color-schemes/` |
| `aurorae/ChicagoNine` | `~/.local/share/aurorae/themes/` |
| `aurorae/ChicagoNineDark` | `~/.local/share/aurorae/themes/` |
| `icons/nineicons-redux-v0.6` | `~/.local/share/icons/` |
| `cursors/XCursor-Pro-Red` | `~/.icons/` |
| `fonts/ChicagoFLF.ttf` | `~/.local/share/fonts/` |

After copying fonts run: `fc-cache -f ~/.local/share/fonts/`

Then open **System Settings → Colors & Themes → Global Theme** and select
**NiceOS9 dark** or **NiceOS9 bright**.

> **Note:** The installer sets up wallpaper paths and kscreenlocker config automatically.
> If you install manually, run the `kwriteconfig6` commands in `install.sh` (search for
> `kscreenlockerrc`) to configure the lock screen background.

---

## Panel / taskbar (Plasma shell theme)

The panel color is controlled by the **Plasma shell theme** — separate from the
application color scheme and the look-and-feel package itself.

| Theme | Plasma shell | Panel background | Panel text |
|---|---|---|---|
| **NiceOS9 dark** | niceos9-dark | `#2c2a28` dark warm charcoal | cream white |
| **NiceOS9 bright** | niceos9-bright | `#c8c4bc` Platinum gray | black |

`install.sh` copies both desktop themes to `~/.local/share/plasma/desktoptheme/`.
The `defaults` files in each look-and-feel package reference them so they apply
automatically when you select the global theme.

The panel is also forced to **non-floating** mode by the autostart script
`autostart/panel-nofloat.sh` (installed to `~/.local/bin/` and registered in
`~/.config/autostart/`). Plasma 6 resets floating mode on each session start, so
the autostart runs 4 seconds after login and keeps only `floating = false`.
Panel height is now user-editable after install. The installer also supports an
initial default height with `NICEOS9_PANEL_HEIGHT=40 ./install.sh`.

### Adjusting panel colors

The shell themes are plain text files. To tune the panel background:

```bash
# Edit the colors file
nano ~/.local/share/plasma/desktoptheme/niceos9-bright/colors
# Change Colors:Complementary > BackgroundNormal to your preferred R,G,B
# Then restart Plasma shell to apply:
plasmashell --replace &
```

---

## Lock screen (plasmalogin / kscreenlocker)

On Nobara and most modern KDE setups, `plasmalogin` is the display manager. When you
lock your session, `plasmalogin` hands off to **kscreenlocker**, which loads the lock
screen UI from the active look-and-feel's `contents/lockscreen/` directory.

The NiceOS9 lock screen renders the same **Mac OS 9 Finder Greeter** as the SDDM theme:
- Mac OS 9 menu bar at the top with live clock
- Platinum-chrome login window with user avatar, password field and Unlock button
- NiceOS9 wallpaper as background from the shared `~/.local/share/wallpapers/NiceOS9/` install
- Current defaults: `Flowing_Indigo_Wave.png` for dark and `Flowing_Platinum_Wave.png` for bright

**Test without locking your session:**

```bash
/usr/libexec/kscreenlocker_greet --testing
```

Press any key or move the mouse to show the password prompt. Press Escape to dismiss.

### How the background works

kscreenlocker renders a wallpaper layer (from `~/.config/kscreenlockerrc`) below the
QML. `install.sh` updates that key to the NiceOS9 wallpaper so there is no flash of
a foreign background on slow hardware. The QML itself also renders the wallpaper
directly as an `Image` item — no dependency on the `wallpaper` context property, which
was how Nobara's background was bleeding through before.

**Do not** replace the `Image` with `WallpaperFader { source: wallpaper }`. The
`wallpaper` context property reads from `kscreenlockerrc` (defaults to Nobara's image).
`WallpaperFader { source: someItem }` also silently fails if the item source hasn't
rendered to a layer yet, leaving the compositor background visible.

### Key files to edit if you want to change the lock screen

| File | What it controls |
|---|---|
| `look-and-feel/niceos9-dark/contents/lockscreen/LockScreenUi.qml` | Background image, menu bar, lifecycle, opacity animations |
| `look-and-feel/niceos9-dark/contents/lockscreen/MainBlock.qml` | Platinum login window, avatar, password field, Unlock button |
| `look-and-feel/niceos9-dark/contents/lockscreen/MacButton.qml` | Shared Mac OS 9 button component |
| `look-and-feel/niceos9-dark/contents/lockscreen/LockScreen.qml` | Root container — exposes kscreenlocker's required API (do not change without reading kscreenlocker docs) |

After editing, redeploy with:

```bash
cp -r look-and-feel/niceos9-dark ~/.local/share/plasma/look-and-feel/
cp fonts/ChicagoFLF.ttf ~/.local/share/plasma/look-and-feel/niceos9-dark/contents/lockscreen/
```

---

## Login screen (SDDM)

> **Note:** On Nobara and other systems using `plasmalogin`, the initial login
> screen (before your session starts) uses a **binary-compiled greeter** —
> `plasma-login-greeter`. Its UI is embedded in the executable and cannot be
> themed via QML. Only its background wallpaper is configurable (via
> `/etc/plasmalogin.conf` or System Settings → Security → Screen Locking).
>
> The SDDM theme below applies to systems that actually use SDDM as their
> display manager.

The `sddm/niceos9-sddm/` theme renders a Mac OS 9 "Finder Greeter": platinum menu bar
with live clock, blue Finder desktop, and a Mac OS 9-style login dialog with beveled
title bar, user avatar, and styled buttons.

**Install requires root** (SDDM themes are system-wide):

```bash
sudo cp -r sddm/niceos9-sddm /usr/share/sddm/themes/
```

**Activate** — either via System Settings → Colors & Themes → Login Screen (SDDM), or
directly:

```bash
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=niceos9-sddm" | sudo tee /etc/sddm.conf.d/niceos9.conf
```

On Ubuntu-based Plasma systems such as KDE neon, SDDM is usually still the display
manager, so the SDDM theme above is the path that matters. On Fedora derivatives such
as Nobara, check first whether the system is using `sddm` or `plasmalogin`.

---

## Boot screen (Plymouth)

The `plymouth/niceos9-plymouth/` theme shows a classic compact Mac face ("Happy Mac")
on a platinum gray background with an animated candy-stripe progress bar, rendered in
ChicagoFLF.

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
sudo update-initramfs -u   # Ubuntu / Debian / KDE neon
# or:
sudo dracut -f
```

The `generate-assets.py` script uses the bundled ChicagoFLF font to bake text into
PNGs so no font is needed inside the initramfs.

### Applying changes after editing the theme

Plymouth is embedded into the initramfs, so editing source files has no effect until
you reinstall and rebuild it. After any change to files in `plymouth/niceos9-plymouth/`:

```bash
python3 plymouth/niceos9-plymouth/generate-assets.py
sudo cp plymouth/niceos9-plymouth/*.png \
        plymouth/niceos9-plymouth/niceos9.script \
        plymouth/niceos9-plymouth/niceos9-plymouth.plymouth \
        /usr/share/plymouth/themes/niceos9-plymouth/
sudo plymouth-set-default-theme niceos9-plymouth
sudo update-initramfs -u   # Ubuntu / Debian / KDE neon
# or:
sudo dracut -f             # Fedora / Nobara
```

Rebuilding the initramfs takes 30–60 seconds. The updated animation appears on the
next reboot.

---

## GRUB boot menu

The `grub/niceos9-grub/` theme shows a 1920×1080 platinum Mac OS 9 desktop as the
GRUB background: a menu bar at the top, a large Happy Mac centred on screen, the
"NiceOS 9" title, and a "Select a startup volume:" prompt — with the boot entry list
appearing below as a Mac OS 9-style dialog window.

**Install requires root** (GRUB themes are system-wide):

```bash
# Generate PNG assets (Pillow required: pip install Pillow)
python3 grub/niceos9-grub/generate-assets.py

# Copy to system
sudo mkdir -p /boot/grub/themes/niceos9-grub     # Ubuntu / Debian / KDE neon
# or:
sudo mkdir -p /boot/grub2/themes/niceos9-grub    # Fedora / Nobara
sudo cp grub/niceos9-grub/*.png grub/niceos9-grub/theme.txt /boot/grub/themes/niceos9-grub/
# or:
sudo cp grub/niceos9-grub/*.png grub/niceos9-grub/theme.txt /boot/grub2/themes/niceos9-grub/

# Generate PF2 fonts from ChicagoFLF
# Use grub-mkfont on Ubuntu/Debian, or grub2-mkfont on Fedora if that is the installed name.
sudo grub-mkfont -s 18 -n "ChicagoFLF 18" \
    -o /boot/grub/themes/niceos9-grub/ChicagoFLF-18.pf2 fonts/ChicagoFLF.ttf
sudo grub-mkfont -s 14 -n "ChicagoFLF 14" \
    -o /boot/grub/themes/niceos9-grub/ChicagoFLF-14.pf2 fonts/ChicagoFLF.ttf
# or on Fedora/Nobara:
sudo grub2-mkfont -s 18 -n "ChicagoFLF 18" \
    -o /boot/grub2/themes/niceos9-grub/ChicagoFLF-18.pf2 fonts/ChicagoFLF.ttf
sudo grub2-mkfont -s 14 -n "ChicagoFLF 14" \
    -o /boot/grub2/themes/niceos9-grub/ChicagoFLF-14.pf2 fonts/ChicagoFLF.ttf
```

**Activate** — add the theme line to `/etc/default/grub`, then rebuild:

```bash
# Ubuntu / Debian / KDE neon:
GRUB_THEME='/boot/grub/themes/niceos9-grub/theme.txt'
sudo update-grub

# Fedora / Nobara:
GRUB_THEME='/boot/grub2/themes/niceos9-grub/theme.txt'
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

> **Fedora / Nobara note:** the config file is `/boot/grub2/grub.cfg` on BIOS and
> `/boot/efi/EFI/fedora/grub.cfg` on UEFI. Use whichever matches your system.

### Applying changes after editing the theme

```bash
python3 grub/niceos9-grub/generate-assets.py
sudo cp grub/niceos9-grub/*.png /boot/grub/themes/niceos9-grub/
sudo update-grub

# or on Fedora / Nobara:
sudo cp grub/niceos9-grub/*.png /boot/grub2/themes/niceos9-grub/
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
