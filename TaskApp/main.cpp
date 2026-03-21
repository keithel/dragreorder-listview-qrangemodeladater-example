#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;
    // addImportPath is only needed because in CMake, we explicitly
    // specify to generate the QML modules in "${CMAKE_BINARY_DIR}/qml" from the
    // project root CMakeLists.txt file. If we specified it to be next to the
    // binary executable itself (no "qml" subdir) then this can be omitted.
    engine.addImportPath(QCoreApplication::applicationDirPath() + QDir::separator() + "qml");

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("Com.Example.App", "Main");

    return app.exec();
}
