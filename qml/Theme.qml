pragma Singleton

import QtQuick
import QtQuick.Controls.Material

QtObject {
    readonly property real verticalMargin: 5
    readonly property real horizontalMargin: 10
    readonly property int minimumColumnWidth: 110
    readonly property int maximumColumnWidth: 120

    readonly property color backgroundColor: Material.background
    readonly property color foregroundColor: Material.foreground
    readonly property color accentColor: Material.accent
}
