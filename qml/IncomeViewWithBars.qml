import QtQuick
import QtGraphs
import QtQuick.Controls
import TableModel 1.0

GraphsView {
    antialiasing: true
    theme: GraphsTheme {
        colorScheme: GraphsTheme.ColorScheme.Dark
    }

    axisX: BarCategoryAxis {
        categories: tableModel.barMonths
    }
    axisY: ValueAxis {
        min: 0
        max: 100000
        labelFormat: "%.0f"
    }

    BarSeries {
        BarSet {
            label: qsTr("Venit Brut")
            color: "blue"
            values: tableModel.barRevenue
        }
        BarSet {
            label: qsTr("Venit Net")
            color: "orange"
            values: tableModel.barNetIncome
        }
    }
}
