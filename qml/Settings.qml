import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

Dialog {
    id: control

    readonly property real selectFolderWidth: control.width * 2 / 3
    readonly property real editWidth: control.selectFolderWidth / 3

    property list<int> invisibleColumns

    title: qsTr("Configurare")
    implicitWidth: winApp.width * 0.75
    implicitHeight: winApp.height * 0.9
    x: (winApp.width-width)/2
    y: (winApp.height-height)/2

    standardButtons: Dialog.Ok | Dialog.Cancel

    Component.onCompleted: control.visible = true
    onAccepted: {
        if (!venitMin.acceptableInput || !invoiceStartNum.acceptableInput) {
            settingsLoader.active = true
            settingsLoader.item.visible = true
        }
        tableModel.setInvisibleColumns(control.invisibleColumns)
        control.invisibleColumns = []
        settings.save()
    }
    onRejected: {
        settingsLoader.active = false
        control.invisibleColumns = []
    }

    TabBar {
        id: tabBar
        width: parent.width
        background: Item {}
        TabButton {
            text: qsTr("General")
        }
        TabButton {
            text: qsTr("Coloane Vizibile")
        }
    }

    StackLayout {
        width: parent.width
        height: parent.height - tabBar.height
        currentIndex: tabBar.currentIndex
        anchors{
            top: tabBar.bottom
            topMargin: Theme.verticalMargin
        }

        // general settings tab
        Item {
            id: generalSettings
            Column {
                anchors.fill: parent
                anchors.margins: Theme.horizontalMargin
                spacing: 2 * Theme.verticalMargin
                LabelTextField {
                    id: venitMin
                    width: control.editWidth
                    text: qsTr("Venitul Minim")
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
                    text: qsTr("Numarul de Start pentru Chitante")
                    editText: settings.invoiceNumberStart
                    onEditingFinished: settings.invoiceNumberStart = parseInt(editText)
                    validator: IntValidator { bottom: 1 }
                }
                LabelComboBox {
                    width: control.editWidth
                    text: qsTr("Limba Interfetei")
                    model: ["RO", "EN", "FR"]
                    currentIndex: settings.languageIndex
                    onCurrentIndexChanged: settings.languageIndex = currentIndex
                }
            }
        } // general settings tab

        // advanced settings tab
        Item {
            id: advancedSettings
            ColumnLayout {
                spacing: Theme.verticalMargin
                Repeater {
                    model: tableModel.tableHeader.length
                    delegate: CheckBox {
                        enabled: (tableModel.tableHeader.length - 1) !== index
                        text: tableModel.tableHeader[index]
                        checked: tableModel.isColumnVisible(index)
                        onCheckedChanged: {
                            if (checked) {
                                control.invisibleColumns.splice(index, 1)
                            } else {
                                control.invisibleColumns.push(index)
                            }
                        }
                    }
                }
            }
        } // advanced settings tab
    } // StackLayout
}
