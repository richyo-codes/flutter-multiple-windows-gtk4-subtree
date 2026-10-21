# Focused native popup example

This entry point uses the root project and its shared popup widgets. It is
not a separate Flutter package. Run from the repository root with the custom
GTK4 SDK and experimental windowing enabled:

```sh
flutter run -d linux --linux-gtk=gtk4 -t examples/popup/main.dart
```

For a locally built engine, add the same local-engine options documented in
the root README. `flutter run` without `-t` continues to launch the full
multi-window app in `lib/main.dart`. CI uploads the full app; this focused
entry point is also built as a compilation check.

See `tools/GTK4_POPUPS.md` for native regression evidence and known limitations.
