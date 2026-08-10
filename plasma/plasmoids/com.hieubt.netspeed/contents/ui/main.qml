import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors

PlasmoidItem {
    id: root

    readonly property color downColor: "#fab387"   // peach
    readonly property color upColor:   "#94e2d5"   // teal

    Sensors.Sensor { id: downSensor; sensorId: "network/all/download"; updateRateLimit: 1000 }
    Sensors.Sensor { id: upSensor;   sensorId: "network/all/upload";   updateRateLimit: 1000 }

    function fmt(bytes) {
        if (bytes >= 1073741824) return (bytes / 1073741824).toFixed(1) + "G"
        if (bytes >= 1048576)    return (bytes / 1048576).toFixed(1) + "M"
        if (bytes >= 1024)       return Math.round(bytes / 1024) + "K"
        return Math.round(bytes || 0) + ""
    }

    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        id: rep

        TextMetrics {
            id: metrics
            font.pixelSize: 11
            text: "888.8M"
        }

        Layout.minimumWidth: metrics.width + 20
        Layout.preferredWidth: Layout.minimumWidth
        Layout.maximumWidth: Layout.minimumWidth
        Layout.fillHeight: true

        GridLayout {
            anchors.centerIn: parent
            columns: 2
            rowSpacing: -2
            columnSpacing: 3

            Text { text: "↓"; color: root.downColor; font.pixelSize: 11; font.bold: true }
            Text {
                text: root.fmt(downSensor.value)
                color: root.downColor
                font.pixelSize: 11
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: metrics.width
            }
            Text { text: "↑"; color: root.upColor; font.pixelSize: 11; font.bold: true }
            Text {
                text: root.fmt(upSensor.value)
                color: root.upColor
                font.pixelSize: 11
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: metrics.width
            }
        }
    }

    toolTipMainText: "Mạng"
    toolTipSubText: "↓ " + fmt(downSensor.value) + "B/s   ↑ " + fmt(upSensor.value) + "B/s"
}
