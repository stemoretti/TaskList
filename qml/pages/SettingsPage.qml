import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import "../common"
import "../popups"
import "../languages.js" as JS

import Settings 1.0
import System 1.0

AppStackPage {
    title: qsTr("Settings")
    padding: 0

    Flickable {
        contentHeight: settingsPane.implicitHeight
        anchors.fill: parent

        Pane {
            id: settingsPane

            anchors.fill: parent
            padding: 0

            ColumnLayout {
                width: parent.width
                spacing: 0

                SettingsItem {
                    title: qsTr("Dark Theme")
                    subtitle: Settings.darkTheme ?
                                  qsTr("Dark theme is enabled") :
                                  qsTr("Dark theme is disabled")
                    check.visible: true
                    check.checked: Settings.darkTheme
                    check.onClicked: Settings.darkTheme = !Settings.darkTheme
                    onClicked: check.clicked()
                }

                SettingsItem {
                    title: qsTr("Primary Color")
                    subtitle: primaryColorPopup.model.get(primaryColorPopup.currentIndex).title
                    onClicked: primaryColorPopup.open()
                }

                SettingsItem {
                    title: qsTr("Accent Color")
                    subtitle: accentColorPopup.model.get(accentColorPopup.currentIndex).title
                    onClicked: accentColorPopup.open()
                }

                HorizontalDivider { }

                SettingsItem {
                    title: qsTr("Language")
                    subtitle: JS.getLanguageFromCode(Settings.language)
                    onClicked: languagePopup.open()
                }

                SettingsItem {
                    property string name: JS.getCountryFromCode(Settings.country)
                    property string nativeName: JS.getCountryFromCode(Settings.country, "native")

                    title: qsTr("Country")
                    subtitle: nativeName + ((name !== nativeName) ? " (" + name + ")" : "")
                    onClicked: push(Qt.resolvedUrl("SettingsContinentsPage.qml"))
                }
            }
        }
    }

    ColorSelectionPopup {
        id: primaryColorPopup
    }

    ColorSelectionPopup {
        id: accentColorPopup
        selectAccentColor: true
        currentColor: accentColor
    }

    LocalizationPopup {
        id: languagePopup

        model: System.translations()
        delegateFunction: JS.getLanguageFromCode
        onClicked: {
            Settings.language = data
            currentIndex = index
            close()
        }
        Component.onCompleted: {
            currentIndex = model.indexOf(Settings.language)
        }
    }
}
