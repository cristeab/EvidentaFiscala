import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: control

    title: qsTr("About FiscalRecords")
    modal: true
    width: 0.6 * winApp.width
    height: 0.8 * winApp.height
    standardButtons: Dialog.Close

    x: (winApp.width-width)/2
    y: (winApp.height-height)/2

    Component.onCompleted: control.visible = true
    onClosed: {
        control.close()
        aboutDialogLoader.active = false
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 16

            // ── App identity ──────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Image {
                    Layout.alignment: Qt.AlignHCenter
                    source: "qrc:/img/logo.png"   // adjust to your asset
                    width: 64
                    height: 64
                    fillMode: Image.PreserveAspectFit
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: "FiscalRecords"
                    font.pixelSize: 22
                    font.bold: true
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Version %1").arg(settings.swVersion)
                    font.pixelSize: 12
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: qsTr("Lightweight fiscal records management for self-employed professionals and freelancers.")
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: palette.mid; opacity: 0.3 }

            // ── Features ──────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label {
                    text: qsTr("Key Features")
                    font.bold: true
                }

                Repeater {
                    model: [
                        qsTr("Automated receipt numbering and expense tracking"),
                        qsTr("Monthly income/expense charts (line & bar)"),
                        qsTr("ODF Fiscal Register report generation"),
                        qsTr("Multi-currency support with official exchange rates"),
                        qsTr("Local Git backups"),
                        qsTr("Available in Romanian, English and French")
                    ]
                    delegate: Label {
                        Layout.fillWidth: true
                        text: "• " + modelData
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: palette.mid; opacity: 0.3 }

            // ── Author + repository ───────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label { text: qsTr("Author"); font.bold: true }

                Label {
                    // Replace with your name
                    text: "Bogdan Cristea"
                }

                Label { text: qsTr("Source Code"); font.bold: true }

                Label {
                    text: "<a href='https://github.com/cristeab/EvidentaFiscala'>github.com/cristeab/EvidentaFiscala</a>"
                    onLinkActivated: (link) => Qt.openUrlExternally(link)
                    linkColor: palette.link
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: palette.mid; opacity: 0.3 }

            // ── Claude Tax Assistant teaser ───────────────────────────
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: teaserLayout.implicitHeight + 16
                radius: 6
                // Subtle tinted background to make it stand out
                color: Qt.rgba(palette.highlight.r,
                               palette.highlight.g,
                               palette.highlight.b, 0.08)
                border.color: Qt.rgba(palette.highlight.r,
                                      palette.highlight.g,
                                      palette.highlight.b, 0.3)
                border.width: 1

                ColumnLayout {
                    id: teaserLayout
                    anchors { fill: parent; margins: 8 }
                    spacing: 4

                    RowLayout {
                        spacing: 6
                        Label { text: "🤖"; font.pixelSize: 18 }
                        Label {
                            text: qsTr("Claude Tax Assistant Skill")
                            font.bold: true
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: qsTr("Install the skill in your preferred AI assistant (e.g. Anthropic Claude) to automatically estimate your taxes, spot deductions, and generate a tax preparation summary.")
                    }

                    Label {
                        text: "<a href='https://github.com/cristeab/EvidentaFiscala/wiki/Claude-Skill'>"
                              + qsTr("Learn more") + "</a>"
                        onLinkActivated: (link) => Qt.openUrlExternally(link)
                        linkColor: palette.link
                    }
                }
            }

            // ── License ───────────────────────────────────────────────
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Released under the LGPL License")
                font.pixelSize: 11
            }
        }
    }
}
