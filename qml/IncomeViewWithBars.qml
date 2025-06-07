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
        categories: ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
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
            values: [80000, 85000, 90000, 87000, 95000, 93000]
        }
        BarSet {
            label: qsTr("Venit Net")
            color: "orange"
            values: [12000, 15000, 17000, 14000, 18000, 16000]
        }
    }
}
