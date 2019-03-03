import QtQuick 2.12
import QtCharts 2.3
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
        name: "Gross Income"
        color: "#16c5f0"
        axisX: axisX
        axisY: axisY
    }
    LineSeries {
        id: expenseLineSeries
        name: "Expenses"
        color: "#b416e7"
        axisX: axisX
        axisY: axisY
    }
    LineSeries {
        id: netIncomeLineSeries
        name: "Net Income"
        color: "#21f15e"
        axisX: axisX
        axisY: axisY
    }
    Component.onCompleted: {
        tableModel.setChartSeries(TableModel.GROSS_INCOME_CURVE, grossIncomeLineSeries)
        tableModel.setChartSeries(TableModel.EXPENSE_CURVE, expenseLineSeries)
        tableModel.setChartSeries(TableModel.NET_INCOME_CURVE, netIncomeLineSeries)
    }
}
