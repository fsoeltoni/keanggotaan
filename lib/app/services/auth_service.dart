import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:keanggotaan/app/services/logger_service.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final LoggerService _logger;

  // Observable user state
  final Rx<User?> _firebaseUser = Rx<User?>(null);

  // Getter untuk user saat ini
  User? get currentUser => _firebaseUser.value;

  // Getter untuk reactive stream user
  Stream<User?> get user => _firebaseUser.stream;

  // Status autentikasi
  RxBool isLoggedIn = false.obs;

  // Status verifikasi
  RxBool isVerificationInProgress = false.obs;
  RxString verificationId = ''.obs;
  RxBool isTimeout = false.obs;

  // Initialize method for GetX service pattern
  Future<AuthService> init() async {
    _logger = LoggerService.to;
    _logger.i('AuthService: Initializing');

    _firebaseUser.value = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      _firebaseUser.value = user;
      isLoggedIn.value = user != null;

      if (user != null) {
        _logger.i('AuthService: User signed in with ID: ${user.uid}');
        // Set user identifier for Crashlytics
        _logger.setUserIdentifier(user.uid);
      } else {
        _logger.i('AuthService: User signed out');
      }
    });

    return this;
  }

  @override
  void onInit() {
    super.onInit();
    _logger = LoggerService.to;
    _logger.d('AuthService: onInit called');
  }

  /// Validasi nomor telepon menggunakan regex
  bool isValidPhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^\+[1-9]\d{1,14}$');
    final isValid = regex.hasMatch(phoneNumber);

    _logger.d(
      'AuthService: Validating phone number: $phoneNumber, isValid: $isValid',
    );
    return isValid;
  }

  /// Memulai proses autentikasi menggunakan nomor telepon.
  Future<void> signInWithPhone(
    String phoneNumber, {
    Function(PhoneAuthCredential)? autoVerificationCompleted,
    Function(String, int?)? codeSent,
    Function(String)? verificationFailed,
    Function(String)? codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    _logger.i('AuthService: Starting phone authentication for $phoneNumber');

    if (!isValidPhoneNumber(phoneNumber)) {
      const errorMsg =
          'Nomor telepon tidak valid. Pastikan menggunakan format internasional.';
      _logger.w('AuthService: Invalid phone number format: $phoneNumber');

      if (verificationFailed != null) {
        verificationFailed(errorMsg);
      }
      return;
    }

    try {
      isVerificationInProgress.value = true;
      isTimeout.value = false;

      // Set custom key for tracking this authentication attempt
      _logger.setCustomKey('auth_phone_number', phoneNumber);
      _logger.setCustomKey('auth_timeout_seconds', timeout.inSeconds);

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          _logger.i('AuthService: Auto-verification triggered');

          try {
            await _auth.signInWithCredential(credential);
            isVerificationInProgress.value = false;
            _logger.i('AuthService: Auto-verification successful');

            if (autoVerificationCompleted != null) {
              autoVerificationCompleted(credential);
            }
          } catch (e, stack) {
            isVerificationInProgress.value = false;
            _logger.e('AuthService: Auto-verification failed', e, stack);

            if (verificationFailed != null) {
              verificationFailed('Auto-verification failed: ${e.toString()}');
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          isVerificationInProgress.value = false;
          String errorMessage = getFirebaseErrorMessage(e);

          _logger.e('AuthService: Verification failed', e, e.stackTrace);
          _logger.setCustomKey('auth_error_code', e.code);

          if (verificationFailed != null) {
            verificationFailed(errorMessage);
          }
        },
        codeSent: (String verId, int? resendToken) {
          _logger.i('AuthService: Verification code sent');
          _logger.setCustomKey('auth_verification_id', verId);
          _logger.setCustomKey(
            'auth_resend_token',
            resendToken?.toString() ?? 'null',
          );

          verificationId.value = verId;

          if (codeSent != null) {
            codeSent(verId, resendToken);
          }
        },
        codeAutoRetrievalTimeout: (String verId) {
          _logger.w('AuthService: Code auto-retrieval timeout occurred');
          _logger.setCustomKey('auth_timeout_occurred', true);

          verificationId.value = verId;
          isTimeout.value = true;
          isVerificationInProgress.value = false;

          if (codeAutoRetrievalTimeout != null) {
            codeAutoRetrievalTimeout(verId);
          }
        },
        timeout: timeout,
      );
    } catch (e, stack) {
      isVerificationInProgress.value = false;
      _logger.f(
        'AuthService: Unexpected exception during phone verification',
        e,
        stack,
      );

      if (verificationFailed != null) {
        verificationFailed('Unexpected error: ${e.toString()}');
      }
    }
  }

  /// Verifikasi OTP yang diterima pengguna
  Future<bool> verifyOTP(String otp) async {
    _logger.i('AuthService: Verifying OTP');
    _logger.setCustomKey('auth_verifying_otp', true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      isVerificationInProgress.value = false;

      bool success = userCredential.user != null;
      _logger.i(
        'AuthService: OTP verification ${success ? 'successful' : 'failed'}',
      );
      _logger.setCustomKey('auth_otp_verified', success);

      if (success && userCredential.user != null) {
        _logger.setUserIdentifier(userCredential.user!.uid);
      }

      return success;
    } catch (e, stack) {
      _logger.e('AuthService: Error verifying OTP', e, stack);
      _logger.setCustomKey('auth_otp_error', e.toString());
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _logger.i('AuthService: Signing out user');

    try {
      // Clear user identifier before sign out
      if (_auth.currentUser != null) {
        _logger.setUserIdentifier('');
      }

      await _auth.signOut();
      _logger.i('AuthService: User signed out successfully');
    } catch (e, stack) {
      _logger.e('AuthService: Error signing out', e, stack);
    }
  }

  /// Cek status autentikasi saat ini
  bool isAuthenticated() {
    bool authenticated = _auth.currentUser != null;
    _logger.d('AuthService: Checking authentication status: $authenticated');
    return authenticated;
  }

  /// Mengambil pesan error spesifik dari Firebase
  String getFirebaseErrorMessage(FirebaseAuthException e) {
    String errorMessage;

    switch (e.code) {
      case 'invalid-phone-number':
        errorMessage =
            'Nomor telepon tidak valid. Pastikan format nomor benar.';
        break;
      case 'too-many-requests':
        errorMessage = 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
        break;
      case 'quota-exceeded':
        errorMessage = 'Kuota SMS terlampaui. Silakan coba lagi nanti.';
        break;
      case 'invalid-verification-code':
        errorMessage = 'Kode OTP tidak valid. Silakan periksa dan coba lagi.';
        break;
      case 'session-expired':
        errorMessage =
            'Sesi verifikasi telah berakhir. Silakan minta kode baru.';
        break;
      default:
        errorMessage = e.message ?? 'Terjadi kesalahan';
    }

    _logger.w('AuthService: Firebase error: ${e.code} - $errorMessage');
    return errorMessage;
  }
}
