import QtQuick 2.12
import QtCharts 2.3
import TableModel 1.0

ChartView {
    anchors.fill: parent
    ValueAxis {
        id: axisX
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
    theme: ChartView.ChartThemeDark
    Component.onCompleted: {
        tableModel.setChartSeries(TableModel.GROSS_INCOME_COURVE, grossIncomeLineSeries)
        tableModel.setChartSeries(TableModel.EXPENSE_COURVE, expenseLineSeries)
        tableModel.setChartSeries(TableModel.NET_INCOME_COURVE, netIncomeLineSeries)
    }
}
