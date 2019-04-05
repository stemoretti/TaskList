import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import "../ekke/common"

ToolBar {
    property Action leftButton
    property list<Action> rightButtons

    property alias title: titleLabel.text

    RowLayout {
        focus: false
        spacing: 0
        anchors { fill: parent; leftMargin: 4; rightMargin: 4 }

        ToolButton {
            icon.source: leftButton ? leftButton.icon.source : ""
            icon.color: textOnPrimary
            focusPolicy: Qt.NoFocus
            enabled: leftButton && leftButton.enabled
            onClicked: leftButton.trigger()
        }
        LabelTitle {
            id: titleLabel
            elide: Label.ElideRight
            color: textOnPrimary
            Layout.fillWidth: true
        }
        Repeater {
            model: rightButtons.length
            delegate: ToolButton {
                icon.source: rightButtons[index].icon.source
                icon.color: textOnPrimary
                focusPolicy: Qt.NoFocus
                enabled: rightButtons[index].enabled
                onClicked: rightButtons[index].trigger()
            }
        }
    }
}
