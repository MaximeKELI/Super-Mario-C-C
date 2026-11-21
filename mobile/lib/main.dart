import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/secure_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Never leak internals in release crash logs to the UI.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (!kReleaseMode) {
      debugPrint(details.toString());
    }
  };

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Warm Keystore-backed integrity key before any save/load.
  try {
    await SecureStore.warmup();
  } catch (e, st) {
    if (!kReleaseMode) {
      debugPrint('SecureStore.warmup failed: $e\n$st');
    }
  }

  runApp(const PipeLeapApp());
}
