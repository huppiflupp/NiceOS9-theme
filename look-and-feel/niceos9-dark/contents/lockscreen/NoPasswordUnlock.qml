/*
    NiceOS 9 — NoPasswordUnlock
    Shown when PAM authenticates without requiring a password prompt.
    Keeps SessionManagementScreen as base (provides tryToSwitchUser).
*/
import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.breeze.components

SessionManagementScreen {
    id: root
    focus: true

    MacButton {
        id: unlockBtn
        focus: true
        text: "Unlock"
        isDefault: true
        fontFamily: "ChicagoFLF"
        onClicked: Qt.quit()
        Keys.onReturnPressed: Qt.quit()
        Keys.onEnterPressed:  Qt.quit()
    }

    Component.onCompleted: {
        forceActiveFocus()
        Qt.callLater(tryToSwitchUser, false)
    }
}
