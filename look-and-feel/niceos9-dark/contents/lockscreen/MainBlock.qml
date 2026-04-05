/*
    NiceOS 9 — MainBlock  (Mac OS 9 "Finder Greeter" login window)
    Loaded into the StackView by LockScreenUi.qml.

    Required interface:
      property alias  mainPasswordBox  — the TextField kscreenlocker talks to
      property bool   showPassword     — cleared by LockScreenUi's fadeout timer
      property string notificationMessage
      property var    actionItems
      property bool   lockScreenUiVisible
      property var    userListModel
      property bool   showUserList
      property Item   userList         — .y used by LockScreenUi for clock pos
      property int    visibleBoundary  — bottom of password form for VKB nudge
      signal passwordResult(string)
      signal userSelected()
      function playHighlightAnimation()
*/
import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: root

    // ── Interface ──────────────────────────────────────────────────────────
    property alias  mainPasswordBox:    passwordField
    property bool   showPassword:       false
    property string notificationMessage: ""
    property alias  actionItems:        actionRow.children
    property bool   lockScreenUiVisible: false
    property var    userListModel:       null
    property bool   showUserList:        true

    // Dummy item at y=0 → makes LockScreenUi's clock y come out negative
    // → clock.visible = (y > 0) = false → menu bar clock shows instead.
    property Item userList: _fakeUserList
    Item { id: _fakeUserList; y: 0; height: 0 }

    // Bottom of the Platinum window — tells VirtualKeyboardLoader how far
    // to scroll the stack so the Unlock button stays above the keyboard.
    property int visibleBoundary: loginWindow.y + loginWindow.height + Kirigami.Units.smallSpacing

    signal passwordResult(string password)
    signal userSelected()

    function playHighlightAnimation() { _rejectAnim.start() }

    // ── Palette ────────────────────────────────────────────────────────────
    readonly property color platinum:      "#c8c4bc"
    readonly property color platinumLight: "#e8e4dc"
    readonly property color platinumDark:  "#a8a4a0"
    readonly property color accentBlue:    "#0000aa"
    FontLoader { id: _chicagoLoader; source: "ChicagoFLF.ttf" }
    readonly property string cf: _chicagoLoader.status === FontLoader.Ready
                                 ? _chicagoLoader.name : "ChicagoFLF"

    // ── Shake animation on bad password ────────────────────────────────────
    SequentialAnimation {
        id: _rejectAnim
        PropertyAnimation { target: loginWindow; property: "x"; from: loginWindow.x - 8; to: loginWindow.x + 8; duration: 60 }
        PropertyAnimation { target: loginWindow; property: "x"; from: loginWindow.x + 8; to: loginWindow.x - 8; duration: 60 }
        PropertyAnimation { target: loginWindow; property: "x"; from: loginWindow.x - 4; to: loginWindow.x;     duration: 60 }
    }

    // ── Platinum login window ───────────────────────────────────────────────
    Rectangle {
        id: loginWindow
        width: 340
        height: loginColumn.implicitHeight + 1
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 11   // half of 22 px menu bar

        color: root.platinum
        border.color: "#333333"
        border.width: 1

        // Drop shadow
        Rectangle {
            x: 4; y: 4
            width: loginWindow.width; height: loginWindow.height
            color: "#44000000"
            z: -1
        }

        Column {
            id: loginColumn
            width: parent.width

            // ── Title bar ─────────────────────────────────────────────────
            Rectangle {
                id: titleBar
                width: parent.width
                height: 22

                gradient: Gradient {
                    GradientStop { position: 0.0;  color: "#b8b8b8" }
                    GradientStop { position: 0.45; color: "#a0a0a0" }
                    GradientStop { position: 0.55; color: "#989898" }
                    GradientStop { position: 1.0;  color: "#888888" }
                }
                Rectangle { width: parent.width; height: 1; color: "rgba(255,255,255,0.5)"; anchors.top: parent.top }
                Rectangle { width: parent.width; height: 1; color: "#555555"; anchors.bottom: parent.bottom }

                Canvas {
                    anchors { left: parent.left; leftMargin: 44; right: parent.right; rightMargin: 44 }
                    anchors.top: parent.top; anchors.bottom: parent.bottom
                    opacity: 0.6
                    onPaint: {
                        var ctx = getContext("2d")
                        for (var y = 0; y < height; y += 2) {
                            ctx.fillStyle = "rgba(255,255,255,0.22)"; ctx.fillRect(0, y, width, 1)
                            ctx.fillStyle = "rgba(0,0,0,0.10)";       ctx.fillRect(0, y + 1, width, 1)
                        }
                    }
                }

                // Close box
                Rectangle {
                    x: 6; anchors.verticalCenter: parent.verticalCenter
                    width: 14; height: 14
                    border.color: "#666666"; border.width: 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#d8d4cc" }
                        GradientStop { position: 1.0; color: "#b8b4ac" }
                    }
                    Rectangle { x: 1; y: 1; width: parent.width - 2; height: 1; color: "rgba(255,255,255,0.5)" }
                }

                Text {
                    anchors.centerIn: parent
                    text: "Log In"
                    font.family: root.cf; font.pixelSize: 12; color: "#000000"
                }
            }

            // ── Window body ───────────────────────────────────────────────
            Item {
                width: parent.width
                height: bodyColumn.implicitHeight + 36

                Column {
                    id: bodyColumn
                    width: parent.width - 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top; anchors.topMargin: 18
                    spacing: 10

                    // User avatar
                    Item {
                        width: parent.width; height: 68
                        Rectangle {
                            width: 60; height: 60
                            anchors.horizontalCenter: parent.horizontalCenter
                            border.color: "#888888"; border.width: 2
                            color: "transparent"
                            clip: true

                            // Photo if available
                            Image {
                                id: userPhoto
                                anchors.fill: parent
                                source: (root.userListModel && root.userListModel.count > 0)
                                        ? (root.userListModel.get(0).icon || "") : ""
                                fillMode: Image.PreserveAspectCrop
                                visible: status === Image.Ready
                            }

                            // Silhouette fallback
                            Rectangle {
                                anchors.fill: parent
                                visible: !userPhoto.visible
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#d4d0c8" }
                                    GradientStop { position: 1.0; color: "#b8b4ac" }
                                }
                                Canvas {
                                    anchors.fill: parent; anchors.margins: 6
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.fillStyle = "#888888"
                                        ctx.beginPath()
                                        ctx.arc(width / 2, height * 0.32, height * 0.22, 0, Math.PI * 2)
                                        ctx.fill()
                                        ctx.beginPath()
                                        ctx.ellipse(width * 0.12, height * 0.60, width * 0.76, height * 0.46)
                                        ctx.fill()
                                    }
                                }
                            }
                        }
                    }

                    // Username
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: kscreenlocker_userName || ""
                        font.family: root.cf; font.pixelSize: 13; color: "#000000"
                    }

                    // Divider
                    Rectangle { width: parent.width; height: 1; color: "#aaaaaa" }

                    // Password row
                    Row {
                        width: parent.width; spacing: 8
                        Text {
                            width: 72; text: "Password:"
                            font.family: root.cf; font.pixelSize: 11; color: "#000000"
                            horizontalAlignment: Text.AlignRight
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Mac OS 9 styled TextField (T.TextField so VKB loader accepts it)
                        QQC2.TextField {
                            id: passwordField
                            width: parent.width - 80
                            height: 22

                            property bool showPassword: root.showPassword
                            echoMode: showPassword ? TextInput.Normal : TextInput.Password

                            font.family: root.cf
                            font.pixelSize: 12
                            color: "#000000"
                            leftPadding: 4; rightPadding: 4

                            background: Rectangle {
                                color: "white"
                                border.color: passwordField.activeFocus ? root.accentBlue : "#666666"
                                border.width: passwordField.activeFocus ? 2 : 1
                                // Inset shadow (sunken Mac OS 9 look)
                                Rectangle {
                                    visible: !passwordField.activeFocus
                                    x: 1; y: 1; width: parent.width - 2; height: 1
                                    color: "#cccccc"
                                }
                                Rectangle {
                                    visible: !passwordField.activeFocus
                                    x: 1; y: 1; width: 1; height: parent.height - 2
                                    color: "#cccccc"
                                }
                            }

                            Keys.onReturnPressed: { if (root.lockScreenUiVisible) { passwordResult(text) } }
                            Keys.onEnterPressed:  { if (root.lockScreenUiVisible) { passwordResult(text) } }
                            Keys.onTabPressed:    { unlockButton.forceActiveFocus() }

                            Component.onCompleted: forceActiveFocus()
                        }
                    }

                    // Error / notification message
                    Text {
                        id: errorLabel
                        width: parent.width
                        visible: root.notificationMessage.length > 0
                        text: root.notificationMessage
                        font.family: root.cf; font.pixelSize: 10; color: "#880000"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    // Buttons row
                    Row {
                        anchors.right: parent.right
                        spacing: 8

                        MacButton {
                            id: unlockButton
                            text: "Unlock"
                            isDefault: true
                            fontFamily: root.cf
                            onClicked: {
                                if (root.lockScreenUiVisible)
                                    passwordResult(passwordField.text)
                            }
                            Keys.onReturnPressed: clicked()
                            Keys.onEnterPressed:  clicked()
                            Keys.onTabPressed:    passwordField.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }

    // ── Action items (Sleep / Hibernate / Switch User) ──────────────────────
    // Shown below the Platinum window via the actionItems alias above.
    Row {
        id: actionRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: loginWindow.bottom; anchors.topMargin: 14
        spacing: 8
        visible: visibleChildren.length > 0
    }
}
