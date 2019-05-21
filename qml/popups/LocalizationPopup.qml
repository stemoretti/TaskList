import QtQuick 2.12
import QtQuick.Controls 2.5

Popup {
    id: root

    property alias model: internalList.model
    property alias currentIndex: internalList.currentIndex
    property var delegateFunction

    signal clicked(var data, int index)

    modal: true
    dim: true
    padding: 0
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2 - appToolBar.height / 2
    implicitWidth: appWindow.width * 0.9
    implicitHeight: Math.min(internalList.contentHeight, appWindow.height * 0.9)

    ListView {
        id: internalList
        anchors.fill: parent
        clip: true
        highlightMoveDuration: 0
        delegate: ItemDelegate {
            id: internalDelegate
            width: parent.width
            implicitHeight: 40
            text: delegateFunction(modelData)
            onClicked: root.clicked(modelData, index)
        }
        onCurrentIndexChanged: {
            internalList.positionViewAtIndex(currentIndex, ListView.Center)
        }
    }
}
