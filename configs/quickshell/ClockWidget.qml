import QtQuick
import Quickshell

Rectangle {
    id: clockWidget

    width: clockRow.width + 16
    height: 22
    radius: 4
    color: "transparent"

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "\uf017" // fa-clock-o
            color: ColorService.primary
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: Qt.formatDateTime(clock.date, "hh:mm:ss - yyyy-MM-dd")
            color: ColorService.foregroundSurface
            font.pixelSize: 12
            font.family: "monospace"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
