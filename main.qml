import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.5

ApplicationWindow {
    visible: true
    width: tableTab.winWidth
    maximumWidth: width
    minimumWidth: width
    height: 600
    title: qsTr("Evidenta Fiscala")

    QtObject {
        id: props
        readonly property real verticalMargin: 5
        readonly property real horizontalMargin: 10
    }

    TabBar {
        id: bar
        anchors {
            top: parent.top
            topMargin: props.verticalMargin
            left: parent.left
            leftMargin: props.horizontalMargin
            right: parent.right
            rightMargin: props.horizontalMargin
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
            topMargin: props.verticalMargin
            left: parent.left
            leftMargin: props.horizontalMargin
            right: parent.right
            rightMargin: props.horizontalMargin
            bottom: parent.bottom
            bottomMargin: props.verticalMargin
        }
        currentIndex: bar.currentIndex
        ContentView {
            id: tableTab
        }
        IncomeView {
            id: chartTab
        }
    }

    Connections {
        target: tableModel
        onError: {
            errMsg.isFatal = fatal
            errMsg.show(msg)
        }
    }
    Dialog {
        id: errMsg
        property bool isFatal: false
        function show(msg) {
            errMsgLabel.text = msg
            visible = true
        }
        onAccepted: {
            visible = false
            if (isFatal) {
                Qt.quit()
            }
        }
        visible: false
        width: parent.width/2
        height: parent.height/2
        x: (parent.width - width)/2
        y: (parent.height - height)/2
        title: qsTr("Eroare")
        modal: true
        standardButtons: Dialog.Ok
        Label {
            id: errMsgLabel
            anchors.fill: parent
            clip: true
            wrapMode: Text.WordWrap
        }
    }

    footer: Label {
        id: footerLabel
        width: parent.width
        text: tableModel.fileName
        horizontalAlignment: Text.AlignRight
    }
}
