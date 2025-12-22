

import 'package:flutter/material.dart';
import 'package:keke/screens/splash_screen.dart';

void main() {
  runApp(const RideApp());
}

class RideApp extends StatelessWidget {
  const RideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RideApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFBF5102),
      ),
      home: const SplashScreen(),
    );
  }
}
