import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    ReloadPopup {}

    ModeSelector {
        id: modeSelector
    }

    AudioDeviceSelector {
        id: audioDeviceSelector
    }

    PanelWindow {
        id: root

        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 34

        // Transparent background for blur to show through
        color: "transparent"

        // Content layer
        Rectangle {
            id: panelBackground
            anchors.fill: parent

            // Semi-transparent frosted glass effect
            color: Qt.rgba(
                ColorService.surface.r,
                ColorService.surface.g,
                ColorService.surface.b,
                0.7
            )

            // Bottom border
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: Qt.rgba(
                    ColorService.primary.r,
                    ColorService.primary.g,
                    ColorService.primary.b,
                    0.5
                )
            }

            // Mode selector button on the left
            Rectangle {
                id: modeButton
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                width: 28
                height: 22
                radius: 4
                color: modeMouseArea.containsMouse ? Qt.rgba(
                    ColorService.primary.r,
                    ColorService.primary.g,
                    ColorService.primary.b,
                    0.3
                ) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "\uf042" // fa-adjust (half-filled circle for light/dark)
                    color: ColorService.foregroundSurface
                    font.family: "FiraCode Nerd Font"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: modeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: modeSelector.visible = !modeSelector.visible
                }
            }

            // Workspace switcher
            WorkspaceWidget {
                anchors.left: modeButton.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
            }

            // Right side widgets
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 10
                spacing: 8

                AudioWidget {
                    audioSelector: audioDeviceSelector
                }
                CpuWidget {}
                ClockWidget {}
            }
        }
    }
}
