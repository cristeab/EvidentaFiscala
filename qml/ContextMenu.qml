import QtQuick
import QtQuick.Controls

Menu {
    id: contextMenu

    property int currentRow

    implicitWidth: textMetrics.boundingRect.width + 40

    TextMetrics {
        id: textMetrics
        font.pixelSize: 14  // match your app font
        text: menuItem.text
    }

    MenuItem {
        id: menuItem
        text: qsTr("Delete row ") + contextMenu.currentRow + " ..."

        width: parent.width
        topPadding: 0
        bottomPadding: 0
        leftPadding: 8
        rightPadding: 8

        onTriggered: {
            //TODO: show confirmation dialog
            //tableModel.remove(contextMenu.currentRow)
            contextMenu.close()
        }
    }
}
