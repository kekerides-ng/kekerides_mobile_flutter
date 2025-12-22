import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage.dart';
import '../stores/auth_store.dart';


class TokenInterceptor extends Interceptor {
  final Ref ref;

  TokenInterceptor(this.ref);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Prefer the in-memory token from the AuthNotifier
      final tokenFromStore = ref.read(authNotifierProvider).token;
      final token = tokenFromStore ?? await SecureStorage.getToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // ignore any error reading token — continue without header
    }
    handler.next(options);
  }
}
