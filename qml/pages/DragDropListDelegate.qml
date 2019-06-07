import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQml.Models 2.12

Item {
    id: dragArea

    signal moveItemRequested(int from, int to)
    signal clicked()
    signal pressAndHold()

    property Item draggedItemParent
    property alias dragPointItem: dragPoint.parent
    property alias contentItem: content.contentItem
    property int scrollEdgeSize: 40

    property ListView _listView: ListView.view
    property int _scrollingDirection: 0

    anchors { left: parent.left; right: parent.right }
    height: content.height

    MouseArea {
        id: dragPoint

        anchors.fill: parent
        drag {
            target: content
            axis: Drag.YAxis
            smoothed: false
//            minimumY: 0
//            maximumY: _listView.height - contentItem.height
        }
    }

    ItemDelegate {
        id: content

        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        width: parent.width
        height: contentItem.implicitHeight
        padding: 0
        highlighted: dragPoint.pressed
        onClicked: dragArea.clicked()
        onPressAndHold: dragArea.pressAndHold()

        Drag.active: dragPoint.drag.active
        Drag.source: dragArea
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        // http://agateau.com/2016/reordering-a-listview-via-dragndrop-2
        SmoothedAnimation {
            id: upAnimation
            target: _listView
            property: "contentY"
            to: 0
            running: _listView.contentY > 0 &&
                     dragArea._scrollingDirection == -1
        }
        SmoothedAnimation {
            id: downAnimation
            target: _listView
            property: "contentY"
            to: _listView.contentHeight - _listView.height
            running: _listView.contentHeight > _listView.height &&
                     dragArea._scrollingDirection == 1
        }

        states: State {
            when: dragPoint.drag.active
            name: "dragging"

            ParentChange { target: content; parent: draggedItemParent }
            AnchorChanges {
                target: content
                anchors {
                    horizontalCenter: undefined
                    verticalCenter: undefined
                }
            }
            PropertyChanges {
                target: dragArea
                _scrollingDirection: {
                    var yCoord = _listView.mapFromItem(dragPoint, 0, dragPoint.mouseY).y
                    if (yCoord < scrollEdgeSize) {
                        -1
                    } else if (yCoord > _listView.height - scrollEdgeSize) {
                        1
                    } else {
                        0
                    }
                }
            }
        }
    }
    DropArea {
        id: dropArea

        anchors { fill: parent; margins: 10 }

        onEntered: {
            moveItemRequested(
                        drag.source.DelegateModel.itemsIndex,
                        dragArea.DelegateModel.itemsIndex)
        }
    }
}
