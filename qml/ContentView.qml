import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import TableModel 1.0

Item {
    id: control

    property alias calendarVisible: calendar.visible
    property alias count: tableView.rows
    readonly property var locale: Qt.locale()

    function deselectRow(index) {
        tableView.deselectRow(index)
    }

    Component.onCompleted: {
        dateField.text = Qt.formatDate(new Date(), controller.dateFormat)
        controller.updateCurrencyRate(dateField.text)
    }

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
            placeholderText: qsTr("Date")
        }
        ComboBox {
            id: typeCombo
            Layout.preferredWidth: 1.75*dateField.width
            model: tableModel.transactionTypeModel
            currentIndex: tableModel.defaultTransactionTypeModelIndex
        }
        TextField {
            id: amountField
            horizontalAlignment: Text.AlignHCenter
            placeholderText: qsTr("Amount")
            validator: DoubleValidator {
                decimals: 4
                notation: DoubleValidator.StandardNotation
            }
        }
        ComboBox {
            id: currencyCombo
            model: tableModel.currencyModel
            currentIndex: tableModel.currencyModelIndex
            onCurrentIndexChanged: {
                tableModel.currencyModelIndex = currentIndex
                controller.updateCurrencyRate(dateField.text)
            }
        }
        TextField {
            id: rateField
            text: control.locale.toString(Number(controller.conversionRate), 'f', 4)
            visible: 0 !== currencyCombo.currentIndex
            horizontalAlignment: Text.AlignHCenter
            placeholderText: qsTr("Exchange Rate")
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
            dateField.text = Qt.formatDate(date, controller.dateFormat)
            calendar.visible = false
            controller.updateCurrencyRate(dateField.text)
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
        placeholderText: qsTr("Comments")

        // Show popup when typing
        onTextChanged: {
            suggestionPopup.userInput = text
            if (suggestionPopup.canOpen &&
                    text.length > 0 &&
                    !suggestionPopup.opened &&
                    0 < suggestionPopup.count) {
                suggestionPopup.open()
            } else if (3 > text.length) {
                suggestionPopup.canOpen = true
            }
        }

        Keys.onEscapePressed: {
            if (suggestionPopup.opened) {
                suggestionPopup.close()
                suggestionPopup.canOpen = false
            }
        }

        SuggestionPopup {
            id: suggestionPopup
            property bool canOpen: true
            x: obsField.cursorRectangle.x
            y: obsField.cursorRectangle.y + obsField.cursorRectangle.height
            onClicked: (selection) => {
                obsField.clear()
                obsField.insert(0, selection)
                suggestionPopup.close()
                suggestionPopup.canOpen = false
            }
        }
    }

    Button {
        id: okButton
        text: qsTr("Add")
        z: 10
        height: 40
        width: 45
        leftPadding: 0
        rightPadding: 0
        anchors {
            top: obsField.bottom
            right: parent.right
        }

        onClicked: {
            if ("" === dateField.text) {
                errMsg.show(qsTr("Date must be specified"))
                calendar.visible = true
                return
            }
            if ("" === amountField.text) {
                errMsg.show(qsTr("Amount must be specified"))
                amountField.focus = true
                return
            }
            if (rateField.visible && ("" === rateField.text)) {
                errMsg.show(qsTr("Exchange rate must be specified"))
                rateField.focus = true
                return
            }
            if ("" === obsField.text) {
                errMsg.show(qsTr("Observations must be specified"))
                obsField.focus = true
                return
            }
            var amount = Number.fromLocaleString(control.locale, amountField.text)
            var rate = Number.fromLocaleString(control.locale, rateField.text)
            if (tableModel.add(dateField.text, typeCombo.currentIndex, amount,
                           currencyCombo.currentIndex, rate, obsField.text)) {
                dateField.text = ""
                typeCombo.currentIndex = tableModel.defaultTransactionTypeModelIndex
                amountField.text = ""
                currencyCombo.currentIndex = 0
                rateField.text = ""
                obsField.text = ""
            } else {
                errMsg.show(qsTr("Cannot add a new row") + "\n" + tableModel.errorMessage)
            }
        }
    }

    TableView {
        id: tableView

        // Relative weight for each column
        readonly property var columnWeights: ({
                                                  [TableModel.DATE_INDEX]:           1.0,
                                                  [TableModel.BANK_INCOME_INDEX]:    1.6,
                                                  [TableModel.CASH_INCOME_INDEX]:    1.6,
                                                  [TableModel.BANK_EXPENSES_INDEX]:  1.6,
                                                  [TableModel.CASH_EXPENSES_INDEX]:  1.6,
                                                  [TableModel.INVOICE_NUMBER_INDEX]: 1.25,
                                                  [TableModel.COMMENTS_INDEX]:       2.5   // gets more space
                                              })
        readonly property real rowNumberWidth: settings.enableRowNumber ? 28 : 0

        function deselectRow(index) {
            const targetIndex = tableView.model.index(index, 0)
            tableView.selectionModel.select(targetIndex, ItemSelectionModel.Deselect | ItemSelectionModel.Rows)
        }

        function totalVisibleWeight() {
            let total = 0
            for (let c = 0; c < tableView.columns; c++) {
                if (tableModel.isColumnVisible(c)) {
                    total += columnWeights[c] ?? 1.0
                }
            }
            return total
        }

        function customColumnWidth(column) {
            if (!tableModel.isColumnVisible(column)) {
                return 0
            }
            const weight = columnWeights[column] ?? 1.0
            // Subtract row-number label width if visible
            const availableWidth = tableView.width - (settings.enableRowNumber ? tableView.rowNumberWidth : 0)
            return Math.floor((weight / totalVisibleWeight()) * availableWidth)
        }

        anchors {
            top: obsField.bottom
            topMargin: 2 * Theme.verticalMargin
            bottom: parent.bottom
        }
        columnWidthProvider: function(column) {
            return column === 0 ? tableView.width : 0
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
        selectionModel: ItemSelectionModel {}
        delegate: Item {
            id: tableRowFrame

            required property int row
            required property bool current
            required property bool selected

            implicitHeight: visible ? tableRow.implicitHeight : 0
            implicitWidth: tableView.width

            Rectangle {
                z: -1
                anchors.fill: parent
                color: "transparent"
                border {
                    width: current ? 2 : 0
                    color: selected ? "red" : palette.base
                }
            }

            RowLayout {
                id: tableRow

                readonly property int visibleRowIndex: settings.sortDescendingOrder ? (tableView.rows - index) : index

                anchors.fill: parent
                spacing: 0

                Label {
                    visible: settings.enableRowNumber
                    text: (0 != index) ? String(tableRow.visibleRowIndex).padStart(2, ' ') : "  "
                    rightPadding: 3
                    font.bold: true
                    color: "gray"
                }
                Repeater {
                    model: [
                        { value: date,          col: TableModel.DATE_INDEX },
                        { value: bankIncome,    col: TableModel.BANK_INCOME_INDEX },
                        { value: cashIncome,    col: TableModel.CASH_INCOME_INDEX },
                        { value: bankExpenses,  col: TableModel.BANK_EXPENSES_INDEX },
                        { value: cashExpenses,  col: TableModel.CASH_EXPENSES_INDEX },
                        { value: invoiceNumber, col: TableModel.INVOICE_NUMBER_INDEX },
                        { value: comments,      col: TableModel.COMMENTS_INDEX }
                    ]

                    delegate: Label {
                        id: rowLabel

                        readonly property bool colVisible: tableModel.isColumnVisible(modelData.col)

                        visible: colVisible
                        Layout.preferredWidth: colVisible ? tableView.customColumnWidth(modelData.col) : 0
                        text: modelData.value
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignLeft
                        clip: true
                        MouseArea {
                            id: rowLabelMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onPressed: (mouse) => {
                                           if (Qt.RightButton === mouse.button) {
                                               const idx = tableView.model.index(tableRowFrame.row, 0)
                                               tableView.selectionModel.setCurrentIndex(idx, ItemSelectionModel.ClearAndSelect | ItemSelectionModel.Rows)
                                               contextMenuLoader.open(tableRowFrame.row)
                                           }
                                       }
                        }
                        ToolTip {
                            id: rowLabelTooltip
                            visible: rowLabelMouseArea.containsMouse && ("" !== rowLabel.text) && rowLabel.truncated
                            text: rowLabel.text
                        }
                    }
                }
            } // RowLayout
        } // Item
    } // TableView
    SelectionRectangle {
        target: tableView
    }
}
