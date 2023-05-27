import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

import TaskList

Popup {
    id: root

    readonly property int selectedSize: d.num
    property list<Action> rightButtons
    property list<bool> selected

    function clear() {
        for (var i = 0; i < root.selected.length; i++)
            root.selected[i] = false
        d.selected = []
        d.num = 0
    }

    function toggle(name) {
        if (d.selected.includes(name))
            d.selected.splice(d.selected.indexOf(name), 1)
        else
            d.selected.push(name)
        d.num = d.selected.length
    }

    function append(name) {
        if (!d.selected.includes(name)) {
            d.selected.push(name)
            d.num = d.selected.length
        }
    }

    function at(index) {
        return d.selected[index]
    }

    parent: Overlay.overlay

    padding: 0
    verticalPadding: 0
    horizontalPadding: 4

    closePolicy: Popup.CloseOnEscape
    modal: false
    dim: false
    focus: true

    // XXX: click events pass below
    background: MouseArea {
        Rectangle {
            anchors.fill: parent
            color: UI.Style.toolBarBackground
        }
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0 }
    }

    onAboutToShow: AppData.drawerEnabled = false
    onClosed: AppData.drawerEnabled = true
    onAboutToHide: {
        root.clear()
        root.selected.length = 0
    }

    contentItem: RowLayout {
        spacing: 0

        // XXX: here because Popup is a QtObject
        Keys.onBackPressed: (event) => {
            if (root.opened) {
                event.accepted = true
                root.close()
            }
        }

        ToolButton {
            icon.source: UI.Icons.arrow_back
            icon.color: UI.Style.toolBarForeground
            focusPolicy: Qt.NoFocus
            onClicked: root.close()
        }

        Text {
            id: selectedTotal

            color: UI.Style.toolBarForeground
            font.pixelSize: UI.Style.fontSizeTitle
            text: d.num + ""
        }

        Item {
            Layout.fillWidth: true
        }

        Repeater {
            model: rightButtons.length
            delegate: ToolButton {
                icon.source: rightButtons[index].icon.source
                icon.color: UI.Style.toolBarForeground
                focusPolicy: Qt.NoFocus
                opacity: UI.Style.opacityTitle
                enabled: rightButtons[index].enabled
                onClicked: rightButtons[index].trigger()
            }
        }
    }

    QtObject {
        id: d

        property var selected: []
        property int num: 0
    }
}
