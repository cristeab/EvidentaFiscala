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
            errMsg.show(qsTr("Setari invalide"), false)
            settingsLoader.active = true
            settingsLoader.item.visible = true
            return
        }

        settings.minIncome = parseFloat(venitMin.editText)
        settings.useBars = 0 === displayMode.currentIndex
        settings.workingFolderPath = workingFolder.editText
        settings.invoiceNumberStart = parseInt(invoiceStartNum.editText)
        settings.languageIndex = uiLanguage.currentIndex

        tableModel.setInvisibleColumns(control.invisibleColumns)
        control.invisibleColumns = []
        settings.save()
        settingsLoader.active = false
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
                Row {
                    spacing: parent.width - venitMin.width - displayMode.width
                    LabelTextField {
                        id: venitMin
                        width: control.editWidth
                        text: qsTr("Venitul Brut Minim")
                        editText: settings.minIncome
                        validator: IntValidator { bottom: 0 }
                    }
                    LabelComboBox {
                        id: displayMode
                        width: control.editWidth
                        text: qsTr("Reprezentarea Grafica")
                        model: ["Bare", "Linii"]
                        currentIndex: settings.useBars ? 0 : 1
                    }
                }
                LabelTextFieldBrowser {
                    id: workingFolder
                    width: control.selectFolderWidth
                    text: qsTr("Directorul de Lucru")
                    editText: settings.workingFolderPath
                }
                LabelTextField {
                    id: invoiceStartNum
                    width: control.editWidth
                    text: qsTr("Numarul de Start pentru Chitante")
                    editText: settings.invoiceNumberStart
                    validator: IntValidator { bottom: 1 }
                }
                LabelComboBox {
                    id: uiLanguage
                    width: control.editWidth
                    text: qsTr("Limba Interfetei")
                    model: ["RO", "EN", "FR"]
                    currentIndex: settings.languageIndex
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
