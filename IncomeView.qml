import QtQuick 2.12
import QtCharts 2.3
import TableModel 1.0

ChartView {
    antialiasing: true
    theme: ChartView.ChartThemeDark
    ValueAxis {
        id: axisX
        tickInterval: 1
        tickType: ValueAxis.TicksFixed
        min: tableModel.xAxisMin
        max: tableModel.xAxisMax
    }
    LineSeries {
        id: grossIncomeLineSeries
        name: "Gross Income"
        color: "#16c5f0"
        axisX: axisX
    }
    LineSeries {
        id: expenseLineSeries
        name: "Expenses"
        color: "#b416e7"
        axisX: axisX
    }
    LineSeries {
        id: netIncomeLineSeries
        name: "Net Income"
        color: "#21f15e"
        axisX: axisX
    }
    Component.onCompleted: {
        tableModel.setChartSeries(TableModel.GROSS_INCOME_CURVE, grossIncomeLineSeries)
        tableModel.setChartSeries(TableModel.EXPENSE_CURVE, expenseLineSeries)
        tableModel.setChartSeries(TableModel.NET_INCOME_CURVE, netIncomeLineSeries)
    }
}
