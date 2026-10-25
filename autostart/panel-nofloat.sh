#!/bin/bash
# Wait for plasmashell to be fully ready
sleep 4
# The Qt 6 D-Bus tool goes by different names: qdbus6 (Arch, Gentoo,
# openSUSE), qdbus-qt6 (Fedora), qdbus (Debian/Ubuntu).
QDBUS=$(command -v qdbus6 || command -v qdbus-qt6 || command -v qdbus) || exit 0
"$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
for (var i = 0; i < panels().length; i++) {
    panels()[i].floating = false;
}
'
