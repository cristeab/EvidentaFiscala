import QtQuick
import QtQuick.Controls

Item {
    id: control

    property int currentRow

    function show() {
        contextMenu.popup()
    }

    Menu {
        id: contextMenu

        MenuItem {
            text: "Delete row " + control.currentRow
            onTriggered: {
                //TODO: show confirmation dialog
                //tableModel.remove(control.currentRow)
                contextMenu.close()
            }
        }
    }
}
