# Drag Cancellation

This document describes how to cancel drag-reorder operations in the ListView. It covers keyboard (ESC key) and multi-touch (second finger) cancellation methods.

## Overview

When a user initiates a drag operation (pressing and holding on the grab handle), the item can be reordered by dragging it to a new position. The drag operation can be cancelled in two ways:

1. **Keyboard (ESC key)** — For desktop environments with a physical keyboard
2. **Multi-touch (second finger press)** — For touch devices without a keyboard

When a drag is cancelled, all moves performed during that drag are reversed, and the item is returned to its original position.

## Keyboard Cancellation (ESC Key)

### How it works:
- While dragging an item, press the `Esc` key to cancel the drag operation immediately.
- All intermediate moves are reversed to restore the original order.
- The dragged item returns to its starting position.

### Implementation:

This is handled through the [Keys.onReleased handler](../TaskLib/TaskListView.qml#L52-L58) in `TaskListView.qml`, which calls the `cancelDrag()` function when the Esc key is released.

## Multi-Touch Cancellation (Second Finger Press)

This is useful on touch devices that may not have a physical keyboard or in situations where keyboard access is not available.

### How it works:

- While dragging an item with one finger, pressing a second finger anywhere on the screen cancels the drag operation. The drag is then cancelled immediately upon detection of the second touch point.
- All intermediate moves are reversed to restore the original order.
- The dragged item returns to its starting position.

### Implementation:

A [MultiPointTouchArea overlay](../TaskLib/TaskListView.qml#L108-L116) covers the entire list view. It is enabled only during active drag operations (`enabled: listView.draggingItem`). When a second touch point is detected (`onGestureStarted`), it calls `listView.cancelDrag()` and grabs the gesture to prevent further event propagation.

### Technical Details:

- The first finger (on the grab handle) is captured by the `MouseArea` within each delegate item.
- The `MultiPointTouchArea` only sees additional touch points beyond the first, so `minimumTouchPoints` is left at its default value of 1.
- Once `gesture.grab()` is called, the second touch event is consumed, preventing it from affecting other interactive elements.

## Implementation in TaskListView.qml

The shared [`cancelDrag()` function](../TaskLib/TaskListView.qml#L38-L50) encapsulates the cancellation logic:

1. Sets `dragCanceled = true` to signal that no commit should occur
2. Iterates through all tracked moves in reverse and restores the original order
3. Resets all drag-related state variables

Both cancellation mechanisms (keyboard and multi-touch) invoke this same function to ensure consistent behavior.

## Use Cases

- **Desktop:** User wants to cancel a reorder operation while following a keyboard workflow.
- **Touch Device:** User wants to cancel a drag by simply pressing with a second finger instead of hunting for an ESC key or back button.
- **Hybrid Devices:** Provides flexibility on devices that may have both touch and keyboard but the user prefers one method over the other.

## Future Enhancements

These cancellation mechanisms set the foundation for enabling drag-reorder on keyboard-less devices (e.g., mobile phones, tablets, kiosks). The multi-touch cancel allows for an intuitive, touch-native workflow without relying on system keys.