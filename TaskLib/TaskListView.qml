// TaskListView.qml
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
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: visualModel
    }
}
