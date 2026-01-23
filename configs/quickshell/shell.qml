import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    ReloadPopup {}

    WallpaperSelector {
        id: wallpaperSelector
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

            // Wallpaper button on the left
            Rectangle {
                id: wallpaperButton
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 10
                width: 28
                height: 22
                radius: 4
                color: wallpaperMouseArea.containsMouse ? Qt.rgba(
                    ColorService.primary.r,
                    ColorService.primary.g,
                    ColorService.primary.b,
                    0.3
                ) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "\uf03e" // fa-image
                    color: ColorService.foregroundSurface
                    font.family: "FiraCode Nerd Font"
                    font.pixelSize: 14
                }

                MouseArea {
                    id: wallpaperMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: wallpaperSelector.visible = !wallpaperSelector.visible
                }
            }

            // Workspace switcher
            WorkspaceWidget {
                anchors.left: wallpaperButton.right
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
