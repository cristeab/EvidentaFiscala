import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Column {
    id: control

    property alias text: controlLabel.text
    property alias editText: controlTextField.text

    spacing: 5
    onEditTextChanged: control.error = false

    Label {
        id: controlLabel
        width: parent.width
        elide: Text.ElideRight
        color: control.error ? Theme.errorColor : Material.foreground
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
            width: height
            text: qsTr("...")
            onClicked: {
                if (control.selectFolder) {
                    fileDialogLoader.active = true
                } else {
                    fileDlgLoader.active = true
                    fileDlgLoader.item.visible = true
                }
            }
        }
    }
}
