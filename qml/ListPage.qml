import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

import TaskList

UI.AppStackPage {
    id: root

    readonly property bool hideCompleted: AppData.currentList?.hideCompleted ?? false
    readonly property int tasksCount: AppData.currentList?.tasksCount ?? 0
    readonly property int completedTasksCount: AppData.currentList?.completedTasksCount ?? 0
    readonly property int ordering: AppData.currentList?.ordering ?? List.UserReorder

    function formatDate(d, t) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-ddTHH:mm:ss")
        return f.toLocaleDateString(Qt.locale(Settings.country), t)
    }

    function formatDateTime(d, t) {
        var f = Date.fromLocaleString(Qt.locale(), d, "yyyy-MM-ddTHH:mm:ss")
        return f.toLocaleString(Qt.locale(Settings.country), t)
    }

    function _editTask(task) {
        // XXX: fix double tap
        if (root.stack.depth > 1)
            return
        root.stack.push(Qt.resolvedUrl("TaskDetailsPage.qml"), { task: task })
    }

    title: AppData.currentList?.name ?? qsTr("No list")

    leftButton: Action {
        icon.source: UI.Icons.menu
        onTriggered: navDrawer.open()
    }

    rightButtons: [
        Action {
            enabled: AppData.currentList
            icon.source: UI.Icons.search
            onTriggered: searchBar.open()
        },
        Action {
            enabled: AppData.currentList
            icon.source: UI.Icons.add
            onTriggered: textInputBar.open()
        },
        Action {
            icon.source: UI.Icons.more_vert
            onTriggered: optionsMenu.open()
        }
    ]

    Component {
        id: reorderView
        ReorderListView {
            onTaskClicked: (task) => { _editTask(task) }
        }
    }

    Component {
        id: sortedView
        SortedListView {
            onTaskClicked: (task) => { _editTask(task) }
        }
    }

    Loader {
        visible: !searchBar.opened
        anchors.fill: parent
        sourceComponent: root.ordering === List.UserReorder ? reorderView : sortedView
    }

    UI.ListViewEdgeEffect {
        id: searchList
        anchors.fill: parent
        model: AppData.currentList?.searchModel ?? 0
        delegate: ItemDelegate {
            padding: 0
            topPadding: 0
            bottomPadding: 0

            implicitHeight: contentItem.implicitHeight
            implicitWidth: searchList.width

            onClicked: _editTask(modelData)

            contentItem: RowLayout {
                spacing: 0

                CheckBox {
                    enabled: false
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
            }
        }
        visible: searchBar.opened
    }

    UI.LabelBody {
        anchors.centerIn: parent
        text: {
            if (AppData.currentList) {
                if (root.tasksCount == 0)
                    qsTr("The list is empty")
                else
                    qsTr("%n completed task(s) not shown", "", root.completedTasksCount)
            } else {
                qsTr("No list")
            }
        }
        visible: AppData.currentList == null
                 || root.tasksCount == 0
                 || (root.hideCompleted && root.completedTasksCount == root.tasksCount)
    }

    Menu {
        id: taskMenu

        property Task task

        modal: true
        dim: false
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        transformOrigin: Menu.Center

        MenuItem {
            text: qsTr("Delete task")
            onTriggered: AppData.currentList.removeTask(taskMenu.task)
        }
    }

    Menu {
        id: optionsMenu

        modal: true
        dim: false
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        x: parent.width - width - 6
        y: -root.appToolBar.height + 6
        transformOrigin: Menu.TopRight

        // https://martin.rpdev.net/2018/03/13/qt-quick-controls-2-automatically-set-the-width-of-menus.html
        width: {
            var result = 0;
            var padding = 0;
            for (var i = 0; i < count; ++i) {
                var item = itemAt(i);
                result = Math.max(item.contentItem.implicitWidth, result);
                padding = Math.max(item.padding, padding);
            }
            return result + padding * 2;
        }

        onAboutToHide: currentIndex = -1 // reset highlighting

        MenuItem {
            enabled: root.completedTasksCount > 0
            text: qsTr("Remove completed")
            onTriggered: popupConfirmRemoveCompleted.open()
        }
        MenuItem {
            enabled: root.tasksCount > 0
            text: qsTr("Remove all")
            onTriggered: popupConfirmRemoveAll.open()
        }
        MenuItem {
            enabled: root.tasksCount > 0
            text: {
                switch (root.ordering) {
                case List.UserReorder: return qsTr("Order: User reorder")
                case List.AlphabeticalInc: return qsTr("Order: Alpha (A to Z)")
                case List.AlphabeticalDec: return qsTr("Order: Alpha (Z to A)")
                case List.CreatedInc: return qsTr("Order: Created (old)")
                case List.CreatedDec: return qsTr("Order: Created (new)")
                case List.DueInc: return qsTr("Order: Due (old)")
                case List.DueDec: return qsTr("Order: Due (new)")
                case List.CompletedInc: return qsTr("Order: Completed (old)")
                case List.CompletedDec: return qsTr("Order: Completed (new)")
                }
            }
            onTriggered: orderingOptionsDialog.open()
        }

        MenuItem {
            enabled: root.tasksCount > 0
            text: root.hideCompleted ? qsTr("Show completed") : qsTr("Hide completed")
            onTriggered: AppData.currentList.hideCompleted = !AppData.currentList.hideCompleted
        }
    }

    UI.OptionsDialog {
        id: orderingOptionsDialog

        title: qsTr("Tasks ordering")
        model: [
            { choice: List.UserReorder, text: QT_TR_NOOP("User reorder") },
            { choice: List.AlphabeticalInc, text: QT_TR_NOOP("Alphabetical (A to Z)") },
            { choice: List.AlphabeticalDec, text: QT_TR_NOOP("Alphabetical (Z to A)") },
            { choice: List.CreatedInc, text: QT_TR_NOOP("Created date (oldest first)") },
            { choice: List.CreatedDec, text: QT_TR_NOOP("Created date (newest first)") },
            { choice: List.DueInc, text: QT_TR_NOOP("Due date (oldest first)") },
            { choice: List.DueDec, text: QT_TR_NOOP("Due date (newest first)") },
            { choice: List.CompletedInc, text: QT_TR_NOOP("Completed date (oldest first)") },
            { choice: List.CompletedDec, text: QT_TR_NOOP("Completed date (newest first)") }
        ]
        delegate: RadioButton {
            checked: modelData.choice === root.ordering
            text: qsTr(modelData.text)
            onClicked: {
                orderingOptionsDialog.close()
                AppData.currentList.ordering = modelData.choice
            }
        }
    }

    TextInputBar {
        id: textInputBar

        width: parent.width

        placeholderText: qsTr("Insert task name here")
        onAccepted: function(text) {
            if (AppData.currentList.newTask(text)) {
                snackbar.showMessage(qsTr("Added %1 to list").arg(text))
                clearText()
            } else {
                snackbar.showError(qsTr("%1 is already in the list").arg(text))
            }
        }
    }

    TextInputBar {
        id: searchBar

        width: parent.width

        modal: false
        closePolicy: Popup.CloseOnEscape
        placeholderText: qsTr("Insert search term here")
        onAccepted: (text) => {
            AppData.currentList.filterTasks(text)
        }
        onAboutToShow: AppData.currentList.filterTasks("")
    }

    Drawer {
        id: navDrawer

        interactive: stack.depth === 1 && AppData.drawerEnabled
        width: Math.min(240,  Math.min(parent.width, parent.height) / 3 * 2 )
        height: parent.height

        onAboutToShow: menuColumn.enabled = true
        topPadding: 0
        bottomPadding: 0

        Flickable {
            anchors.fill: parent
            contentHeight: menuColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: menuColumn

                anchors { left: parent.left; right: parent.right }
                spacing: 0

                Label {
                    text: Qt.application.displayName
                    color: Material.foreground
                    font.pixelSize: UI.Style.fontSizeHeadline
                    padding: (root.appToolBar.implicitHeight - contentHeight) / 2
                    leftPadding: 20
                    Layout.fillWidth: true
                }

                UI.HorizontalListDivider {}

                Repeater {
                    model: AppData.lists

                    delegate: ItemDelegate {
                        Layout.fillWidth: true

                        contentItem: RowLayout {
                            UI.LabelSubheading {
                                text: model.name
                                color: UI.Style.isDarkTheme ? "#FFFFFF" : "#000000"
                                elide: Text.ElideRight
                                Layout.maximumWidth: parent.width - itemNumber.width - parent.spacing
                            }

                            UI.LabelSubheading {
                                id: itemNumber
                                text: model.completedTasksCount + " / " + model.tasksCount
                                color: UI.Style.isDarkTheme ? "#FFFFFF" : "#000000"
                                Layout.alignment: Qt.AlignRight
                                Layout.fillWidth: false
                            }
                        }

                        onClicked: {
                            AppData.selectList(model.name)
                            navDrawer.close()
                        }
                    }
                }

                UI.HorizontalListDivider {}

                Repeater {
                    model: [
                        {
                            icon: UI.Icons.edit,
                            text: QT_TR_NOOP("List Management"),
                            page: "ListManagementPage.qml"
                        },
                        {
                            icon: UI.Icons.settings,
                            text: QT_TR_NOOP("Settings"),
                            page: "SettingsPage.qml"
                        },
                        {
                            icon: UI.Icons.info_outline,
                            text: QT_TR_NOOP("Info"),
                            page: "InfoPage.qml"
                        }
                    ]

                    delegate: ItemDelegate {
                        icon.source: modelData.icon
                        text: qsTr(modelData.text)
                        Layout.fillWidth: true
                        onClicked: {
                            // Disable or a double click will push the page twice
                            menuColumn.enabled = false
                            navDrawer.close()
                            root.stack.push(Qt.resolvedUrl(modelData.page))
                        }
                    }
                }
            }
        }
    }

    PopupConfirm {
        id: popupConfirmRemoveCompleted
        text: qsTr("Do you want to remove %n completed task(s)?", "", root.completedTasksCount)
        onAccepted: {
            snackbar.showMessage(qsTr("%n completed task(s) removed", "", root.completedTasksCount))
            AppData.currentList.removeCompleted()
        }
    }

    PopupConfirm {
        id: popupConfirmRemoveAll
        text: qsTr("Do you want to clear the list?")
        onAccepted: {
            snackbar.showMessage(qsTr("List cleared"))
            AppData.currentList.removeAll()
        }
    }

    Snackbar {
        id: snackbar
    }
}
