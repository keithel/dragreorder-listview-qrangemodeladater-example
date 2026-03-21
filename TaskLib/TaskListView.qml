// TaskListView.qml
import QtQuick
import QtQuick.Controls

ListView {
    id: root

    model: ListModel {
        ListElement { description: "Buy groceries"; }
        ListElement { description: "Walk the dog"; }
        ListElement { description: "Empty dishwasher"; }
        ListElement { description: "Wash clothes"; }
        ListElement { description: "Clear table"; }
        ListElement { description: "Dry clothes"; }
        ListElement { description: "Load dishwasher"; }
        ListElement { description: "Fold clothes"; }
        ListElement { description: "Run dishwasher"; }
        ListElement { description: "Empty trash"; }
    }

    delegate: ItemDelegate {
        required property string description
        width: ListView.view.width
        text: description
    }
}
