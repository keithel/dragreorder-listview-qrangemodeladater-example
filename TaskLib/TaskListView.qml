// TaskListView.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQml.Models

Item {
    id: root
    property alias model: visualModel.model
    signal commitMove(int from, int to)

    DelegateModel {
        id: visualModel
        delegate: TaskDelegate {
            width: ListView.view.width
            // Use itemsIndex from DelegateModel for the current visual position
            visualIndex: DelegateModel.itemsIndex
            listView: listView

            onStartMove: {
                listView.dragSourceIndex = index
                // Start tracking moves
                listView.dragMoves = []
            }
            onMoveItem: (from, to) => {
                visualModel.items.move(from, to)
                listView.dragTargetIndex = to
                // Track the move
                listView.dragMoves.push({from: from, to: to})
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent

        Keys.onReleased: (event) => {
            if (draggingItem && event.key === Qt.Key_Escape) {
                // Cancel drag: replay moves in reverse to restore original order
                dragCanceled = true;
                if (dragMoves && dragMoves.length > 0) {
                    for (let i = dragMoves.length - 1; i >= 0; --i) {
                        let move = dragMoves[i];
                        visualModel.items.move(move.to, move.from);
                    }
                }
                draggingItem = false;
                dragSourceIndex = -1;
                dragTargetIndex = -1;
                dragMoves = [];
                event.accepted = true;
            }
        }
        focus: true

        function generateId() {
            // Uses the current time in milliseconds + a 4-digit random number
            return Date.now().toString(36) + Math.random().toString(36).substring(2, 6);
        }

        property bool draggingItem: false
        property int dragSourceIndex: -1
        property int dragTargetIndex: -1
        property string dragDropKey
        property int dragDuration: 200
        property bool dragCanceled: false
        property var dragMoves: []

        interactive: !draggingItem
        model: visualModel

        displaced: Transition {
            SequentialAnimation {
                PropertyAction { property: "itemsMoving"; value: false }
                NumberAnimation { properties: "y"; duration: listView.dragDuration; easing.type: Easing.OutQuad }
                PropertyAction { property: "itemsMoving"; value: true }
            }
        }

        Component.onCompleted: dragDropKey = generateId()
        onDraggingItemChanged: {
            if (draggingItem)
                return;

            if (dragCanceled) {
                dragCanceled = false;
                dragMoves = [];
            } else {
                console.log("Committing move from", dragSourceIndex, "to", dragTargetIndex)
                root.commitMove(dragSourceIndex, dragTargetIndex)
                dragMoves = [];
            }

            dragSourceIndex = -1
            dragTargetIndex = -1
        }
    }
}
