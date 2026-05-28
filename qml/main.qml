import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs

ApplicationWindow {
    id: winApp

    readonly property real tabScale: 0.6

    visible: true
    width: 800
    minimumWidth: 800
    height: 600
    title: qsTr("Fiscal Records") + " v" + settings.swVersion

    ToolBar {
        id: toolBar
        spacing: Theme.horizontalMargin
        width: parent.width
        height: newFileBtn.height
        background: Item {}
        Row {
            anchors {
                top: parent.top
                left: parent.left
                right: newFileBtn.left
            }
            ToolButton {
                icon.source: "qrc:/img/FileCsv.svg"
                onClicked: {
                    fileDialogLoader.active = true
                    fileDialogLoader.item.visible = true
                }
                ToolTip {
                    text: qsTr("Open...")
                    visible: parent.hovered
                }
            }
            ToolButton {
                icon.source: "qrc:/img/FileExport.svg"
                onClicked: tableModel.generateRegistry()
                enabled: 0 < tableTab.count
                ToolTip {
                    text: qsTr("Generate Fiscal Records Register")
                    visible: parent.hovered
                }
            }
            ToolButton {
                icon.source: "qrc:/img/Settings.svg"
                onClicked: {
                    settingsLoader.active = true
                }
                ToolTip {
                    text: qsTr("Settings...")
                    visible: parent.hovered
                }
            }
        } // Row
        ToolButton {
            id: newFileBtn
            anchors {
                top: parent.top
                right: parent.right
            }
            icon.source: "qrc:/img/NewFile.svg"
            onClicked: {
                const filePath = controller.createFileName()
                if ("" !== filePath) {
                    dialogLoader.show(qsTr("Question"),
                                      qsTr("Create new ledger ") + filePath + " ?",
                                      filePath,
                                      (arg) => {
                                        controller.openLedger(controller.fromLocalFile(arg))
                                      },
                                      null)
                }
            }

            ToolTip {
                text: qsTr("New CSV File...")
                visible: parent.hovered
            }
        }
    }

    TabBar {
        id: bar
        anchors {
            top: toolBar.bottom
            topMargin: -Theme.verticalMargin
            left: parent.left
            leftMargin: Theme.horizontalMargin
            right: parent.right
            rightMargin: Theme.horizontalMargin
        }
        TabButton {
            text: qsTr("Table")
            Component.onCompleted: implicitHeight = implicitHeight * winApp.tabScale
        }
        TabButton {
            text: qsTr("Chart")
            Component.onCompleted: implicitHeight = implicitHeight * winApp.tabScale
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
            sourceComponent: settings.useBars ? chartWithBarsTab : chartWithLinesTab
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
        rightPadding: 5
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
        ToolTip {
            text: qsTr("Click to Open in Default Editor")
            visible: control.containsMouse
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
            errMsg.item.text = fatal ? qsTr("Error") : qsTr("Warning")
            errMsg.item.informativeText = msg
            errMsg.item.visible = true
        }
        active: false
        anchors.centerIn: parent
        sourceComponent: errMsgComp
    }

    Component {
        id: dialogComp

        MessageDialog {
            id: msgDialog

            property var arg: null
            property var callbackAccept: null
            property var callbackReject: null

            buttons: MessageDialog.Ok | MessageDialog.Cancel
            onAccepted: {
                if (msgDialog.callbackAccept) {
                    msgDialog.callbackAccept(msgDialog.arg)
                }
            }
            onRejected: {
                if (msgDialog.callbackReject) {
                    msgDialog.callbackReject(msgDialog.arg)
                }
            }
        }
    }
    Loader {
        id: dialogLoader

        function show(title, text, arg, callbackAccept, callbackReject) {
            dialogLoader.active = true

            dialogLoader.item.text = title
            dialogLoader.item.informativeText = text
            dialogLoader.item.arg = arg
            dialogLoader.item.callbackAccept = callbackAccept
            dialogLoader.item.callbackReject = callbackReject

            dialogLoader.item.visible = true
        }

        active: false
        anchors.centerIn: parent
        sourceComponent: dialogComp
    }

    Component {
        id: fileDialogComp
        FileDialog {
            title: qsTr("Select File")
            currentFolder: controller.fromLocalFile(settings.workingFolderPath)
            fileMode: FileDialog.OpenFile
            nameFilters: [ "CSV files (*.csv)", "All files (*)" ]
            onAccepted: controller.openLedger(selectedFile)
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
            property var callback

            Component.onCompleted: visible = true
            onAccepted: {
                if (callback) {
                    callback(controller.toLocalFile(selectedFolder.toString()))
                }
            }
        }
    }
    Loader {
        id: folderDialogLoader

        function show(title, currentFolder, callback) {
            folderDialogLoader.active = true

            folderDialogLoader.item.title = title
            folderDialogLoader.item.currentFolder = controller.fromLocalFile(currentFolder)
            folderDialogLoader.item.callback = callback

            folderDialogLoader.item.visible = true
        }

        active: false
        anchors.centerIn: parent
        sourceComponent: folderDialogComp
    }

    Loader {
        id: settingsLoader
        active: false
        source: "qrc:/qml/Settings.qml"
        asynchronous: true
    }

    Loader {
        id: contextMenuLoader

        function open(index) {
            contextMenuLoader.active = true
            contextMenuLoader.item.currentRow = index
            contextMenuLoader.item.popup()
        }
        active: false
        source: "qrc:/qml/ContextMenu.qml"
    }
}
