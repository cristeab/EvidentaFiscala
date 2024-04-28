import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

Column {
    property alias text: controlLabel.text
    property alias model: controlCombo.model
    property alias currentIndex: controlCombo.currentIndex
    property alias textRole: controlCombo.textRole
    spacing: 5
    Label {
        id: controlLabel
        elide: Text.ElideRight
        font {
            italic: true
        }
    }
    ComboBox {
        id: controlCombo
        width: parent.width
    }
}
