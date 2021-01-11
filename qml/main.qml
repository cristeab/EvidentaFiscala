import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.2

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
            width: 320
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
            }
            MenuItem {
                text: qsTr("Generare Registru de Evidenta Fiscala")
                onTriggered: tableModel.generateRegistry()
            }
            MenuItem {
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
        Dialog {
            property bool isFatal: false
            function show(msg) {
                errMsgLabel.text = msg
                visible = true
            }
            onAccepted: visible = false
            visible: false
            width: winApp.width/2
            height: winApp.height/3
            title: qsTr("Eroare")
            standardButtons: Dialog.Ok
            Label {
                id: errMsgLabel
                anchors {
                    fill: parent
                    margins: Theme.horizontalMargin
                }
                verticalAlignment: Text.AlignVCenter
                clip: true
                wrapMode: Text.WordWrap
            }
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
            folder: shortcuts.home
            selectExisting: true
            selectFolder: false
            selectMultiple: false
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
