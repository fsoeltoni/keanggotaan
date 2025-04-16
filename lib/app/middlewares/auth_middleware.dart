import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keanggotaan/app/routes/app_pages.dart';
import 'package:keanggotaan/app/services/auth_service.dart';
import 'package:keanggotaan/app/services/logger_service.dart';

class AuthMiddleware extends GetMiddleware {
  late final AuthService _authService;
  late final LoggerService _logger;

  AuthMiddleware() {
    _logger = Get.put(LoggerService());
    // Ensure we use the existing AuthService instance rather than creating a new one
    _authService = Get.put(AuthService());
    _logger.d('AuthMiddleware: Initialized');
  }

  @override
  RouteSettings? redirect(String? route) {
    _logger.d('AuthMiddleware: Checking route redirect for "$route"');

    final isAuth = _authService.isAuthenticated();
    _logger.d('AuthMiddleware: User authentication status - $isAuth');

    if (isAuth && (route == Routes.SIGN_IN || route == '/')) {
      _logger.i(
        'AuthMiddleware: Authenticated user trying to access login page, redirecting to ${Routes.VERIFICATION}',
      );
      return const RouteSettings(name: Routes.VERIFICATION);
    }

    if (!isAuth && route != Routes.SIGN_IN && route != Routes.OTP) {
      _logger.i(
        'AuthMiddleware: Unauthenticated user trying to access protected route "$route", redirecting to ${Routes.SIGN_IN}',
      );
      return const RouteSettings(name: Routes.SIGN_IN);
    }

    _logger.d('AuthMiddleware: No redirection needed for route "$route"');
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    _logger.d('AuthMiddleware: Page called: ${page?.name}');
    return super.onPageCalled(page);
  }

  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    _logger.d('AuthMiddleware: Bindings started for route');
    return super.onBindingsStart(bindings);
  }

  @override
  Widget onPageBuilt(Widget page) {
    _logger.d('AuthMiddleware: Page built');
    return super.onPageBuilt(page);
  }

  @override
  void onPageDispose() {
    _logger.d('AuthMiddleware: Page disposed');
    super.onPageDispose();
  }

  @override
  int? get priority => 1;
}
