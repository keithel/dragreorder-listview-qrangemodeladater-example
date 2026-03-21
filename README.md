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

## Step 2 — C++ backend with QRangeModel

**What's here:** the first C++ layer, focused entirely on `QRangeModel`.

- `TaskBackend` is a `QObject`/`QML_ELEMENT` that exposes a `QRangeModel` built
  from a QStringList holding the task descriptions. The model is passed
  `std::ref(s_data)` so it reads live from the vector.
- `Main.qml` instantiates `TaskBackend` and passes `backend.taskModel` to
  `TaskListView`.
- The delegate remains a plain `ItemDelegate` — no drag-and-drop yet.

The key takeaway for this step is how little code is needed to connect a plain
C++ data structure to a QML `ListView` using `QRangeModel`.

---

## Step 3 — Modular delegate with DelegateModel (this commit)

**What's here:** introducing `DelegateModel` for better item management and
preparation for drag-and-drop.

- Extract the delegate into a dedicated `TaskDelegate.qml` component, replacing
  `ItemDelegate` with a custom `Item` containing a `Rectangle` and `Label`.
- Wrap the `ListView` inside a `DelegateModel` in `TaskListView.qml`.

**Why `DelegateModel`?** While not strictly required for simple display,
`DelegateModel` provides critical benefits:

1. **Item pooling & recycling:** `DelegateModel` manages the creation and
   reuse of delegate instances, improving performance in large lists.
2. **Visual state separation:** It maintains an intermediate *visual model*
   between the data model and the `ListView`, allowing us to move items
   visually and animate them *before* committing changes to the underlying
   data.
3. **Explicit move semantics:** The `move()` method lets us reorder visual items
   in real time during drag operations, essential for the "live preview"
   effect we'll add in later steps.

This step sets up the structural foundation so that upcoming drag-and-drop
features can be added cleanly to the delegate.
