import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

GridLayout {
    id: control

    signal clicked(date date)

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
        month: Calendar.December
        year: 2015
        locale: Qt.locale("en_US")

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
