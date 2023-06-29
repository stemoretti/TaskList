import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

import TaskList

Item {
    id: root

    property int ordering: AppData.currentList?.ordering ?? List.DueInc

    signal taskClicked(Task task)

    function formatDate(d) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-ddTHH:mm:ss")
        return f.toLocaleDateString(Qt.locale(GlobalSettings.country))
    }

    function formatDateTime(d) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-ddTHH:mm:ss")
        return f.toLocaleString(Qt.locale(GlobalSettings.country))
    }

    function formatDateSection(d) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-dd")
        return f.toLocaleDateString(Qt.locale(GlobalSettings.country))
    }

    Component {
        id: taskDelegate

        ItemDelegate {
            padding: 0
            topPadding: 0
            bottomPadding: 0

            width: root.width

            highlighted: selectItemsBar.opened && index >= 0 && selectItemsBar.selected[index]

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
                        font.strikeout: GlobalSettings.strikeCompleted && model.completed
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
                    visible: root.ordering != List.DueInc
                             && root.ordering != List.DueDec
                             && model.dueDate
                    opacity: 0.6
                    text: {
                        if (model.allDay)
                            formatDate(model.dueDateTime)
                        else
                            formatDateTime(model.dueDateTime)
                    }
                    elide: Text.ElideRight
                    Layout.fillWidth: false
                    Layout.rightMargin: 10
                }
            }
        }
    }

    Component {
        id: sectionDelegate

        UI.LabelSubheading {
            required property string section

            width: parent.width
            height: 30
            text: {
                if (root.ordering === List.AlphabeticalInc
                    || root.ordering === List.AlphabeticalDec)
                    section.toUpperCase()
                else if (section.length)
                    formatDateSection(section)
                else
                    qsTr("None")
            }
            color: Material.foreground
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            background: Rectangle {
                anchors.centerIn: parent
                width: parent.implicitWidth + 10
                height: parent.implicitHeight + 10
                radius: width / 2
                color: "gray"
                opacity: 0.3
            }
        }
    }

    UI.ListViewEdgeEffect {
        id: listView

        anchors.fill: parent
        model: AppData.currentList?.visualModelSorted ?? 0
        delegate: taskDelegate

        section.criteria: {
            if (root.ordering === List.AlphabeticalInc
                || root.ordering === List.AlphabeticalDec)
                ViewSection.FirstCharacter
            else
                ViewSection.FullString
        }
        section.property: {
            switch (root.ordering) {
            case List.AlphabeticalInc:
            case List.AlphabeticalDec:
                return "name"
            case List.CreatedInc:
            case List.CreatedDec:
                return "createdDate"
            case List.DueInc:
            case List.DueDec:
                return "dueDate"
            case List.CompletedInc:
            case List.CompletedDec:
                return "completedDate"
            }
        }
        section.delegate: sectionDelegate
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
                        selectItemsBar.append(AppData.currentList.visualModel.get(i).id)
                    }
                } else {
                    selectItemsBar.clear()
                    for (var i = 0; i < listView.count; i++)
                        selectItemsBar.selected[i] = false
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

        onAboutToHide: selectItemsBar.selected.length = 0
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
