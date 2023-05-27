import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "languages.js" as JS

import BaseUI as UI

import TaskList

UI.AppStackPage {
    id: root

    property int continent: 0

    function back() {
        root.stack.replace(Qt.resolvedUrl("SettingsContinentsPage.qml"), StackView.PopTransition)
    }

    leftButton: Action {
        icon.source: UI.Icons.arrow_back
        onTriggered: root.back()
    }

    title: JS.regions[continent].name
    padding: 0

    UI.ListViewEdgeEffect {
        anchors.fill: parent
        model: JS.regions[continent].countries.map(function (o) { return o.code })

        delegate: ItemDelegate {
            width: root.width
            contentItem: ColumnLayout {
                spacing: 0
                UI.LabelSubheading {
                    text: JS.getCountryFromCode(modelData)
                }
                UI.LabelBody {
                    text: JS.getCountryFromCode(modelData, "native")
                    opacity: 0.6
                    Layout.fillWidth: false
                }
            }
            onClicked: {
                Settings.country = modelData
                pop()
            }
        }
    }
}
