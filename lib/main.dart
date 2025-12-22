import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keke/screens/splash_screen.dart';
import 'package:keke/services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await PreferencesService.init();

  runApp(const Keke());
}

class Keke extends StatelessWidget {
  const Keke({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Keke',
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