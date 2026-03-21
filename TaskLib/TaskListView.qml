// TaskListView.qml
import QtQuick
import QtQml.Models

Item {
    id: root
    property alias model: visualModel.model
    signal moveRequested(int from, int to)

    DelegateModel {
        id: visualModel
        delegate: TaskDelegate {
            required property string modelData
            width: ListView.view.width
            display: modelData
            visualIndex: DelegateModel.itemsIndex

            onMoveItem: (from, to) => {
                visualModel.items.move(from, to)
                ListView.view.moveRequested(from, to)
            }
        }
    }

    ListView {
        id: listView
        property bool dragActive: false
        signal moveRequested(int from, int to)

        anchors.fill: parent
        interactive: !dragActive
        model: visualModel

        onMoveRequested: (from, to) => { root.moveRequested(from, to) }
    }
}
