import 'package:keke/app_config.dart';
import 'package:keke/main.dart';

void main() async {
  AppConfig.set(AppConfig(
    role: AppRole.passenger,
    appName: 'Keke Passenger',
  ));

  await initApp();
}
