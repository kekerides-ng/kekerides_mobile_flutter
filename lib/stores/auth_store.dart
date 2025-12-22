// lib/stores/auth_store.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../services/secure_storage.dart';
import '../services/dio_provider.dart';
import '../services/preferences_service.dart';

final navigatorKeyProvider =
Provider<GlobalKey<NavigatorState>>((ref) => GlobalKey<NavigatorState>());

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? token;
  final String? errorMessage;
  final Map<String, dynamic>? user;
  final bool hasCheckedInitialAuth;
  final String? tempEmail; // Store email for OTP verification

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.token,
    this.errorMessage,
    this.user,
    this.hasCheckedInitialAuth = false,
    this.tempEmail,
  });

  factory AuthState.initial() => const AuthState();

  factory AuthState.loading() => const AuthState(isLoading: true);

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? token,
    String? errorMessage,
    Map<String, dynamic>? user,
    bool? hasCheckedInitialAuth,
    String? tempEmail,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      errorMessage: errorMessage,
      user: user ?? this.user,
      hasCheckedInitialAuth: hasCheckedInitialAuth ?? this.hasCheckedInitialAuth,
      tempEmail: tempEmail ?? this.tempEmail,
    );
  }
}

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState.initial()) {
    _init();
  }

  Dio _dio() => ref.read(dioProvider);

  /// Initialization: check if user is already logged in
  Future<void> _init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final token = await SecureStorage.getToken();

      if (token != null && token.isNotEmpty) {
        // Token exists, try to fetch user data
        state = state.copyWith(
          isLoading: true,
          token: token,
          isAuthenticated: false,
        );

        try {
          await _fetchUser();
        } catch (e) {
          // If fetching user fails, clear token
          print('Failed to fetch user: $e');
          await _performFullLogout();
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          token: null,
          user: null,
          hasCheckedInitialAuth: true,
        );
      }
    } catch (e) {
      print('AUTH INIT ERROR: $e');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        token: null,
        errorMessage: e.toString(),
        user: null,
        hasCheckedInitialAuth: true,
      );
    }
  }

  /// Helper to extract user id from response
  String? _extractUserId(Map<String, dynamic>? userMap) {
    if (userMap == null) return null;
    final candidates = ['id', 'user_id', '_id', 'uuid'];
    for (final k in candidates) {
      if (userMap.containsKey(k) && userMap[k] != null) {
        return userMap[k].toString();
      }
    }
    // Look inside nested 'data' or 'attributes' if present
    if (userMap['data'] is Map) {
      final nested = Map<String, dynamic>.from(userMap['data']);
      for (final k in candidates) {
        if (nested.containsKey(k) && nested[k] != null) {
          return nested[k].toString();
        }
      }
    }
    return null;
  }

  /// Fetch user data from API
  Future<void> _fetchUser() async {
    try {
      print('AUTH: Fetching user data...');
      final resp = await _dio().get('/user');
      final body = resp.data;

      Map<String, dynamic>? userMap;
      if (body is Map<String, dynamic>) {
        if (body['data'] is Map<String, dynamic>) {
          final data = body['data'] as Map<String, dynamic>;
          if (data['user'] is Map<String, dynamic>) {
            userMap = Map<String, dynamic>.from(data['user']);
          } else {
            userMap = Map<String, dynamic>.from(data);
          }
        } else if (body['user'] is Map<String, dynamic>) {
          userMap = Map<String, dynamic>.from(body['user']);
        } else {
          userMap = Map<String, dynamic>.from(body);
        }
      }

      print('AUTH: User fetched successfully');

      // Persist user id
      final extractedId = _extractUserId(userMap);
      if (extractedId != null && extractedId.isNotEmpty) {
        await SecureStorage.saveUserId(extractedId);
      }

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: userMap,
        hasCheckedInitialAuth: true,
      );

    } on DioException catch (e) {
      final status = e.response?.statusCode;
      print('AUTH: Fetch user failed with status $status: ${e.message}');

      if (status == 401) {
        await _performFullLogout();
        return;
      }

      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Failed to fetch user';
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: errorMessage,
        hasCheckedInitialAuth: true,
      );

    } catch (e) {
      print('AUTH: Unexpected error fetching user: $e');
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString(),
        hasCheckedInitialAuth: true,
      );
    }
  }

  /// Sign up with email, password, name, and phone
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? role, // passenger or driver
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final response = await _dio().post(
        '/auth/signup', // Adjust endpoint as needed
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role ?? 'passenger',
        },
      );

      final data = response.data;
      final token = data['data']?['token'] ?? data['token'];

      if (token != null && token.isNotEmpty) {
        await SecureStorage.saveToken(token);

        // Store email for OTP verification
        state = state.copyWith(
          isLoading: false,
          token: token,
          tempEmail: email,
          errorMessage: null,
        );

        return {
          'success': true,
          'message': 'Account created successfully. Please verify your email.',
          'data': data,
        };
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Token not received');
        return {
          'success': false,
          'message': 'Token not received from server',
        };
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Signup failed';
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final response = await _dio().post(
        '/auth/signin', // Adjust endpoint as needed
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      final token = data['data']?['token'] ?? data['token'];

      if (token != null && token.isNotEmpty) {
        await SecureStorage.saveToken(token);

        // Check if user needs OTP verification
        final needsVerification = data['data']?['needs_verification'] ?? false;

        if (needsVerification) {
          // Store email for OTP verification
          state = state.copyWith(
            isLoading: false,
            token: token,
            tempEmail: email,
            isAuthenticated: false,
            errorMessage: null,
          );

          return {
            'success': true,
            'needs_verification': true,
            'message': 'Please verify your OTP',
          };
        } else {
          // User is already verified, fetch full user data
          state = state.copyWith(
            isLoading: true,
            token: token,
            isAuthenticated: false,
          );

          await _fetchUser();

          return {
            'success': true,
            'needs_verification': false,
            'message': 'Login successful',
          };
        }
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Token not received');
        return {
          'success': false,
          'message': 'Token not received from server',
        };
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Login failed';
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
    String? email, // Optional, use stored email if not provided
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final verifyEmail = email ?? state.tempEmail;
      if (verifyEmail == null) {
        throw Exception('Email not found for OTP verification');
      }

      final response = await _dio().post(
        '/auth/verify-otp', // Adjust endpoint as needed
        data: {
          'email': verifyEmail,
          'otp': otp,
        },
      );

      final data = response.data;
      final token = data['data']?['token'] ?? data['token'];

      if (token != null && token.isNotEmpty) {
        await SecureStorage.saveToken(token);

        // Fetch user data after successful verification
        state = state.copyWith(
          isLoading: true,
          token: token,
          tempEmail: null, // Clear temp email
          isAuthenticated: false,
        );

        await _fetchUser();

        return {
          'success': true,
          'message': 'OTP verified successfully',
        };
      } else {
        // If no token returned but verification successful
        if (data['success'] == true || response.statusCode == 200) {
          // Try to fetch user with existing token
          final existingToken = state.token ?? await SecureStorage.getToken();
          if (existingToken != null) {
            state = state.copyWith(
              isLoading: true,
              token: existingToken,
              tempEmail: null,
              isAuthenticated: false,
            );
            await _fetchUser();
          }

          return {
            'success': true,
            'message': 'OTP verified successfully',
          };
        }

        state = state.copyWith(isLoading: false, errorMessage: 'Verification failed');
        return {
          'success': false,
          'message': 'Verification failed',
        };
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'OTP verification failed';
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOtp({
    String? email, // Optional, use stored email if not provided
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final resendEmail = email ?? state.tempEmail;
      if (resendEmail == null) {
        throw Exception('Email not found for OTP resend');
      }

      final response = await _dio().post(
        '/auth/resend-otp', // Adjust endpoint as needed
        data: {
          'email': resendEmail,
        },
      );

      state = state.copyWith(isLoading: false);

      return {
        'success': true,
        'message': 'OTP sent successfully',
      };
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Failed to resend OTP';
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Internal helper to perform complete logout cleanup
  Future<void> _performFullLogout() async {
    print('AUTH: Performing full logout');

    await SecureStorage.deleteToken();
    await SecureStorage.deleteUserId();
    await PreferencesService.clearAllData();

    state = AuthState.initial().copyWith(hasCheckedInitialAuth: true);
  }

  /// Public logout method
  Future<void> logout() async {
    await _performFullLogout();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Get current token
  String? get token => state.token;
}