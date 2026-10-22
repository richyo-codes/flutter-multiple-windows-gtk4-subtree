# Deferred GTK4 header-bar experiment

The header-bar demo is preserved on branch
`feat/gtk4-window-chrome-20260912`, commit `49013f8`.
It depends on the separate `WindowControllerLinux.setGtk4HeaderBar` and
`supportsGtk4HeaderBar` extensions, which are absent from the SDK used by the
popup portability demo. It is disabled here so both example entry points can
build without those extensions. Restore it in a separate feature branch when
that SDK work is ready.
