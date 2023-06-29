import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import BaseUI as UI

Popup {
    id: root

    function showMessage(text) {
        root._errorMessage = false
        _start(text)
    }

    function showError(text) {
        root._errorMessage = true
        _start(text)
    }

    property bool _errorMessage: false

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
    y: 16

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
            visible: root._errorMessage
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
            color: Material.foreground
            wrapMode: Label.WordWrap
        }
    }
}
