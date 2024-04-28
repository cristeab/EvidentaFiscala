import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Column {
    id: control

    property alias text: controlLabel.text
    property alias editText: controlTextField.text
    property alias validator: controlTextField.validator
    property alias echoMode: controlTextField.echoMode

    signal editingFinished()

    spacing: 5

    Label {
        id: controlLabel
        elide: Text.ElideRight
        color: control.error ? Theme.errorColor : Material.foreground
        font {
            italic: true
        }
    }
    TextField {
        id: controlTextField
        width: parent.width
        onEditingFinished: control.editingFinished()
    }
}
