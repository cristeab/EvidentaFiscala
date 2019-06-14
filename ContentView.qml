import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls 1.4 as Old

Item {
    readonly property real winWidth: dateField.width + typeCombo.width + amountField.width + currencyCombo.width + rateField.width + 8 * props.horizontalMargin
    clip: true
    TextField {
        id: dateField
        anchors {
            top: parent.top
            topMargin: props.verticalMargin
            left: parent.left
            leftMargin: props.horizontalMargin
        }
        readOnly: true
        horizontalAlignment: Text.AlignHCenter
        MouseArea {
            anchors.fill: parent
            onClicked: calendar.visible = true
        }
        placeholderText: qsTr("Data")
    }
    Old.Calendar {
        id: calendar
        z: 10
        visible: false
        anchors {
            top: dateField.bottom
            topMargin: props.verticalMargin
            left: dateField.left
        }
        onClicked: {
            dateField.text = Qt.formatDate(date, "dd/MM/yyyy")
            calendar.visible = false
        }
    }

    ComboBox {
        id: typeCombo
        width: 1.75*dateField.width
        anchors {
            verticalCenter: dateField.verticalCenter
            left: dateField.right
            leftMargin: props.horizontalMargin
        }
        model: tableModel.typeModel
        currentIndex: 0
    }

    TextField {
        id: amountField
        anchors {
            verticalCenter: typeCombo.verticalCenter
            left: typeCombo.right
            leftMargin: props.horizontalMargin
        }
        horizontalAlignment: Text.AlignHCenter
        placeholderText: qsTr("Suma")
        validator: DoubleValidator {
            decimals: 4
            notation: DoubleValidator.StandardNotation
        }
    }

    ComboBox {
        id: currencyCombo
        anchors {
            verticalCenter: amountField.verticalCenter
            left: amountField.right
            leftMargin: props.horizontalMargin
        }
        model: tableModel.currencyModel
        currentIndex: 0
    }

    TextField {
        id: rateField
        visible: 0 !== currencyCombo.currentIndex
        anchors {
            verticalCenter: currencyCombo.verticalCenter
            left: currencyCombo.right
            leftMargin: props.horizontalMargin
        }
        horizontalAlignment: Text.AlignHCenter
        placeholderText: qsTr("Rata de Schimb")
        validator: DoubleValidator {
            decimals: 4
            notation: DoubleValidator.StandardNotation
        }
    }

    TextArea {
        id: obsField
        anchors {
            top: dateField.bottom
            topMargin: props.verticalMargin
            left: parent.left
            leftMargin: props.horizontalMargin
            right: parent.right
            rightMargin: props.horizontalMargin
        }
        height: 2*dateField.height
        placeholderText: qsTr("Observatii")
    }

    Button {
        id: okButton
        text: qsTr("ADD")
        anchors {
            top: obsField.bottom
            topMargin: props.verticalMargin
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: {
            if ("" === dateField.text) {
                errMsg.show(qsTr("Data trebuie specificata"))
                calendar.visible = true
                return
            }
            if ("" === amountField.text) {
                errMsg.show(qsTr("Suma trebuie specificata"))
                amountField.focus = true
                return
            }
            if (rateField.visible && ("" === rateField.text)) {
                errMsg.show(qsTr("Rata de schimb trebuie specificata"))
                rateField.focus = true
                return
            }
            if ("" === obsField.text) {
                errMsg.show(qsTr("Observatiile trebuie specificate"))
                obsField.focus = true
                return
            }
            var locale = Qt.locale()
            var amount = Number.fromLocaleString(locale, amountField.text)
            var rate = Number.fromLocaleString(locale, rateField.text)
            if (tableModel.add(dateField.text, typeCombo.currentIndex, amount,
                           currencyCombo.currentIndex, rate, obsField.text)) {
                dateField.text = ""
                typeCombo.currentIndex = 0
                amountField.text = ""
                currencyCombo.currentIndex = 0
                rateField.text = ""
                obsField.text = ""
            } else {
                errMsg.show(qsTr("Cannot add row"))
            }
        }
    }

    TableView {
        id: tableView
        anchors {
            top: okButton.bottom
            topMargin: props.verticalMargin
            left: parent.left
            right: parent.right
            rightMargin: props.horizontalMargin
            bottom: parent.bottom
        }
        model: tableModel
        rowSpacing: 5
        clip: true
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        delegate: Row {
            id: tableRow
            readonly property var modelName: [date, bankIncome, cashIncome,
                bankExpenses, cashExpenses, invoiceNumber, observations]
            spacing: 0
            Repeater {
                model: tableModel.tableHeader.length
                delegate: Label {
                    id: rowLabel
                    width: tableView.width/tableModel.tableHeader.length
                    text: tableRow.modelName[index]
                    elide: Text.ElideRight
                    clip: true
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            if (("" !== rowLabel.text) && rowLabel.truncated) {
                                rowLabelTooltip.visible = true
                            }
                        }
                        onExited: {
                            if (("" !== rowLabel.text) && rowLabel.truncated) {
                                rowLabelTooltip.visible = false
                            }
                        }
                    }
                    ToolTip {
                        id: rowLabelTooltip
                        visible: false
                        text: rowLabel.text
                    }
                }
            }
        }
    }
}
