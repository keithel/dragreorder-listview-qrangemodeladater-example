// TaskListView.qml
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
            visualIndex: DelegateModel.itemsIndex

            onStartMove: ListView.view.dragSourceIndex = index
            onMoveItem: (from, to) => {
                visualModel.items.move(from, to)
                listView.dragTargetIndex = to
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent

        function generateId() {
            // Uses the current time in milliseconds + a 4-digit random number
            return Date.now().toString(36) + Math.random().toString(36).substring(2, 6);
        }

        property bool draggingItem: false
        property int dragSourceIndex: -1
        property int dragTargetIndex: -1
        property string dragDropKey
        property int dragDuration: 200

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
            console.log("Committing move from", dragSourceIndex, "to", dragTargetIndex)
            root.commitMove(dragSourceIndex, dragTargetIndex)
            dragSourceIndex = -1
            dragTargetIndex = -1
        }
    }
}
