// lib/main.dart

import 'package:flutter/material.dart';
import 'package:qr_reader/presentation/screens/home_screen.dart';
import 'package:qr_reader/presentation/theme/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: clsColors.background,
        brightness: Brightness.dark,
        primaryColor: clsColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: clsColors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
