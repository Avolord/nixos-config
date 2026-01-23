import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: workspaceWidget

    width: 88
    height: 22
    radius: 4
    color: "transparent"

    property int activeWorkspace: 1
    property int workspaceCount: 4
    property int hoveredWorkspace: -1

    // Process to get current workspace
    Process {
        id: getWorkspaceProcess
        command: ["hyprctl", "activeworkspace", "-j"]

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    const json = JSON.parse(data.trim())
                    if (json.id) {
                        workspaceWidget.activeWorkspace = json.id
                    }
                } catch (e) {
                    // Ignore parse errors
                }
            }
        }
    }

    // Process to switch workspace
    Process {
        id: switchWorkspaceProcess
        property int targetWorkspace: 1
        command: ["hyprctl", "dispatch", "workspace", targetWorkspace.toString()]
    }

    // Poll for workspace changes
    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: getWorkspaceProcess.running = true
    }

    // Pill background
    Rectangle {
        id: pillBackground
        anchors.centerIn: parent
        width: 84
        height: 18
        radius: 9
        color: ColorService.surfaceVariant

        Row {
            anchors.fill: parent
            anchors.margins: 2

            Repeater {
                model: workspaceWidget.workspaceCount

                Item {
                    width: (pillBackground.width - 4) / workspaceWidget.workspaceCount
                    height: parent.height

                    // Divider line (except for first item)
                    Rectangle {
                        visible: index > 0
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: parent.height - 4
                        color: ColorService.surface
                    }

                    // Active/hover indicator
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 4
                        height: parent.height - 2
                        radius: 6
                        color: {
                            const wsNum = index + 1
                            if (workspaceWidget.activeWorkspace === wsNum) {
                                return ColorService.primary
                            } else if (workspaceWidget.hoveredWorkspace === wsNum) {
                                return Qt.rgba(
                                    ColorService.primary.r,
                                    ColorService.primary.g,
                                    ColorService.primary.b,
                                    0.3
                                )
                            }
                            return "transparent"
                        }

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }

                    // Workspace number (optional, for accessibility)
                    Text {
                        anchors.centerIn: parent
                        text: (index + 1).toString()
                        color: workspaceWidget.activeWorkspace === (index + 1)
                            ? ColorService.foregroundPrimary
                            : ColorService.foregroundSurface
                        font.pixelSize: 10
                        font.family: "monospace"
                        font.bold: workspaceWidget.activeWorkspace === (index + 1)
                        opacity: 0.8
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: workspaceWidget.hoveredWorkspace = index + 1
                        onExited: workspaceWidget.hoveredWorkspace = -1

                        onClicked: {
                            switchWorkspaceProcess.targetWorkspace = index + 1
                            switchWorkspaceProcess.running = true
                            // Immediately update visual feedback
                            workspaceWidget.activeWorkspace = index + 1
                        }
                    }
                }
            }
        }
    }
}
