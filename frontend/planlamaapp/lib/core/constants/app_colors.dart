// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary       = Color(0xFF7C5CFC);
  static const Color secondary     = Color(0xFF4EA8DE);
  static const Color accent        = Color(0xFFFC5C7C);
  static const Color success       = Color(0xFF4ECB71);
  static const Color warning       = Color(0xFFFFC857);

  static const Color background    = Color(0xFF0F0F14);
  static const Color surface       = Color(0xFF1A1A24);
  static const Color surfaceVar    = Color(0xFF2A2A36);

  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xFF8A8A9A);
  static const Color textHint      = Color(0xFF3A3A4A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
