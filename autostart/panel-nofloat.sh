#!/bin/bash
# Wait for plasmashell to be fully ready
sleep 4
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
for (var i = 0; i < panels().length; i++) {
    panels()[i].floating = false;
    panels()[i].height = 32;
}
'
