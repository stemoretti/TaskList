import QtQuick
import QtQuick.Controls.Material

import BaseUI as UI

import TaskList

UI.App {
    title: Qt.application.displayName
    width: 640
    height: 480

    initialPage: "qrc:/qml/ListPage.qml"

    function getTheme(theme) {
        return theme == "System" ? Material.System : (theme == "Dark" ? Material.Dark : Material.Light)
    }

    Connections {
        target: Settings
        function onPrimaryColorChanged() { System.updateStatusBarColor(UI.Style.isDarkTheme) }
        function onThemeChanged() { System.updateStatusBarColor(UI.Style.isDarkTheme) }
        function onToolBarPrimaryChanged() { System.updateStatusBarColor(UI.Style.isDarkTheme) }
    }

    Component.onCompleted: {
        UI.Style.theme = Qt.binding(function() { return getTheme(Settings.theme) })
        UI.Style.primaryColor = Qt.binding(function() { return Settings.primaryColor })
        UI.Style.accentColor = Qt.binding(function() { return Settings.accentColor })
        UI.Style.isDarkTheme = Qt.binding(function() { return Material.theme === Material.Dark })
        UI.Style.toolBarPrimary = Qt.binding(function() { return Settings.toolBarPrimary })
        System.updateStatusBarColor(UI.Style.isDarkTheme)
        System.checkPermissions()
    }
}
