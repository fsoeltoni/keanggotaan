import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keanggotaan/app/services/auth_service.dart';
import 'package:keanggotaan/app/services/logger_service.dart';
import 'package:keanggotaan/app/routes/app_pages.dart';

class OtpController extends GetxController {
  late final LoggerService _logger;
  late final AuthService _authService;

  // Controllers
  final TextEditingController pinController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  // Variables
  final RxString otp = ''.obs;
  final RxBool canVerify = false.obs;
  final RxInt remainingTime = 60.obs;
  final RxBool canResend = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorText = ''.obs;
  final RxBool isTimeout = false.obs;
  final RxBool isLoadingState = false.obs;
  Timer? _timer;

  // Get the phone number from the previous screen
  String get phoneNumber {
    final args = Get.arguments;
    final phone =
        args != null && args['phoneNumber'] != null
            ? args['phoneNumber']
            : 'unknown';
    return phone;
  }

  // Loading state
  RxBool get isLoading => isLoadingState;

  @override
  void onInit() {
    super.onInit();
    _logger = Get.find<LoggerService>();
    _authService = Get.find<AuthService>();

    _logger.i('OtpController: Initialized for phone number $phoneNumber');
    _logger.setCustomKey('otp_phone_number', phoneNumber);

    startTimer();

    // Setup focus listener
    focusNode.addListener(() {
      onFocusChange();
    });

    // Listen to timeout state from auth service
    ever(_authService.isTimeout, (timeout) {
      if (timeout) {
        _logger.d(
          'OtpController: Received timeout notification from AuthService',
        );
        handleTimeout();
      }
    });
  }

  @override
  void onClose() {
    _logger.d('OtpController: Cleaning up resources');
    _timer?.cancel();
    pinController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  // Start countdown timer for resend button
  void startTimer() {
    _logger.d('OtpController: Starting countdown timer (60s)');

    canResend.value = false;
    remainingTime.value = 60;
    isTimeout.value = false;
    _logger.setCustomKey('otp_timer_active', true);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;

        // Log at specific intervals
        if (remainingTime.value % 10 == 0) {
          _logger.d('OtpController: Timer remaining: ${remainingTime.value}s');
        }
      } else {
        handleTimeout();
        timer.cancel();
      }
    });
  }

  // Handle timeout consistently
  void handleTimeout() {
    _logger.w('OtpController: Verification timeout occurred');
    _logger.setCustomKey('otp_timeout_occurred', true);

    canResend.value = true;
    isTimeout.value = true;

    // Clear input field on timeout
    pinController.clear();
    otp.value = '';
    canVerify.value = false;

    // Show timeout error message
    hasError.value = true;
    errorText.value = 'Waktu verifikasi habis. Silakan kirim ulang kode OTP.';
  }

  // OTP input handler
  void onOtpChanged(String value) {
    otp.value = value;
    canVerify.value = value.length == 6;

    // Clear error when user modifies the input
    if (hasError.value) {
      _logger.d('OtpController: Clearing error state on input change');
      hasError.value = false;
      errorText.value = '';
    }

    _logger.d(
      'OtpController: OTP input changed, length: ${value.length}, can verify: ${canVerify.value}',
    );
  }

  // Focus listener to clear errors when tapped
  void onFocusChange() {
    if (focusNode.hasFocus && hasError.value) {
      _logger.d('OtpController: Clearing error state on focus change');
      hasError.value = false;
      errorText.value = '';
    }
  }

  // Handle OTP completed - now automatically triggers verification
  void onOtpCompleted(String value) {
    _logger.i('OtpController: OTP input completed with 6 digits');

    otp.value = value;
    canVerify.value = true;
    _logger.setCustomKey('otp_entry_completed', true);

    // Auto-verify when complete
    verifyOtp();
  }

  // Resend OTP
  Future<void> resendOtp() async {
    if (!canResend.value) {
      _logger.w('OtpController: Attempted to resend OTP before timer expired');
      return;
    }

    _logger.i('OtpController: Initiating OTP resend to $phoneNumber');
    _logger.setCustomKey('otp_resend_attempt', true);

    // Clear any previous error
    hasError.value = false;
    errorText.value = '';

    // Clear the input field
    pinController.clear();
    otp.value = '';
    canVerify.value = false;

    isLoadingState.value = true;

    try {
      await _authService.signInWithPhone(
        phoneNumber,
        autoVerificationCompleted: (credential) {
          _logger.i('OtpController: Auto verification completed on resend');
          _logger.setCustomKey('otp_auto_verified_on_resend', true);

          isLoadingState.value = false;
          Get.offAllNamed(Routes.VERIFICATION);
        },
        verificationFailed: (errorMessage) {
          _logger.e(
            'OtpController: Verification failed on resend: $errorMessage',
          );
          _logger.setCustomKey('otp_resend_error', errorMessage);

          isLoadingState.value = false;
          hasError.value = true;
          errorText.value = errorMessage;
        },
        codeSent: (verificationId, resendToken) {
          _logger.i('OtpController: Code resent successfully');
          _logger.setCustomKey('otp_resend_success', true);
          _logger.setCustomKey('otp_has_resend_token', resendToken != null);

          isLoadingState.value = false;
          Get.snackbar('Berhasil', 'Kode verifikasi telah dikirim ulang');
          startTimer();
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _logger.w('OtpController: Auto-retrieval timeout on resend');
          isLoadingState.value = false;
          handleTimeout();
        },
      );
    } catch (e, stack) {
      _logger.f(
        'OtpController: Unexpected error resending verification code',
        e,
        stack,
      );

      isLoadingState.value = false;
      hasError.value = true;
      errorText.value = 'Gagal mengirim ulang kode verifikasi';
    }
  }

  // Verify OTP
  Future<void> verifyOtp() async {
    if (otp.value.length != 6) {
      _logger.w(
        'OtpController: Attempted verification with incomplete OTP (${otp.value.length} digits)',
      );
      hasError.value = true;
      errorText.value = 'Mohon masukkan 6 digit kode OTP';
      return;
    }

    _logger.i('OtpController: Initiating OTP verification');
    _logger.setCustomKey('otp_verification_attempt', true);
    isLoadingState.value = true;

    try {
      // Use the updated verifyOTP method
      bool success = await _authService.verifyOTP(otp.value);

      if (success) {
        _logger.i('OtpController: OTP verification successful');
        _logger.setCustomKey('otp_verification_success', true);

        // Cancel timer as it's no longer needed
        _timer?.cancel();

        isLoadingState.value = false;
        Get.offAllNamed(Routes.VERIFICATION);
      } else {
        _logger.w('OtpController: OTP verification failed - invalid code');
        _logger.setCustomKey('otp_verification_failed', true);

        isLoadingState.value = false;
        hasError.value = true;
        errorText.value = 'Kode OTP tidak valid';
      }
    } catch (e, stack) {
      _logger.e('OtpController: Error during OTP verification', e, stack);
      _logger.setCustomKey('otp_verification_error', e.toString());

      isLoadingState.value = false;
      hasError.value = true;
      errorText.value = 'Kode OTP tidak valid';
    }
  }
}
