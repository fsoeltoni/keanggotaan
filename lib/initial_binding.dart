import 'package:get/get.dart';
import 'package:keanggotaan/app/services/auth_service.dart';
import 'package:keanggotaan/app/services/logger_service.dart';
import 'package:keanggotaan/app/services/reference_data_service.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Logger Service - diinisialisasi pertama
    Get.putAsync<LoggerService>(
      () => LoggerService().init(),
      permanent: true,
    ).then((logger) {
      logger.i('Logger service initialized successfully');

      // Reference Data Service - inisialisasi setelah Logger
      Get.putAsync<ReferenceDataService>(() async {
        logger.i('Starting ReferenceDataService initialization');
        final referenceDataService = ReferenceDataService();
        final service = await referenceDataService.init();
        logger.i('ReferenceDataService initialized successfully');
        return service;
      }, permanent: true);

      // Auth Service - inisialisasi setelah Logger
      Get.putAsync<AuthService>(() async {
        logger.i('Starting AuthService initialization');
        final authService = AuthService();
        final service = await authService.init();
        logger.i('AuthService initialized successfully');
        return service;
      }, permanent: true);
    });
  }
}
