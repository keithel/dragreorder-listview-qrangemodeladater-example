cmake_minimum_required(VERSION 3.21)
project(TaskReorderer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.10 REQUIRED COMPONENTS Core Quick QuickControls2)

qt_policy(SET QTP0001 NEW)

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")
add_subdirectory(TaskLib)
add_subdirectory(TaskApp)
