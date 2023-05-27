/*
 * References:
 * http://agateau.com/2016/reordering-a-listview-via-dragndrop-2
 * https://doc.qt.io/qt-6/qtquick-draganddrop-example.html#gridview-example
 */

import QtQuick
import QtQuick.Controls

DropArea {
    id: root

    required property Item dragParent
    required property Item grabArea
    default required property Item contentItem

    property int scrollEdgeSize: content.height / 2
    property int scrollFasterEdgeSize: 5

    readonly property bool dragging: drag.active

    QtObject {
        id: d

        property ListView listView: root.ListView.view
        property int scrollingDirection: 0

        onScrollingDirectionChanged: {
            var pixelsAbove = listView.contentY - listView.originY
            var pixelsBelow = listView.contentHeight - pixelsAbove - listView.height
            var slowFactor = Math.abs(scrollingDirection) > 1 ? 2 : 4
            if (scrollingDirection < 0) {
                upAnimation.duration = pixelsAbove * slowFactor
                if (upAnimation.running)
                    upAnimation.restart()
            } else if (scrollingDirection > 0) {
                downAnimation.duration = pixelsBelow * slowFactor
                if (downAnimation.running)
                    downAnimation.restart()
            }
        }
    }

    // XXX: Scrolling the list by dragging the item to an edge and holding it still
    // won't update the item's position.
    Timer {
        interval: 100
        repeat: true
        running: d.scrollingDirection || (drag.active && d.listView.moving)
        onTriggered: { content.x++; content.x-- }
    }

    DragHandler {
        id: drag

        parent: root.grabArea
        target: content

        xAxis.enabled: false
        yAxis.minimum: 0
        yAxis.maximum: Math.min(d.listView.height, d.listView.contentHeight) - content.height
    }

    NumberAnimation {
        id: upAnimation

        target: d.listView
        property: "contentY"
        to: d.listView.originY
        running: d.listView.contentY - d.listView.originY > 0 && d.scrollingDirection < 0
    }

    NumberAnimation {
        id: downAnimation

        target: d.listView
        property: "contentY"
        to: d.listView.originY + d.listView.contentHeight - d.listView.height
        running: d.listView.contentHeight > d.listView.height && d.scrollingDirection > 0
    }

    Control {
        id: content

        height: implicitHeight
        width: implicitWidth
        implicitHeight: root.implicitHeight
        implicitWidth: root.implicitWidth

        contentItem: root.contentItem

        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }

        Drag.active: drag.active
        Drag.source: root
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        states: State {
            when: drag.active
            name: "dragging"

            ParentChange { target: content; parent: root.dragParent }
            AnchorChanges {
                target: content
                anchors {
                    horizontalCenter: undefined
                    verticalCenter: undefined
                }
            }
            PropertyChanges {
                target: d
                scrollingDirection: {
                    if (content.y < scrollEdgeSize) {
                        if (content.y < scrollFasterEdgeSize)
                            -2
                        else
                            -1
                    } else if (content.y + content.height > listView.height - scrollEdgeSize) {
                        if (content.y + content.height > listView.height - scrollFasterEdgeSize)
                            2
                        else
                            1
                    } else {
                        0
                    }
                }
            }
        }
    }
}
