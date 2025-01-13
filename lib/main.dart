import 'package:flutter/material.dart';
import 'package:looting/Screen/home_screen.dart';
import 'package:looting/Screen/login_screen.dart';
import 'package:looting/Screen/profile_screen.dart';
import 'package:looting/Screen/settings_screen.dart';
import 'package:looting/Screen/signup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/home': (context) => HomeScreen(),
        '/settings': (context) => SettingsScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
