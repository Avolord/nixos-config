import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: cpuWidget

    width: cpuRow.width + 16
    height: 22
    radius: 4
    color: "transparent"

    property string loadAvg: "0.00"

    Process {
        id: loadProcess
        command: ["cat", "/proc/loadavg"]

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                // /proc/loadavg format: "0.00 0.01 0.05 1/234 5678"
                // First value is 1-minute load average
                const parts = data.trim().split(" ")
                if (parts.length > 0) {
                    cpuWidget.loadAvg = parts[0] + "%"
                }
            }
        }
    }

    Timer {
        interval: 3000 // Update every 3 seconds
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: loadProcess.running = true
    }

    Row {
        id: cpuRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "\uf2db" // fa-microchip
            color: ColorService.primary
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: cpuWidget.loadAvg
            color: ColorService.foregroundSurface
            font.pixelSize: 12
            font.family: "monospace"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
