import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

import TaskList

Popup {
    id: root

    property alias placeholderText: placeholderTextItem.text

    signal accepted(string text)

    function clearText() { inputField.clear() }

    parent: Overlay.overlay

    padding: 0
    verticalPadding: 0
    horizontalPadding: 4

    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    modal: true
    dim: false
    focus: true

    background: Rectangle { color: UI.Style.toolBarBackground }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0 }
    }

    onAboutToShow: inputField.clear()

    contentItem: RowLayout {
        spacing: 0

        ToolButton {
            icon.source: UI.Icons.arrow_back
            icon.color: UI.Style.toolBarForeground
            focusPolicy: Qt.NoFocus
            onClicked: { inputField.clear(); root.close() }
        }

        TextInput {
            id: inputField

            clip: true
            focus: true

            topPadding: 0
            bottomPadding: 0

            color: UI.Style.toolBarForeground
            font.pixelSize: UI.Style.fontSizeTitle

            EnterKey.type: Qt.EnterKeySend

            Layout.fillWidth: true

            states: State {
                when: inputField.displayText.length > 0
                PropertyChanges { target: clearButton; visible: true }
                PropertyChanges {
                    target: speechButton
                    icon.source: UI.Icons.send
                    onClicked: {
                        Qt.inputMethod.commit()
                        root.accepted(inputField.text)
                    }
                }
            }

            onEditingFinished: root.close()
            Keys.onReturnPressed: root.accepted(inputField.text)

            Text {
                id: placeholderTextItem

                anchors.fill: parent
                visible: !(inputField.text.length || inputField.preeditText.length)
                opacity: 0.7
                color: UI.Style.toolBarForeground
                font.pixelSize: UI.Style.fontSizeTitle
            }

            Connections {
                target: System
                function onSpeechRecognized(result) { inputField.text = result }
            }
        }

        ToolButton {
            id: clearButton

            icon.source: UI.Icons.clear
            icon.color: UI.Style.toolBarForeground
            focusPolicy: Qt.NoFocus
            visible: false
            onClicked: { Qt.inputMethod.commit(); inputField.clear() }
        }

        ToolButton {
            id: speechButton

            icon.source: UI.Icons.mic
            icon.color: UI.Style.toolBarForeground
            focusPolicy: Qt.NoFocus
            onClicked: System.startSpeechRecognizer();
        }
    }
}
