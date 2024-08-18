import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

Dialog {
    id: control

    readonly property real selectFolderWidth: control.width * 2 / 3
    readonly property real editWidth: control.selectFolderWidth / 3

    title: qsTr("Configurare")
    implicitWidth: winApp.width * 3 / 4
    x: (winApp.width-width)/2
    y: (winApp.height-height)/2 - 25

    standardButtons: Dialog.Ok | Dialog.Cancel

    Component.onCompleted: control.visible = true
    onAccepted: {
        if (!venitMin.acceptableInput || !invoiceStartNum.acceptableInput) {
            settingsLoader.active = true
            settingsLoader.item.visible = true
        }
        settings.save()
    }
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
            onEditingFinished: settings.minIncome = parseFloat(editText)
            validator: IntValidator { bottom: 0 }
        }
        LabelTextFieldBrowser {
            width: control.selectFolderWidth
            text: qsTr("Directorul de Lucru")
            editText: settings.workingFolderPath
            onEditTextChanged: settings.workingFolderPath = editText
        }
        LabelTextField {
            id: invoiceStartNum
            width: control.editWidth
            text: qsTr("Numar de Start pentru Chitante")
            editText: settings.invoiceNumberStart
            onEditingFinished: settings.invoiceNumberStart = parseInt(editText)
            validator: IntValidator { bottom: 1 }
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
