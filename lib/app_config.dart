enum AppRole { passenger, driver }

class AppConfig {
  final AppRole role;
  final String appName;

  AppConfig({
    required this.role,
    required this.appName,
  });

  static AppConfig? _instance;

  static void set(AppConfig config) {
    _instance = config;
  }

  static AppConfig get instance {
    return _instance!;
  }

  bool get isPassenger => role == AppRole.passenger;
  bool get isDriver => role == AppRole.driver;
}
