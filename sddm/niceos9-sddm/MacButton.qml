// MacButton.qml — Mac OS 9 style button for NiceOS 9 SDDM theme
import QtQuick 2.15

Rectangle {
    id: root

    property string text:      ""
    property bool   isDefault: false

    signal clicked()

    width:  label.implicitWidth + 28
    height: 22
    radius: 0

    border.color: isDefault ? "#000000" : "#555555"
    border.width: isDefault ? 2 : 1

    gradient: Gradient {
        GradientStop { position: 0.0; color: mouseArea.pressed ? "#b0aca4" : "#e8e4dc" }
        GradientStop { position: 1.0; color: mouseArea.pressed ? "#a0a09a" : "#c8c4bc" }
    }

    // Top highlight
    Rectangle {
        x: 1; y: 1
        width:  parent.width - 2
        height: 1
        color:  "rgba(255,255,255,0.65)"
    }
    // Left highlight
    Rectangle {
        x: 1; y: 1
        width:  1
        height: parent.height - 2
        color:  "rgba(255,255,255,0.45)"
    }

    Text {
        id: label
        anchors.centerIn: parent
        text:             root.text
        font.family:      root.fontFamily
        font.pixelSize:   11
        color:            "#000000"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.clicked()
    }

    // Font forwarded from parent via attached property isn't automatic —
    // expose it so Main.qml can set it explicitly.
    property string fontFamily: "monospace"
}
