// ModeSelector.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: modePopup

    visible: false

    anchors {
        top: true
        left: true
    }

    margins {
        top: 10
        left: 10
    }

    width: content.width
    height: content.height

    color: "transparent"

    property string currentMode: "dark"
    property string currentWallpaper: ""
    property string currentColor: ""

    // Mode configurations
    readonly property var modeConfigs: ({
        "light": {
            wallpaper: Quickshell.env("HOME") + "/nixos/wallpapers/house.png",
            color: "#ffb366"  // light orange
        },
        "dark": {
            wallpaper: Quickshell.env("HOME") + "/nixos/wallpapers/flower.png",
            color: "#ffffff"
        }
    })

    function applyMode(mode) {
        console.log("Applying mode:", mode)
        currentMode = mode
        currentWallpaper = modeConfigs[mode].wallpaper
        currentColor = modeConfigs[mode].color
        matugenProcess.mode = mode
        matugenProcess.color = currentColor
        matugenProcess.running = true
        modePopup.visible = false
    }

    // Timer to reload colors after matugen finishes
    Timer {
        id: colorReloadTimer
        interval: 200
        running: false
        onTriggered: ColorService.loadColors()
    }

    // Process for matugen - uses color instead of image
    Process {
        id: matugenProcess
        property string mode: "dark"
        property string color: "#ffffff"
        command: ["matugen", "color", "hex", color, "--mode", mode]

        onExited: code => {
            if (code === 0) {
                hyprpaperProcess.running = true
                colorReloadTimer.running = true
            }
        }
    }

    // Process for hyprpaper - still sets the wallpaper
    Process {
        id: hyprpaperProcess
        command: ["hyprctl", "hyprpaper", "wallpaper", "," + currentWallpaper]

        onExited: code => {
            if (code === 0) {
                // Save current wallpaper as symlink for hyprpaper.conf
                saveWallpaperProcess.running = true
            }
        }
    }

    // Process to save current wallpaper as symlink
    Process {
        id: saveWallpaperProcess
        command: ["ln", "-sf", currentWallpaper, Quickshell.env("HOME") + "/.config/hypr/current_wallpaper"]
    }

    Rectangle {
        id: content
        radius: 8
        color: Qt.rgba(
            ColorService.surface.r,
            ColorService.surface.g,
            ColorService.surface.b,
            0.95
        )
        border.color: ColorService.primary
        border.width: 1

        implicitWidth: layout.implicitWidth + 30
        implicitHeight: layout.implicitHeight + 30

        // Close when clicking outside
        MouseArea {
            anchors.fill: parent
            onClicked: {} // Consume clicks inside popup
        }

        ColumnLayout {
            id: layout
            anchors.centerIn: parent
            spacing: 12

            // Header
            Text {
                text: "Mode"
                font.pixelSize: 14
                font.bold: true
                color: ColorService.foregroundSurface
                Layout.alignment: Qt.AlignHCenter
            }

            // Mode buttons row
            RowLayout {
                spacing: 10

                // Light Mode Button
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 70
                    color: lightMouseArea.containsMouse ? ColorService.primary : ColorService.surfaceVariant
                    radius: 8
                    border.color: currentMode === "light" ? ColorService.primary : "transparent"
                    border.width: 2

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "\uf185" // sun icon
                            font.family: "FiraCode Nerd Font"
                            font.pixelSize: 24
                            color: lightMouseArea.containsMouse ? ColorService.foregroundPrimary : ColorService.foregroundSurface
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Light"
                            font.pixelSize: 11
                            color: lightMouseArea.containsMouse ? ColorService.foregroundPrimary : ColorService.foregroundSurface
                        }
                    }

                    MouseArea {
                        id: lightMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: applyMode("light")
                    }
                }

                // Dark Mode Button
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 70
                    color: darkMouseArea.containsMouse ? ColorService.primary : ColorService.surfaceVariant
                    radius: 8
                    border.color: currentMode === "dark" ? ColorService.primary : "transparent"
                    border.width: 2

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "\uf186" // moon icon
                            font.family: "FiraCode Nerd Font"
                            font.pixelSize: 24
                            color: darkMouseArea.containsMouse ? ColorService.foregroundPrimary : ColorService.foregroundSurface
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Dark"
                            font.pixelSize: 11
                            color: darkMouseArea.containsMouse ? ColorService.foregroundPrimary : ColorService.foregroundSurface
                        }
                    }

                    MouseArea {
                        id: darkMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: applyMode("dark")
                    }
                }
            }
        }
    }
}
