import 'package:get/get.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:keanggotaan/app/services/auth_service.dart';
import 'package:keanggotaan/app/services/logger_service.dart';
import 'package:keanggotaan/app/routes/app_pages.dart';

class SignInController extends GetxController {
  late final LoggerService _logger;
  late final AuthService _authService;

  /// Initial phone number set to Indonesia with empty nsn
  final Rx<PhoneNumber?> phone = Rx<PhoneNumber?>(
    PhoneNumber(isoCode: IsoCode.ID, nsn: ''),
  );

  /// Loading state
  final RxBool isLoadingState = false.obs;
  RxBool get isLoading => isLoadingState;

  /// Error message for phone field
  final RxString phoneError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _logger = Get.find<LoggerService>();
    _authService = Get.find<AuthService>();
    _logger.i('SignInController: Initialized');
  }

  @override
  void onClose() {
    _logger.d('SignInController: Controller being closed');
    super.onClose();
  }

  /// Enable button if phone number is valid and not loading
  bool get isPhoneValid {
    final isValid =
        phone.value != null &&
        phone.value!.nsn.isNotEmpty &&
        phone.value!.isValid() &&
        phoneError.isEmpty;

    _logger.d('SignInController: Phone validation check - isValid: $isValid');
    return isValid;
  }

  bool get isValidAndNotLoading {
    final valid = isPhoneValid && !isLoading.value;
    _logger.d('SignInController: Button state check - enabled: $valid');
    return valid;
  }

  /// Validator for phone number
  String? phoneValidator(PhoneNumber? value) {
    // If we have a Firebase error, return that instead
    if (phoneError.isNotEmpty) {
      _logger.d(
        'SignInController: Using Firebase error for validation: ${phoneError.value}',
      );
      return phoneError.value;
    }

    if (value == null || value.nsn.isEmpty) {
      _logger.d('SignInController: Phone validation failed - empty number');
      return 'Nomor telepon tidak boleh kosong';
    }
    if (!value.isValid()) {
      _logger.d(
        'SignInController: Phone validation failed - invalid format for ${value.international}',
      );
      return 'Format nomor telepon tidak valid';
    }

    _logger.d(
      'SignInController: Phone validation passed for ${value.international}',
    );
    return null;
  }

  /// Update phone input and log
  void onPhoneChanged(PhoneNumber? value) {
    phone.value = value;
    // Clear any existing Firebase errors when the user changes the input
    phoneError.value = '';

    if (value != null) {
      _logger.d('SignInController: Phone changed to ${value.international}');
      // Set custom key for tracking
      _logger.setCustomKey('signin_phone_country', value.isoCode.name);
      _logger.setCustomKey('signin_phone_valid', value.isValid());
    } else {
      _logger.d('SignInController: Phone cleared');
    }
  }

  /// Send verification code to phone number
  Future<void> sendCode() async {
    if (!isPhoneValid) {
      _logger.w('SignInController: Attempted to send code with invalid phone');
      return;
    }

    final String number = phone.value!.international;
    _logger.i('SignInController: Initiating code send to $number');

    // Set custom keys for tracking
    _logger.setCustomKey('signin_attempt_phone', number);

    isLoadingState.value = true;
    // Clear any previous errors
    phoneError.value = '';

    try {
      await _authService.signInWithPhone(
        number,
        autoVerificationCompleted: (credential) {
          _logger.i('SignInController: Auto verification completed');
          _logger.setCustomKey('signin_auto_verified', true);
          isLoadingState.value = false;
          Get.offAllNamed(Routes.VERIFICATION);
        },
        verificationFailed: (errorMessage) {
          _logger.e(
            'SignInController: Verification failed with error: $errorMessage',
          );
          _logger.setCustomKey('signin_error', errorMessage);

          isLoadingState.value = false;
          // Set the error message to be displayed in the field
          phoneError.value = errorMessage;
        },
        codeSent: (String verificationId, int? resendToken) {
          _logger.i(
            'SignInController: Code sent successfully, navigating to OTP screen',
          );
          _logger.setCustomKey('signin_code_sent', true);
          _logger.setCustomKey('signin_has_resend_token', resendToken != null);

          isLoadingState.value = false;
          Get.toNamed(
            Routes.OTP,
            arguments: {'phoneNumber': phone.value!.international},
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _logger.w('SignInController: Auto-retrieval timeout occurred');
          _logger.setCustomKey('signin_timeout', true);

          isLoadingState.value = false;
        },
      );
    } catch (e, stack) {
      _logger.f(
        'SignInController: Unexpected error during code sending process',
        e,
        stack,
      );

      isLoadingState.value = false;
      // Set the error message to be displayed in the field
      phoneError.value = 'Failed to send verification code: ${e.toString()}';
    }
  }

  // Reset error state
  void resetError() {
    _logger.d('SignInController: Resetting error state');
    phoneError.value = '';
  }
}
