import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

Dialog {
    id: control

    readonly property real selectFolderWidth: control.width * 2 / 3
    readonly property real editWidth: control.selectFolderWidth / 3

    title: qsTr("Settings")
    implicitWidth: winApp.width * 0.75
    implicitHeight: winApp.height * 0.9
    x: (winApp.width-width)/2
    y: (winApp.height-height)/2

    standardButtons: Dialog.Ok | Dialog.Cancel

    Component.onCompleted: control.visible = true
    onAccepted: {
        if (!minIncome.acceptableInput || !invoiceStartNum.acceptableInput) {
            errMsg.show(qsTr("Invalid Settings"), false)
            settingsLoader.active = true
            return
        }

        generalSettings.save()
        advancedSettings.save()
        backupSettings.save()

        settings.save()

        control.close()
        settingsLoader.active = false
    }
    onRejected: {
        control.close()
        settingsLoader.active = false
    }

    TabBar {
        id: tabBar
        width: parent.width
        background: Item {}
        TabButton {
            text: qsTr("General")
        }
        TabButton {
            text: qsTr("Visible Columns")
        }
        TabButton {
            text: qsTr("Backup")
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

            function save() {
                settings.minIncome = parseFloat(minIncome.editText)
                settings.useBars = 0 === displayMode.currentIndex
                settings.workingFolderPath = workingFolder.editText
                settings.invoiceNumberStart = parseInt(invoiceStartNum.editText)
                settings.languageIndex = uiLanguage.currentIndex
                settings.csvHeaderIndex = csvLanguage.currentIndex
            }

            Column {
                anchors.fill: parent
                anchors.margins: Theme.horizontalMargin
                spacing: 2 * Theme.verticalMargin
                Row {
                    id: grossIncomeRow
                    spacing: parent.width - minIncome.width - displayMode.width
                    LabelTextField {
                        id: minIncome
                        width: control.editWidth
                        text: qsTr("Minimum Gross Income")
                        editText: settings.minIncome
                        validator: IntValidator { bottom: 0 }
                    }
                    LabelComboBox {
                        id: displayMode
                        width: control.editWidth
                        text: qsTr("Graphic Representation")
                        model: [qsTr("Bars"), qsTr("Lines")]
                        currentIndex: settings.useBars ? 0 : 1
                    }
                }
                LabelTextFieldBrowser {
                    id: workingFolder
                    width: control.selectFolderWidth
                    text: qsTr("Working Directory")
                    editText: settings.workingFolderPath
                }
                LabelTextField {
                    id: invoiceStartNum
                    width: control.editWidth
                    text: qsTr("Starting Number for Receipts")
                    editText: settings.invoiceNumberStart
                    validator: IntValidator { bottom: 1 }
                }
                Row {
                    spacing: grossIncomeRow.spacing
                    LabelComboBox {
                        id: uiLanguage
                        width: control.editWidth
                        text: qsTr("Interface Language")
                        model: ["RO", "EN", "FR"]
                        currentIndex: settings.languageIndex
                    }
                    LabelComboBox {
                        id: csvLanguage
                        width: control.editWidth
                        text: qsTr("CSV Header Language")
                        model: uiLanguage.model
                        currentIndex: settings.csvHeaderIndex
                    }
                }
            }
        } // general settings tab

        // advanced settings tab
        Item {
            id: advancedSettings

            function save() {
                settings.enableRowNumber = enableRowNumber.checked

                let invisibleColumns = []
                for (let i = 0; i < (columnRepeater.count - 1); ++i) {
                    const it = columnRepeater.itemAt(i)
                    if (!it.checked) {
                        invisibleColumns.push(i)
                    }
                }
                if (tableModel.updateInvisibleColumns(invisibleColumns)) {
                    errMsg.show(qsTr("Restart the application to apply changes"), false)
                }
            }

            ColumnLayout {
                id: leftCol
                spacing: Theme.verticalMargin
                Repeater {
                    id: columnRepeater
                    model: tableModel.tableHeader.length
                    delegate: CheckBox {
                        enabled: (tableModel.tableHeader.length - 1) !== index
                        text: tableModel.tableHeader[index]
                        checked: tableModel.isColumnVisible(index)
                    }
                }
            }
            CheckBox {
                id: enableRowNumber
                anchors {
                    top: leftCol.top
                    left: leftCol.right
                    leftMargin: 4 * Theme.horizontalMargin
                }
                text: qsTr("Enable Row Numbers")
                checked: settings.enableRowNumber
            }
        } // advanced settings tab

        // backup tab
        Item {
            id: backupSettings

            function save() {
                settings.enableBackup = gitBackup.checked
                settings.userName = userName.text
                settings.userEmail = userEmail.text
            }

            Column {
                anchors.fill: parent
                anchors.margins: Theme.horizontalMargin
                spacing: 2 * Theme.verticalMargin
                CheckBox {
                    id: gitBackup
                    text: qsTr("Git Backup")
                }
                LabelTextField {
                    id: userName
                    enabled: gitBackup.checked
                    width: 3 * control.editWidth
                    text: qsTr("Username")
                    editText: settings.userName
                }
                LabelTextField {
                    id: userEmail
                    enabled: gitBackup.checked
                    width: 3 * control.editWidth
                    text: qsTr("User Email")
                    editText: settings.userEmail
                    inputMethodHints: Qt.ImhEmailCharactersOnly
                    validator: RegularExpressionValidator {
                        regularExpression: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
                    }
                }
            }
        } // backup tab
    } // StackLayout
}
