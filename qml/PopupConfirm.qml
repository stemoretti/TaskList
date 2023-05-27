import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

Dialog {
    id: root

    property alias text: message.text

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    modal: true
    dim: true

    closePolicy: Popup.CloseOnEscape

    contentItem: UI.LabelSubheading {
        id: message

        topPadding: 20
        leftPadding: 8
        rightPadding: 8
        text: ""
        color: UI.Style.popupTextColor
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    footer: DialogButtonBox {
        alignment: Qt.AlignHCenter

        UI.ButtonContained {
            text: qsTr("Confirm")
            Layout.rightMargin: 10
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
        }

        UI.ButtonFlat {
            text: qsTr("Cancel")
            textColor: UI.Style.primaryColor
            Layout.leftMargin: 10
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }
}
