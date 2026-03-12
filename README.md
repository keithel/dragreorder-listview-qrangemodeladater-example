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

## Step 3 — Modular delegate with DelegateModel

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

---

## Step 4 — Add a drag handle visual + mouse hold feedback

**What's here:** Preparation for drag interaction with visual feedback

- Add a drag handle Rectangle with drag glyph (☰) on the left side of each task
  item to serve as the drag handle, visually indicating to the user that this
  region is the hotspot for dragging the item.
- Add a PointHandler to the drag handle to capture touch and mouse events.
- Add a Qt Quick State that changes the item's color when the dragArea is
  active, providing visual feedback.
- Disable ListView interactivity when the dragArea is active.

This shows the delegate structure we'll build upon, with the handle separated
from the task content, and the foundation for recognizing drag gestures.

---

## Step 5 — Drag/Drop mechanism with item movement

**What's here:** full drag-and-drop interaction enabling item reordering.

### TaskDelegate changes:
- Enable `target` on the `DragHandler` to allow Y-axis dragging.
- Store the initial Y position in `heldY` to track the drag origin.
- Reparent `content` to the window's root when held, using `ParentChange` in the
  state, so the item renders above the list during drag.
- Add `Drag` properties (`Drag.active`, `Drag.source`, `Drag.keys`) to
  advertise the drag source.
- Add a `DropArea` that receives drop events and emits `moveItem` signal to
  communicate the reorder request.

### TaskListView changes:
- Expose `visualIndex` from `DelegateModel.itemsIndex` so each delegate knows
  its current visual position.
- Add moveRequested signal to the ListView and the root item
- Create TaskDelegate `onMoveItem` handler to:
  - Call `visualModel.items.move()` which rearranges the items in the
    `DelegateModel` visual model.
  - Emit ListView's moveRequested signal. The latter is just to allow us to
    dump the content of the backend model when a move occurs.
- Create ListView `onMoveRequested` handler, and emit `TaskListView` root item's
  `moveRequested` signal.

### Main.qml
- Create `onMoveRequested` handler and call `backend.dumpModel()` to dump the
  contents of the backend model.


At this point, dragging a handle visually moves the item in the list immediately,
but the backend data model is not yet updated. The visual reordering follows the
drag, creating an immediate but temporary effect.

---

## Step 6 — Commit drop to the C++ model

**What's here:** wiring the drag-and-drop result back to the C++ data layer,
and registering `TaskItem` properties as named model roles.

### New: TaskItem
Introduces `TaskItem`, a `QObject` subclass with a `description` `Q_PROPERTY`.
This replaces the plain `QStringList` used in earlier steps. Each task is now
a heap-allocated `TaskItem*` owned by the backend.

A `QRangeModel::RowOptions` specialization is added to declare `TaskItem` as
a `MultiRoleItem`. This tells `QRangeModel` to introspect the `QObject`'s
`Q_PROPERTY` list and register each one as a named model role, so QML can access
`description` (and any future properties) by name rather than through a numeric
role index:

```cpp
template<> struct QRangeModel::RowOptions<TaskItem>
{
    static constexpr auto rowCategory = QRangeModel::RowCategory::MultiRoleItem;
};
```

### TaskBackend changes:
- Replace `QRangeModel` + `QStringList` with
  `QRangeModelAdapter<std::vector<TaskItem*>>`. `QRangeModelAdapter` wraps any
  STL-compatible container and exposes the `Q_PROPERTY` values of the pointed-to
  objects as model roles — including `description`.
- Add `Q_INVOKABLE moveTask(int from, int to)` which calls
  `m_adapter.moveRows()` to physically reorder elements in the vector.

### TaskListView changes:
- Remove explicit creation of required display property bound to modelData,
  as QRangeModelAdapter exposes the TaskItem property names automatically.

### Main.qml changes:
- Connect `onMoveRequested` to `backend.moveTask(from, to)` so the drop is
  committed to the underlying data. Right now this occurs as the item is dragged
  through the list.

After this step, the application is fully functional: items dragged in the
list are reordered both visually and in the C++ model.

---

## Step 7 — Commit-on-release

**What's here:** This introduces commit of the item move after it is dragged
through the list. The item being dragged through the list updates the visual
model without updating the underlying backend model.

DelegateModel move calls are used to show the item moves and where it will be
committed to. When the user releases drag, then the change is committed to the
underlying model.

### The problem this solves

In the last step, `moveRequested` was emitted on every `DropArea.onEntered`
event, so the C++ model was updated many times during a single drag. This is not
optimal performance wise, especially if there is complex logic that occurs in
the backend when the model changes (not in this case, but there might be in some
real-world scenarios).

### TaskListView changes:
- Replace `moveRequested` with `commitMove` — emitted once, when dragging ends.
- Track `dragSourceIndex` (set at drag start) and `dragTargetIndex` (updated on
  each visual move). The `onDraggingItemChanged` handler fires `commitMove` only
  when `draggingItem` becomes `false` (i.e. on release).
- `dragDropKey`: a unique ID generated per `ListView` instance so `Drag.keys`
  and `DropArea.keys` match only within the same list, preventing conflicts in
  multi-list layouts.

### TaskDelegate changes:
- `startMove()` signal lets the `ListView` record `dragSourceIndex` at the
  moment the drag begins.
- Optional chaining (`?.`) on `Window` properties for safer access.

### TaskBackend changes:
- Switches from `moveRows(from, 1, to)` to `moveRow(from, to)`.

---

## Step 8 — Drag cancellation via Escape key (this commit)

**What's here:** Allow the user to cancel an in-progress drag by pressing <ESC>,
restoring the list to its pre-drag order.

### How it works

Each visual move during a drag is recorded in `dragMoves` (an array of
`{from, to}` pairs). When Escape is pressed, the list replays those moves in
reverse via `visualModel.items.move()`, restoring items to their original
positions without touching the backend model.

### TaskListView changes:
- `Keys.onReleased` detects `Qt.Key_Escape` while `draggingItem` is true.
- Sets `dragCanceled = true` and replays `dragMoves` in reverse to undo the
  visual reorder.
- Resets drag state (`draggingItem = false`, clears indices and move list).
- `onStartMove` now initialises `dragMoves = []` at drag start.
- `onMoveItem` appends each `{from, to}` pair to `dragMoves`.
- `onDraggingItemChanged` checks `dragCanceled` and skips `commitMove` when
  the drag was cancelled.

### TaskDelegate changes:
- Delegate now gates DropArea events on whether view.draggingItem is set to
  prevent any aborted drags when cancel is performed (<ESC> is pressed).
