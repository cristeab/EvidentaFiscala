import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs

ApplicationWindow {
    id: winApp
    visible: true
    width: tableTab.winWidth
    maximumWidth: width
    minimumWidth: width
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
            id: errMsg
            property bool isFatal: false
            function show(msg) {
                errMsg.text = qsTr("Eroare: ") + msg
                errMsg.visible = true
            }
            onAccepted: visible = false
            visible: false
            buttons: MessageDialog.Ok
        }
    }
    Loader {
        id: errMsgLoader
        active: false
        anchors.centerIn: parent
        sourceComponent: errMsgComp
    }

    Component {
        id: fileDialogComp
        FileDialog {
            title: "Selectati fisier"
            currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
            fileMode: FileDialog.OpenFile
            nameFilters: [ "CSV files (*.csv)", "All files (*)" ]
            onAccepted: tableModel.openLedger(fileUrl)
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
