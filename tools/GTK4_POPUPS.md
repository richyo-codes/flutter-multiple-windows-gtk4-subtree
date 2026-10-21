# GTK4 popup portability evidence

## Reproduction

Build `examples/popup/main.dart` with experimental windowing enabled and the GTK4
engine. Open the upper **Show Popup** button. The popup contains an animated,
content-sized view and an editable field. Click outside it and reopen it;
also try the lower-right anchor.

The app uses the same `PopupWindowController` abstraction for GTK3 and GTK4.
It does not call GTK APIs or require the native popup handle to be a GtkWindow.
The backend's GTK4 host is a GtkPopover. A private Sway Wayland run recorded
`xdg_surface.get_popup`, confirming an actual native popup surface.

## Floating the parent under Sway

A tiling layout can override application size requests. To observe those
requests, add `include /path/to/flutter-multiple-windows/tools/sway-demo.conf`
to your Sway configuration and reload it with `swaymsg reload`, then reopen
the example. The rules match only the parent titles of the focused and full
examples; they do not force a size or change popup behavior.

For an already-open focused demo, run:

```sh
swaymsg '[title="^Native popup portability demo$"] floating enable'
```

For the full example:

```sh
swaymsg '[title="^Multi-Window Reference Application$"] floating enable'
```

The automated geometry test floats its parent in a private Sway session.
Floating makes the parent-resize defect visible; it is not a workaround for
popup sizing, animation, or input defects.

## Parent-resize defect found by this demo

Affected local engine source: `eb4303071049cfccbce41ec468e276b0e9361821`.
The original engine changes the parent window from 800×600 to dimensions of
the animated popup. Expected: only the popup changes size.

In `fl_view.cc`, the sized-to-content renderer updates the enclosing top-level
window through `fl_view_gtk4_get_toplevel_window`. For a popover's view this
finds the parent application's window. The narrow fix obtains the nearest
GtkNative and updates the window's default size only when that native is a
GtkWindow. GtkPopover content continues to use the render area's size request.

The fix and native regression driver are isolated on the Flutter branch
`fix/gtk4-popover-content-resize`. The main integration branch and published
engine archives are unchanged. This is a defect in the downstream GTK4
implementation, not evidence that GTK4 cannot support popup windows.

The driver `engine/src/flutter/shell/platform/linux/testing/run_gtk4_popup_test.py`
accepts the built demo binary, `--engine-dir`, and `--output`. It creates a
private headless Sway session, clicks the popup with a virtual pointer, checks
for a native popup protocol request, and compares parent geometry across
several animation cycles. The original engine failed (800×600 → 244×160);
the fixed engine passed (800×600 → 800×600). Its output includes protocol logs, JSON results,
and a screenshot. Supply the original and fixed engine directories separately
for the regression comparison.

## Validation limits

Local GTK3 and GTK4 release builds succeeded using the CI pins. The isolated
fix was compiled and linked with cached objects from the existing debug engine;
this was not a fresh full engine build. Headless Wayland testing exercised
popup opening, content resizing, outside-click dismissal, reopening, and the
second anchor. Virtual keyboard typing did not produce visible text in the popup during
the manual check; input delivery and focus need investigation. Accessibility,
X11, multiple monitors, and nested popups need separate validation. GitHub-hosted workflows have not run.

## API concern to raise upstream

Keep transient popup semantics distinct from top-level window semantics.
Requiring a GtkWindow pointer for every native controller would exclude this
working GtkPopover surface model. Native move/resize should also be mediated
by the embedder's input context rather than exposing GTK3-specific root
coordinates. A successful popup demonstration does not settle native ABI
versioning, capability queries, or final placement reporting.
