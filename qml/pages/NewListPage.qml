import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import "../ekke/common"
import "../common"

AppStackPage {
    title: qsTr("Add New List")

    function resetFocus() {
        nameField.focus = false
    }

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
//                        inputMethodHints: Qt.ImhUppercaseOnly
                        selectByMouse: true
                    }
                }

                HorizontalDivider { }

                ButtonRaised {
                    text: qsTr("Add List")

                    onClicked: {
                        if (nameField.length > 0) {
                            if (appData.addList(nameField.text)) {
                                appData.selectList(nameField.text)
                                showToast(qsTr("Created list %1").arg(nameField.text))
                                nameField.text = ""
                                resetFocus()
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
