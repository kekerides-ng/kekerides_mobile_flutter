import 'package:keke/app_config.dart';
import 'package:keke/main.dart';

void main() async {
  AppConfig.set(AppConfig(
    role: AppRole.driver,
    appName: 'Keke Driver',
  ));

  await initApp();
}
