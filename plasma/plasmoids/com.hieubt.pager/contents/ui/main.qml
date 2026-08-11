import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    readonly property color mauve:   "#cba6f7"
    readonly property color surface: "#313244"
    readonly property color textDim: "#cdd6f4"
    readonly property color crust:   "#1e1e2e"

    TaskManager.VirtualDesktopInfo { id: vdi }

    // currentDesktop có thể là số (1-based) hoặc uuid tuỳ backend
    readonly property int current: {
        var c = vdi.currentDesktop
        if (typeof c === "number") return c
        var i = vdi.desktopIds.indexOf(c)
        return i >= 0 ? i + 1 : 1
    }

    P5Support.DataSource {
        id: runner
        engine: "executable"
        onNewData: (sourceName) => disconnectSource(sourceName)
    }

    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        Layout.minimumWidth: row.implicitWidth + 8
        Layout.preferredWidth: Layout.minimumWidth
        Layout.maximumWidth: Layout.minimumWidth
        Layout.fillHeight: true

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: Math.max(1, vdi.numberOfDesktops)

                Rectangle {
                    readonly property int num: index + 1
                    readonly property bool active: num === root.current

                    Layout.preferredWidth: active ? 30 : 22
                    Layout.preferredHeight: 22
                    radius: 6
                    color: active ? root.mauve
                         : cellMouse.containsMouse ? Qt.alpha(root.mauve, 0.35)
                         : Qt.alpha(root.surface, 0.75)

                    Behavior on Layout.preferredWidth { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
                    Behavior on color { ColorAnimation { duration: 180 } }

                    Text {
                        anchors.centerIn: parent
                        text: parent.num
                        color: parent.active ? root.crust : root.textDim
                        font.pixelSize: 11
                        font.bold: parent.active
                    }

                    MouseArea {
                        id: cellMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: runner.connectSource(
                            "qdbus6 org.kde.KWin /KWin org.kde.KWin.setCurrentDesktop " + parent.num)
                    }
                }
            }
        }
    }

    toolTipMainText: "Desktop " + root.current + " / " + vdi.numberOfDesktops
    toolTipSubText: "Bấm để chuyển desktop ảo"
}
