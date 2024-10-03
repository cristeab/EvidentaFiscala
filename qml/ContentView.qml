import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: control
    property alias calendarVisible: calendar.visible
    property alias count: tableView.rows
    readonly property string dateFormat: "dd/MM/yyyy"

    Component.onCompleted: dateField.text = Qt.formatDate(new Date(), control.dateFormat)

    clip: true

    RowLayout {
        id: dateFieldRow

        anchors {
            top: parent.top
            topMargin: Theme.verticalMargin
            left: parent.left
            leftMargin: Theme.horizontalMargin
            right: parent.right
            rightMargin: Theme.horizontalMargin
        }
        spacing: Theme.horizontalMargin

        TextField {
            id: dateField
            readOnly: true
            horizontalAlignment: Text.AlignHCenter
            MouseArea {
                anchors.fill: parent
                onClicked: calendar.visible = true
            }
            placeholderText: qsTr("Data")
        }
        ComboBox {
            id: typeCombo
            Layout.preferredWidth: 1.75*dateField.width
            model: tableModel.typeModel
            currentIndex: 2
        }
        TextField {
            id: amountField
            horizontalAlignment: Text.AlignHCenter
            placeholderText: qsTr("Suma")
            validator: DoubleValidator {
                decimals: 4
                notation: DoubleValidator.StandardNotation
            }
        }
        ComboBox {
            id: currencyCombo
            model: tableModel.currencyModel
            currentIndex: 0
        }
        TextField {
            id: rateField
            visible: 0 !== currencyCombo.currentIndex
            horizontalAlignment: Text.AlignHCenter
            placeholderText: qsTr("Rata de Schimb")
            Layout.alignment: Qt.AlignRight
            validator: DoubleValidator {
                decimals: 4
                notation: DoubleValidator.StandardNotation
            }
        }
    }

    DatePicker {
        id: calendar
        z: 10
        visible: false
        anchors {
            top: dateFieldRow.bottom
            topMargin: Theme.verticalMargin
            left: dateFieldRow.left
        }
        onClicked: (date) => {
            dateField.text = Qt.formatDate(date, control.dateFormat)
            calendar.visible = false
        }
    }
    MouseArea {
        z: calendar.z - 1
        anchors.fill: parent
        enabled: calendar.visible
        onClicked: calendar.visible = false
        propagateComposedEvents: true
    }

    TextArea {
        id: obsField
        anchors {
            top: dateFieldRow.bottom
            topMargin: Theme.verticalMargin
            left: parent.left
            leftMargin: Theme.horizontalMargin
            right: parent.right
            rightMargin: Theme.horizontalMargin
        }
        height: 2*dateFieldRow.height
        placeholderText: qsTr("Observatii")
    }

    Button {
        id: okButton
        text: qsTr("Adauga")
        anchors {
            top: obsField.bottom
            topMargin: Theme.verticalMargin
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
                errMsg.show(qsTr("Nu se poate adauga un rand nou"))
            }
        }
    }

    TableView {
        id: tableView

        function customColumnWidth(column) {
            const cols = tableModel.tableHeader.length - tableModel.invisibleColumnsCount()
            let w = tableView.width / cols
            w = (w < Theme.maximumColumnWidth) ? w : Theme.maximumColumnWidth
            if ((cols - 1) === column) {
                return tableView.width - (cols - 1) * w
            }
            return w
        }

        anchors {
            top: okButton.bottom
            topMargin: Theme.verticalMargin
            bottom: parent.bottom
        }
        width: parent.width
        onWidthChanged: tableView.forceLayout()
        model: tableModel
        rowSpacing: 5
        columnSpacing: 0
        clip: true
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        alternatingRows: true
        delegate: RowLayout {
            id: tableRow
            readonly property var modelName: [date, bankIncome, cashIncome,
                bankExpenses, cashExpenses, invoiceNumber, observations]
            spacing: 0
            Repeater {
                model: tableModel.tableHeader.length
                delegate: Label {
                    id: rowLabel
                    Layout.preferredWidth: tableView.customColumnWidth(index)
                    Layout.minimumWidth: Theme.minimumColumnWidth
                    text: tableRow.modelName[index]
                    elide: Text.ElideRight
                    clip: true
                    visible: tableModel.isColumnVisible(index)
                    MouseArea {
                        id: rowLabelMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    ToolTip {
                        id: rowLabelTooltip
                        visible: rowLabelMouseArea.containsMouse && ("" !== rowLabel.text) && rowLabel.truncated
                        text: rowLabel.text
                    }
                }
            }
        }
    }
}
