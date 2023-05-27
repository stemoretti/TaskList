import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

import TaskList

UI.AppStackPage {
    id: root

    title: qsTr("List Management")

    leftButton: Action {
        icon.source: UI.Icons.arrow_back
        onTriggered: root.back()
    }

    rightButtons: [
        Action {
            icon.source: UI.Icons.playlist_add
            onTriggered: textInputBar.open()
        }
    ]

    Component {
        id: listDelegate

        ReorderDelegate {
            required property int index
            required property QtObject model
            required property QtObject modelData

            property bool selected: false

            height: implicitHeight
            width: implicitWidth
            implicitHeight: contentItem.implicitHeight
            implicitWidth: root.width

            dragParent: root
            grabArea: grabItem

            onEntered: function(drag) {
                AppData.lists.move(drag.source.index, index)
            }

            contentItem: ItemDelegate {
                padding: 0

                highlighted: dragging || (selectItemsBar.opened && selected)

                onPressAndHold: {
                    if (!selectItemsBar.opened) {
                        selectItemsBar.open()
                        selectItemsBar.toggle(modelData.name)
                        selected = !selected
                    }
                }

                onClicked: {
                    if (selectItemsBar.opened) {
                        selectItemsBar.toggle(modelData.name)
                        selected = !selected
                    }
                }

                contentItem: RowLayout {
                    spacing: 0

                    RadioButton {
                        enabled: !selectItemsBar.opened
                        checked: modelData === AppData.currentList
                        onClicked: AppData.selectList(modelData.name)
                        verticalPadding: 0
                    }

                    UI.LabelSubheading {
                        text: model.name
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    UI.LabelBody {
                        text: model.completedTasksCount + " / " + model.tasksCount
                        elide: Text.ElideRight
                        Layout.fillWidth: false
                    }

                    Item {
                        id: grabItem

                        width: 40
                        enabled: !selectItemsBar.opened

                        Layout.margins: 4
                        Layout.rightMargin: 10
                        Layout.fillHeight: true

                        UI.Icon {
                            anchors.centerIn: parent
                            height: 25
                            width: 25
                            icon: UI.Icons.drag_handle
                            color: UI.Style.isDarkTheme ?
                                (grabItem.enabled ? "darkgray" : "gray") :
                                (grabItem.enabled ? "gray" : "darkgray")
                        }
                    }
                }
            }
        }
    }

    UI.ListViewEdgeEffect {
        id: listView

        anchors.fill: parent
        model: AppData.lists
        delegate: listDelegate
    }

    UI.LabelBody {
        anchors.centerIn: parent
        text: qsTr("No Lists")
        visible: listView.count < 1
    }

    TextInputBar {
        id: textInputBar

        width: parent.width

        placeholderText: qsTr("Insert list name here")
        onAccepted: function(text) {
            if (AppData.addList(text)) {
                AppData.selectList(text)
                textInputBar.clearText()
                snackbar.showMessage(qsTr("Created list '%1'").arg(text))
            } else {
                snackbar.showError(qsTr("List '%1' exists").arg(text))
            }
        }
    }

    Menu {
        id: actionMenu

        modal: true
        dim: false
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        x: parent.width - width - 6
        y: -selectItemsBar.height + 6
        transformOrigin: Menu.TopRight

        onAboutToHide: currentIndex = -1 // reset highlighting

        MenuItem {
            checkable: true
            checked: selectItemsBar.selectedSize == listView.count
            text: qsTr("Select All")
            onTriggered: {
                if (checked) {
                    for (var i = 0; i < listView.count; i++) {
                        listView.itemAtIndex(i).selected = true
                        selectItemsBar.append(listView.model.get(i).name)
                    }
                } else {
                    selectItemsBar.clear()
                    for (var i = 0; i < listView.count; i++)
                        listView.itemAtIndex(i).selected = false
                }
            }
        }
        MenuItem {
            enabled: selectItemsBar.selectedSize > 0
            text: qsTr("Delete")
            onTriggered: popupConfirmDeleteSelected.open()
        }
    }

    SelectItemsBar {
        id: selectItemsBar

        width: parent.width

        rightButtons: [
            Action {
                icon.source: UI.Icons.more_vert
                onTriggered: actionMenu.open()
            }
        ]

        onAboutToHide: {
            for (var i = 0; i < listView.count; i++)
                listView.itemAtIndex(i).selected = false
        }
    }

    PopupConfirm {
        id: popupConfirmDeleteSelected
        text: qsTr("Do you want to delete %n selected list(s)?", "", selectItemsBar.selectedSize)
        onAccepted: {
            snackbar.showMessage(qsTr("%n list(s) deleted", "", selectItemsBar.selectedSize))
            for (var i = 0; i < selectItemsBar.selectedSize; i++)
                AppData.removeList(selectItemsBar.at(i))
            selectItemsBar.close()
        }
    }

    Snackbar {
        id: snackbar
    }
}
