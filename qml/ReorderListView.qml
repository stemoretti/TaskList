import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

import TaskList

Item {
    id: root

    signal taskClicked(Task task)

    function formatDate(d, t) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-ddTHH:mm:ss")
        return f.toLocaleDateString(Qt.locale(Settings.country), t)
    }

    function formatDateTime(d, t) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-ddTHH:mm:ss")
        return f.toLocaleString(Qt.locale(Settings.country), t)
    }

    Component {
        id: taskDelegate

        ReorderDelegate {
            required property int index
            required property QtObject model
            required property QtObject modelData

            height: implicitHeight
            width: implicitWidth
            implicitHeight: contentItem.implicitHeight
            implicitWidth: root.width

            dragParent: root
            grabArea: grabItem

            onEntered: function(drag) {
                AppData.currentList.moveTask(drag.source.index, index)
            }

            contentItem: ItemDelegate {
                padding: 0
                topPadding: 0
                bottomPadding: 0

                highlighted: dragging || (selectItemsBar.opened && index >= 0 && selectItemsBar.selected[index])

                onPressAndHold: {
                    if (!selectItemsBar.opened) {
                        selectItemsBar.open()
                        selectItemsBar.toggle(modelData.id)
                        selectItemsBar.selected.length = listView.count
                        selectItemsBar.selected[index] = !selectItemsBar.selected[index]
                    }
                }

                onClicked: {
                    if (selectItemsBar.opened) {
                        selectItemsBar.toggle(modelData.id)
                        selectItemsBar.selected[index] = !selectItemsBar.selected[index]
                    } else {
                        root.taskClicked(modelData)
                    }
                }

                contentItem: RowLayout {
                    spacing: 0

                    CheckBox {
                        enabled: !selectItemsBar.opened
                        checkState: model.completed ? Qt.Checked : Qt.Unchecked
                        onClicked: model.completed = !model.completed
                        Layout.leftMargin: 10
                    }

                    ColumnLayout {
                        spacing: 2

                        UI.LabelSubheading {
                            text: model.name
                            font.strikeout: Settings.strikeCompleted && model.completed
                            elide: Text.ElideRight
                        }

                        UI.LabelBody {
                            visible: model.notes.length
                            text: model.notes.replace(/\n/g, ' ')
                            elide: Text.ElideRight
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    UI.LabelBody {
                        visible: model.dueDateTime
                        opacity: 0.6
                        text: {
                            if (model.allDay)
                                formatDate(model.dueDateTime, Locale.ShortFormat)
                            else
                                formatDateTime(model.dueDateTime, Locale.ShortFormat)
                        }
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
                            width: 25
                            height: 25
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

        UI.HorizontalListDivider {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            opacity: listView.contentY - listView.originY > 0 ? 1 : 0
            Behavior on opacity { NumberAnimation {} }
        }

        anchors.fill: parent
        model: AppData.currentList?.visualModel ?? 0
        delegate: taskDelegate
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
                        selectItemsBar.selected[i] = true
                        selectItemsBar.append(listView.model.get(i).id)
                    }
                } else {
                    selectItemsBar.clear()
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
    }

    PopupConfirm {
        id: popupConfirmDeleteSelected
        text: qsTr("Do you want to delete %n selected task(s)?", "", selectItemsBar.selectedSize)
        onAccepted: {
            snackbar.showMessage(qsTr("%n task(s) deleted", "", selectItemsBar.selectedSize))
            for (var i = 0; i < selectItemsBar.selectedSize; i++)
                AppData.currentList.removeTask(selectItemsBar.at(i))
            selectItemsBar.close()
        }
    }

    Snackbar {
        id: snackbar
    }
}
