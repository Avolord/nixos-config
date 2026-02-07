import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import "." as Local

ShellRoot {
    PanelWindow {
        id: bar

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: 8
            left: 12
            right: 12
        }

        implicitHeight: 40

        // Transparent window background
        color: "transparent"

        // Wayland layering
        WlrLayershell.namespace: "quickshell"
        WlrLayershell.layer: WlrLayer.Top

        // Main bar container
        Rectangle {
            id: barContainer
            anchors.fill: parent
            anchors.margins: 2

            color: Local.Colors.surface_container_lowest
            radius: 4

            // Inner glow border effect
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: parent.radius
                border.width: 1
                border.color: Local.Colors.primary

                // Outer glow layer
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -1
                    color: "transparent"
                    radius: parent.radius + 1
                    border.width: 1
                    border.color: Qt.rgba(
                        Local.Colors.primary.r,
                        Local.Colors.primary.g,
                        Local.Colors.primary.b,
                        0.3
                    )
                }
            }

            // Corner accents - top left
            Rectangle {
                width: 12
                height: 2
                color: Local.Colors.primary
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: -1
                anchors.topMargin: -1
            }
            Rectangle {
                width: 2
                height: 12
                color: Local.Colors.primary
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: -1
                anchors.topMargin: -1
            }

            // Corner accents - top right
            Rectangle {
                width: 12
                height: 2
                color: Local.Colors.primary
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: -1
                anchors.topMargin: -1
            }
            Rectangle {
                width: 2
                height: 12
                color: Local.Colors.primary
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: -1
                anchors.topMargin: -1
            }

            // Corner accents - bottom left
            Rectangle {
                width: 12
                height: 2
                color: Local.Colors.primary
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.leftMargin: -1
                anchors.bottomMargin: -1
            }
            Rectangle {
                width: 2
                height: 12
                color: Local.Colors.primary
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.leftMargin: -1
                anchors.bottomMargin: -1
            }

            // Corner accents - bottom right
            Rectangle {
                width: 12
                height: 2
                color: Local.Colors.primary
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: -1
                anchors.bottomMargin: -1
            }
            Rectangle {
                width: 2
                height: 12
                color: Local.Colors.primary
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: -1
                anchors.bottomMargin: -1
            }
        }
    }
}
