import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gts_01/app/app_debug.dart';
import 'package:gts_01/app/time_app.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const bool enableAppDebug = true;
  const bool enablePreferences = true;
  AppDebug.configure(enabled: enableAppDebug);
  await _maximizeWindow();
  runApp(TimeApp(enablePreferences: enablePreferences));
}

Future<void> _maximizeWindow() async {
  if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
    return;
  }
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    titleBarStyle: TitleBarStyle.normal,
    center: true,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.maximize();
    await windowManager.show();
    await windowManager.focus();
  });
}
