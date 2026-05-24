import QtQuick
import QtQuick.Controls

Menu {
    id: contextMenu

    property int currentRow

    implicitWidth: textMetrics.boundingRect.width + 50

    TextMetrics {
        id: textMetrics
        font.pixelSize: 14
        text: deleteItem.text
    }

    MenuItem {
        id: deleteItem
        text: qsTr("Delete row #") + contextMenu.currentRow + " ..."

        width: parent.width
        implicitHeight: fontMetrics.height + 8

        FontMetrics {
            id: fontMetrics
            font: deleteItem.font
        }

        onTriggered: {
            dialogLoader.show(qsTr("Question"),
                              qsTr("Are you sure you want to delete row #") + contextMenu.currentRow + " ?",
                              contextMenu.currentRow,
                              (arg) => {
                                  const index = parseInt(arg)
                                  tableModel.remove(index)
                                  tableTab.deselectRow(index)
                              },
                              (arg) => {
                                  const index = parseInt(arg)
                                  tableTab.deselectRow(index)
                              })
            contextMenu.close()
        }
    }
}
