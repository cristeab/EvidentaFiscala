import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs
import Qt.labs.platform 1.1 as Platf

ApplicationWindow {
    id: winApp
    visible: true
    width: tableTab.winWidth
    height: 600
    title: qsTr("Evidenta Fiscala")

    menuBar: MenuBar {
        Menu {
            title: qsTr("Fisier")
            Action {
                text: qsTr("Deschide...")
                onTriggered: {
                    fileDialogLoader.active = true
                    fileDialogLoader.item.visible = true
                }
            }
            Action {
                text: qsTr("Configurare...")
            }
            Action {
                text: qsTr("Generare Registru de Evidenta Fiscala")
                onTriggered: tableModel.generateRegistry()
            }
            Action {
                text: qsTr("Inchide")
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
            errMsgLoader.active = true
            errMsgLoader.item.visible = true
            errMsgLoader.item.isFatal = fatal
            errMsgLoader.item.show(msg)
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
        function show(msg) {
            errMsg.active = true
            errMsg.item.title = qsTr("Eroare")
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
            title: "Selectati fisier"
            currentFolder: Platf.StandardPaths.standardLocations(Platf.StandardPaths.HomeLocation)[0]
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
}
