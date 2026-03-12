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

## Step 0 — Simple QML-only list

The bare minimum: a `ListView` with an inline `ListModel` defined entirely in
QML. No C++, no drag-and-drop. Establishes the two-module CMake layout.

---

## Step 1 — C++ backend with QRangeModel

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

## Step 2 — Modular delegate with DelegateModel

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

## Step 3 — Add drag handle visual

**What's here:** visual preparation for drag interaction.

- Add a `Rectangle` on the left side of each `TaskDelegate` to serve as the
  drag handle.
- Display a hamburger menu icon (☰) to visually indicate to the user that this
  region is for dragging.
- No interaction yet — purely visual setup.

This shows the delegate structure we'll build upon, with the handle separated
from the task content.

---

## Step 4 — Handle mouse press/release

**What's here:** basic mouse interaction and visual feedback.

- Add a `MouseArea` over the drag handle to capture mouse events.
- Introduce a `held` Property to track when the user has pressed down on the
  handle.
- Add a Qt Quick **State** that changes the item's color when `held` is true,
  providing visual feedback.
- Disable ListView interactivity when held.

This establishes the foundation for recognizing drag gestures. In the next step,
we'll add the actual dragging logic and Drag/Drop mechanism.

---

## Step 5 — Drag/Drop mechanism with item movement

**What's here:** full drag-and-drop interaction enabling item reordering.

### TaskDelegate changes:
- Enable `drag.target` on the `MouseArea` to allow Y-axis dragging.
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
- Connect delegate's `moveItem` signal to call `visualModel.items.move()`,
  which rearranges items in the visual model.

At this point, dragging a handle visually moves the item in the list immediately,
but the backend data model is not yet updated. The visual reordering follows the
drag, creating an immediate but temporary effect.

---

## Step 6 — Add animation to displaced items

**What's here:** smooth visual transitions when items are displaced during drag.

- Add a `displaced: Transition` to the `ListView` with a `NumberAnimation` that
  animates the `y` property over 200ms using an `OutQuad` easing curve.
- When an item is moved, other items that shift position are automatically
  animated to their new locations, rather than jumping instantly.

This creates a polished user experience where items smoothly "flow" around the
dragged item as it moves through the list. The application now has fully working
visual drag-and-drop reordering, with the list items rearranging visually and
staying in their new order once the drag is released.

**Note:** The backend C++ model is not yet synchronized with these visual changes.
In the next step, we'll add the code to update the underlying data model on drop.

---

## Step 7 — Commit drop to the C++ model

**What's here:** wiring the drag-and-drop result back to the C++ data layer,
and registering `TaskItem` properties as named model roles.

### New: `TaskItem`
Introduces `TaskItem`, a `QObject` subclass with a `description` Q_PROPERTY.
This replaces the plain `QStringList` used in earlier steps. Each task is now
a heap-allocated `TaskItem*` owned by a static s_dataParent that gets deleted
on app termination.

A `QRangeModel::RowOptions` specialization is added to declare `TaskItem` as
a `MultiRoleItem`. This tells `QRangeModel` to introspect the `QObject`'s
Q_PROPERTY list and register each one as a named model role, so QML can access
`description` (and any future properties) by name rather than through a numeric
role index:

```cpp
template<> struct QRangeModel::RowOptions<TaskItem>
{
    static constexpr auto rowCategory = QRangeModel::RowCategory::MultiRoleItem;
};
```

### `TaskBackend` changes:
- Replace `QRangeModel` + `QStringList` with
  `QRangeModelAdapter<std::vector<TaskItem*>>`. `QRangeModelAdapter` wraps any
  STL-compatible container and exposes the `Q_PROPERTY` values of the pointed-to
  objects as model roles — including `description`.
- Add `Q_INVOKABLE moveTask(int from, int to)` which calls
  `m_adapter.moveRows()` to physically reorder elements in the vector.

### `TaskListView` changes:
- Introduce `moveRequested` signals that are used to update the backend model.
- Connect the delegate's `onMoveItem` to both `visualModel.items.move()`
  (visual) and `ListView.view.moveRequested` (backend), and propagate it up to
  `root.moveRequested`.

### `Main.qml` changes:
- Connect `onMoveRequested` to `backend.moveTask(from, to)` so the drop is
  committed to the underlying data. Right now this occurs as the item is dragged
  through the list.

After this step, the application is fully functional: items dragged in the
list are reordered both visually and in the C++ model.

---

## Step 8 — Commit-on-release (this commit)

**What's here:** This introduces commit of the item move after it is dragged
through the list. The item being dragged through the list updates the visual
model without updating the underlying backend model.

Animations are used to show the item moves and where it will be committed to.
committed to. When the user releases drag, then the change is committed to the
underlying model.

### The problem this solves

In Step 7, `moveRequested` was emitted on every `DropArea.onEntered` event, so
the C++ model was updated many times during a single drag. This is not optimal
performance wise, especially if there is complex logic that occurs in the
backend when the model changes (not in this case, but there might be in some
real-world scenarios).

### Key changes

**`TaskListView` changes:**
- Replace `moveRequested` with `commitMove` — emitted once, when dragging ends.
- Track `dragSourceIndex` (set at drag start) and `dragTargetIndex` (updated on
  each visual move). The `onDraggingItemChanged` handler fires `commitMove` only
  when `draggingItem` becomes `false` (i.e. on release).
- `dragDropKey`: a unique ID generated per `ListView` instance so `Drag.keys`
  and `DropArea.keys` match only within the same list, preventing conflicts in
  multi-list layouts.
- `displaced` transition now uses `SequentialAnimation` to toggle an
  `itemsMoving` property: set to `false` at the start of the animation, and back
  to `true` at the end. This is used by the delegate to gate `DropArea` events.

**`TaskDelegate` changes:**
- `itemsMoving` property gates `DropArea.onEntered`: moves are only processed
  when items are not currently animating, preventing spurious reorders caused by
  animation displacement triggering the drop area.
- `startMove()` signal lets the `ListView` record `dragSourceIndex` at the
  moment the drag begins.
- Optional chaining (`?.`) on `Window` properties for safer access.

**`TaskBackend` changes:**
- Switches from `moveRows(from, 1, to)` to `moveRow(from, to)`.

---

## Step 9 — Drag cancellation via Escape key (this commit)

**What's here:** Allow the user to cancel an in-progress drag by pressing <ESC>,
restoring the list to its pre-drag order.

### How it works

Each visual move during a drag is recorded in `dragMoves` (an array of
`{from, to}` pairs). When Escape is pressed, the list replays those moves in
reverse via `visualModel.items.move()`, restoring items to their original
positions without touching the backend model.

### Key changes

**`TaskListView`:**
- `Keys.onReleased` detects `Qt.Key_Escape` while `draggingItem` is true.
- Sets `dragCanceled = true` and replays `dragMoves` in reverse to undo the
  visual reorder.
- Resets drag state (`draggingItem = false`, clears indices and move list).
- `onStartMove` now initialises `dragMoves = []` at drag start.
- `onMoveItem` appends each `{from, to}` pair to `dragMoves`.
- `onDraggingItemChanged` checks `dragCanceled` and skips `commitMove` when
  the drag was cancelled.
