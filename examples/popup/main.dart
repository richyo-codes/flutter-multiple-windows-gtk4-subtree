// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/_window.dart';
import 'package:material_ui/material_ui.dart';

import 'package:multiple_windows/app/models.dart';
import 'package:multiple_windows/app/popup_button.dart';

/// A focused native popup example, independent of the header-bar extension.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runWidget(const PopupDemo());
}

class PopupDemo extends StatefulWidget {
  const PopupDemo({super.key});

  @override
  State<PopupDemo> createState() => _PopupDemoState();
}

class _PopupDemoState extends State<PopupDemo> {
  final WindowController controller = WindowController(
    size: const Size(800, 600),
    title: 'Native popup portability demo',
    delegate: _MainWindowDelegate(),
  );
  final WindowSettings settings = WindowSettings();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WindowSettingsAccessor(
      windowSettings: settings,
      child: WindowManager(
        initialWindows: [
          WindowEntry(
            controller: controller,
            builder: (context) => MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Native popup portability')),
                body: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Open the popup, type in its field, then click outside '
                        'and reopen it. Its animated size exercises native '
                        'surface resizing.',
                      ),
                      const SizedBox(height: 24),
                      PopupButton(parentController: controller),
                      const Spacer(),
                      const Text(
                        'The same PopupWindowController API runs on GTK3 and '
                        'GTK4. GTK4 hosts the popup in a GtkPopover, rather '
                        'than a GtkWindow.',
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: PopupButton(parentController: controller),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainWindowDelegate with WindowControllerDelegate {
  @override
  void onWindowDestroyed() {
    ServicesBinding.instance.exitApplication(AppExitType.required);
  }
}
