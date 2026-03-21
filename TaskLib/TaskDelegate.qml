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

        Label {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: delegateRoot.display
        }
    }
}
