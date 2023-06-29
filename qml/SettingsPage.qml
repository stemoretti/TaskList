import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import "languages.js" as JS

import BaseUI as UI

import TaskList

UI.AppStackPage {
    id: root

    title: qsTr("Settings")
    padding: 0

    leftButton: Action {
        icon.source: UI.Icons.arrow_back
        onTriggered: root.back()
    }

    Flickable {
        id: flick

        contentHeight: settingsPane.implicitHeight
        anchors.fill: parent

        boundsMovement: Flickable.StopAtBounds
        boundsBehavior: Flickable.DragOverBounds

        Pane {
            id: settingsPane

            anchors.fill: parent
            padding: 0

            ColumnLayout {
                width: parent.width
                spacing: 0

                UI.SettingsSectionTitle { text: qsTr("Theme and colors") }

                UI.SettingsItem {
                    title: qsTr("Theme")
                    subtitle: qsTr(themeDialog.selected())
                    onClicked: themeDialog.open()
                    Layout.fillWidth: true
                }

                UI.SettingsItem {
                    title: qsTr("Primary Color")
                    subtitle: colorDialog.getColorName(GlobalSettings.primaryColor)
                    onClicked: {
                        colorDialog.selectAccentColor = false
                        colorDialog.open()
                    }
                }

                UI.SettingsItem {
                    title: qsTr("Accent Color")
                    subtitle: colorDialog.getColorName(GlobalSettings.accentColor)
                    onClicked: {
                        colorDialog.selectAccentColor = true
                        colorDialog.open()
                    }
                }

                UI.SettingsCheckItem {
                    title: qsTr("Tool bar primary color")
                    subtitle: qsTr("Use the primary color for the tool bar background")
                    checkState: GlobalSettings.toolBarPrimary ? Qt.Checked : Qt.Unchecked
                    onClicked: GlobalSettings.toolBarPrimary = !GlobalSettings.toolBarPrimary
                    Layout.fillWidth: true
                }

                UI.SettingsSectionTitle { text: qsTr("Localization") }

                UI.SettingsItem {
                    title: qsTr("Language")
                    subtitle: JS.getLanguageFromCode(GlobalSettings.language)
                    onClicked: languageDialog.open()
                }

                UI.SettingsItem {
                    property string name: JS.getCountryFromCode(GlobalSettings.country)
                    property string nativeName: JS.getCountryFromCode(GlobalSettings.country, "native")

                    title: qsTr("Country")
                    subtitle: nativeName + ((name !== nativeName) ? " (" + name + ")" : "")
                    onClicked: root.stack.push(Qt.resolvedUrl("SettingsContinentsPage.qml"))
                }

                UI.SettingsSectionTitle { text: qsTr("Task settings") }

                UI.SettingsCheckItem {
                    title: qsTr("Strikethrough completed tasks")
                    subtitle: qsTr("Add a strikethrough over the name of completed tasks in list view")
                    checkState: GlobalSettings.strikeCompleted ? Qt.Checked : Qt.Unchecked
                    onClicked: GlobalSettings.strikeCompleted = !GlobalSettings.strikeCompleted
                    Layout.fillWidth: true
                }

                UI.SettingsCheckItem {
                    title: qsTr("Use AM/PM time selection")
                    subtitle: qsTr("The time is selected using AM/PM clock")
                    checkState: GlobalSettings.timeAMPM ? Qt.Checked : Qt.Unchecked
                    onClicked: GlobalSettings.timeAMPM = !GlobalSettings.timeAMPM
                    Layout.fillWidth: true
                }

                UI.SettingsCheckItem {
                    title: qsTr("Use the tumbler time selector")
                    subtitle: qsTr("Select the time using a tumbler clock")
                    checkState: GlobalSettings.timeTumbler ? Qt.Checked : Qt.Unchecked
                    onClicked: GlobalSettings.timeTumbler = !GlobalSettings.timeTumbler
                    Layout.fillWidth: true
                }

                UI.SettingsSectionTitle { text: qsTr("Backups") }

                UI.SettingsItem {
                    title: qsTr("Export lists")
                    subtitle: qsTr("Save the lists to a safe location")
                    onClicked: saveBackupDialog.open()
                }

                UI.SettingsItem {
                    title: qsTr("Import lists")
                    subtitle: qsTr("Load previously saved lists backups")
                    onClicked: loadBackupDialog.open()
                }
            }
        }
    }

    FileDialog {
        id: loadBackupDialog

        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        onAccepted: AppData.readListFile(selectedFile)
    }

    FileDialog {
        id: saveBackupDialog

        fileMode: FileDialog.SaveFile
        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        selectedFile: {
            "%1/TaskList_backup_lists_%2.json"
                .arg(currentFolder)
                .arg(Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH:mm"))
        }
        onAccepted: AppData.writeListFile(selectedFile)
    }

    UI.EdgeEffect {
        width: parent.width
        anchors.top: parent.top
        side: UI.EdgeEffect.Side.Top
        overshoot: flick.verticalOvershoot < 0 ? -flick.verticalOvershoot : 0
        maxOvershoot: parent.height
        color: UI.Style.isDarkTheme ? "gray" : "darkgray"
    }

    UI.EdgeEffect {
        width: parent.width
        anchors.bottom: parent.bottom
        side: UI.EdgeEffect.Side.Bottom
        overshoot: flick.verticalOvershoot > 0 ? flick.verticalOvershoot : 0
        maxOvershoot: parent.height
        color: UI.Style.isDarkTheme ? "gray" : "darkgray"
    }

    UI.OptionsDialog {
        id: themeDialog

        function selected() {
            for (var i = 0; i < model.length; i++)
                if (model[i] === GlobalSettings.theme)
                    return model[i]
        }

        title: qsTr("Choose theme style")
        model: [ QT_TR_NOOP("Dark"), QT_TR_NOOP("Light"), QT_TR_NOOP("System") ]
        delegate: RowLayout {
            spacing: 0

            RadioButton {
                checked: modelData === GlobalSettings.theme
                text: qsTr(modelData)
                Layout.leftMargin: 4
                onClicked: {
                    themeDialog.close()
                    GlobalSettings.theme = modelData
                }
            }
        }
    }

    UI.OptionsDialog {
        id: colorDialog

        property bool selectAccentColor: false

        function getColorName(color) {
            var filtered = colorDialog.model.filter((c) => {
                return Material.color(c.bg) === color
            })
            return filtered.length ? filtered[0].name : ""
        }

        title: selectAccentColor ? qsTr("Choose accent color") : qsTr("Choose primary color")
        model: [
            { name: "Material Red", bg: Material.Red },
            { name: "Material Pink", bg: Material.Pink },
            { name: "Material Purple", bg: Material.Purple },
            { name: "Material DeepPurple", bg: Material.DeepPurple },
            { name: "Material Indigo", bg: Material.Indigo },
            { name: "Material Blue", bg: Material.Blue },
            { name: "Material LightBlue", bg: Material.LightBlue },
            { name: "Material Cyan", bg: Material.Cyan },
            { name: "Material Teal", bg: Material.Teal },
            { name: "Material Green", bg: Material.Green },
            { name: "Material LightGreen", bg: Material.LightGreen },
            { name: "Material Lime", bg: Material.Lime },
            { name: "Material Yellow", bg: Material.Yellow },
            { name: "Material Amber", bg: Material.Amber },
            { name: "Material Orange", bg: Material.Orange },
            { name: "Material DeepOrange", bg: Material.DeepOrange },
            { name: "Material Brown", bg: Material.Brown },
            { name: "Material Grey", bg: Material.Grey },
            { name: "Material BlueGrey", bg: Material.BlueGrey }
        ]
        delegate: RowLayout {
            spacing: 0

            Rectangle {
                visible: colorDialog.selectAccentColor
                color: UI.Style.primaryColor
                Layout.margins: 0
                Layout.leftMargin: 10
                Layout.minimumWidth: 48
                Layout.minimumHeight: 32
            }

            Rectangle {
                color: Material.color(modelData.bg)
                Layout.margins: 0
                Layout.leftMargin: colorDialog.selectAccentColor ? 0 : 10
                Layout.minimumWidth: 32
                Layout.minimumHeight: 32
            }

            RadioButton {
                checked: {
                    if (colorDialog.selectAccentColor)
                        Material.color(modelData.bg) === UI.Style.accentColor
                    else
                        Material.color(modelData.bg) === UI.Style.primaryColor
                }
                text: modelData.name
                Layout.leftMargin: 4
                onClicked: {
                    colorDialog.close()
                    if (colorDialog.selectAccentColor)
                        GlobalSettings.accentColor = Material.color(modelData.bg)
                    else
                        GlobalSettings.primaryColor = Material.color(modelData.bg)
                }
            }
        }
    }

    UI.OptionsDialog {
        id: languageDialog

        title: qsTr("Language")
        model: System.translations()
        delegate: RadioButton {
            checked: modelData === GlobalSettings.language
            text: JS.getLanguageFromCode(modelData)
            onClicked: { languageDialog.close(); GlobalSettings.language = modelData }
        }
    }
}
