import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import "../common"

import AppData 1.0

AppStackPage {
    title: qsTr("Add New List")
    padding: 6

    Flickable {
        contentHeight: listPane.implicitHeight
        anchors.fill: parent

        Pane {
            id: listPane

            anchors.fill: parent

            ColumnLayout {
                width: parent.width

                LabelBody {
                    leftPadding: 10
                    rightPadding: 10
                    text: qsTr("Name:")
                }
                Pane {
                    topPadding: 0
                    leftPadding: 10
                    rightPadding: 10
                    Layout.fillWidth: true
                    TextField {
                        id: nameField
                        leftPadding: 10
                        rightPadding: 10
                        anchors.fill: parent
                        placeholderText: qsTr("Tap here to insert name")
                        inputMethodHints: Qt.ImhNoPredictiveText
                        selectByMouse: true
                    }
                }

                HorizontalDivider { }

                ButtonRaised {
                    text: qsTr("Add List")

                    onClicked: {
                        if (nameField.displayText.length > 0) {
                            Qt.inputMethod.commit()
                            if (AppData.addList(nameField.text)) {
                                AppData.selectList(nameField.text)
                                showToast(qsTr("Created list %1").arg(nameField.text))
                                nameField.text = ""
                                nameField.focus = false
                            } else {
                                showError(qsTr("List %1 exists").arg(nameField.text))
                            }
                        }
                    }
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
