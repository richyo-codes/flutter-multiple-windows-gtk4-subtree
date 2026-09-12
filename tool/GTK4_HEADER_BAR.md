# GTK4 Header Bar Demo

Build and run with the GTK4 Flutter checkout containing
`WindowControllerLinux.setGtk4HeaderBar`:

```sh
FLUTTER_ROOT=/path/to/flutter-gtk4
NO_PROXY=localhost,127.0.0.1,::1 no_proxy=localhost,127.0.0.1,::1 \
  "$FLUTTER_ROOT/bin/flutter" run -d linux --linux-gtk=gtk4 \
  --local-engine=host_debug_unopt --local-engine-host=host_debug_unopt \
  --local-engine-src-path="$FLUTTER_ROOT/engine/src"
```

Enable the experimental windowing feature with `flutter config
--enable-windowing` first. Select **GTK4 Header Bar** in the New Window panel.

The native GTK4 header bar follows the desktop button arrangement and window
title. It provides GTK's normal move, double-click, and window-menu behavior.
The accent border is drawn by Flutter inside the content area; it does not
change compositor-owned borders. Focus another window to check its inactive
appearance. Test maximize/restore, title edits, close, and repeated creation.

The header bar must be installed synchronously after controller creation,
before the window is realized. GTK3 does not expose this experimental helper;
the demo button is hidden there. GTK3 itself also supports native header bars.

This is not yet a Flutter-rendered titlebar or a cross-platform decoration API.
GTK's Rust bindings expose the same native header-bar and layout capabilities:
https://gtk-rs.org/gtk4-rs/stable/latest/docs/gtk4/struct.HeaderBar.html
