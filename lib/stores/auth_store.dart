// lib/stores/auth_store.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

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
      hasCheckedInitialAuth:
          hasCheckedInitialAuth ?? this.hasCheckedInitialAuth,
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
      final userDataJson = PreferencesService.getUserData();

      if (token != null && token.isNotEmpty) {
        Map<String, dynamic>? userMap;
        if (userDataJson != null) {
          try {
            userMap = json.decode(userDataJson) as Map<String, dynamic>;
          } catch (e) {
            print('Error decoding user data: $e');
          }
        }

        state = state.copyWith(
          isLoading: false,
          token: token,
          isAuthenticated: true,
          user: userMap,
          hasCheckedInitialAuth: true,
        );
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
    return userMap['id']?.toString() ?? userMap['_id']?.toString() ?? userMap['uuid']?.toString();
  }

  /// Sign up with email, password, name, and phone
  Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required bool acceptTerms,
    String? role,
  }) async {
    try {
      print('📡 SIGNUP REQUEST STARTED');
      print(
          '📤 Data: {firstName: $firstName, lastName: $lastName, email: $email, phone: $phone}');

      state = state.copyWith(isLoading: true, errorMessage: null);

      final response = await _dio().post(
        'auth/register',
        data: {
          'name': '$firstName $lastName',
          'email': email,
          'phone': phone,
          'password': password,
          'confirmPassword': confirmPassword,
          'acceptTerms': acceptTerms,
          'role': role ?? 'passenger',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'KekeApp/1.0',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        print('✅ Signup successful');

        final userMap = responseData['user'] as Map<String, dynamic>?;
        final token = responseData['token'] as String?;

        if (token != null) {
          await SecureStorage.saveToken(token);
        }

        if (userMap != null) {
          await PreferencesService.saveUserData(json.encode(userMap));
          final extractedId = _extractUserId(userMap);
          if (extractedId != null) {
            await SecureStorage.saveUserId(extractedId);
          }
        }

        state = state.copyWith(
          isLoading: false,
          tempEmail: email,
          token: token,
          user: userMap,
          isAuthenticated: token != null,
          errorMessage: null,
        );

        return {
          'success': true,
          'message': responseData['message'] ?? 'Account created successfully',
          'needs_verification': true,
        };
      } else {
        final responseData = response.data as Map<String, dynamic>;
        final errorMsg = responseData['data']?.toString() ??
            responseData['responseMessage']?.toString() ??
            'Registration failed with status ${response.statusCode}';

        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMsg,
        );

        return {
          'success': false,
          'message': errorMsg,
        };
      }
    } on DioException catch (e) {

      String errorMessage = 'Signup failed';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Server may be spinning up.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          
          if (errorData['message'] is List) {
            final messages = errorData['message'] as List;
            if (messages.isNotEmpty && messages[0] is Map) {
              // Handle NestJS style validation errors
              final firstError = messages[0] as Map;
              if (firstError['constraints'] is Map) {
                final constraints = firstError['constraints'] as Map;
                errorMessage = constraints.values.first.toString();
              }
            } else if (messages.isNotEmpty) {
              errorMessage = messages[0].toString();
            }
          } else {
            errorMessage = errorData['data']?.toString() ??
                errorData['message']?.toString() ??
                errorData['responseMessage']?.toString() ??
                errorMessage;
          }
        } catch (_) {
          errorMessage = e.response!.data.toString();
        }
      }

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

  /// Sign up as a driver
  Future<Map<String, dynamic>> signUpDriver({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String licenseNumber,
    required String licenseExpiry,
  }) async {
    try {
      print('📡 DRIVER SIGNUP REQUEST STARTED');
      state = state.copyWith(isLoading: true, errorMessage: null);

      final response = await _dio().post(
        'drivers/register',
        data: {
          'name': '$firstName $lastName',
          'email': email,
          'phone': phone,
          'password': password,
          'licenseNumber': licenseNumber,
          'licenseExpiry': licenseExpiry,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('📥 DRIVER SIGNUP RESPONSE STATUS: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        print('✅ Driver signup successful');

        final userMap = (responseData['user'] ?? responseData['driver']) as Map<String, dynamic>?;
        final token = responseData['token'] as String?;

        if (token != null) {
          await SecureStorage.saveToken(token);
        }

        if (userMap != null) {
          await PreferencesService.saveUserData(json.encode(userMap));
          final extractedId = _extractUserId(userMap);
          if (extractedId != null) {
            await SecureStorage.saveUserId(extractedId);
          }
        }

        state = state.copyWith(
          isLoading: false,
          tempEmail: email,
          token: token,
          user: userMap,
          isAuthenticated: token != null,
          errorMessage: null,
        );

        return {
          'success': true,
          'message': responseData['message'] ?? 'Driver account created successfully',
          'needs_verification': true,
        };
      } else {
        final responseData = response.data as Map<String, dynamic>;
        final errorMsg = responseData['data']?.toString() ??
            responseData['message']?.toString() ??
            responseData['responseMessage']?.toString() ??
            'Registration failed';

        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMsg,
        );

        return {
          'success': false,
          'message': errorMsg,
        };
      }
    } on DioException catch (e) {
      print('❌ DRIVER SIGNUP DIO ERROR: ${e.message}');
      String errorMessage = 'Driver signup failed';
      
      if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message']?.toString() ?? 
                         errorData['data']?.toString() ?? 
                         errorMessage;
        } catch (_) {}
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('❌ DRIVER SIGNUP ERROR: $e');
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
    String? role,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final endpoint = role == 'driver' ? 'drivers/login' : 'auth/login';

      final response = await _dio().post(
        endpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      final token = data['token'] ?? data['data']?['token'];
      final userMap = (data['user'] ?? data['driver'] ?? data['data']?['user']) as Map<String, dynamic>?;

      if (token != null && token.isNotEmpty) {
        await SecureStorage.saveToken(token);

        if (userMap != null) {
          await PreferencesService.saveUserData(json.encode(userMap));
          final extractedId = _extractUserId(userMap);
          if (extractedId != null) {
            await SecureStorage.saveUserId(extractedId);
          }
        }

        final needsVerification = data['needs_verification'] ?? data['data']?['needs_verification'] ?? false;

        if (needsVerification) {
          state = state.copyWith(
            isLoading: false,
            token: token,
            user: userMap,
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
          state = state.copyWith(
            isLoading: false,
            token: token,
            user: userMap,
            isAuthenticated: true,
          );

          return {
            'success': true,
            'needs_verification': false,
            'message': 'Login successful',
          };
        }
      } else {
        state =
            state.copyWith(isLoading: false, errorMessage: 'Token not received');
        return {
          'success': false,
          'message': 'Token not received from server',
        };
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Login failed';
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
    String? email,
  }) async {
    try {
      // Clear previous errors and set loading state
      state = state.copyWith(isLoading: true, errorMessage: null);

      final verifyEmail = email ?? state.tempEmail;
      if (verifyEmail == null) {
        throw Exception('Email not found for OTP verification');
      }

      final response = await _dio().post(
        'auth/verify-otp',
        data: {
          'email': verifyEmail,
          'otp': otp,
        },
      );

      final data = response.data;
      final token = data['token'] ?? data['data']?['token'];
      final userMap = (data['user'] ?? data['driver'] ?? data['data']?['user']) as Map<String, dynamic>?;

      if (token != null && token.isNotEmpty) {
        await SecureStorage.saveToken(token);

        if (userMap != null) {
          await PreferencesService.saveUserData(json.encode(userMap));
        }

        state = state.copyWith(
          isLoading: false,
          token: token,
          user: userMap,
          tempEmail: null,
          isAuthenticated: true,
        );

        return {
          'success': true,
          'message': 'OTP verified successfully',
        };
      } else {
        if (data['success'] == true || response.statusCode == 200) {
          final existingToken = state.token ?? await SecureStorage.getToken();
          
          state = state.copyWith(
            isLoading: false,
            token: existingToken,
            tempEmail: null,
            isAuthenticated: existingToken != null,
          );

          return {
            'success': true,
            'message': 'OTP verified successfully',
          };
        }
        final errorMessage = data['data']?.toString() ?? data['message']?.toString() ?? 'Verification failed';
        state = state.copyWith(isLoading: false, errorMessage: errorMessage);
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['data']?.toString() ??
          e.response?.data?['message'] ??
          e.message ??
          'OTP verification failed';
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
    String? email,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final resendEmail = email ?? state.tempEmail;
      if (resendEmail == null) {
        throw Exception('Email not found for OTP resend');
      }

      final response = await _dio().post(
        'auth/resend-otp',
        data: {
          'email': resendEmail,
        },
         options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      state = state.copyWith(isLoading: false);
      
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
         if (responseData['responseCode'] == '200' ||
            responseData['responseMessage']?.toLowerCase() == 'success') {
          return {
            'success': true,
            'message': responseData['data'] ?? 'OTP sent successfully',
          };
        } else {
           final errorMsg = responseData['data']?.toString() ??
              responseData['responseMessage']?.toString() ??
              'Failed to resend OTP';
          state = state.copyWith(errorMessage: errorMsg);
           return {
            'success': false,
            'message': errorMsg,
          };
        }
      } else {
        final responseData = response.data as Map<String, dynamic>;
        final errorMsg = responseData['data']?.toString() ??
            responseData['responseMessage']?.toString() ??
            'Failed to resend OTP with status ${response.statusCode}';
        state = state.copyWith(errorMessage: errorMsg);
        return {
          'success': false,
          'message': errorMsg,
        };
      }

    } on DioException catch (e) {
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Failed to resend OTP';
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

  /// Toggle online/offline status for drivers
  Future<void> toggleOnlineStatus() async {
    if (state.user == null) return;
    
    final oldUser = state.user!;
    final isOnline = oldUser['isOnline'] == true;
    final newStatus = !isOnline;
    
    // Optimistic update
    final updatedUser = Map<String, dynamic>.from(oldUser);
    updatedUser['isOnline'] = newStatus;
    state = state.copyWith(user: updatedUser, errorMessage: null);
    
    try {
      final userId = _extractUserId(oldUser);
      final endpoint = oldUser['role'] == 'driver' ? 'drivers/$userId/online-status' : 'users/status';
      await _dio().patch(endpoint, data: {'isOnline': newStatus});
      
      // Persist updated user data
      await PreferencesService.saveUserData(json.encode(updatedUser));
    } catch (e) {
      print('Error toggling online status: $e');
      
      String errorMsg = 'Failed to update status';
      if (e is DioException && e.response?.data != null) {
        try {
          final data = e.response!.data as Map<String, dynamic>;
          errorMsg = data['message']?.toString() ?? errorMsg;
        } catch (_) {}
      }

      // Revert on error
      state = state.copyWith(
        user: oldUser,
        errorMessage: errorMsg,
      );
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