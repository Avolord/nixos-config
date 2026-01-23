import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    WallpaperSelector {
        id: wallpaperSelector
    }
    
    // Your other windows/panels here
    PanelWindow {
    id: root
    
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    
    // Use themed colors
    color: ColorService.surface
    
    Rectangle {
        anchors.fill: parent
        color: ColorService.primary

        // Wallpaper button on the left
        Rectangle {
            id: wallpaperButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            width: 80
            height: 22
            radius: 4
            color: wallpaperMouseArea.containsMouse ? ColorService.secondary : "transparent"

            Text {
                anchors.centerIn: parent
                text: "Wallpaper"
                color: ColorService.foregroundPrimary
                font.pixelSize: 12
            }

            MouseArea {
                id: wallpaperMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: wallpaperSelector.visible = !wallpaperSelector.visible
            }
        }

        Text {
            anchors.centerIn: parent
            text: "Themed Panel"
            color: ColorService.foregroundPrimary
        }
    }
}
}