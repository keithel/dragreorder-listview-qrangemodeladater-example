import QtQuick
import QtQuick.Controls

import Com.Example.Tasks

ApplicationWindow {
    id: rootWindow
    width: 400
    height: 600
    visible: true
    title: "Task List"

    TaskBackend {
        id: backend
    }

    TaskListView {
        anchors.fill: parent
        model: backend.taskModel
        onMoveRequested: (from, to) => backend.moveTask(from, to)
    }
}
