import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'auth_dio_interceptor.dart';
import 'token_interceptor.dart';

final logoutOn401Provider = Provider<bool>((ref) => false);

final dioProvider = Provider<Dio>((ref) {
  final dio = ApiClient().dio;

  // Add token interceptor once
  final hasTokenInterceptor = dio.interceptors.any((i) => i is TokenInterceptor);
  if (!hasTokenInterceptor) {
    dio.interceptors.add(TokenInterceptor(ref));
  }

  // Add auth error interceptor once
  final hasAuthInterceptor = dio.interceptors.any((i) => i is AuthDioInterceptor);
  if (!hasAuthInterceptor) {
    final logoutOn401 = ref.read(logoutOn401Provider);
    dio.interceptors.add(AuthDioInterceptor(ref, logoutOn401: logoutOn401));
  }

  return dio;
});
