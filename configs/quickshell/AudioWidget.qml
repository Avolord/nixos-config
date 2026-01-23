import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: audioWidget

    width: audioRow.width + 16
    height: 22
    radius: 4
    color: mouseArea.containsMouse ? Qt.rgba(
        ColorService.primary.r,
        ColorService.primary.g,
        ColorService.primary.b,
        0.2
    ) : "transparent"

    property int volume: 0
    property bool muted: false
    property var audioSelector: null

    // Volume icon based on level and mute state
    property string volumeIcon: {
        if (muted) return "\uf6a9"      // muted icon
        if (volume <= 0) return "\uf026" // volume off
        if (volume <= 50) return "\uf027" // volume low
        return "\uf028"                   // volume high
    }

    // Get current volume
    Process {
        id: volumeProcess
        command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                // Output format: "Volume: front-left: 65536 / 100% / 0.00 dB, front-right: ..."
                const match = data.match(/(\d+)%/)
                if (match) {
                    audioWidget.volume = parseInt(match[1])
                }
            }
        }
    }

    // Get mute state
    Process {
        id: muteProcess
        command: ["pactl", "get-sink-mute", "@DEFAULT_SINK@"]

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                audioWidget.muted = data.includes("yes")
            }
        }
    }

    // Toggle mute
    Process {
        id: toggleMuteProcess
        command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
        onExited: {
            muteProcess.running = true
        }
    }

    // Set volume
    Process {
        id: setVolumeProcess
        property int targetVolume: 0
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", targetVolume + "%"]
        onExited: {
            volumeProcess.running = true
        }
    }

    // Update timer
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            volumeProcess.running = true
            muteProcess.running = true
        }
    }

    Row {
        id: audioRow
        anchors.centerIn: parent
        spacing: 6

        // Volume icon
        Text {
            text: audioWidget.volumeIcon
            color: ColorService.primary
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        // Volume bar container
        Rectangle {
            width: 50
            height: 8
            radius: 4
            color: ColorService.surfaceVariant
            anchors.verticalCenter: parent.verticalCenter

            // Volume fill
            Rectangle {
                width: Math.max(0, Math.min(parent.width, parent.width * (audioWidget.muted ? 0 : audioWidget.volume / 100)))
                height: parent.height
                radius: 4
                color: audioWidget.muted ? ColorService.tertiary : ColorService.primary
            }
        }

        // Volume percentage
        Text {
            text: audioWidget.volume + "%"
            color: ColorService.foregroundSurface
            font.pixelSize: 12
            font.family: "monospace"
            anchors.verticalCenter: parent.verticalCenter
            width: 32
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                toggleMuteProcess.running = true
            } else if (mouse.button === Qt.RightButton) {
                if (audioWidget.audioSelector) {
                    audioWidget.audioSelector.visible = !audioWidget.audioSelector.visible
                }
            }
        }

        onWheel: wheel => {
            const delta = wheel.angleDelta.y > 0 ? 5 : -5
            const newVolume = Math.max(0, Math.min(100, audioWidget.volume + delta))
            setVolumeProcess.targetVolume = newVolume
            setVolumeProcess.running = true
        }
    }
}
