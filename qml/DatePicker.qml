import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    color: Theme.backgroundColor
    width: childrenRect.width
    height: childrenRect.height

    onVisibleChanged: {
        if (visible) {
            const currentDate = new Date()
            dayTumbler.currentIndex = currentDate.getDate() - 1
            monthTumbler.currentIndex = currentDate.getMonth()
            yearTumbler.currentIndex = currentDate.getFullYear() - yearTumbler.years[0]
        }
    }

    RowLayout {
        id: datePicker

        Layout.leftMargin: 20

        property alias dayTumbler: dayTumbler
        property alias monthTumbler: monthTumbler
        property alias yearTumbler: yearTumbler

        readonly property var days: [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

        Tumbler {
            id: dayTumbler

            function updateModel() {
                // Populate the model with days of the month. For example: [0, ..., 30]
                var previousIndex = dayTumbler.currentIndex
                var array = []
                var newDays = datePicker.days[monthTumbler.currentIndex]
                for (var i = 1; i <= newDays; ++i)
                    array.push(i)
                dayTumbler.model = array
                dayTumbler.currentIndex = Math.min(newDays - 1, previousIndex)
            }

            Component.onCompleted: updateModel()

            delegate: Label {
                text: modelData
                color: (index === dayTumbler.currentIndex) ? Theme.accentColor : Theme.foregroundColor
            }
        }
        Tumbler {
            id: monthTumbler

            onCurrentIndexChanged: dayTumbler.updateModel()

            model: 12
            delegate: Label {
                text: modelData + 1
                color: (index === monthTumbler.currentIndex) ? Theme.accentColor : Theme.foregroundColor
            }
        }
        Tumbler {
            id: yearTumbler

            // This array is populated with the next three years. For example: [2018, 2019, 2020]
            readonly property var years: (function() {
                var currentYear = new Date().getFullYear()
                return [0, 1, 2].map(function(value) { return value + currentYear; })
            })()

            Layout.alignment: Qt.AlignVCenter
            model: years
            delegate: Label {
                text: modelData
                color: (index === yearTumbler.currentIndex) ? Theme.accentColor : Theme.foregroundColor
            }
        }
    }
}
