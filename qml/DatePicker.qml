import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: control

    signal clicked(date date)

    onVisibleChanged: {
        if (visible) {
            grid.calendarDate = new Date()
        }
    }

    radius: 5
    width: calendarGrid.width + 2 * Theme.horizontalMargin
    height: calendarGrid.height + monthYearToolbar.height + 3 * Theme.verticalMargin
    color: Theme.backgroundColor
    border.color: "grey"

    ToolBar {
        id: monthYearToolbar
        anchors {
            top: parent.top
            topMargin: Theme.verticalMargin
            left: parent.left
            leftMargin: Theme.horizontalMargin
        }
        width: calendarGrid.width
        background: Item{}

        RowLayout {
            width: parent.width
            ToolButton {
                text: qsTr("<")
                onClicked: stack.pop()
                padding: 0
                Layout.alignment: Qt.AlignLeft
            }
            Label {
                text: grid.calendarDate.toLocaleString(grid.locale, 'MMMM yyyy')
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            ToolButton {
                text: qsTr(">")
                onClicked: stack.pop()
                padding: 0
                Layout.alignment: Qt.AlignRight
            }
        }
    }

    GridLayout {
        id: calendarGrid

        anchors {
            top: monthYearToolbar.bottom
            left: parent.left
            leftMargin: Theme.horizontalMargin
        }

        columns: 2

        DayOfWeekRow {
            id: dowRow
            locale: grid.locale

            Layout.column: 1
            Layout.fillWidth: true

            delegate: Text {
                text: shortName
                font: dowRow.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.foregroundColor

                required property string shortName
            }
        }

        WeekNumberColumn {
            id: wnCol
            month: grid.month
            year: grid.year
            locale: grid.locale

            Layout.fillHeight: true

            delegate: Text {
                text: weekNumber
                font: wnCol.font
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.foregroundColor

                required property int weekNumber
            }
        }

        MonthGrid {
            id: grid

            property date calendarDate: new Date()

            month: calendarDate.getUTCMonth()
            year: calendarDate.getUTCFullYear()
            locale: Qt.locale("Ro-ro")

            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: Text {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: model.month === grid.month ? 1 : 0
                text: model.day
                font: grid.font
                color: Theme.foregroundColor

                required property var model
            }

            onClicked: (date) => {
                           control.clicked(date)
                       }
        }
    }
}
