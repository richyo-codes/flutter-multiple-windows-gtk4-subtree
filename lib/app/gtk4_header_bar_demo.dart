// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'package:flutter/src/widgets/_window.dart';
import 'package:flutter/src/widgets/_window_linux.dart';
import 'package:material_ui/material_ui.dart';

import 'window_content.dart';

void showGtk4HeaderBarDemo(BuildContext context) {
  final WindowRegistry registry = WindowRegistry.of(context);
  WindowEntry? entry;
  final WindowController controller = WindowController(
    title: 'GTK4 Native Header Bar',
    size: const Size(640, 420),
    delegate: CallbackWindowControllerDelegate(
      onDestroyed: () {
        if (entry != null) {
          registry.unregister(entry);
        }
      },
    ),
  );
  try {
    (controller as WindowControllerLinux).setGtk4HeaderBar();
  } catch (_) {
    controller.destroy();
    rethrow;
  }
  entry = WindowEntry(
    controller: controller,
    builder: (BuildContext context) =>
        MaterialApp(home: _HeaderBarContent(controller: controller)),
  );
  registry.register(entry);
}

class _HeaderBarContent extends StatefulWidget {
  const _HeaderBarContent({required this.controller});

  final WindowController controller;

  @override
  State<_HeaderBarContent> createState() => _HeaderBarContentState();
}

class _HeaderBarContentState extends State<_HeaderBarContent> {
  bool accentBorder = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final bool active = widget.controller.isActivated;
        final bool maximized = widget.controller.isMaximized;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: accentBorder && active
                  ? Colors.tealAccent
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: ListView(
                  children: [
                    Text(active ? 'Active window' : 'Inactive window'),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Accent border'),
                      value: accentBorder,
                      onChanged: (bool value) =>
                          setState(() => accentBorder = value),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: Icon(
                        maximized ? Icons.fullscreen_exit : Icons.fullscreen,
                      ),
                      label: Text(maximized ? 'Restore' : 'Maximize'),
                      onPressed: () =>
                          widget.controller.setMaximized(!maximized),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Window title',
                      ),
                      onChanged: widget.controller.setTitle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
