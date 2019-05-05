import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    id: page

    property bool canNavigateBack: false
    property alias appToolBar: appToolBar
    property alias leftButton: appToolBar.leftButton
    property alias rightButtons: appToolBar.rightButtons

    function pop(item, operation) {
        if (StackView.view.currentItem !== page)
            return false

        return StackView.view.pop(item, operation)
    }

    function push(item, properties, operation) {
        return StackView.view.push(item, properties, operation)
    }

    Keys.onBackPressed: {
        if (StackView.view.depth > 1) {
            event.accepted = true
            pop()
        } else {
            Qt.quit()
        }
    }

    Action {
        id: backAction
        icon.source: "image://icon/arrow_back"
        onTriggered: page.pop()
    }

    AppToolBar {
        id: appToolBar
        title: page.title
        leftButton: canNavigateBack ? backAction : null
    }
}
