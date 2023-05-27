import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import BaseUI as UI

UI.AppStackPage {
    id: root

    title: qsTr("Info")
    padding: 10

    leftButton: Action {
        icon.source: UI.Icons.arrow_back
        onTriggered: root.back()
    }

    Flickable {
        contentHeight: infoPane.implicitHeight
        anchors.fill: parent

        Pane {
            id: infoPane

            anchors.fill: parent

            ColumnLayout {
                width: parent.width

                UI.LabelTitle {
                    text: Qt.application.displayName
                    horizontalAlignment: Qt.AlignHCenter
                }

                UI.LabelBody {
                    text: "<a href='%1'>%1</a>".arg("https://github.com/stemoretti/tasklist")
                    linkColor: UI.Style.isDarkTheme ? "lightblue" : "blue"
                    onLinkActivated: Qt.openUrlExternally(link)
                    horizontalAlignment: Qt.AlignHCenter
                }
            }
        }
    }
}
