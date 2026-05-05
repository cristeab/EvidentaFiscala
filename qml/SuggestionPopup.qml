import QtQuick
import QtQuick.Controls

Popup {
    id: control

    property string userInput
    readonly property int itemHeight: 30
    readonly property int maxRows: 10
    property alias count: suggestionList.count

    width: Math.min(700, 8 * tableModel.suggestionMaxLength)
    height: Math.min(suggestionList.contentHeight, control.itemHeight * control.maxRows)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    signal clicked(string selection)

    contentItem: ListView {
        id: suggestionList
        spacing: 0
        model: tableModel.suggestions(control.userInput)
        delegate: ItemDelegate {
            height: suggestionPopup.itemHeight
            text: modelData
            width: parent.width
            onClicked: control.clicked(modelData)
        }
    }
}
