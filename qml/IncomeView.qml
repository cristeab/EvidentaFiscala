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

    LineSeries {
        id: grossIncomeLineSeries
        name: "Venit Brut"
        color: "#16c5f0"
        axisX: axisX
        axisY: axisY
        style: Qt.DashDotLine
        width: 2
    }
    LineSeries {
        id: expenseLineSeries
        name: "Cheltuieli"
        color: "#b416e7"
        axisX: axisX
        axisY: axisY
        style: Qt.SolidLine
        width: 2
    }
    LineSeries {
        id: netIncomeLineSeries
        name: "Venit Net"
        color: "#21f15e"
        axisX: axisX
        axisY: axisY
        style: Qt.SolidLine
        width: 2
    }
    LineSeries {
        id: threshold
        axisX: axisX
        axisY: axisY
        style: Qt.DashDotDotLine
        color: "lightgray"
        width: 1
    }
    Component.onCompleted: {
        tableModel.setChartSeries(TableModel.GROSS_INCOME_CURVE, grossIncomeLineSeries)
        tableModel.setChartSeries(TableModel.EXPENSE_CURVE, expenseLineSeries)
        tableModel.setChartSeries(TableModel.NET_INCOME_CURVE, netIncomeLineSeries)
        tableModel.setChartSeries(TableModel.THRESHOLD_CURVE, threshold)
    }
}
