import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keke/app_config.dart';
import 'package:keke/screens/splash_screen.dart';
import 'package:keke/services/preferences_service.dart';

void main() async {
  // Default to passenger if run directly
  AppConfig.set(AppConfig(
    role: AppRole.passenger,
    appName: 'Keke Passenger',
  ));
  
  await initApp();
}

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await PreferencesService.init();

  runApp(const Keke());
}

class Keke extends StatelessWidget {
  const Keke({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;
    
    return ProviderScope(
      child: MaterialApp(
        title: config.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFBF5102),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFBF5102),
            primary: const Color(0xFFBF5102),
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
