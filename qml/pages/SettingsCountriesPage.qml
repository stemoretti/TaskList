import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import "../ekke/common"
import "../common"
import "../languages.js" as JS

AppStackPage {
    property int continent: 0

    title: qsTr("Countries")
    padding: 0

    leftButton: Action {
        icon.source: "image://icon/arrow_back"
        onTriggered: replace(Qt.resolvedUrl("SettingsContinentsPage.qml"), StackView.PopTransition)
    }

    ListView {
        anchors.fill: parent
        model: JS.regions[continent].countries.map(function (o) { return o.code })

        delegate: ItemDelegate {
            width: parent.width
            contentItem: ColumnLayout {
                spacing: 0
                LabelSubheading {
                    text: JS.getCountryFromCode(modelData)
                }
                LabelBody {
                    text: JS.getCountryFromCode(modelData, "native")
                    opacity: 0.6
                }
            }
            onClicked: {
                appSettings.country = modelData
                pop()
            }
        }

        ScrollIndicator.vertical: ScrollIndicator { }
    }
}
