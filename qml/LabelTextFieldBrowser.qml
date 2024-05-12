import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Column {
    id: control

    property alias text: controlLabel.text
    property alias editText: controlTextField.text

    spacing: 5

    Label {
        id: controlLabel
        width: parent.width
        elide: Text.ElideRight
        color: Material.foreground
        font {
            italic: true
        }
    }
    Row {
        id: browseRow
        spacing: 5
        TextField {
            id: controlTextField
            width: control.width - browseButton.width - browseRow.spacing
        }
        Button {
            id: browseButton
            height: controlTextField.height
            width: height
            icon.source: "qrc:/img/FolderOpen.svg"
            display: AbstractButton.IconOnly
            onClicked: {
                folderDialogLoader.active = true
                folderDialogLoader.item.visible = true
            }
        }
    }
}
