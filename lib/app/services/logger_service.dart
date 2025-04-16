import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class LoggerService extends GetxService {
  static LoggerService get to => Get.find<LoggerService>();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Initialize logger immediately instead of using late
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? Level.trace : Level.warning,
  );

  Future<LoggerService> init() async {
    // Konfigurasi Crashlytics
    if (!kDebugMode) {
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Tangkap Flutter errors dan kirim ke Crashlytics
      FlutterError.onError = _crashlytics.recordFlutterError;

      // Tangkap errors yang tidak tertangani di zona Dart
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      _logger.i('Crashlytics service initialized');
    } else {
      await _crashlytics.setCrashlyticsCollectionEnabled(false);
      _logger.i('Crashlytics disabled in debug mode');
    }

    return this;
  }

  // Method untuk log debug information
  void d(String message) {
    _logger.d(message);
  }

  // Method untuk log informational messages
  void i(String message) {
    _logger.i(message);
  }

  // Method untuk log warning messages
  void w(String message) {
    _logger.w(message);
    // Record non-fatal warning to Crashlytics
    if (!kDebugMode) {
      _crashlytics.log('[WARNING] $message');
    }
  }

  // Method untuk log error messages
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // Record error to Crashlytics
    if (!kDebugMode) {
      if (error != null) {
        _crashlytics.recordError(
          error,
          stackTrace,
          reason: message,
          fatal: false,
        );
      } else {
        _crashlytics.log('[ERROR] $message');
      }
    }
  }

  // Method untuk log fatal error messages
  void f(String message, dynamic error, StackTrace stackTrace) {
    _logger.f(message, error: error, stackTrace: stackTrace);

    // Record fatal error to Crashlytics
    if (!kDebugMode) {
      _crashlytics.recordError(error, stackTrace, reason: message, fatal: true);
    }
  }

  // Method untuk log trace information (replacing verbose)
  void t(String message) {
    _logger.t(message);
  }

  // Set user identifier untuk tracking di Crashlytics
  void setUserIdentifier(String userId) {
    _crashlytics.setUserIdentifier(userId);
    d('User identifier set: $userId');
  }

  // Tambahkan custom key untuk membantu debugging
  void setCustomKey(String key, dynamic value) {
    _crashlytics.setCustomKey(key, value);
    d('Custom key set: $key = $value');
  }

  // Method untuk mengirim crash
  void forceCrash() {
    _crashlytics.crash();
  }
}
