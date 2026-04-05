/*
    NiceOS 9 — Plasma Login Screen (plasmalogin / kscreenlocker)
    Root container: exposes the magical properties kscreenlocker looks for.
    Based on org.kde.breeze pattern.
*/
import QtQuick 2.5
import org.kde.plasma.private.sessions 2.0
import org.kde.breeze.components

Item {
    id: root

    // ── kscreenlocker magic properties ─────────────────────────────────────
    property bool   debug:                 false
    property string notification
    signal clearPassword()
    signal notificationRepeated()

    property bool viewVisible:           false
    property bool suspendToRamSupported: false
    property bool suspendToDiskSupported: false
    signal suspendToDisk()
    signal suspendToRam()
    // ───────────────────────────────────────────────────────────────────────

    LayoutMirroring.enabled:        Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    implicitWidth:  800
    implicitHeight: 600

    LockScreenUi {
        anchors.fill: parent
    }
}
