// TaskDelegate.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

Item {
    id: delegateRoot
    height: 60

    required property string display
    required property int index
    property ListView view: ListView.view

    Rectangle {
        id: content
        anchors.fill: parent
        color: "white"
        border.color: "#ccc"

        states: State {
            when: dragArea.held
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

            MouseArea {
                id: dragArea
                anchors.fill: parent
                property bool held: false

                onPressed: {
                    held = true
                    delegateRoot.view.dragActive = true
                }
                onReleased: {
                    held = false
                    delegateRoot.view.dragActive = false
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
