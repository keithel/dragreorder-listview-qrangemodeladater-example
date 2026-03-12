cmake_minimum_required(VERSION 3.16)
find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_add_qml_module(TaskLib
    URI "Com.Example.Tasks"
    VERSION 1.0
    SOURCES
        TaskItem.h TaskItem.cpp
        TaskBackend.h TaskBackend.cpp
    QML_FILES
        TaskListView.qml
        TaskDelegate.qml
)
target_link_libraries(TaskLib PRIVATE Qt6::Core Qt6::Quick Qt6::Qml)
