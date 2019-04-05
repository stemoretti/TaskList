import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtQml.Models 2.12
import "../ekke/common"
import "../common"
import "../popups"

AppStackPage {
    id: root

    property var clist: appData.currentList
    property bool hideCompleted: clist ? clist.hideCompleted : false
    property bool sortList: clist ? clist.sortByDueDate : false
//    property string ordering: "custom"

    title: clist ? clist.name : qsTr("No list")

    leftButton: Action {
        icon.source: "qrc:icons/menu.svg"
        onTriggered: navDrawer.open()
    }

    rightButtons: [
        Action {
            icon.source: "qrc:icons/more_vert.svg"
            onTriggered: optionsMenu.open()
        }
    ]

    Loader {
        id: listViewLoader
        anchors.fill: parent
        source: !sortList ? //ordering == "custom" ?
                    Qt.resolvedUrl("DragDropListView.qml") :
                    Qt.resolvedUrl("SortedListView.qml")
    }

    LabelBody {
        anchors.centerIn: parent
        text: {
            if (clist) {
                if (clist.tasks.count === 0)
                    qsTr("The list is empty")
                else if (clist.completedTasks > 1)
                    qsTr("%1 completed tasks not shown").arg(clist.completedTasks)
                else
                    qsTr("One completed task not shown")
            } else
                qsTr("No list")
        }
        visible: clist === null || (clist.tasks.count - (hideCompleted ? clist.completedTasks : 0) < 1)
    }

    Menu {
        id: taskMenu

        property var task

        modal: true
        dim: false
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        transformOrigin: Menu.Center

        MenuItem {
            text: qsTr("Delete task")
            onTriggered: {
                clist.tasks.remove(taskMenu.task)
            }
        }
    }

    Menu {
        id: optionsMenu
        modal: true
        dim: false
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        x: parent.width - width - 6
        y: -appToolBar.height + 6
        transformOrigin: Menu.TopRight

        onAboutToShow: {
            enabled = true
        }

        onAboutToHide: {
            // reset highlighting
            currentIndex = -1
        }

        MenuItem {
            enabled: clist
            text: qsTr("Add task")
            onTriggered: {
                // If the menu is not disabled, a double click will push the page twice.
                // The menu will be re-enabled the next time it is shown.
                optionsMenu.enabled = false
                push(Qt.resolvedUrl("AddTaskPage.qml"))
            }
        }
        MenuItem {
            enabled: clist && clist.completedTasks > 0
            text: qsTr("Remove completed")
            onTriggered: popupConfirmCleanChecked.open()
        }
        MenuItem {
            enabled: clist && clist.tasks.count
            text: qsTr("Remove all")
            onTriggered: popupConfirmClearAll.open()
        }
        MenuItem {
            enabled: clist && clist.tasks.count
            text: sortList ? qsTr("Custom Order") : qsTr("Sort By Due Date")
            onTriggered: {
                clist.sortByDueDate = !clist.sortByDueDate
            }
        }

        MenuItem {
            enabled: clist && clist.tasks.count
            text: hideCompleted ? qsTr("Show completed") : qsTr("Hide completed")
            onTriggered: {
                clist.hideCompleted = !clist.hideCompleted
            }
        }
    }

    PopupConfirm {
        id: popupConfirmCleanChecked
        text: qsTr("Do you want to clear the selected tasks?\n\n")
        onAboutToHide: {
            stopTimer()
            if (isConfirmed) {
                showToast(clist.completedTasks === 1 ?
                              qsTr("One completed task removed") :
                              qsTr("%1 completed tasks removed").arg(clist.completedTasks))
                clist.removeChecked()
                isConfirmed = false
            }
        }
    }

    PopupConfirm {
        id: popupConfirmClearAll
        text: qsTr("Do you want to clear the list?\n\n")
        onAboutToHide: {
            stopTimer()
            if (isConfirmed) {
                showToast(qsTr("List cleared"))
                clist.removeAll()
                isConfirmed = false
            }
        }
    }
}
