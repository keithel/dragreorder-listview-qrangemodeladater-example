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

## Validating steps

To validate that each step compiles, runs and the behavior matches the desired
step content, run [test/rebase_test_step.sh](test/rebase_test_step.sh) (which
will itself show you how to use it)

---

## Step 1 — Simple QML-only list

The bare minimum: a `ListView` with an inline `ListModel` defined entirely in
QML. No C++, no drag-and-drop. Establishes the two-module CMake layout.

---

## Step 2 — C++ backend with QRangeModel (this commit)

**What's here:** the first C++ layer, focused entirely on `QRangeModel`.

- `TaskBackend` is a `QObject`/`QML_ELEMENT` that exposes a `QRangeModel` built
  from a QStringList holding the task descriptions. The model is passed
  `std::ref(s_data)` so it reads live from the vector.
- `Main.qml` instantiates `TaskBackend` and passes `backend.taskModel` to
  `TaskListView`.
- The delegate remains a plain `ItemDelegate` — no drag-and-drop yet.

The key takeaway for this step is how little code is needed to connect a plain
C++ data structure to a QML `ListView` using `QRangeModel`.
