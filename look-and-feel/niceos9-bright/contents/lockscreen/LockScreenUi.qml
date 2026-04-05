/*
    NiceOS 9 — LockScreenUi
    Lifecycle shell lifted from org.nobaraproject.desktop (GPL-2.0-or-later).
    Mac OS 9 menu bar overlay; wallpaper rendered directly from look-and-feel
    bundle (no dependency on kscreenlockerrc wallpaper config).
*/
import QtQml 2.15
import QtQuick 2.8
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.workspace.components 2.0 as PW
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kscreenlocker 1.0 as ScreenLocker

import org.kde.plasma.private.sessions 2.0
import org.kde.breeze.components

Item {
    id: lockScreenUi

    // Chicago font — co-located in the lockscreen directory by install.sh
    FontLoader { id: _chicagoLoader; source: "ChicagoFLF.ttf" }
    readonly property string cf: _chicagoLoader.status === FontLoader.Ready
                                 ? _chicagoLoader.name : "ChicagoFLF"

    property bool hadPrompt: false

    function handleMessage(msg) {
        if (!root.notification) {
            root.notification += msg;
        } else if (root.notification.includes(msg)) {
            root.notificationRepeated();
        } else {
            root.notification += "\n" + msg
        }
    }

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    // ── Authentication ──────────────────────────────────────────────────────
    Connections {
        target: authenticator
        function onFailed(kind) {
            if (kind !== 0) return;
            lockScreenUi.handleMessage(
                i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Unlocking failed"));
            graceLockTimer.restart();
            notificationRemoveTimer.restart();
            rejectPasswordAnimation.start();
            lockScreenUi.hadPrompt = false;
        }
        function onSucceeded() {
            if (lockScreenUi.hadPrompt) {
                Qt.quit();
            } else {
                mainStack.replace(null, Qt.resolvedUrl("NoPasswordUnlock.qml"),
                    { userListModel: users }, StackView.Immediate);
                mainStack.forceActiveFocus();
            }
        }
        function onInfoMessageChanged() {
            lockScreenUi.handleMessage(authenticator.infoMessage);
            lockScreenUi.hadPrompt = true;
        }
        function onErrorMessageChanged()      { lockScreenUi.handleMessage(authenticator.errorMessage); }
        function onPromptChanged(msg)         { lockScreenUi.handleMessage(authenticator.prompt); }
        function onPromptForSecretChanged(msg) {
            mainBlock.showPassword = false;
            mainBlock.mainPasswordBox.forceActiveFocus();
            lockScreenUi.hadPrompt = true;
        }
    }

    SessionManagement { id: sessionManagement }
    Connections {
        target: sessionManagement
        function onAboutToSuspend() { root.clearPassword(); }
    }

    P5Support.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    RejectPasswordAnimation {
        id: rejectPasswordAnimation
        target: mainBlock
    }

    // ── Main interactive layer ──────────────────────────────────────────────
    MouseArea {
        id: lockScreenRoot

        property bool uiVisible: false
        property bool blockUI: mainStack.depth > 1
                               || mainBlock.mainPasswordBox.text.length > 0
                               || inputPanel.keyboardActive

        x: parent.x; y: parent.y
        width: parent.width; height: parent.height
        hoverEnabled: true
        cursorShape: uiVisible ? Qt.ArrowCursor : Qt.BlankCursor
        drag.filterChildren: true

        onPressed:         uiVisible = true
        onPositionChanged: uiVisible = true
        onUiVisibleChanged: {
            if (blockUI) { fadeoutTimer.running = false; }
            else if (uiVisible) { fadeoutTimer.restart(); }
            authenticator.startAuthenticating();
        }
        onBlockUIChanged: {
            if (blockUI) { fadeoutTimer.running = false; uiVisible = true; }
            else { fadeoutTimer.restart(); }
        }
        Keys.onEscapePressed: {
            if (uiVisible) {
                uiVisible = false;
                if (inputPanel.keyboardActive) inputPanel.showHide();
                root.clearPassword();
            }
        }
        Keys.onPressed: event => { uiVisible = true; event.accepted = false; }

        Timer {
            id: fadeoutTimer; interval: 10000
            onTriggered: {
                if (!lockScreenRoot.blockUI) {
                    mainBlock.mainPasswordBox.showPassword = false;
                    lockScreenRoot.uiVisible = false;
                }
            }
        }
        Timer { id: notificationRemoveTimer; interval: 3000; onTriggered: root.notification = "" }
        Timer {
            id: graceLockTimer; interval: 3000
            onTriggered: { root.clearPassword(); authenticator.startAuthenticating(); }
        }

        PropertyAnimation {
            id: launchAnimation; target: lockScreenRoot; property: "opacity"
            from: 0; to: 1; duration: Kirigami.Units.veryLongDuration * 2
        }
        Component.onCompleted: launchAnimation.start()

        // ── Background wallpaper ────────────────────────────────────────────
        // Loaded directly from the shared wallpaper install location.
        // This keeps the lock screen independent from the user's configured desktop wallpaper.
        Image {
            anchors.fill: parent
            source: "file://HOME_PLACEHOLDER/.local/share/wallpapers/NiceOS9/bright/Flowing_Platinum_Wave.png"
            fillMode: Image.PreserveAspectCrop
        }

        // ── Users model ─────────────────────────────────────────────────────
        ListModel {
            id: users
            Component.onCompleted: {
                users.append({
                    name:     kscreenlocker_userName,
                    realName: kscreenlocker_userName,
                    icon: kscreenlocker_userImage !== ""
                          ? "file://" + kscreenlocker_userImage
                                .split("/").map(encodeURIComponent).join("/")
                          : "",
                })
            }
        }

        // ── Login form ──────────────────────────────────────────────────────
        StackView {
            id: mainStack
            anchors { left: parent.left; right: parent.right }
            height: lockScreenRoot.height + Kirigami.Units.gridUnit * 3
            focus: true
            visible: opacity > 0
            opacity: lockScreenRoot.uiVisible ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: Kirigami.Units.veryLongDuration; easing.type: Easing.InOutQuad }
            }

            initialItem: MainBlock {
                id: mainBlock
                lockScreenUiVisible: lockScreenRoot.uiVisible
                showUserList: mainBlock.userList.y + mainStack.y > 0
                enabled: !graceLockTimer.running
                StackView.onStatusChanged: {
                    if (StackView.status === StackView.Activating) {
                        mainPasswordBox.clear();
                        mainPasswordBox.focus = true;
                        root.notification = "";
                    }
                }
                userListModel: users
                notificationMessage: {
                    const parts = [];
                    if (keystateSource.data["Caps Lock"]["Locked"])
                        parts.push(i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Caps Lock is on"));
                    if (root.notification) parts.push(root.notification);
                    return parts.join(" • ");
                }
                onPasswordResult: password => { authenticator.respond(password) }
                actionItems: [
                    ActionButton {
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Sleep")
                        iconSource: "system-suspend"
                        onClicked: root.suspendToRam()
                        visible: root.suspendToRamSupported
                    },
                    ActionButton {
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Hibernate")
                        iconSource: "system-suspend-hibernate"
                        onClicked: root.suspendToDisk()
                        visible: root.suspendToDiskSupported
                    },
                    ActionButton {
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Switch User")
                        iconSource: "system-switch-user"
                        onClicked: sessionManagement.switchUser()
                        visible: sessionManagement.canSwitchUser
                    }
                ]
            }
        }

        VirtualKeyboardLoader {
            id: inputPanel; z: 1
            screenRoot: lockScreenRoot
            mainStack: mainStack
            mainBlock: mainBlock
            passwordField: mainBlock.mainPasswordBox
        }

        Loader {
            z: 2
            active: root.viewVisible
            source: "LockOsd.qml"
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: Kirigami.Units.gridUnit
            }
        }

        // ── Footer (virtual keyboard / layout switcher / battery) ───────────
        RowLayout {
            id: footer
            anchors {
                bottom: parent.bottom; left: parent.left; right: parent.right
                margins: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.smallSpacing
            opacity: lockScreenRoot.uiVisible ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: Kirigami.Units.veryLongDuration; easing.type: Easing.InOutQuad }
            }

            PlasmaComponents3.ToolButton {
                id: virtualKeyboardButton
                focusPolicy: Qt.TabFocus
                text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel",
                             "Button to show/hide virtual keyboard", "Virtual Keyboard")
                icon.name: inputPanel.keyboardActive
                           ? "input-keyboard-virtual-on" : "input-keyboard-virtual-off"
                onClicked: {
                    mainBlock.mainPasswordBox.forceActiveFocus();
                    inputPanel.showHide();
                }
                visible: inputPanel.status === Loader.Ready
                Layout.fillHeight: true
                containmentMask: Item {
                    parent: virtualKeyboardButton
                    anchors.fill: parent
                    anchors.leftMargin:   -footer.anchors.margins
                    anchors.bottomMargin: -footer.anchors.margins
                }
            }

            PlasmaComponents3.ToolButton {
                id: keyboardButton
                focusPolicy: Qt.TabFocus
                Accessible.description: i18ndc("plasma_lookandfeel_org.kde.lookandfeel",
                                               "Button to change keyboard layout", "Switch layout")
                icon.name: "input-keyboard"
                PW.KeyboardLayoutSwitcher {
                    id: keyboardLayoutSwitcher
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                }
                text: keyboardLayoutSwitcher.layoutNames.longName
                onClicked: keyboardLayoutSwitcher.keyboardLayout.switchToNextLayout()
                visible: keyboardLayoutSwitcher.hasMultipleKeyboardLayouts
                Layout.fillHeight: true
                containmentMask: Item {
                    parent: keyboardButton
                    anchors.fill: parent
                    anchors.leftMargin:   virtualKeyboardButton.visible ? 0 : -footer.anchors.margins
                    anchors.bottomMargin: -footer.anchors.margins
                }
            }

            Item { Layout.fillWidth: true }
            Battery {}
        }

        // ── Mac OS 9 Menu Bar ───────────────────────────────────────────────
        // z:10 keeps it above all other children; always visible.
        // Provides the clock — suppresses the standard kscreenlocker clock
        // (MainBlock keeps userList.y=0 so that clock calculates y < 0).
        Rectangle {
            id: macMenuBar
            anchors.top: parent.top
            width: parent.width
            height: 22
            z: 10

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#eae6de" }
                GradientStop { position: 1.0; color: "#d2cec6" }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#888888" }
            Rectangle { anchors.top:    parent.top;    width: parent.width; height: 1; color: "rgba(255,255,255,0.7)" }

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                Item {
                    width: 34; height: macMenuBar.height
                    Text {
                        anchors.centerIn: parent
                        text: "\u2318"
                        font.family: lockScreenUi.cf; font.pixelSize: 15; color: "#000000"
                    }
                }
                Repeater {
                    model: ["Finder", "File", "Edit", "View", "Special", "Help"]
                    Item {
                        width: menuLabel.implicitWidth + 18; height: macMenuBar.height
                        Text {
                            id: menuLabel
                            anchors.centerIn: parent
                            text: modelData
                            font.family: lockScreenUi.cf; font.pixelSize: 13; color: "#000000"
                        }
                    }
                }
            }

            Text {
                id: menuBarClock
                anchors.right: parent.right; anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                font.family: lockScreenUi.cf; font.pixelSize: 12; color: "#222222"
                function pad(n) { return n < 10 ? "0" + n : n }
                function tick() {
                    var d = new Date(), h = d.getHours()
                    var ampm = h >= 12 ? "PM" : "AM"
                    h = h % 12; if (h === 0) h = 12
                    text = h + ":" + pad(d.getMinutes()) + " " + ampm
                }
                Component.onCompleted: tick()
                Timer { interval: 10000; running: true; repeat: true; onTriggered: menuBarClock.tick() }
            }
        }
    }
}
