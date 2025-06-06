import QtQuick
import QtGraphs
import QtQuick.Controls
import TableModel 1.0

GraphsView {
    antialiasing: true
    theme: GraphsTheme {
        colorScheme: GraphsTheme.ColorScheme.Dark
    }

    axisX: DateTimeAxis {
        id: axisX
        labelFormat: "MMM yyyy"
        min: tableModel.xAxisMin
        max: tableModel.xAxisMax
        subTickCount: tableModel.xAxisTickCount
    }

    axisY: ValueAxis {
        id: axisY
        min: tableModel.yAxisMin
        max: tableModel.yAxisMax
        titleText: "RON"
    }

    ToolTip {
        id: pointTooltip
        visible: false
        function show(position, value, lineSeries) {
            // Find closest data point index
            let minDist = Infinity;
            let closestIndex = -1;

            for (let i = 0; i < lineSeries.count; i++) {
                const point = lineSeries.at(i);
                const dx = point.x - value.x;
                const dy = point.y - value.y;
                const dist = Math.sqrt(dx*dx + dy*dy);

                if (dist < minDist) {
                    minDist = dist;
                    closestIndex = i;
                }
            }
            if (closestIndex !== -1) {
                // set text
                const closestPoint = lineSeries.at(closestIndex);
                pointTooltip.text = closestPoint.y.toFixed(2)
                pointTooltip.x = position.x + 1
                pointTooltip.y = position.y + 1
                pointTooltip.visible = true
                // set marker
                markerSeries.clear()
                markerSeries.append(closestPoint.x, closestPoint.y)
                markerSeries.color = lineSeries.color
            }
        }
        function hide() {
            pointTooltip.visible = false
            markerSeries.clear()
        }
    }

    // Marker series (styled as a red circle)
    ScatterSeries {
        id: markerSeries
        pointDelegate: Rectangle {
            width: 12
            height: width
            radius: width / 2
            color: markerSeries.color
        }
    }

    LineSeries {
        id: grossIncomeLineSeries
        name: qsTr("Venit Brut")
        color: "#16c5f0"
        width: 2
        hoverable: true
        onHover: (name, position, value) => {
            pointTooltip.show(position, value, grossIncomeLineSeries)
        }
        onHoverExit: pointTooltip.hide()
    }
    LineSeries {
        id: expenseLineSeries
        name: qsTr("Cheltuieli")
        color: "#b416e7"
        width: 2
        hoverable: true
        onHover: (name, position, value) => {
            pointTooltip.show(position, value, expenseLineSeries)
        }
        onHoverExit: pointTooltip.hide()
    }
    LineSeries {
        id: netIncomeLineSeries
        name: qsTr("Venit Net")
        color: "#21f15e"
        width: 2
        hoverable: true
        onHover: (name, position, value) => {
            pointTooltip.show(position, value, netIncomeLineSeries)
        }
        onHoverExit: pointTooltip.hide()
    }
    LineSeries {
        id: threshold
        color: "lightgray"
        width: 1
        hoverable: true
        onHover: (name, position, value) => {
            pointTooltip.show(position, value, threshold)
        }
        onHoverExit: pointTooltip.hide()
    }
    Component.onCompleted: {
        tableModel.setChartSeries(TableModel.GROSS_INCOME_CURVE, grossIncomeLineSeries)
        tableModel.setChartSeries(TableModel.EXPENSE_CURVE, expenseLineSeries)
        tableModel.setChartSeries(TableModel.NET_INCOME_CURVE, netIncomeLineSeries)
        tableModel.setChartSeries(TableModel.THRESHOLD_CURVE, threshold)
    }
}
