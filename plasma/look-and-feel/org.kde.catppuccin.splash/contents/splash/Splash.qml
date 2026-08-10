import QtQuick 2.5

Rectangle {
    id: root
    color: "#1e1e2e"

    property int stage
    onStageChanged: {
        if (stage == 1) introAnimation.running = true
    }

    Image {
        anchors.fill: parent
        source: "images/background.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.85
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0
        TextMetrics {
            id: units
            text: "M"
            property int gridUnit: boundingRect.height
            property int largeSpacing: units.gridUnit
            property int smallSpacing: Math.max(2, gridUnit / 4)
        }

        // chữ chào giữa màn
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: bar.top
            anchors.bottomMargin: units.gridUnit * 2
            text: "hieubt"
            color: "#cdd6f4"
            font.pointSize: 22
            font.weight: Font.Light
        }

        // thanh nạp mauve
        Rectangle {
            id: bar
            anchors.centerIn: parent
            anchors.verticalCenterOffset: parent.height / 4
            width: parent.width / 5
            height: 6
            radius: 3
            color: "#313244"

            Rectangle {
                height: parent.height
                radius: 3
                color: "#cba6f7"
                width: (root.stage / 6) * parent.width
                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: 800
        easing.type: Easing.InOutQuad
    }
}
