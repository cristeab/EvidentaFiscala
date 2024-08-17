import QtQuick
import QtCharts
import TableModel 1.0

ChartView {
    antialiasing: true
    theme: ChartView.ChartThemeDark
    legend.alignment: Qt.AlignBottom
    DateTimeAxis {
        id: axisX
        format: "MMM yyyy"
        min: tableModel.xAxisMin
        max: tableModel.xAxisMax
        tickCount: tableModel.xAxisTickCount
    }
    ValueAxis {
        id: axisY
        min: tableModel.yAxisMin
        max: tableModel.yAxisMax
        titleText: "RON"
    }

    Text {
        id: pointTooltip
        color: Theme.accentColor
        font {
            bold: true
            pixelSize: 12
        }
        visible: false
        function show(point, color) {
            pointTooltip.text = point.y.toFixed(2)
            pointTooltip.color = color
            pointTooltip.visible = true
            pointTooltip.x = mapToPosition(point).x
            pointTooltip.y = mapToPosition(point).y - 15
        }
    }

    LineSeries {
        id: grossIncomeLineSeries
        name: qsTr("Venit Brut")
        color: "#16c5f0"
        axisX: axisX
        axisY: axisY
        style: Qt.DashDotLine
        width: 2
        onHovered: function(point, state) {
            if (state) {
                pointTooltip.show(point, grossIncomeLineSeries.color)
            } else {
                pointTooltip.visible = false
            }
        }
    }
    LineSeries {
        id: expenseLineSeries
        name: qsTr("Cheltuieli")
        color: "#b416e7"
        axisX: axisX
        axisY: axisY
        style: Qt.SolidLine
        width: 2
        onHovered: function(point, state) {
            if (state) {
                pointTooltip.show(point, expenseLineSeries.color)
            } else {
                pointTooltip.visible = false
            }
        }
    }
    LineSeries {
        id: netIncomeLineSeries
        name: qsTr("Venit Net")
        color: "#21f15e"
        axisX: axisX
        axisY: axisY
        style: Qt.SolidLine
        width: 2
        onHovered: function(point, state) {
            if (state) {
                pointTooltip.show(point, netIncomeLineSeries.color)
            } else {
                pointTooltip.visible = false
            }
        }
    }
    LineSeries {
        id: threshold
        axisX: axisX
        axisY: axisY
        style: Qt.DashDotDotLine
        color: "lightgray"
        width: 1
        onHovered: function(point, state) {
            if (state) {
                pointTooltip.show(point, threshold.color)
            } else {
                pointTooltip.visible = false
            }
        }
    }
    Component.onCompleted: {
        tableModel.setChartSeries(TableModel.GROSS_INCOME_CURVE, grossIncomeLineSeries)
        tableModel.setChartSeries(TableModel.EXPENSE_CURVE, expenseLineSeries)
        tableModel.setChartSeries(TableModel.NET_INCOME_CURVE, netIncomeLineSeries)
        tableModel.setChartSeries(TableModel.THRESHOLD_CURVE, threshold)
    }
}
