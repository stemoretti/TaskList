import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtQml.Models 2.12
import "../common"
import "../popups"

import AppData 1.0

Item {
    id: root

    property var clist: AppData.currentList

    Component {
        id: listDelegate

        ItemDelegate {
            anchors { left: parent.left; right: parent.right }
            height: contentItem.implicitHeight

            onClicked: push(Qt.resolvedUrl("TaskDetailsPage.qml"),
                              { task: modelData })
            onPressAndHold: {
                taskMenu.task = modelData
                taskMenu.y = mapToItem(listView, 0, listView.y).y
                taskMenu.open()
            }

            contentItem: ColumnLayout {
                id: dataColumn

                anchors.fill: parent
                spacing: 0

                RowLayout {
                    CheckBox {
                        leftPadding: 24
                        checked: model.checked
                        onCheckStateChanged: model.checked = checked
                    }
                    LabelBody {
                        text: model.name
                        font.strikeout: model.checked
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    Component {
        id: sectionDelegate

        LabelSubheading {
            width: parent.width
            text: dateString(new Date(section), Locale.LongFormat)
            color: textOnAccent
            horizontalAlignment: Qt.AlignHCenter
            background: ColumnLayout {
                spacing: 0
                anchors.fill: parent

                HorizontalListDivider { }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: accentColor
                }
                HorizontalListDivider { }
            }
        }
    }

    ListView {
        id: listView

        anchors.fill: parent
        model: clist ? clist.sortedList : 0
        delegate: listDelegate

        section.property: "dueDate"
        section.delegate: sectionDelegate

        ScrollIndicator.vertical: ScrollIndicator { }
    }
}
