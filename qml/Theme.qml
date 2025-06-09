pragma Singleton

import QtQuick
import QtQuick.Controls.Material

QtObject {
    // column type indices
    readonly property int dateColumn: 0
    readonly property int bankIncomeColumn: 1
    readonly property int cashIncomeColumn: 2
    readonly property int bankExpensesColumn: 3
    readonly property int cashExpensesColumn: 4
    readonly property int invoiceNumberColumn: 5
    readonly property int commentsColumn: 6

    readonly property real verticalMargin: 5
    readonly property real horizontalMargin: 10
    readonly property int minimumColumnWidth: 90

    readonly property color backgroundColor: Material.background
    readonly property color foregroundColor: Material.foreground
    readonly property color accentColor: Material.accent
}
