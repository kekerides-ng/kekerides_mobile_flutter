// lib/services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _userTypeKey = 'user_type';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Type (passenger/driver)
  static Future<void> saveUserType(String userType) async {
    await _prefs.setString(_userTypeKey, userType);
  }

  static String? getUserType() {
    return _prefs.getString(_userTypeKey);
  }

  static Future<void> clearUserType() async {
    await _prefs.remove(_userTypeKey);
  }

  // First Launch
  static Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await _prefs.setBool(_isFirstLaunchKey, isFirstLaunch);
  }

  static bool isFirstLaunch() {
    return _prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  // Onboarding
  static Future<void> setHasSeenOnboarding(bool hasSeen) async {
    await _prefs.setBool(_hasSeenOnboardingKey, hasSeen);
  }

  static bool hasSeenOnboarding() {
    return _prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  // User Info
  static Future<void> saveUserEmail(String email) async {
    await _prefs.setString(_userEmailKey, email);
  }

  static String? getUserEmail() {
    return _prefs.getString(_userEmailKey);
  }

  static Future<void> saveUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  static String? getUserName() {
    return _prefs.getString(_userNameKey);
  }

  static Future<void> saveUserPhone(String phone) async {
    await _prefs.setString(_userPhoneKey, phone);
  }

  static String? getUserPhone() {
    return _prefs.getString(_userPhoneKey);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await _prefs.clear();
  }

  // Clear user data only
  static Future<void> clearUserData() async {
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userPhoneKey);
    await _prefs.remove(_userTypeKey);
  }
}