// TaskDelegate.qml
import QtQuick
import QtQuick.Controls

Item {
    id: delegateRoot
    height: 60

    required property string description
    required property int index
    required property int visualIndex
    property ListView view: ListView.view
    property bool itemsMoving: true

    signal startMove()
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
                parent: content.Window?.contentItem ? content.Window.contentItem : content.parent
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
                    let contentItem = content.Window?.contentItem
                    let globalPos = delegateRoot.mapToItem(
                        contentItem ? contentItem : delegateRoot, 0, 0)
                    heldY = globalPos.y
                    held = true
                    delegateRoot.startMove()
                    delegateRoot.view.draggingItem = true
                }
                onReleased: {
                    held = false
                    delegateRoot.view.draggingItem = false
                }

                drag.target: content
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: content.Window?.height ? content.Window.height - content.height : 10000
            }
        }

        Label {
            anchors.left: handle.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: delegateRoot.description
        }

        // Drag/Drop Logic
        Drag.active: dragArea.held
        Drag.source: delegateRoot
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2
        Drag.keys: [delegateRoot.view.dragDropKey]
    }

    DropArea {
        anchors.fill: parent
        keys: [delegateRoot.view.dragDropKey]
        onEntered: (drag) => {
            if (!delegateRoot.itemsMoving)
                return;

            let from = drag.source.visualIndex
            let to = delegateRoot.visualIndex
            console.log("DropArea", to, "entered by index", from)
            if (from !== to) {
                delegateRoot.moveItem(from, to)
            }
        }
    }
}
