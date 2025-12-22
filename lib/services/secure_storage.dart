// lib/services/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = const FlutterSecureStorage();

  // Keys
  static const _tokenKey = 'token';
  static const _userIdKey = 'user_id';

  // TOKEN helpers
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // USER ID helpers (added)
  /// Save the currently authenticated user's id (as string)
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Read the stored user id (may be null if not set)
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Delete stored user id (call on logout)
  static Future<void> deleteUserId() async {
    await _storage.delete(key: _userIdKey);
  }
}
