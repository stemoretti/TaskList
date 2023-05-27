import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "languages.js" as JS

import BaseUI as UI

UI.AppStackPage {
    id: root

    title: qsTr("Continents")
    padding: 0

    leftButton: Action {
        icon.source: UI.Icons.arrow_back
        onTriggered: root.back()
    }

    UI.ListViewEdgeEffect {
        anchors.fill: parent
        model: JS.regions.map(function (o) { return o.name })

        delegate: ItemDelegate {
            width: parent.width
//            height: 50
            contentItem: UI.LabelSubheading {
                text: modelData
            }
            onClicked: {
                root.stack.replace(Qt.resolvedUrl("SettingsCountriesPage.qml"), { "continent": index })
            }
        }
    }
}
