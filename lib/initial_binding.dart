import 'package:get/get.dart';
import 'package:keanggotaan/app/services/logger_service.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.putAsync<LoggerService>(() => LoggerService().init(), permanent: true);
  }
}
