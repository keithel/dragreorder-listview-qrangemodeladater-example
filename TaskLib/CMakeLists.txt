find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

qt_add_qml_module(TaskLib
    URI "Com.Example.Tasks"
    VERSION 1.0
    SOURCES
        TaskBackend.h TaskBackend.cpp
    QML_FILES
        TaskListView.qml
)
target_link_libraries(TaskLib PRIVATE Qt6::Quick Qt6::QuickControls2)
