import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs

ApplicationWindow {
    id: winApp
    visible: true
    width: 800
    minimumWidth: 800
    height: 600
    title: qsTr("Evidenta Fiscala") + " v" + settings.swVersion

    ToolBar {
        id: toolBar
        spacing: Theme.horizontalMargin
        width: parent.width
        background: Item {}
        Row {
            anchors.fill: parent
            ToolButton {
                icon.source: "qrc:/img/FileCsv.svg"
                onClicked: {
                    fileDialogLoader.active = true
                    fileDialogLoader.item.visible = true
                }
                ToolTip {
                    text: qsTr("Deschide...")
                    visible: parent.hovered
                }
            }
            ToolButton {
                icon.source: "qrc:/img/Settings.svg"
                onClicked: {
                    settingsLoader.active = true
                    settingsLoader.item.visible = true
                }
                ToolTip {
                    text: qsTr("Configurare...")
                    visible: parent.hovered
                }
            }
            ToolButton {
                icon.source: "qrc:/img/FileExport.svg"
                onClicked: tableModel.generateRegistry()
                enabled: 0 < tableTab.count
                ToolTip {
                    text: qsTr("Generare Registru de Evidenta Fiscala")
                    visible: parent.hovered
                }
            }
        }
    }

    TabBar {
        id: bar
        anchors {
            top: toolBar.bottom
            topMargin: Theme.verticalMargin
            left: parent.left
            leftMargin: Theme.horizontalMargin
            right: parent.right
            rightMargin: Theme.horizontalMargin
        }
        TabButton {
            text: qsTr("Tabel")
        }
        TabButton {
            text: qsTr("Grafic")
        }
    }
    SwipeView {
        Keys.onEscapePressed: {
            tableTab.calendarVisible = false
        }

        focus: true
        interactive: false
        clip: true
        anchors {
            top: bar.bottom
            topMargin: Theme.verticalMargin
            left: parent.left
            leftMargin: Theme.horizontalMargin
            right: parent.right
            rightMargin: Theme.horizontalMargin
            bottom: parent.bottom
            bottomMargin: Theme.verticalMargin
        }
        currentIndex: bar.currentIndex
        ContentView {
            id: tableTab
        }
        Loader {
            property bool useBars: true
            sourceComponent: tableModel.settings.useBars ? chartWithBarsTab : chartWithLinesTab
            Component {
                id: chartWithLinesTab
                IncomeViewWithLines {
                }
            }
            Component {
                id: chartWithBarsTab
                IncomeViewWithBars {
                }
            }
        }
    }

    footer: Label {
        id: footerLabel
        width: parent.width
        text: settings.ledgerFilePath
        horizontalAlignment: Text.AlignRight
        bottomPadding: 5
        MouseArea {
            id: control
            property var prevCursorShape: null
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                control.prevCursorShape = control.cursorShape
                control.cursorShape = Qt.PointingHandCursor
            }
            onExited: {
                if (null !== control.prevCursorShape) {
                    control.cursorShape = control.prevCursorShape
                    control.prevCursorShape = null
                }
            }
            onClicked: Qt.openUrlExternally("file://"+ footerLabel.text)
        }
    }

    Connections {
        target: tableModel
        function onError(msg, fatal) {
            errMsg.show(msg, fatal)
        }
    }
    Component {
        id: errMsgComp
        MessageDialog {
            buttons: MessageDialog.Ok
        }
    }
    Loader {
        id: errMsg
        function show(msg, fatal) {
            errMsg.active = true
            errMsg.item.title = fatal ? qsTr("Eroare") : qsTr("Avertisment")
            errMsg.item.text = msg
            errMsg.item.visible = true
        }
        active: false
        anchors.centerIn: parent
        sourceComponent: errMsgComp
    }

    Component {
        id: fileDialogComp
        FileDialog {
            title: qsTr("Selectati Fisier")
            currentFolder: settings.workingFolderPath
            fileMode: FileDialog.OpenFile
            nameFilters: [ "CSV files (*.csv)", "All files (*)" ]
            onAccepted: tableModel.openLedger(selectedFile)
            Component.onCompleted: visible = true
        }
    }
    Loader {
        id: fileDialogLoader
        active: false
        anchors.centerIn: parent
        sourceComponent: fileDialogComp
    }

    Component {
        id: folderDialogComp
        FolderDialog {
            title: qsTr("Selectati Directorul de Lucru")
            currentFolder: settings.workingFolderPath
            onAccepted: settings.workingFolderPath = selectedFolder.toString().replace("file://", "")
            Component.onCompleted: visible = true
        }
    }
    Loader {
        id: folderDialogLoader
        active: false
        anchors.centerIn: parent
        sourceComponent: folderDialogComp
    }

    Loader {
        id: settingsLoader
        active: false
        source: "qrc:/qml/Settings.qml"
    }
}
