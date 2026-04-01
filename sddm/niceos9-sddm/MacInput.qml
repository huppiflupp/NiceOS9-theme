// MacInput.qml — Mac OS 9 style text input for NiceOS 9 SDDM theme
import QtQuick 2.15

FocusScope {
    id: root

    property alias text:       field.text
    property alias echoMode:   field.echoMode
    property alias inputFocus: field.focus
    property string fontFamily: "monospace"

    signal accepted()
    signal tabForward()

    height: 20
    width:  200

    Rectangle {
        id: frame
        anchors.fill: parent
        color:        "white"
        border.color: field.activeFocus ? "#0000aa" : "#666666"
        border.width: field.activeFocus ? 2 : 1
    }

    // Inner top-left shadow (sunken look)
    Rectangle {
        x: 1; y: 1
        width:  parent.width - 2
        height: 1
        color:  "#cccccc"
        visible: !field.activeFocus
    }
    Rectangle {
        x: 1; y: 1
        width:  1
        height: parent.height - 2
        color:  "#cccccc"
        visible: !field.activeFocus
    }

    TextInput {
        id:               field
        anchors.fill:     parent
        anchors.margins:  3
        font.family:      root.fontFamily
        font.pixelSize:   12
        color:            "#000000"
        verticalAlignment: TextInput.AlignVCenter
        clip:             true
        focus:            true

        Keys.onReturnPressed: root.accepted()
        Keys.onEnterPressed:  root.accepted()
        Keys.onTabPressed:    root.tabForward()
    }
}
