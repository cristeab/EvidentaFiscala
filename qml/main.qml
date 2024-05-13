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
    title: qsTr("Evidenta Fiscala")

    menuBar: MenuBar {
        Menu {
            title: qsTr("Fisier")
            MenuItem {
                text: qsTr("Deschide...")
                onTriggered: {
                    fileDialogLoader.active = true
                    fileDialogLoader.item.visible = true
                }
            }
            MenuItem {
                text: qsTr("Configurare...")
                onTriggered: settingsLoader.active = true
            }
            MenuItem {
                id: genReg
                text: qsTr("Generare Registru de Evidenta Fiscala")
                onTriggered: tableModel.generateRegistry()
                enabled: 0 < tableTab.count
                ToolTip {
                    text: genReg.text
                    visible: genReg.hovered
                }
            }
        }
    }

    TabBar {
        id: bar
        anchors {
            top: parent.top
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
        IncomeView {
            id: chartTab
        }
    }

    footer: Label {
        id: footerLabel
        width: parent.width
        text: tableModel.fileName
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
            currentFolder: settings.csvFolderPath
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
            title: qsTr("Selectati Director")
            currentFolder: settings.csvFolderPath
            onAccepted: settings.csvFolderPath = selectedFolder.toString().replace("file://", "")
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
