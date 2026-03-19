// TaskDelegate.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: delegateRoot
    required property string description
    required property bool pastDue
    required property bool done

    required property int index
    required property int visualIndex
    property ListView view: ListView.view
    property alias held: dragArea.active

    signal startMove()
    signal moveItem(int from, int to)

    height: 60

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
            delegateRoot.view.draggingItem = false
        }

        states: State {
            when: dragArea.active
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

                DragHandler {
                    id: dragArea
                    property real heldY: 0

                    onGrabChanged: (transition, point) => {
                        if (transition === PointerDevice.GrabExclusive ||
                            transition === PointerDevice.GrabPassive) {
                            let contentItem = content.Window?.contentItem
                            let globalPos = delegateRoot.mapToItem(
                                contentItem ? contentItem : delegateRoot, 0, 0)
                            heldY = globalPos.y;
                            delegateRoot.startMove()
                            delegateRoot.view.draggingItem = true
                        }
                        else {
                            if (!delegateRoot.view.draggingItem) {
                                // If listView is not dragging item on release,
                                // cancel was performed and the item can still have
                                // been dragged around. Return the item to its
                                // proper y position.
                                content.y = 0
                            }
                            delegateRoot.view.draggingItem = false
                        }
                    }

                    target: content
                    xAxis.enabled: false
                    yAxis.enabled: true
                    yAxis.minimum: 0
                    yAxis.maximum: content.Window?.height ? content.Window.height - content.height : 10000
                }
            }

            Label {
                id: taskLabel
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft
                verticalAlignment: Text.AlignVCenter
                text: delegateRoot.description
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

        // Drag/Drop Logic
        Drag.active: dragArea.active
        Drag.source: delegateRoot
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2
        Drag.keys: [delegateRoot.view.dragDropKey]
    }

    DropArea {
        anchors.fill: parent
        keys: [delegateRoot.view.dragDropKey]
        onEntered: (drag) => {
            if (!delegateRoot.view.draggingItem)
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
        target: delegateRoot.view
        function onDragCanceledChanged() {
            if (delegateRoot.view.dragCanceled && dragArea.active) {
                cancelTimer.start();
            }
        }
        property Timer cancelTimer: Timer {
            interval: 0
            onTriggered: content.cancelDrag()
        }
    }
}
