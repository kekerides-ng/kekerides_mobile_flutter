

import 'package:flutter/material.dart';
import 'package:keke/screens/splash_screen.dart';

void main() {
  runApp(const Keke());
}

class Keke extends StatelessWidget {
  const Keke({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keke',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFBF5102),
      ),
      home: const SplashScreen(),
    );
  }
}
