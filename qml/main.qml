import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import "common"
import "ekke/common"
import "pages"

App {
    id: appWindow

    title: "TaskList"
    header: pageStack.currentItem.appToolBar

    StackView {
        id: pageStack
        anchors.fill: parent
        initialItem: ListPage { }
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

        onAboutToShow: {
            colums.enabled = true
        }

        Flickable {
            anchors.fill: parent
            contentHeight: colums.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: colums

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
                    model: appData.lists
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
                            appData.selectList(model.name)
                            navDrawer.close()
                        }
                    }
                }

                HorizontalListDivider {}

                Repeater {
                    id: pageList

                    model: ListModel {
                        ListElement {
                            iconUrl: "qrc:icons/add.svg"
                            text: qsTr("New List")
                            page: "pages/NewListPage.qml"
                        }
                        ListElement {
                            iconUrl: "qrc:icons/edit.svg"
                            text: qsTr("Edit Lists")
                            page: "pages/EditListsPage.qml"
                        }
                        ListElement {
                            iconUrl: "qrc:icons/settings.svg"
                            text: qsTr("Settings")
                            page: "pages/SettingsPage.qml"
                        }
                        ListElement {
                            iconUrl: "qrc:icons/info.svg"
                            text: qsTr("About")
                            page: "pages/AboutPage.qml"
                        }
                    }

                    delegate: ItemDelegate {
                        icon.source: iconUrl
                        text: model.text
                        Layout.fillWidth: true
                        onClicked: {
                            colums.enabled = false
                            navDrawer.close()
                            pageStack.push(Qt.resolvedUrl(model.page))
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: Qt.application
        onStateChanged: {
//            if (Qt.application.state === Qt.ApplicationActive) {
//                ;
//            } else {
            if (Qt.application.state === Qt.ApplicationSuspended) {
                appData.writeListFile()
                appSettings.writeSettingsFile()
            }
        }
    }
}
