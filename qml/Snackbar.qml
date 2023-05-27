import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Window

import BaseUI as UI

Popup {
    id: root

    property bool errorMessage: false

    function showMessage(text) {
        root.errorMessage = false
        _start(text)
    }

    function showError(text) {
        root.errorMessage = true
        _start(text)
    }

    function _start(text) {
        label.text = text
        if (timer.running) {
            timer.restart()
            close()
        }
        open()
    }

    closePolicy: Popup.CloseOnPressOutside
    implicitWidth: parent.width > parent.height ? parent.width * 0.50 : parent.width * 0.95

    x: (parent.width - implicitWidth) / 2
    // y: (parent.height - implicitHeight) - 6
    y: 16

    background: Rectangle {
        color: Material.color(Material.Grey, Material.Shade900)
        radius: 4
    }

    onAboutToShow: timer.start()
    onAboutToHide: timer.stop()

    Timer {
        id: timer

        interval: 3000
        repeat: false

        onTriggered: root.close()
    }

    RowLayout {
        width: parent.width

        UI.Icon {
            visible: root.errorMessage
            width: 24
            height: 24
            icon: UI.Icons.error
            color: "red"
        }

        Label {
            id: label

            Layout.fillWidth: true
            Layout.preferredWidth: 1

            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 16
            color: root.errorMessage ? "red" : "white"
            wrapMode: Label.WordWrap
        }
    }
}
