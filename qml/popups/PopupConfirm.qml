import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "../ekke/common"
import "../common"

Popup {
    id: popup
    modal: true
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    property bool isConfirmed: false
    property alias text: label.text
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
//    implicitHeight: 160
    implicitWidth: Math.min(parent.width * .9, Math.max(popupColumn.implicitWidth, 300))
    ColumnLayout {
        id: popupColumn
        anchors { right: parent.right; left: parent.left }
        spacing: 10
        LabelSubheading {
            id: label
            topPadding: 20
            leftPadding: 8
            rightPadding: 8
            text: ""
            color: popupTextColor
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        } // popupLabel
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            ButtonFlat {
                id: cancelButton
		text: qsTr("Confirm")
                textColor: primaryColor
                onClicked: {
		    isConfirmed = true
                    popup.close()
                }
                Layout.rightMargin: 15
            } // cancelButton
            ButtonFlat {
                id: exitButton
		text: qsTr("Cancel")
                textColor: accentColor
                onClicked: {
		    isConfirmed = false
                    popup.close()
                }
                Layout.leftMargin: 15
            } // exitButton
        } // row button
    } // col layout

    onAboutToHide: {
        stopTimer()
    }
    onAboutToShow: {
        closeTimer.start()
    }

    Timer {
        id: closeTimer
        interval: 6000
        repeat: false
        onTriggered: {
	    isConfirmed = false
            popup.close()
        }
    }
    function stopTimer() {
        closeTimer.stop()
    }
} // popup
