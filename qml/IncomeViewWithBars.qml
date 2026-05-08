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
        categories: controller.barMonths
    }
    axisY: ValueAxis {
        min: controller.yAxisMin
        max: 1.05 * controller.yAxisMax
        labelFormat: "%.0f"
        titleText: "RON"
    }

    ToolTip {
        id: pointTooltip
        visible: false
        function show(name, position, value) {
            const index = Math.round(value.x)
            const revenue = controller.barRevenue[index];
            const netIncome = controller.barNetIncome[index];
            pointTooltip.text = qsTr("Gross Income: %1\nNet Income: %2\nExpenses: %3")
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
            label: qsTr("Gross Income")
            color: "blue"
            values: controller.barRevenue
        }
        BarSet {
            label: qsTr("Net Income")
            color: "orange"
            values: controller.barNetIncome
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
