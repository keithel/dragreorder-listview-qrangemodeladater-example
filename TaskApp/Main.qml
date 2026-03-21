import QtQuick
import QtQuick.Controls

import Com.Example.Tasks

ApplicationWindow {
    id: rootWindow
    width: 400
    height: 600
    visible: true
    title: "Task List"

    TaskListView {
        anchors.fill: parent
    }
}
