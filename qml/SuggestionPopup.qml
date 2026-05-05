import QtQuick
import QtQuick.Controls

Popup {
    id: control

    property string userInput
    readonly property int itemHeight: 40
    readonly property int maxRows: 10
    property alias count: suggestionList.count

    width: 150
    height: Math.min(suggestionList.contentHeight, control.itemHeight * control.maxRows)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    signal clicked(string selection)

    contentItem: ListView {
        id: suggestionList
        model: tableModel.suggestions(control.userInput)
        delegate: ItemDelegate {
            height: suggestionPopup.itemHeight
            text: modelData
            width: parent.width
            onClicked: control.clicked(modelData)
        }
    }
}
