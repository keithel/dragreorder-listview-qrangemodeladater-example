// TaskDelegate.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

Item {
    id: delegateRoot
    height: 60

    required property string display
    required property int index
    required property int visualIndex
    property ListView view: ListView.view
    signal moveItem(int from, int to)

    Rectangle {
        id: content
        width: delegateRoot.width
        height: delegateRoot.height
        parent: delegateRoot
        y: 0
        color: "white"
        border.color: "#ccc"

        states: State {
            when: dragArea.held
            ParentChange {
                target: content
                parent: content.Window.contentItem
            }
            PropertyChanges {
                content {
                    y: dragArea.heldY
                    z: 100
                    color: "#eeeeee"
                }
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
                property real heldY: 0

                onPressed: (mouse) => {
                    let globalPos = delegateRoot.mapToItem(Window.contentItem, 0, 0)
                    heldY = globalPos.y
                    held = true
                    delegateRoot.view.dragActive = true
                }
                onReleased: {
                    held = false
                    delegateRoot.view.dragActive = false
                }

                drag.target: content
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: Window.height - content.height
            }
        }

        Label {
            anchors.left: handle.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: delegateRoot.display
        }

        // Drag/Drop Logic
        Drag.active: dragArea.held
        Drag.source: delegateRoot
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2
        Drag.keys: ["task-item"]
    }

    DropArea {
        anchors.fill: parent
        keys: ["task-item"]
        onEntered: (drag) => {
            let from = drag.source.visualIndex
            let to = delegateRoot.visualIndex

            if (from !== to) {
                delegateRoot.moveItem(from, to)
            }
        }
    }
}
