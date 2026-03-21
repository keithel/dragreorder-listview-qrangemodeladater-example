// TaskDelegate.qml
import QtQuick
import QtQuick.Controls

Item {
    id: delegateRoot
    required property string display
    property ListView view: ListView.view

    height: 60

    Rectangle {
        id: content
        anchors.fill: parent
        color: "white"
        border.color: "#ccc"

        states: State {
            when: dragArea.active
            PropertyChanges {
                content.color: "#eeeeee"
            }
        }

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

            PointHandler {
                id: dragArea
                onGrabChanged: (transition, point) => {
                    delegateRoot.view.dragActive =
                        (transition === PointerDevice.GrabExclusive ||
                         transition === PointerDevice.GrabPassive);
                }
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
