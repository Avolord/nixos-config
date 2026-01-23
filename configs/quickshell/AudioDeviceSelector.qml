import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FloatingWindow {
    id: audioDeviceWindow

    visible: false
    implicitWidth: 400
    implicitHeight: 300
    color: ColorService.surface

    property string defaultSink: ""

    Component.onCompleted: {
        refreshDevices()
    }

    onVisibleChanged: {
        if (visible) {
            refreshDevices()
        }
    }

    function refreshDevices() {
        sinkListModel.clear()
        defaultSinkProcess.running = true
    }

    // Get default sink
    Process {
        id: defaultSinkProcess
        command: ["pactl", "get-default-sink"]

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                audioDeviceWindow.defaultSink = data.trim()
                listSinksProcess.running = true
            }
        }
    }

    // List all sinks
    Process {
        id: listSinksProcess
        command: ["pactl", "list", "sinks", "short"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (data.trim() === "") return

                // Format: "ID\tNAME\tDRIVER\tSAMPLE_SPEC\tSTATE"
                const parts = data.trim().split("\t")
                if (parts.length >= 2) {
                    const sinkName = parts[1]
                    // Get friendly name for this sink
                    const friendlyProcess = friendlyNameComponent.createObject(audioDeviceWindow, {
                        sinkName: sinkName
                    })
                    friendlyProcess.running = true
                }
            }
        }
    }

    // Component for getting friendly sink names
    Component {
        id: friendlyNameComponent

        Process {
            property string sinkName: ""
            property string friendlyName: ""

            command: ["pactl", "list", "sinks"]

            stdout: SplitParser {
                splitMarker: ""
                onRead: data => {
                    // Find description for our sink
                    const lines = data.split("\n")
                    let foundSink = false
                    let description = sinkName

                    for (let i = 0; i < lines.length; i++) {
                        const line = lines[i].trim()
                        if (line.includes("Name: " + sinkName)) {
                            foundSink = true
                        }
                        if (foundSink && line.startsWith("Description:")) {
                            description = line.substring("Description:".length).trim()
                            break
                        }
                        if (foundSink && line.startsWith("Name:") && !line.includes(sinkName)) {
                            break
                        }
                    }

                    sinkListModel.append({
                        "name": sinkName,
                        "description": description,
                        "isDefault": sinkName === audioDeviceWindow.defaultSink
                    })
                }
            }

            onExited: destroy()
        }
    }

    // Set default sink process
    Process {
        id: setDefaultSinkProcess
        property string sinkName: ""
        command: ["pactl", "set-default-sink", sinkName]

        onExited: {
            audioDeviceWindow.defaultSink = sinkName
            // Update the list model
            for (let i = 0; i < sinkListModel.count; i++) {
                const item = sinkListModel.get(i)
                sinkListModel.setProperty(i, "isDefault", item.name === sinkName)
            }
        }
    }

    ListModel {
        id: sinkListModel
    }

    // Header
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: ColorService.background

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
                text: "Audio Output"
                font.pixelSize: 18
                font.bold: true
                color: ColorService.foregroundSurface
                Layout.fillWidth: true
            }

            // Refresh button
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 32
                color: refreshMouseArea.containsMouse ? ColorService.primary : ColorService.surfaceVariant
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: "Refresh"
                    color: refreshMouseArea.containsMouse ? ColorService.foregroundPrimary : ColorService.foregroundSurface
                    font.pixelSize: 12
                }

                MouseArea {
                    id: refreshMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: refreshDevices()
                }
            }

            // Close button
            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                color: closeMouseArea.containsMouse ? ColorService.tertiary : ColorService.surfaceVariant
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: "\uf00d"
                    color: ColorService.foregroundSurface
                    font.family: "FiraCode Nerd Font"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: audioDeviceWindow.visible = false
                }
            }
        }
    }

    // Device list
    Rectangle {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        color: ColorService.background
        radius: 8

        ScrollView {
            anchors.fill: parent
            anchors.margins: 5
            clip: true

            ListView {
                id: deviceList
                anchors.fill: parent
                spacing: 4

                model: sinkListModel

                delegate: Rectangle {
                    width: deviceList.width
                    height: 50
                    radius: 6
                    color: deviceMouseArea.containsMouse ? ColorService.surfaceVariant : ColorService.surface
                    border.color: model.isDefault ? ColorService.primary : "transparent"
                    border.width: model.isDefault ? 2 : 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        // Checkmark for default
                        Text {
                            text: model.isDefault ? "\uf00c" : ""
                            color: ColorService.primary
                            font.family: "FiraCode Nerd Font"
                            font.pixelSize: 16
                            Layout.preferredWidth: 20
                        }

                        // Device info
                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: model.description
                                color: ColorService.foregroundSurface
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                text: model.name
                                color: Qt.rgba(
                                    ColorService.foregroundSurface.r,
                                    ColorService.foregroundSurface.g,
                                    ColorService.foregroundSurface.b,
                                    0.6
                                )
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }
                    }

                    MouseArea {
                        id: deviceMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            setDefaultSinkProcess.sinkName = model.name
                            setDefaultSinkProcess.running = true
                        }
                    }
                }
            }
        }
    }

    // Keyboard shortcuts
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            audioDeviceWindow.visible = false
            event.accepted = true
        }
    }
}
