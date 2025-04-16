import 'package:get/get.dart';
import 'package:keanggotaan/app/services/auth_service.dart';
import 'package:keanggotaan/app/services/logger_service.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.putAsync<LoggerService>(() => LoggerService().init(), permanent: true);

    Get.putAsync<AuthService>(() async {
      await Get.putAsync(() => LoggerService().init());

      final authService = AuthService();
      return await authService.init();
    }, permanent: true);
  }
}
