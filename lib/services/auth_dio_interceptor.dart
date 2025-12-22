import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../stores/auth_store.dart';

class AuthDioInterceptor extends Interceptor {
  final Ref ref;
  final bool logoutOn401;
  bool _alreadyLoggingOut = false;

  AuthDioInterceptor(this.ref, {this.logoutOn401 = false});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;

    if (logoutOn401 && statusCode == 401 && !_alreadyLoggingOut) {
      _alreadyLoggingOut = true;
      try {
        ref.read(authNotifierProvider.notifier).logout();
      } catch (_) {
        // ignore
      }
    }

    super.onError(err, handler);
  }
}
