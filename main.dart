import 'package:flutter/material.dart';
import 'screens/logo_screen.dart'; // Your splash screen
import 'screens/login_screen.dart'; // Your login screen
import 'screens/spirometry_screen.dart'; // Your spirometry screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VenturiSpiro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LogoScreen(), // Start with the splash screen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/spirometry': (context) => const SpirometryScreen(),
      },
    );
  }
}
