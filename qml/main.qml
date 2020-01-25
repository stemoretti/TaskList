import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import "common"

import AppData 1.0

App {
    id: appWindow

    title: "TaskList"
    header: pageStack.currentItem.appToolBar
    width: 640
    height: 480

    function makeDate(date, time) {
        var dateTime = new Date()
        dateTime.setTime(date)
        dateTime.setHours(time.getHours(), time.getMinutes(), time.getSeconds())
        return dateTime
    }

    StackView {
        id: pageStack
        anchors.fill: parent
        initialItem: Qt.resolvedUrl("pages/ListPage.qml")
        onCurrentItemChanged: {
            if (currentItem) {
                currentItem.canNavigateBack = depth > 1
                currentItem.forceActiveFocus()
            }
        }
    }

    Drawer {
        id: navDrawer

        interactive: pageStack.depth === 1
        width: Math.min(240,  Math.min(appWindow.width, appWindow.height) / 3 * 2 )
        height: appWindow.height

        // Disable menuColumn or a double click will push the page twice
        onAboutToShow: menuColumn.enabled = true

        Flickable {
            anchors.fill: parent
            contentHeight: menuColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: menuColumn

                anchors { left: parent.left; right: parent.right }
                spacing: 0

                Rectangle {
                    id: topItem
                    height: 140
                    color: primaryColor
                    Layout.fillWidth: true
                    Text {
                        text: appWindow.title
                        color: textOnPrimary
                        font.pixelSize: fontSizeHeadline
                        anchors {
                            left: parent.left
                            bottom: parent.bottom
                            margins: 25
                        }
                    }
                }

                Repeater {
                    model: AppData.lists
                    delegate: ItemDelegate {
                        Layout.fillWidth: true
                        contentItem: RowLayout {
                            LabelSubheading {
                                text: model.name
                                color: isDarkTheme ? "#FFFFFF" : "#000000"
                                elide: Text.ElideRight
                                Layout.maximumWidth: parent.width - itemNumber.width - parent.spacing
                            }
                            LabelSubheading {
                                id: itemNumber
                                text: model.completedTasks + " / " + model.tasks.count
                                color: isDarkTheme ? "#FFFFFF" : "#000000"
                                Layout.alignment: Qt.AlignRight
                            }
                        }
                        onClicked: {
                            AppData.selectList(model.name)
                            navDrawer.close()
                        }
                    }
                }

                HorizontalListDivider {}

                Repeater {
                    id: pageList

                    model: ListModel {
                        ListElement {
                            iconUrl: "image://icon/add"
                            text: qsTr("New List")
                            page: "pages/NewListPage.qml"
                        }
                        ListElement {
                            iconUrl: "image://icon/edit"
                            text: qsTr("Edit Lists")
                            page: "pages/EditListsPage.qml"
                        }
                        ListElement {
                            iconUrl: "image://icon/settings"
                            text: qsTr("Settings")
                            page: "pages/SettingsPage.qml"
                        }
                        ListElement {
                            iconUrl: "image://icon/info"
                            text: qsTr("About")
                            page: "pages/AboutPage.qml"
                        }
                    }

                    delegate: ItemDelegate {
                        icon.source: iconUrl
                        text: model.text
                        Layout.fillWidth: true
                        onClicked: {
                            menuColumn.enabled = false
                            navDrawer.close()
                            pageStack.push(Qt.resolvedUrl(model.page))
                        }
                    }
                }
            }
        }
    }
}
