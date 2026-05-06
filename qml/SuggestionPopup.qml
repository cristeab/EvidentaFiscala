import QtQuick
import QtQuick.Controls

Popup {
    id: control

    property string userInput
    readonly property int itemHeight: 30
    readonly property int maxRows: 10
    property alias count: controlList.count

    signal clicked(string selection)

    width: Math.min(700, 8 * tableModel.suggestionMaxLength + 20)
    height: Math.min(controlList.contentHeight, control.itemHeight * control.maxRows)
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    focus: true

    onOpened: controlList.forceActiveFocus()

    contentItem: ListView {
        id: controlList
        spacing: 0
        model: tableModel.suggestions(control.userInput)
        clip: true
        interactive: true
        keyNavigationWraps: true
        delegate: ItemDelegate {
            height: suggestionPopup.itemHeight
            text: modelData
            width: parent.width
            onClicked: control.clicked(modelData)
        }
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            active: true
        }
    }
}
