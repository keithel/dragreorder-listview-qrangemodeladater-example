# Drag-Reorder ListView with QRangeModelAdapter — Tutorial Steps

This repository walks through building a drag-reorderable Qt Quick `ListView`
backed by a C++ model, step by step. Each commit on the `steps` branch is one
tutorial step, growing from the simplest possible starting point up to the full
implementation.

## Tutorial Overview

By the end of the tutorial the application will demonstrate:

- A `ListView` backed by a C++ model exposed to QML via **`QRangeModelAdapter`**
  (introduced in Qt 6.11), without requiring the model to inherit
  `QAbstractItemModel`.
- A **drag handle** on each list item that lets the user reorder items by
  dragging up or down.
- **Live visual reordering** while dragging, using `DelegateModel`'s `move`
  feature to shift other items out of the way before the drop is committed.
- A **commit-on-release** pattern: the underlying C++ model is only mutated
  once the user releases the drag handle.
- **Drag cancellation** via the Escape key (desktop) or a second finger press
  (touch devices).

## Project Structure

- `TaskApp/` — Application entry point (`main.cpp`) and top-level QML
  (`Main.qml`).
- `TaskLib/` — QML module (`Com.Example.Tasks`) containing the list view,
  delegate, and (in later steps) the C++ backend.

## Requirements

- Qt 6.11 or newer (earlier versions lack `QRangeModelAdapter`)
- CMake 3.21+

## Building

```sh
/path/to/Qt/6.11.x/<kit>/bin/qt-cmake -B build -S .
cmake --build build
./build/qml/appTaskApp
```

---

## Step 0 — Simple QML-only list (this commit)

**What's here:** the bare minimum to display a task list in a Qt Quick
`ApplicationWindow`.

- `TaskLib` is a QML-only module — no C++ sources at all.
- `TaskListView.qml` is a plain `ListView` with an inline `ListModel` whose
  items are defined directly in QML.
- The delegate is a standard `ItemDelegate` from Qt Quick Controls.
- There is no drag-and-drop.

This step establishes the project skeleton and verifies that the two-module
CMake layout (`TaskLib` + `TaskApp`) builds and runs correctly before any
complexity is added.
