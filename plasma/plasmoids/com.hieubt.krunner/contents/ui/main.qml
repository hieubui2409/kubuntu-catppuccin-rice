import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
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
        Layout.minimumWidth: 32
        Layout.preferredWidth: 32
        Layout.maximumWidth: 32
        Layout.fillHeight: true

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: 8
            color: root.mauve
            opacity: mouse.containsMouse ? 0.25 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Kirigami.Icon {
            anchors.centerIn: parent
            width: 18
            height: 18
            source: "search"
            color: root.mauve
            scale: mouse.containsMouse ? 1.15 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: runner.connectSource(
                "qdbus6 org.kde.krunner /App org.kde.krunner.App.display")
        }
    }

    toolTipMainText: "Tìm kiếm"
    toolTipSubText: "Mở KRunner"
}
