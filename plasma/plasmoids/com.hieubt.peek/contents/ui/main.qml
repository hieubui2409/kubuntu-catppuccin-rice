import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    readonly property color mauve: "#cba6f7"

    P5Support.DataSource {
        id: runner
        engine: "executable"
        onNewData: (sourceName) => disconnectSource(sourceName)
    }

    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        id: rep
        Layout.minimumWidth: 10
        Layout.preferredWidth: 10
        Layout.maximumWidth: 10
        Layout.fillHeight: true

        Rectangle {
            id: chip
            anchors.fill: parent
            anchors.topMargin: 6
            anchors.bottomMargin: 6
            anchors.leftMargin: 3
            anchors.rightMargin: 3
            radius: 2
            color: root.mauve
            opacity: mouse.containsMouse ? 0.9 : 0.15
            border.width: 0

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: runner.connectSource(
                "qdbus6 org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut 'Show Desktop'")
        }
    }

    toolTipMainText: "Peek desktop"
    toolTipSubText: "Bấm để hiện desktop"
}
