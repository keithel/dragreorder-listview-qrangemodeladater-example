# Changelog

## 2026-03-18 — Keith Kyzivat

### Due dates, past-due highlighting, and done toggling

- Added `dueDate`, `pastDue`, and `done` properties to TaskItem.
- A `QTimer` fires every second to recompute `pastDue` by comparing `QDateTime::currentDateTime()`
  against `m_dueDate`, emitting `pastDueChanged` only when the value flips and the item is not
  already done.
- Sample data in TaskBackend extended with representative due dates -- some in the past (overdue),
  some due tomorrow, and some just seconds away -- to exercise the new states. A
  `QObject s_dataParent` is used as the lifetime owner for the static items.
  `AutoConnectPolicy::Full` is set on the range model so property-change signals propagate back to
  the model automatically.
- In TaskDelegate.qml, RowLayout is added to lay out the handle and task entry; background is now
  transparent. The task label gains `font.strikeout` (driven by `done`) and turns red when `pastDue`
  is true via a `State`/`PropertyChanges`. A `TapHandler` toggles `done` on right-click (desktop) or
  long-press (touch screen).
- In TaskListView.qml, Set `delegateModelAccess: DelegateModel.ReadWrite` so the delegate can write
  the `done` property back through the `DelegateModel` to the underlying `TaskItem`.

---

### Initial role-name and property-binding wiring

- `TaskItem` now specializes `QRangeModel::RowOptions` with `rowCategory = MultiRoleItem`,
  enabling the adapter to expose multiple named Qt model roles per row.
- Role names are built by iterating over the properties of `TaskItem::staticMetaObject`,
  exposed via a new static `TaskItem::roleNames()` method used by `TaskBackend`.
- `TaskDelegate.qml` binds to the typed `description` and `priority` properties directly,
  replacing the generic `display` role.
