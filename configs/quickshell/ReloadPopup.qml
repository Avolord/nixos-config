import QtQuick
import QtQuick.Layouts
import Quickshell

Scope {
    id: root
    property bool failed
    property string errorString

    // Connect to the Quickshell global to listen for the reload signals.
    Connections {
        target: Quickshell

        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup()
            root.failed = false
            popupLoader.loading = true
        }

        function onReloadFailed(error: string) {
            Quickshell.inhibitReloadPopup()
            // Close any existing popup before making a new one.
            popupLoader.active = false

            root.failed = true
            root.errorString = error
            popupLoader.loading = true
        }
    }

    // Keep the popup in a loader because it isn't needed most of the time and will take up
    // memory that could be used for something else.
    LazyLoader {
        id: popupLoader

        PanelWindow {
            id: popup

            anchors {
                top: true
                left: true
            }

            margins {
                top: 44
                left: 10
            }

            width: rect.width
            height: rect.height

            color: "transparent"

            Rectangle {
                id: rect
                radius: 8
                color: Qt.rgba(
                    ColorService.surface.r,
                    ColorService.surface.g,
                    ColorService.surface.b,
                    0.9
                )
                border.color: root.failed ? ColorService.tertiary : ColorService.primary
                border.width: 2

                implicitHeight: layout.implicitHeight + 40
                implicitWidth: Math.max(layout.implicitWidth + 40, 200)

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: popupLoader.active = false
                    hoverEnabled: true
                }

                RowLayout {
                    id: layout
                    anchors {
                        centerIn: parent
                        margins: 15
                    }
                    spacing: 10

                    // Status icon
                    Text {
                        text: root.failed ? "\uf06a" : "\uf00c"
                        color: root.failed ? ColorService.tertiary : ColorService.primary
                        font.family: "FiraCode Nerd Font"
                        font.pixelSize: 18
                    }

                    ColumnLayout {
                        spacing: 4

                        Text {
                            text: root.failed ? "Reload failed" : "Reload complete"
                            color: ColorService.foregroundSurface
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            text: root.errorString
                            color: Qt.rgba(
                                ColorService.foregroundSurface.r,
                                ColorService.foregroundSurface.g,
                                ColorService.foregroundSurface.b,
                                0.7
                            )
                            font.pixelSize: 11
                            visible: root.errorString !== ""
                            Layout.maximumWidth: 300
                            wrapMode: Text.Wrap
                        }
                    }
                }

                // Progress bar at the bottom
                Rectangle {
                    id: barBackground
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 4
                    height: 4
                    radius: 2
                    color: ColorService.surfaceVariant

                    Rectangle {
                        id: bar
                        height: parent.height
                        radius: 2
                        color: root.failed ? ColorService.tertiary : ColorService.primary

                        PropertyAnimation {
                            id: anim
                            target: bar
                            property: "width"
                            from: barBackground.width
                            to: 0
                            duration: root.failed ? 10000 : 1500
                            onFinished: popupLoader.active = false
                            paused: mouseArea.containsMouse
                        }
                    }
                }

                Component.onCompleted: anim.start()
            }
        }
    }
}
