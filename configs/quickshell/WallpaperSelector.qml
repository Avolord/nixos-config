// WallpaperSelector.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

FloatingWindow {
    id: wallpaperWindow

    visible: false
    implicitWidth: 900
    implicitHeight: 600
    color: ColorService.surface

    property string wallpaperDir: Quickshell.env("HOME") + "/nixos/wallpapers"
    property string cacheDir: Quickshell.env("HOME") + "/.cache/quickshell_wallpapers"
    property var wallpapers: []
    property var supportedFormats: [".jpg", ".jpeg", ".png", ".webp", ".bmp"]

    Component.onCompleted: {
        mkdirProcess.running = true
        startupTimer.running = true
    }

    // Delay scan to let mkdir complete
    Timer {
        id: startupTimer
        interval: 100
        running: false
        onTriggered: scanProcess.running = true
    }

    // Create cache directory
    Process {
        id: mkdirProcess
        command: ["mkdir", "-p", cacheDir]
    }

    // Scan for wallpapers
    Process {
        id: scanProcess
        command: ["find", wallpaperDir, "-maxdepth", "1", "-type", "f"]

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                if (data.trim() === "") return

                const ext = data.substring(data.lastIndexOf('.')).toLowerCase()
                if (supportedFormats.includes(ext)) {
                    wallpapers.push(data)
                    wallpaperListModel.append({
                        "path": data,
                        "name": data.substring(data.lastIndexOf('/') + 1)
                    })
                }
            }
        }
    }

    function getThumbnailPath(wallpaperPath) {
        const name = wallpaperPath.substring(wallpaperPath.lastIndexOf('/') + 1)
        return cacheDir + "/" + name + ".thumb.jpg"
    }

    function applyWallpaper(wallpaperPath) {
        console.log("Applying wallpaper:", wallpaperPath)
        matugenProcess.wallpaperPath = wallpaperPath
        matugenProcess.running = true
        wallpaperWindow.visible = false
    }

    function rescanWallpapers() {
        wallpapers = []
        wallpaperListModel.clear()
        scanProcess.running = true
    }

    function applyRandomWallpaper() {
        if (wallpapers.length > 0) {
            const randomIndex = Math.floor(Math.random() * wallpapers.length)
            applyWallpaper(wallpapers[randomIndex])
        }
    }

    // Timer to reload colors after matugen finishes
    Timer {
        id: colorReloadTimer
        interval: 200
        running: false
        onTriggered: ColorService.loadColors()
    }

    // Process for matugen
    Process {
        id: matugenProcess
        property string wallpaperPath: ""
        command: ["matugen", "image", wallpaperPath]

        onExited: code => {
            if (code === 0) {
                hyprpaperProcess.wallpaperPath = wallpaperPath
                hyprpaperProcess.running = true
                // Reload colors after a short delay to ensure file is written
                colorReloadTimer.running = true
            }
        }
    }

    // Process for hyprpaper
    Process {
        id: hyprpaperProcess
        property string wallpaperPath: ""
        command: ["hyprctl", "hyprpaper", "wallpaper", "," + wallpaperPath]
    }

    ListModel {
        id: wallpaperListModel
    }

    // Header
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: ColorService.background

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
                text: "Wallpaper Selector"
                font.pixelSize: 20
                font.bold: true
                color: ColorService.foregroundSurface
                Layout.fillWidth: true
            }

            // Random button
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 40
                color: randomMouseArea.containsMouse ? ColorService.primary : ColorService.surfaceVariant
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: "Random"
                    color: randomMouseArea.containsMouse ? ColorService.foregroundPrimary : ColorService.foregroundSurface
                    font.pixelSize: 14
                }

                MouseArea {
                    id: randomMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: applyRandomWallpaper()
                }
            }

            // Rescan button
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 40
                color: rescanMouseArea.containsMouse ? ColorService.primary : ColorService.surfaceVariant
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: "Rescan"
                    color: rescanMouseArea.containsMouse ? ColorService.foregroundPrimary : ColorService.foregroundSurface
                    font.pixelSize: 14
                }

                MouseArea {
                    id: rescanMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: rescanWallpapers()
                }
            }

            // Close button
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                color: closeMouseArea.containsMouse ? ColorService.tertiary : ColorService.surfaceVariant
                radius: 5

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: ColorService.foregroundSurface
                    font.pixelSize: 18
                    font.bold: true
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: wallpaperWindow.visible = false
                }
            }
        }
    }

    // Wallpaper Grid
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
            anchors.margins: 10
            clip: true

            GridView {
                id: wallpaperGrid
                anchors.fill: parent
                cellWidth: 220
                cellHeight: 160

                model: wallpaperListModel

                delegate: Item {
                    width: 220
                    height: 160

                    Rectangle {
                        id: wallpaperCard
                        anchors.fill: parent
                        anchors.margins: 10
                        color: cardMouseArea.containsMouse ? ColorService.surfaceVariant : ColorService.surface
                        radius: 8
                        border.color: cardMouseArea.containsMouse ? ColorService.primary : ColorService.surfaceVariant
                        border.width: 2

                        Image {
                            id: thumbnail
                            anchors.fill: parent
                            anchors.margins: 5
                            fillMode: Image.PreserveAspectCrop
                            source: "file://" + model.path

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 30
                                color: Qt.rgba(
                                    ColorService.background.r,
                                    ColorService.background.g,
                                    ColorService.background.b,
                                    0.8
                                )

                                Text {
                                    anchors.centerIn: parent
                                    text: model.name
                                    color: ColorService.foregroundSurface
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    width: parent.width - 10
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        MouseArea {
                            id: cardMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: applyWallpaper(model.path)
                        }
                    }
                }
            }
        }
    }

    // Keyboard shortcuts
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            wallpaperWindow.visible = false
            event.accepted = true
        }
    }
}
