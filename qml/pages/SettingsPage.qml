import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import "../ekke/common"
import "../common"
import "../popups"
import "../languages.js" as JS

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
                    subtitle: appSettings.darkTheme ?
                                  qsTr("Dark theme is enabled") :
                                  qsTr("Dark theme is disabled")
                    check.visible: true
                    check.checked: appSettings.darkTheme
                    check.onClicked: appSettings.darkTheme = !appSettings.darkTheme
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
                    subtitle: JS.getLanguageFromCode(appSettings.language)
                    onClicked: languagePopup.open()
                }

                SettingsItem {
                    title: qsTr("Region")
                    subtitle: JS.getRegionFromCode(appSettings.region)
                    onClicked: regionPopup.open()
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

        model: appTranslations
        delegateFunction: JS.getLanguageFromCode
        onClicked: {
            appSettings.language = data
            currentIndex = index
            close()
        }
        Component.onCompleted: {
            currentIndex = model.indexOf(appSettings.language)
        }
    }

    LocalizationPopup {
        id: regionPopup

        model: JS.regions.map(function (o) { return o.code })
        delegateFunction: JS.getRegionFromCode
        onClicked: {
            appSettings.region = data
            currentIndex = index
            close()
        }
        Component.onCompleted: {
            currentIndex = model.indexOf(appSettings.region)
        }
    }
}
