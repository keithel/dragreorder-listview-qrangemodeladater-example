// TaskListView.qml
import QtQuick
import QtQuick.Controls

ListView {
    id: root

    // model is set from outside (e.g. Main.qml via TaskBackend.taskModel)

    delegate: ItemDelegate {
        width: ListView.view.width
        text: modelData
    }
}
