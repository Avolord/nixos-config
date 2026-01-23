// ColorService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: colorService

    property string colorsPath: Quickshell.env("HOME") + "/.config/quickshell/colors.json"

    // Color properties with defaults
    property color primary: "#1976d2"
    property color secondary: "#424242"
    property color tertiary: "#03687a"
    property color surface: "#121212"
    property color surfaceVariant: "#49454f"
    property color background: "#000000"
    property color foregroundPrimary: "#ffffff"
    property color foregroundSecondary: "#ffffff"
    property color foregroundSurface: "#ffffff"
    property color foregroundBackground: "#ffffff"

    // Process to read colors file fresh
    Process {
        id: catProcess
        command: ["cat", colorService.colorsPath]

        stdout: SplitParser {
            splitMarker: ""
            onRead: data => colorService.parseColors(data)
        }
    }

    Component.onCompleted: loadColors()

    function loadColors() {
        catProcess.running = true
    }

    function parseColors(content) {
        if (content && content.trim() !== "") {
            try {
                const parsed = JSON.parse(content)
                // Update each property individually to trigger proper change notifications
                if (parsed.primary) primary = parsed.primary
                if (parsed.secondary) secondary = parsed.secondary
                if (parsed.tertiary) tertiary = parsed.tertiary
                if (parsed.surface) surface = parsed.surface
                if (parsed.surfaceVariant) surfaceVariant = parsed.surfaceVariant
                if (parsed.background) background = parsed.background
                if (parsed.onPrimary) foregroundPrimary = parsed.onPrimary
                if (parsed.onSecondary) foregroundSecondary = parsed.onSecondary
                if (parsed.onSurface) foregroundSurface = parsed.onSurface
                if (parsed.onBackground) foregroundBackground = parsed.onBackground
                console.log("Colors loaded successfully:", parsed.primary)
            } catch (e) {
                console.error("Failed to parse colors:", e)
            }
        }
    }
}
