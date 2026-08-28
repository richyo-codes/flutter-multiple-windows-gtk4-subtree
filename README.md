# multiple_windows

A reference application demonstrating multi-window support for Flutter using a
rich semantics windowing API.

## Running

Enable experimental windowing once for this Flutter checkout:

```sh
../../bin/flutter config --enable-windowing
```

After building the local engine, run the default GTK3 runner from this
directory:

```sh
../../bin/flutter run -d linux \
  --local-engine=host_debug_unopt \
  --local-engine-host=host_debug_unopt \
  --local-engine-src-path=../../engine/src
```

To exercise the GTK4 runner with a locally built engine:

```sh
../../bin/flutter run -d linux \
  --linux-gtk=gtk4 \
  --local-engine=host_debug_unopt \
  --local-engine-host=host_debug_unopt \
  --local-engine-src-path=../../engine/src
```

Build the required local engine first from the repository root:

```sh
./engine/src/build.sh
```

The GTK4 path currently supports regular windows and dialog windows. Tooltip
and popup window controllers still use GTK3-only positioning APIs and are not
implemented for GTK4.
