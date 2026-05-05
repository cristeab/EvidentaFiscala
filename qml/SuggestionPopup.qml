import QtQuick
import QtQuick.Controls

Popup {
    id: control

    width: 150
    height: childrenRect.height
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    signal clicked(string selection)

    contentItem: ListView {
        id: suggestionList
        model: ["Option A", "Option B", "Option C"]
        delegate: ItemDelegate {
            text: modelData
            width: parent.width
            onClicked: control.clicked(modelData)
        }
    }
}
