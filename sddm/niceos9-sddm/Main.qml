// ─────────────────────────────────────────────────────────────────────────────
// NiceOS 9 SDDM Theme — "Finder Greeter"
// Mac OS 9 inspired login screen for KDE Plasma 6
// ─────────────────────────────────────────────────────────────────────────────
import QtQuick 2.15
import QtQuick.Window 2.15
import SddmComponents 2.0

Rectangle {
    id: root

    // Screen dimensions (SDDM provides Screen)
    width:  Screen.width  > 0 ? Screen.width  : 1920
    height: Screen.height > 0 ? Screen.height : 1080

    // ── Palette ────────────────────────────────────────────────────────────
    readonly property color platinum:      "#c8c4bc"
    readonly property color platinumLight: "#e8e4dc"
    readonly property color platinumDark:  "#a8a4a0"
    readonly property color accentBlue:    "#0000aa"

    // ── Typography ─────────────────────────────────────────────────────────
    property string cf: chicagoFont.status === FontLoader.Ready
                        ? chicagoFont.name : "monospace"

    FontLoader {
        id: chicagoFont
        source: "ChicagoFLF.ttf"
    }

    // ── Background: wallpaper with gradient fallback ───────────────────────
    // Fallback gradient (always rendered beneath the wallpaper)
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#7898b8" }
        GradientStop { position: 1.0; color: "#4a6888" }
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
        // Slight darkening overlay so the Platinum chrome pops
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            Rectangle {
                anchors.fill: parent
                color: "#18000000"
            }
        }
    }

    // ── Mac OS 9 Menu Bar ──────────────────────────────────────────────────
    Rectangle {
        id: menuBar
        width:  parent.width
        height: 22
        z: 10
        anchors.top: parent.top

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#eae6de" }
            GradientStop { position: 1.0; color: "#d2cec6" }
        }

        // Bottom border
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 1
            color: "#888888"
        }
        // Top shine
        Rectangle {
            anchors.top: parent.top
            width: parent.width; height: 1
            color: "rgba(255,255,255,0.7)"
        }

        Row {
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter

            // ⌘ Apple-menu stand-in
            Item {
                width: 34; height: menuBar.height
                Text {
                    anchors.centerIn: parent
                    text:            "\u2318"
                    font.family:     root.cf
                    font.pixelSize:  15
                    color:           "#000000"
                }
            }

            Repeater {
                model: ["Finder", "File", "Edit", "View", "Special", "Help"]
                Item {
                    width:  menuText.implicitWidth + 18
                    height: menuBar.height
                    Text {
                        id: menuText
                        anchors.centerIn: parent
                        text:             modelData
                        font.family:      root.cf
                        font.pixelSize:   13
                        color:            "#000000"
                    }
                }
            }
        }

        // Clock (right side)
        Text {
            id: clock
            anchors.right:          parent.right
            anchors.rightMargin:    10
            anchors.verticalCenter: parent.verticalCenter
            font.family:   root.cf
            font.pixelSize: 12
            color:         "#222222"

            function pad(n) { return n < 10 ? "0" + n : n }
            function updateTime() {
                var d = new Date()
                var h = d.getHours()
                var ampm = h >= 12 ? "PM" : "AM"
                h = h % 12; if (h === 0) h = 12
                text = h + ":" + pad(d.getMinutes()) + " " + ampm
            }
            Component.onCompleted: updateTime()
            Timer { interval: 10000; running: true; repeat: true; onTriggered: clock.updateTime() }
        }
    }

    // ── Login Window ───────────────────────────────────────────────────────
    Rectangle {
        id: loginWindow
        width:  340
        height: loginColumn.implicitHeight + 1  // +1 for titlebar bottom border
        anchors.centerIn: parent
        anchors.verticalCenterOffset: menuBar.height / 2

        color:        root.platinum
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

            // ── Title bar ──────────────────────────────────────────────
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

                // Top shine
                Rectangle { width: parent.width; height: 1; color: "rgba(255,255,255,0.5)"; anchors.top: parent.top }
                // Bottom separator
                Rectangle { width: parent.width; height: 1; color: "#555555"; anchors.bottom: parent.bottom }

                // Mac OS 9 horizontal scan-line stripes in title bar
                Canvas {
                    anchors.left:        parent.left
                    anchors.leftMargin:  44
                    anchors.right:       parent.right
                    anchors.rightMargin: 44
                    anchors.top: parent.top; anchors.bottom: parent.bottom
                    opacity: 0.6
                    onPaint: {
                        var ctx = getContext("2d")
                        for (var y = 0; y < height; y += 2) {
                            ctx.fillStyle = "rgba(255,255,255,0.22)"
                            ctx.fillRect(0, y, width, 1)
                            ctx.fillStyle = "rgba(0,0,0,0.10)"
                            ctx.fillRect(0, y + 1, width, 1)
                        }
                    }
                }

                // Close box
                Rectangle {
                    x: 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14; height: 14
                    border.color: "#666666"
                    border.width: 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#d8d4cc" }
                        GradientStop { position: 1.0; color: "#b8b4ac" }
                    }
                    Rectangle { x: 1; y: 1; width: parent.width-2; height: 1; color: "rgba(255,255,255,0.5)" }
                }

                // Title text
                Text {
                    anchors.centerIn: parent
                    text:             "Login"
                    font.family:      root.cf
                    font.pixelSize:   12
                    color:            "#000000"
                }
            }

            // ── Window body ────────────────────────────────────────────
            Item {
                width:  parent.width
                height: bodyColumn.implicitHeight + 36   // 18px top + 18px bottom padding

                Column {
                    id: bodyColumn
                    width:   parent.width - 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 18
                    spacing: 12

                    // User avatar
                    Item {
                        width: parent.width; height: 64

                        Rectangle {
                            width: 60; height: 60
                            anchors.horizontalCenter: parent.horizontalCenter
                            border.color: "#888888"
                            border.width: 2
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#d4d0c8" }
                                GradientStop { position: 1.0; color: "#b8b4ac" }
                            }
                            // User silhouette
                            Canvas {
                                anchors.fill: parent
                                anchors.margins: 6
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.fillStyle = "#888888"
                                    // Head (circle)
                                    ctx.beginPath()
                                    ctx.arc(width/2, height * 0.32, height * 0.22, 0, Math.PI * 2)
                                    ctx.fill()
                                    // Body (ellipse: x, y, w, h — top-left origin in Qt Canvas)
                                    ctx.beginPath()
                                    ctx.ellipse(width * 0.12, height * 0.60, width * 0.76, height * 0.46)
                                    ctx.fill()
                                }
                            }
                        }
                    }

                    // "Welcome" label
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:           "Welcome"
                        font.family:    root.cf
                        font.pixelSize: 14
                        color:          "#000000"
                    }

                    // Divider
                    Rectangle {
                        width:  parent.width
                        height: 1
                        color:  "#aaaaaa"
                    }

                    // ── Name row ───────────────────────────────────────
                    Row {
                        width:   parent.width
                        spacing: 8
                        Text {
                            width:               70
                            text:                "Name:"
                            font.family:         root.cf
                            font.pixelSize:      11
                            color:               "#000000"
                            horizontalAlignment: Text.AlignRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        MacInput {
                            id:         nameField
                            width:      parent.width - 78
                            text:       userModel.lastUser
                            fontFamily: root.cf
                            onAccepted:   doLogin()
                            onTabForward: passwordField.inputFocus = true
                        }
                    }

                    // ── Password row ──────────────────────────────────
                    Row {
                        width:   parent.width
                        spacing: 8
                        Text {
                            width:               70
                            text:                "Password:"
                            font.family:         root.cf
                            font.pixelSize:      11
                            color:               "#000000"
                            horizontalAlignment: Text.AlignRight
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        MacInput {
                            id:         passwordField
                            width:      parent.width - 78
                            echoMode:   TextInput.Password
                            fontFamily: root.cf
                            inputFocus: true
                            onAccepted:   doLogin()
                            onTabForward: nameField.inputFocus = true
                        }
                    }

                    // ── Error message ─────────────────────────────────
                    Text {
                        id:                  errorLabel
                        width:               parent.width
                        visible:             false
                        text:                "Sorry, that password is incorrect."
                        font.family:         root.cf
                        font.pixelSize:      10
                        color:               "#880000"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode:            Text.WordWrap
                    }

                    // ── Session selector (small, unobtrusive) ─────────
                    Row {
                        width:   parent.width
                        spacing: 6
                        visible: sessionModel.rowCount() > 1

                        Text {
                            text:               "Session:"
                            font.family:        root.cf
                            font.pixelSize:     10
                            color:              "#555555"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        // Cycle through sessions on click
                        Rectangle {
                            id: sessionBox
                            width:  parent.width - 60
                            height: 18
                            border.color: "#888888"
                            border.width: 1
                            color: "#ffffff"
                            property int idx: sessionModel.lastIndex >= 0
                                              ? sessionModel.lastIndex : 0
                            Text {
                                anchors.fill:    parent
                                anchors.margins: 3
                                text:            sessionModel.data(
                                                     sessionModel.index(sessionBox.idx, 0),
                                                     Qt.DisplayRole) || ""
                                font.family:     root.cf
                                font.pixelSize:  10
                                color:           "#000000"
                                verticalAlignment: Text.AlignVCenter
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: sessionBox.idx =
                                    (sessionBox.idx + 1) % sessionModel.rowCount()
                            }
                        }
                    }

                    // ── Button row ────────────────────────────────────
                    Row {
                        anchors.right: parent.right
                        spacing: 8

                        MacButton {
                            text:       "Guest"
                            fontFamily: root.cf
                            onClicked: {
                                nameField.text     = "guest"
                                passwordField.text = ""
                                doLogin()
                            }
                        }

                        MacButton {
                            text:       "Log In"
                            isDefault:  true
                            fontFamily: root.cf
                            onClicked:  doLogin()
                        }
                    }
                }
            }
        }
    }

    // ── Power controls (bottom-right, Mac OS 9 "Special" menu actions) ─────
    Row {
        anchors.bottom:       parent.bottom
        anchors.right:        parent.right
        anchors.bottomMargin: 20
        anchors.rightMargin:  20
        spacing: 8
        z: 10

        MacButton {
            text:       "Restart\u2026"
            fontFamily: root.cf
            visible:    sddm.canReboot
            onClicked:  sddm.reboot()
        }

        MacButton {
            text:       "Shut Down\u2026"
            fontFamily: root.cf
            visible:    sddm.canPowerOff
            onClicked:  sddm.powerOff()
        }
    }

    // ── SDDM signal handlers ────────────────────────────────────────────────
    Connections {
        target: sddm
        function onLoginSucceeded() {
            errorLabel.visible = false
        }
        function onLoginFailed() {
            errorLabel.visible  = true
            passwordField.text  = ""
            passwordField.inputFocus = true
        }
    }

    // ── Login action ────────────────────────────────────────────────────────
    function doLogin() {
        errorLabel.visible = false
        var sessionIdx = (sessionBox.visible && sessionModel.rowCount() > 0)
                         ? sessionBox.idx
                         : sessionModel.lastIndex
        sddm.login(nameField.text, passwordField.text, sessionIdx)
    }
}
