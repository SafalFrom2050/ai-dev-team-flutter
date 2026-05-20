import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Returns true if the application is running inside a test environment.
bool get isTesting {
  if (kIsWeb) return false;
  try {
    return Platform.environment.containsKey('FLUTTER_TEST');
  } catch (_) {
    return false;
  }
}
