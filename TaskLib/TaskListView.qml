// TaskListView.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQml.Models

Item {
    id: root
    property alias model: visualModel.model

    DelegateModel {
        id: visualModel
        delegate: TaskDelegate {
            required property string modelData
            width: ListView.view.width
            display: modelData
            visualIndex: DelegateModel.itemsIndex

            onMoveItem: (from, to) => {
                visualModel.items.move(from, to)
            }
        }
    }

    ListView {
        id: listView
        property bool dragActive: false
        anchors.fill: parent
        interactive: !dragActive
        model: visualModel

        displaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}
