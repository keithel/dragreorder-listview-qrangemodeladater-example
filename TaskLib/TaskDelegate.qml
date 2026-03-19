// TaskDelegate.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: delegateRoot
    height: 60

    required property string description
    required property int priority
    required property bool pastDue
    required property bool done

    required property int index
    required property int visualIndex
    required property var listView

    property bool itemsMoving: true
    property alias held: dragArea.held

    signal startMove()
    signal moveItem(int from, int to)

    function toggleDone() {
        done = !done;
    }

    Rectangle {
        id: content
        width: delegateRoot.width
        height: delegateRoot.height
        parent: delegateRoot
        y: 0
        color: "transparent"
        border.color: "#ccc"

        function cancelDrag() {
            dragArea.held = false
            delegateRoot.listView.draggingItem = false
        }

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

        RowLayout {
            anchors.fill: parent
            spacing: 10

            // 1. Grab Handle
            Rectangle {
                id: handle
                Layout.preferredWidth: 40
                Layout.fillHeight: true
                color: "#ddd"
                Text { text: "☰"; anchors.centerIn: parent }

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
                        delegateRoot.listView.draggingItem = true
                    }
                    onReleased: {
                        if (!held) {
                            // If it is not held on release, cancel was performed
                            // and the item can still have been dragged around.
                            // Return the item to it's proper y position.
                            content.y = 0
                        }

                        held = false
                        delegateRoot.listView.draggingItem = false
                    }

                    drag.target: content
                    drag.axis: Drag.YAxis
                    drag.minimumY: 0
                    drag.maximumY: content.Window?.height ? content.Window.height - content.height : 10000
                }
            }

            Label {
                id: taskLabel
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft
                verticalAlignment: Text.AlignVCenter
                text: delegateRoot.description + " " + delegateRoot.priority
                font.strikeout: delegateRoot.done

                states: State {
                    when: delegateRoot.pastDue
                    PropertyChanges {
                        taskLabel.color: "red"
                    }
                }

                TapHandler {
                    id: touchHandler
                    enabled: true
                    acceptedButtons: Qt.AllButtons
                    onTapped: (eventPoint, button) => {
                        if (point.device.type !== PointerDevice.TouchScreen && button === Qt.RightButton)
                            delegateRoot.toggleDone();
                    }
                    onLongPressed: {
                        if (point.device.type === PointerDevice.TouchScreen)
                            delegateRoot.toggleDone();
                    }
                }
            }
            Item { Layout.fillWidth: true }
        }

        // 2. Drag/Drop Logic
        Drag.active: dragArea.held
        Drag.source: delegateRoot
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2
        Drag.keys: [delegateRoot.listView.dragDropKey]
    }

    DropArea {
        anchors.fill: parent
        keys: [delegateRoot.listView.dragDropKey]
        onEntered: (drag) => {
            if (!delegateRoot.itemsMoving)
                return;

            let from = drag.source.visualIndex
            let to = delegateRoot.visualIndex
            console.log("DropArea", to, "entered by index", from)
            if (drag.source.held && from !== to) {
                delegateRoot.moveItem(from, to)
            }
        }
    }

    // Watch for drag cancel from the ListView and cancel the drag if needed
    Connections {
        target: delegateRoot.listView
        function onDragCanceledChanged() {
            if (delegateRoot.listView.dragCanceled && dragArea.held) {
                cancelTimer.start();
            }
        }
        property Timer cancelTimer: Timer {
            interval: 0
            onTriggered: content.cancelDrag()
        }
    }
}
