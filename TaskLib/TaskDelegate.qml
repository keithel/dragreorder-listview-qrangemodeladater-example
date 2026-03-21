// TaskDelegate.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

Item {
    id: delegateRoot
    height: 60

    required property string display
    required property int index

    Rectangle {
        anchors.fill: parent
        color: "white"
        border.color: "#ccc"

        // Drag handle
        Rectangle {
            id: handle
            width: 40
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: "#ddd"
            Text {
                text: "☰"
                anchors.centerIn: parent
            }
        }

        Label {
            anchors.left: handle.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: delegateRoot.display
        }
    }
}
