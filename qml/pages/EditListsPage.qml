import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import QtQml.Models 2.12
import QtGraphicalEffects 1.0
import "../ekke/common"
import "../common"

AppStackPage {
    id: root

    title: qsTr("Edit Lists")

    Component {
        id: listDelegate

        DragDropListDelegate {
            id: dragDropDelegate

            draggedItemParent: root
            dragPointItem: dragPointRect
            onPressAndHold: {
                listMenu.list = index
                listMenu.y = mapToItem(listView, 0, listView.y).y
                listMenu.open()
            }

            onMoveItemRequested: appData.lists.move(from, to)

            contentItem: ColumnLayout {
                id: dataColumn

                anchors.fill: parent
                spacing: 0

//                    HorizontalListDivider { }

                RowLayout {
                    Item {
                        height: 52
                        Layout.leftMargin: 24
                    }
                    LabelBody {
                        text: model.name
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        id: dragPointRect

                        width: 40
                        color: "transparent"
                        Layout.margins: 4
                        Layout.rightMargin: 10
                        Layout.fillHeight: true

                        Image {
                            id: grabImage

                            height: 30
                            width: 30
                            anchors.centerIn: parent
                            source: "image://icon/reorder"
                        }

                        ColorOverlay {
                            anchors.fill: grabImage
                            source: grabImage
                            color: isDarkTheme ? "gray" : "lightgray"
                        }
                    }
                }
//                    HorizontalListDivider { }
            }
        }
    }

    DelegateModel {
        id: visualModel

        model: appData.lists
        delegate: listDelegate
    }

    ListView {
        id: listView

        anchors.fill: parent
        model: visualModel

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 200 }
        }
        moveDisplaced: Transition {
            NumberAnimation { property: "y"; duration: 200 }
        }
        removeDisplaced: Transition {
            NumberAnimation { property: "y"; duration: 200 }
        }

        ScrollIndicator.vertical: ScrollIndicator { }
    }

    LabelBody {
        anchors.centerIn: parent
        text: qsTr("No Lists")
        visible: listView.count < 1
    }

    Menu {
        id: listMenu

        property var list

        modal: true
        dim: false
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        transformOrigin: Menu.Center

        MenuItem {
            text: qsTr("Delete list")
            onTriggered: {
                appData.removeList(listMenu.list)
            }
        }
    }

}
