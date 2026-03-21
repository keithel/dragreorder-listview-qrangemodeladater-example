// TaskDelegate.qml
import QtQuick
import QtQuick.Controls

Item {
    id: delegateRoot
    required property string display
    required property int visualIndex
    property ListView view: ListView.view
    signal moveItem(int from, int to)

    height: 60

    Rectangle {
        id: content
        width: delegateRoot.width
        height: delegateRoot.height
        parent: delegateRoot
        y: 0
        color: "white"
        border.color: "#ccc"

        states: State {
            when: dragArea.active
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

            DragHandler {
                id: dragArea
                property real heldY: 0

                onGrabChanged: (transition, point) => {
                    if (transition === PointerDevice.GrabExclusive ||
                         transition === PointerDevice.GrabPassive) {
                        delegateRoot.view.dragActive = true;
                        let globalPos = delegateRoot.mapToItem(delegateRoot.Window.contentItem, 0, 0);
                        heldY = globalPos.y;
                    }
                    else {
                        delegateRoot.view.dragActive = false;
                    }
                }

                target: content
                xAxis.enabled: false
                yAxis.enabled: true
                yAxis.minimum: 0
                yAxis.maximum: delegateRoot.Window.height - content.height
            }
        }

        Label {
            anchors.left: handle.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: delegateRoot.display
        }

        // Drag/Drop Logic
        Drag.active: dragArea.active
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
