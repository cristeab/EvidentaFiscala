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
        min: tableModel.yAxisMin
        max: 1.05 * tableModel.yAxisMax
        labelFormat: "%.0f"
        titleText: "RON"
    }

    ToolTip {
        id: pointTooltip
        visible: false
        function show(name, position, value) {
            const index = Math.round(value.x)
            const revenue = tableModel.barRevenue[index];
            const netIncome = tableModel.barNetIncome[index];
            pointTooltip.text = qsTr("Venit Brut: %1\nVenit Net: %2\nCheltuieli: %3")
            .arg(revenue)
            .arg(netIncome)
            .arg(revenue - netIncome)
            pointTooltip.x = position.x + 80
            pointTooltip.y = position.y + 20
            pointTooltip.visible = true
        }
        function hide() {
            pointTooltip.visible = false
        }
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
        labelsVisible: true
        labelsPrecision: 2
        labelsPosition: BarSeries.LabelsPosition.OutsideEnd
        hoverable: true
        onHover: (name, position, value) => {
            pointTooltip.show(name, position, value)
        }
        onHoverExit: pointTooltip.hide()
    }
}
