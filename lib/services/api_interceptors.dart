// api_interceptors.dart

import 'package:dio/dio.dart';
import 'secure_storage.dart';

class ApiInterceptors extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // **Must** call handler.next(...) to continue the chain
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Optional: handle 401s, token refresh, etc.
    handler.next(err);
  }
}
