# Drag-Reorder ListView Example with QRangeModelAdapter

This project demonstrates how to implement drag-and-drop reordering in a Qt Quick ListView using the new `QRangeModelAdapter` introduced in Qt 6.11. It illustrates how to animate the reorder as the user drags, uses DelegateModel to visualize the dragged item move in a visual model before committing it to the underlying model on release.

It provides a minimal, practical example for developers looking to enable dynamic item reordering in their QML ListViews, leveraging modern Qt model/view patterns.

## Features
- Drag-and-drop reordering: Users can drag items to reorder them in the ListView.
- Animation of insertion point on drag, including logic to prevent improper
moves due to animation.
- Commit only happens once the item drag is complete.
- QRangeModelAdapter usage: Showcases how to use the new adapter for efficient model/view integration.
- Modular C++/QML structure: Clean separation between backend logic and QML UI.

## Project Structure
- `TaskApp/` — Main application entry point and QML UI.
- `TaskLib/` — C++ backend logic, including the model and drag handling.

## Requirements
- Qt 6.11 or newer (QRangeModelAdapter is not available in earlier versions)
- CMake (for building the project)

## Building and Running
1. Clone the repository
2. Configure the project:
   ```sh
   /path/to/Qt/6.11.N/compiler/qt-cmake -B build -S .
   ```
3. Build the project:
   ```sh
   cmake --build build
   ```
4. Run the application:
   ```sh
   ./build/TaskApp/appTaskApp
   ```

## Usage
- Launch the application.
- Drag items in the list to reorder them dynamically.

## License
This project is licensed under the BSD 3-Clause License. See [LICENSE](LICENSE) for details.

## References
- [QRangeModelAdapter](https://doc-snapshots.qt.io/qt6-6.11/qrangemodeladapter.html)
- [Qt Quick ListView](https://doc.qt.io/qt-6/qml-qtquick-listview.html)
- [Qt Quick DelegateModel](https://doc.qt.io/qt-6/qml-qtqml-models-delegatemodel.html)
