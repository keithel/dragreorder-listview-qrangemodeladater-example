qt_add_executable(appTaskApp main.cpp)
qt_add_qml_module(appTaskApp
    URI Com.Example.App
    VERSION 1.0
    QML_FILES Main.qml
)

# main.cpp adds a `qml` dir under the app root to the QML import path, which
# finds Main.qml when loading the module.
set_target_properties(appTaskApp PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml"
)

target_link_libraries(appTaskApp PRIVATE Qt6::Quick Qt6::QuickControls2)
