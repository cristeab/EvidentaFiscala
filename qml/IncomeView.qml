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
        function show(point, lineSeries) {
            const closestPoint = findClosestPoint(point.x, lineSeries)
            const actualPoint = closestPoint ? closestPoint : point
            // set text
            pointTooltip.text = actualPoint.y.toFixed(2)
            pointTooltip.color = lineSeries.color
            pointTooltip.visible = true
            pointTooltip.x = mapToPosition(actualPoint).x + 10
            pointTooltip.y = mapToPosition(actualPoint).y - 20
            // set marker
            pointMarker.x = mapToPosition(actualPoint).x - (pointMarker.width / 2)
            pointMarker.y = mapToPosition(actualPoint).y - (pointMarker.height / 2)
            pointMarker.color = lineSeries.color
            pointMarker.visible = true
        }
        function hide() {
            pointTooltip.visible = false
            pointMarker.visible = false
        }

        function findClosestPoint(mouseX, lineSeries) {
            let minDist = Number.MAX_VALUE
            let closestPoint = null
            for (let i = 0; i < lineSeries.count; i++) {
                const point = lineSeries.at(i)
                const dist = Math.abs(point.x - mouseX)
                if (dist < minDist) {
                    minDist = dist
                    closestPoint = point
                }
            }
            return closestPoint
        }
    }

    Rectangle {
        id: pointMarker
        z: 1
        width: 10
        height: width
        radius: width / 2
        visible: false
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
                pointTooltip.show(point, grossIncomeLineSeries)
            } else {
                pointTooltip.hide()
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
                pointTooltip.show(point, expenseLineSeries)
            } else {
                pointTooltip.hide()
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
                pointTooltip.show(point, netIncomeLineSeries)
            } else {
                pointTooltip.hide()
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
                pointTooltip.show(point, threshold)
            } else {
                pointTooltip.hide()
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
