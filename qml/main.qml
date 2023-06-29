import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import BaseUI as UI

import TaskList

UI.App {
    id: root

    title: Qt.application.displayName
    width: 640
    height: 480

    initialPage: "qrc:/qml/ListPage.qml"

    Connections {
        target: GlobalSettings
        function onPrimaryColorChanged() { System.updateStatusBarColor(UI.Style.isDarkTheme) }
        function onToolBarPrimaryChanged() { System.updateStatusBarColor(UI.Style.isDarkTheme) }
    }

    Connections {
        target: UI.Style
        function onIsDarkThemeChanged() { System.updateStatusBarColor(UI.Style.isDarkTheme) }
    }

    Connections {
        target: Application
        function onStateChanged() {
            if (Application.state == Qt.ApplicationSuspended) {
                GlobalSettings.saveSettings();
                AppData.writeListFile();
            }
        }
    }

    Rectangle {
        id: splashscreen

        parent: Overlay.overlay

        x: 0
        y: 0
        width: parent.width
        height: parent.height

        visible: true
        color: Material.background
    }

    Component.onCompleted: {
        UI.Style.theme = Qt.binding(function() { return GlobalSettings.theme })
        UI.Style.primaryColor = Qt.binding(function() { return GlobalSettings.primaryColor })
        UI.Style.accentColor = Qt.binding(function() { return GlobalSettings.accentColor })
        UI.Style.isDarkTheme = Qt.binding(function() { return Material.theme === Material.Dark })
        UI.Style.toolBarPrimary = Qt.binding(function() { return GlobalSettings.toolBarPrimary })
        System.checkPermissions()
        GlobalSettings.loadSettings()
        AppData.readListFile()
        splashscreen.visible = false
    }
}
