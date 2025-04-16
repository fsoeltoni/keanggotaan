import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class LoggerService extends GetxService {
  static LoggerService get to => Get.find<LoggerService>();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

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

      printInfo(info: 'Crashlytics service initialized');
    } else {
      await _crashlytics.setCrashlyticsCollectionEnabled(false);
      printInfo(info: 'Crashlytics disabled in debug mode');
    }

    return this;
  }

  // Method untuk log debug information
  void d(String message) {
    if (kDebugMode) {
      printInfo(info: '[DEBUG] $message');
    }
  }

  // Method untuk log informational messages
  void i(String message) {
    printInfo(info: '[INFO] $message');
  }

  // Method untuk log warning messages
  void w(String message) {
    // Menggunakan printInfo dengan format warning
    printInfo(info: '[WARNING] $message');
    // Record non-fatal warning to Crashlytics
    if (!kDebugMode) {
      _crashlytics.log('[WARNING] $message');
    }
  }

  // Method untuk log error messages
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    // Menggunakan printError dengan parameter bernama info
    printError(info: '[ERROR] $message');
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
    // Menggunakan printError dengan parameter bernama info
    printError(info: '[FATAL] $message');
    // Record fatal error to Crashlytics
    if (!kDebugMode) {
      _crashlytics.recordError(error, stackTrace, reason: message, fatal: true);
    }
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
