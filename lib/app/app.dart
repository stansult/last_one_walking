// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../core/utils/app_visuals.dart';
import '../features/create_walk/create_walk_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFB5522D);
    return MaterialApp(
      title: 'Last One Walking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F2EC),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFF2A1B13),
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A1B13),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF3C2D24)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4A3D35)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppVisuals.numberFieldFillColor
              .withOpacity(AppVisuals.numberFieldFillOpacity),
          contentPadding: AppVisuals.numberFieldPadding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        useMaterial3: true,
      ),
      home: const CreateWalkScreen(),
    );
  }
}
