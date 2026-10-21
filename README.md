# multiple_windows

A reference application demonstrating multi-window support for Flutter using a
rich semantics windowing API.

## Syncing From Flutter

This repository is a root-level subtree split of Flutter's
`examples/multiple_windows` directory. To bring in the latest version from the
engine checkout, run:

```sh
tool/sync_from_flutter_engine.sh
```

By default, the engine checkout is the sibling `flutter-gtk4` directory.
Tracked changes must be committed before syncing; unrelated generated files
can remain untracked. Run the script from any directory.

The script fetches `master`, creates a fresh subtree split, and merges it into
this repository while preserving the example's history. Set `ENGINE_REPO` to
use a different Flutter checkout, or pass another engine ref as the first
argument:

```sh
ENGINE_REPO=/path/to/flutter tool/sync_from_flutter_engine.sh master
```

## Running

Use a custom Flutter GTK4 checkout with matching engine artifacts. Flutter's
standard stable SDK does not supply this GTK4 implementation. The experimental
windowing flag must be enabled before building either variant:

```sh
FLUTTER_ROOT=/path/to/flutter-gtk4
"$FLUTTER_ROOT/bin/flutter" config --enable-windowing --enable-linux-desktop
"$FLUTTER_ROOT/bin/flutter" run -d linux --linux-gtk=gtk4 -t lib/main.dart
```

For a locally built debug engine, add its paths:

```sh
"$FLUTTER_ROOT/bin/flutter" run -d linux --linux-gtk=gtk4 \
  -t lib/main.dart \
  --local-engine=host_debug_unopt --local-engine-host=host_debug_unopt \
  --local-engine-src-path="$FLUTTER_ROOT/engine/src"
```

Change `--linux-gtk=gtk4` to `--linux-gtk=gtk3` for the comparison build.
The default `lib/main.dart` entry point is the complete upstream example.
Use `-t examples/popup/main.dart` for the focused popup reproduction. The separate native
header-bar experiment is [deferred](tool/GTK4_HEADER_BAR.md).

## Popup portability demonstration

The focused entry point reuses the upstream example's `PopupWindowController`,
animated content sizing, and editable field. Two anchors exercise placement
in different parts of the parent window. See [the evidence and remaining
limitations](tool/GTK4_POPUPS.md) before presenting it as a completed backend.

GTK4 hosts these popups in `GtkPopover`, which implements a native popup
surface without being a `GtkWindow`. Keep native registration and capability
APIs flexible enough to represent that distinction. GTK owns constrained
placement; the current backend does not report the final adjusted offset in
the same way as GTK3's `moved-to-rect` signal.

## Downloadable builds

The Linux build workflow runs on branch pushes, pull requests, and manual
dispatch. Independent GTK4 and GTK3 jobs check that `examples/popup/main.dart` builds,
then build the full `lib/main.dart` application in release mode for upload.
The downloadable `.tar.gz` bundles include checksums and `BUILD_INFO.txt`. GTK4
failure does not cancel GTK3, or vice versa. Extract the entire archive and
run `./multiple_windows`; keep its `lib` and `data` directories alongside it.

The runner is Ubuntu 24.04 x64; bundles require compatible system GTK and
runtime libraries and are not universal Linux packages. SDK and engine pins
are explicit in `.github/workflows/linux-build.yml`, following the prebuilt
engine approach used by the public pcalc project. Both variants use the same
custom SDK so their experimental Dart windowing API matches.

**The current published engine pin predates the popup parent-resize fix.**
Compilation and linkage checks pass, but this pin is not a fixed popup demo.
Update the SDK/engine pins together after publishing a matching fixed engine
and rerun the native popup regression before promoting its GTK4 bundle.

A separate workflow publishes both bundles as a GitHub prerelease when a
`v*` tag is pushed. Ordinary CI only uploads Actions artifacts. No release is
published by running the local scripts.
