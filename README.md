# multiple_windows

A reference application demonstrating Flutter's experimental multi-window API,
with Linux GTK3 and GTK4 runners and a focused native popup demonstration.

The demo was extracted from Flutter's `examples/multiple_windows` directory to
make it easier to build, run, and share independently of the full Flutter engine
checkout. It uses a pinned Flutter SDK and matching precompiled engines, so
trying the demo does not require compiling the engine. The subtree history lets
us continue bringing in upstream example changes without carrying the full
Flutter repository here.

## Syncing From Flutter

This repository is a root-level subtree split of Flutter's
`examples/multiple_windows` directory. To bring in the latest version from the
engine checkout, run:

```sh
tools/sync_from_flutter_engine.sh
```

The upstream source path is `flutter/flutter:examples/multiple_windows`. Our
sync uses that same directory in the sibling `flutter-gtk4` checkout; the script
fetches its `origin/master` by default. This source sync is separate from the
GTK4 SDK and precompiled-engine versions used to run the extracted demo.

By default, the engine checkout is the sibling `flutter-gtk4` directory.
Tracked changes must be committed before syncing; unrelated generated files
can remain untracked. Run the script from any directory.

The script fetches Flutter's `master`, creates a fresh subtree split, and
fast-forwards local `main` to that upstream-only history. It then rebases the
checked-out feature branch's custom commits onto `main`. Set `ENGINE_REPO` to
use a different Flutter checkout, or pass another engine ref as the first
argument:

```sh
ENGINE_REPO=/path/to/flutter tools/sync_from_flutter_engine.sh master
```

Only `examples/multiple_windows` is imported, with its contents mapped to this
repository's root. The script fetches the split commit into this repository
before updating `main` and prints the source Flutter revision. Keep all
repository-specific changes on feature branches; `main` contains only the
upstream subtree. The script refuses to replace a divergent upstream branch.
Set `UPSTREAM_BRANCH=master` if this repository uses `master` instead of `main`.

Rebasing changes feature commit IDs and may require conflict resolution. Use
`git rebase --continue` after resolving conflicts, or `git rebase --abort` to
restore the feature branch (`main` stays updated). The script does not push
branches; coordinate before replacing a previously published feature branch.

`ENGINE_REMOTE` selects the remote in the Flutter checkout (default: `origin`).
Syncing imports example source from the fetched ref, not uncommitted Flutter
changes, and does not update this project's `.fvmrc` or precompiled-engine pin.

## Running

The project pins the public [Flutter GTK4 fork](https://github.com/richyo-codes/flutter)
in `.fvmrc`. SDK downloads and precompiled debug, profile, and release engines
use the same public artifact source as pcalc. No engine compilation is needed.

`tools/flutter_env.sh` exports `FLUTTER_PREBUILT_ENGINE_VERSION` as
`cfd38c9e1e8de9965d24ad412cf70550ec3310f3` and `FLUTTER_STORAGE_BASE_URL` as
`https://pub-79a02b1963fb4da6b5e4e4816e8b7146.r2.dev` for both installation and
builds. Engine archives live under `flutter_infra_release/flutter/<artifact ID>`.
The pinned SDK requests the published fonts archive at
`flutter_infra_release/flutter/fonts/3012db47f3130e62f7cc0beabff968a33cbec8d8/fonts.zip`.

On Linux x86_64, install Dart, FVM, Python 3, curl, unzip, binutils, Clang,
CMake, Ninja, pkg-config, GTK3/GTK4 development packages, and mimalloc development
headers (see [the CI workflow](.github/workflows/linux-build.yml) for Ubuntu
package names), then run from the repository root:

```sh
dart pub global activate fvm 4.3.1
export PATH="$HOME/.pub-cache/bin:$PATH"
bash tools/setup_flutter.sh
tools/flutter.sh run -d linux --linux-gtk=gtk4
```

`tools/flutter.sh` invokes `fvm flutter` with the matching engine version.
For direct FVM commands, load that environment first:

```sh
source tools/flutter_env.sh
fvm flutter run -d linux --linux-gtk=gtk4
```

Keep this environment when launching an IDE too; its Flutter SDK is the
project-relative `.fvm/flutter_sdk`. FVM's SDK symlink and generated metadata
are ignored by Git. Setup leaves existing editor settings alone.

`pubspec.yaml` requests GTK4, but this published SDK predates the tool fix
that honors that default. Keep `--linux-gtk=gtk4` explicit for now. Use
`--linux-gtk=gtk3` for comparison. The published engine's source includes the
parent-resize and popup-shrinking fixes described in [the evidence](tools/GTK4_POPUPS.md).
This setup does not apply local patches.
The SDK may report `Failed to find the latest git commit date` for the engine
artifact revision; local debug and release builds still complete.

The default `lib/main.dart` entry point is the complete upstream example.
Run the focused popup reproduction or compare GTK3 with:

```sh
tools/flutter.sh run -d linux --linux-gtk=gtk4 -t examples/popup/main.dart
tools/flutter.sh run -d linux --linux-gtk=gtk3 -t examples/popup/main.dart
```

The separate native header-bar experiment is [deferred](tools/GTK4_HEADER_BAR.md).

## Popup portability demonstration

The focused entry point reuses the upstream example's `PopupWindowController`,
animated content sizing, and editable field. Two anchors exercise placement
in different parts of the parent window. See [the evidence and remaining
limitations](tools/GTK4_POPUPS.md) before presenting it as a completed backend.

GTK4 hosts these popups in `GtkPopover`, which implements a native popup
surface without being a `GtkWindow`. Keep native registration and capability
APIs flexible enough to represent that distinction. GTK owns constrained
placement; the current backend does not report the final adjusted offset in
the same way as GTK3's `moved-to-rect` signal.

To check the interaction, open **Show Popup**, watch its animated size, click
outside to dismiss it, and reopen it several times. Repeat with the second
anchor. The parent window should retain its size while the popup grows and
shrinks. A successful build or app launch alone does not validate these
interactions; keyboard input and focus still need investigation.

Local validation bundles described in [the evidence](tools/GTK4_POPUPS.md)
include the parent-resize and popup-shrinking fixes. They are generated artifacts;
the current published engine's source also includes those fixes. Rebuilding with
the pinned SDK replaces local validation bundles with the published engine.

## Building locally

After setup, build the complete application in either variant:

```sh
tools/flutter.sh build linux --release --linux-gtk=gtk4 -t lib/main.dart
tools/flutter.sh build linux --release --linux-gtk=gtk3 -t lib/main.dart
```

Use `-t examples/popup/main.dart` to build the focused demo instead. These commands
use the published SDK and engine pins; they do not compile a local Flutter engine.

## Downloadable builds

The Linux build workflow runs on branch pushes, pull requests, and manual
dispatch. Independent GTK4 and GTK3 jobs check that `examples/popup/main.dart` builds,
then build the full `lib/main.dart` application in release mode for upload.
The downloadable `.tar.gz` bundles include checksums and `BUILD_INFO.txt`. GTK4
failure does not cancel GTK3, or vice versa. Extract the entire archive and
run `./multiple_windows`; keep its `lib` and `data` directories alongside it.

The runner is Ubuntu 24.04 x64; bundles require compatible system GTK and
runtime libraries and are not universal Linux packages. SDK and engine pins
are recorded in `.fvmrc` and `tools/flutter_env.sh`, following the prebuilt
engine approach used by the public pcalc project. Both variants use the same
custom SDK so their experimental Dart windowing API matches.

The published engine `cfd38c9e1e8de9965d24ad412cf70550ec3310f3` was built from
Flutter commit `a916555c8d7ff9b1368363179db45ce912e65e71`, also pinned in `.fvmrc`.
Its source includes the popup resizing fixes. Rerun the native popup regression
against this published engine before promoting its GTK4 bundle; the earlier
local validation does not establish the behavior of these newly published binaries.

A separate workflow builds and publishes both bundles and their SHA-256
checksums as a GitHub release whenever a `v*` tag is pushed. The tag supplies the
artifact version, and publishing requires both GTK builds and checksum checks
to pass. Ordinary branch and pull-request CI only uploads Actions artifacts.
No release is published by running the local scripts.
