# NiceOS9 Plymouth — Happy Mac Boot Splash

A Mac OS 9 inspired Plymouth boot splash for KDE Plasma 6.

Greets you at startup with the classic Happy Mac icon on a platinum gray
background, a "Welcome to NiceOS 9" message, and the iconic candy-stripe
progress bar — just like booting a Power Mac in 1999.

## Requirements

- Plymouth
- Python 3 + Pillow (`pip install Pillow`)

## Install

```bash
chmod +x install-plymouth.sh
./install-plymouth.sh
```

Then activate:

```bash
sudo plymouth-set-default-theme niceos9-plymouth
# Fedora / Nobara:
sudo dracut -f
# Ubuntu / KDE neon:
sudo update-initramfs -u
```

## Part of

[NiceOS9 KDE Theme](https://github.com/huppiflupp/NiceOS9-theme) — a full
Mac OS 9 Platinum desktop experience for KDE Plasma 6.
