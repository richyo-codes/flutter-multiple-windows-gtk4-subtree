# Focused native popup example

This entry point uses the root project and its shared popup widgets. It is
not a separate Flutter package. Run from the repository root with the custom
GTK4 SDK and experimental windowing enabled:

```sh
tools/flutter.sh run -d linux --linux-gtk=gtk4 -t examples/popup/main.dart
```

Run `bash tools/setup_flutter.sh` first, as documented in the root README.
The same command without `-t` continues to launch the full
multi-window app in `lib/main.dart`. CI uploads the full app; this focused
entry point is also built as a compilation check.

See `tools/GTK4_POPUPS.md` for native regression evidence and known limitations.
