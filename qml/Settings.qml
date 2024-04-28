import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

Dialog {
    id: control

    readonly property real selectFolderWidth: control.width * 2 / 3
    readonly property real editWidth: control.selectFolderWidth / 3

    implicitWidth: winApp.width * 3 / 4
    x: (winApp.width-width)/2
    y: (winApp.height-height)/2 - 25

    standardButtons: Dialog.Ok | Dialog.Cancel

    Component.onCompleted: control.visible = true
    onAccepted: settings.save()
    onRejected: settingsLoader.active = false

    Column {
        id: settingsCol
        anchors.centerIn: parent
        spacing: 5
        LabelTextField {
            id: venitMin
            width: control.editWidth
            text: qsTr("Venit Minim")
            editText: settings.minIncome
            onEditTextChanged: settings.minIncome = parseFloat(editText)
        }
        LabelTextFieldBrowser {
            width: control.selectFolderWidth
            text: qsTr("Directorul cu Fisiere CSV")
            editText: settings.csvFolderPath
            onEditTextChanged: settings.csvFolderPath = editText
        }
        LabelTextField {
            width: control.editWidth
            text: qsTr("Numar de Start pentru Chitante")
            editText: settings.invoiceNumberStart
            onEditTextChanged: settings.invoiceNumberStart = parseInt(editText)
        }
        LabelComboBox {
            width: control.editWidth
            text: qsTr("Selectati Limba Interfetei")
            model: ["RO", "EN", "FR"]
            currentIndex: settings.languageIndex
            onCurrentIndexChanged: settings.languageIndex = currentIndex
        }
    }
}
