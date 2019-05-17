import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtQml.Models 2.12
import QtGraphicalEffects 1.0
import "../ekke/common"
import "../common"
import "../popups"

Item {
    id: root

    property var clist: appData.currentList
    property bool hideCompleted: clist ? clist.hideCompleted : false

    Component {
        id: listDelegate

        DragDropListDelegate {
            id: dragDropDelegate

            draggedItemParent: root
            dragPointItem: dragPointRect
            onClicked: push(Qt.resolvedUrl("TaskDetailsPage.qml"),
                              { task: modelData })
            onPressAndHold: {
                taskMenu.task = modelData
                taskMenu.y = mapToItem(listView, 0, listView.y).y
                taskMenu.open()
            }

            onMoveItemRequested: clist.moveTask(from, to)

            contentItem: ColumnLayout {
                id: dataColumn

                anchors.fill: parent
                spacing: 0

                RowLayout {
                    CheckBox {
                        leftPadding: 24
                        checked: model.checked
                        onCheckStateChanged: {
                            model.checked = checked
                            dragDropDelegate.DelegateModel.inNotdone = !checked
                        }
                    }
                    LabelBody {
                        text: model.name
                        font.strikeout: model.checked
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    LabelBody {
                        visible: model.dueDate < new Date()
                        text: dateString(model.dueDate)
                        color: isDarkTheme ? "pink" : "red"
                        elide: Text.ElideRight
                        Layout.rightMargin: 10
                    }
                    LabelBody {
                        visible: model.notes.length
                        text: model.notes.replace(/\n/g, ' ')
                        elide: Text.ElideRight
                        Layout.maximumWidth: 100
                        Layout.rightMargin: 10
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
            }
        }
    }

    DelegateModel {
        id: visualModel

        model: clist ? clist.tasks : 0
        delegate: listDelegate
        filterOnGroup: hideCompleted ? "notdone" : ""
        groups: [
            DelegateModelGroup { name: "notdone"; includeByDefault: true }
        ]
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
}
