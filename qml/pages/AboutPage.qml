import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import "../ekke/common"
import "../common"

AppStackPage {
    title: qsTr("About")
    padding: 10

    Flickable {
        contentHeight: aboutPane.implicitHeight
        anchors.fill: parent

        Pane {
            id: aboutPane

            anchors.fill: parent

            ColumnLayout {
                width: parent.width

                LabelTitle {
                    text: "TaskList"
                    Layout.alignment: Qt.AlignHCenter
                }

                LabelBody {
                    text: "<a href='http://github.com/stemoretti/tasklist'>"
                          + "github.com/stemoretti/tasklist</a>"
                    linkColor: isDarkTheme ? "lightblue" : "blue"
                    Layout.alignment: Qt.AlignHCenter
                    onLinkActivated: Qt.openUrlExternally(link)
                }

                HorizontalDivider { }

                LabelSubheading {
                    text: qsTr("This app is based on the following software:")
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                LabelBody {
                    text: "Qt 5.12.2\n"
                          + "Copyright 2008-2019 The Qt Company Ltd."
                          + " All rights reserved."
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                LabelBody {
                    text: "Qt is under the LGPLv3 license."
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                HorizontalDivider { }

                LabelBody {
                    text: "<a href='https://material.io/tools/icons/'"
                          + "title='Material Design'>Material Design</a>"
                          + " icons are under Apache license version 2.0"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    linkColor: isDarkTheme ? "lightblue" : "blue"
                    onLinkActivated: Qt.openUrlExternally(link)
                }

                HorizontalDivider { }

                LabelBody {
                    text: "<div>Icon made by "
                          + "<a href='https://www.freepik.com/'"
                          + " title='Freepik'>Freepik</a> from "
                          + "<a href='https://www.flaticon.com/'"
                          + " title='Flaticon'>www.flaticon.com</a>"
                          + " is licensed by "
                          + "<a href='http://creativecommons.org/licenses/by/3.0/'"
                          + " title='Creative Commons BY 3.0'"
                          + " target='_blank'>CC 3.0 BY</a></div>"
                    wrapMode: Text.WordWrap
                    linkColor: isDarkTheme ? "lightblue" : "blue"
                    onLinkActivated: Qt.openUrlExternally(link)
                    Layout.fillWidth: true
                }

                HorizontalDivider { }

                LabelSubheading {
                    text: qsTr("Some code taken from the following repositories.")
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                LabelBody {
                    text: "<a href='https://www.github.com/ekke'>github.com/ekke</a>"
                    linkColor: isDarkTheme ? "lightblue" : "blue"
                    onLinkActivated: Qt.openUrlExternally(link)
                    Layout.alignment: Qt.AlignHCenter
                }

                LabelBody {
                    text: "<a href='http://gitlab.unique-conception.org/"
                          + "qt-qml-tricks/ui-elements-ng'>"
                          + "gitlab unique-conception ui-elements-ng</a>"
                    linkColor: isDarkTheme ? "lightblue" : "blue"
                    onLinkActivated: Qt.openUrlExternally(link)
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
