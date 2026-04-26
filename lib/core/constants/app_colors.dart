import 'package:flutter/material.dart';

/// Warna utama aplikasi Parking Finder
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF534BAE);
  static const Color primaryDark = Color(0xFF000051);

  // Accent / Secondary
  static const Color accent = Color(0xFFFFD600);
  static const Color accentLight = Color(0xFFFFFF52);
  static const Color accentDark = Color(0xFFC7A500);

  // Status colors
  static const Color statusKosong = Color(0xFF4CAF50);
  static const Color statusPenuh = Color(0xFFF44336);
  static const Color statusUnknown = Color(0xFF9E9E9E);

  // Background
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF212121);

  // Others
  static const Color divider = Color(0xFFBDBDBD);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  /// Mengembalikan warna berdasarkan status parkiran
  static Color getStatusColor(String status) {
    switch (status) {
      case 'kosong':
        return statusKosong;
      case 'penuh':
        return statusPenuh;
      default:
        return statusUnknown;
    }
  }
}
