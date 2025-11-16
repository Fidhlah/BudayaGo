import 'package:flutter/material.dart';

/// ✅ COLOR PALETTE: Define all colors here
class AppColors {
  // ========== PRIMARY COLORS ==========
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryLight = Color(0xFF9D46FF);
  static const Color primaryDark = Color(0xFF0A00B6);
  
  // ========== SECONDARY COLORS ==========
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryLight = Color(0xFF66FFF9);
  static const Color secondaryDark = Color(0xFF00A896);
  
  // ========== ACCENT COLORS ==========
  static const Color accent = Color(0xFFFF6584);
  static const Color accentLight = Color(0xFFFF96AB);
  static const Color accentDark = Color(0xFFC7395F);
  
  // ========== NEUTRAL COLORS ==========
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color surfaceVariant = Color(0xFFE0E0E0);
  
  // ========== TEXT COLORS ==========
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFFE0E0E0);
  
  // ========== STATUS COLORS ==========
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF80E27E);
  static const Color successDark = Color(0xFF087F23);
  
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFFFA000);
  
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);
  
  // ========== SPECIAL COLORS ==========
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x29000000);
  static const Color overlay = Color(0x80000000);
  static const Color shimmer = Color(0xFFE0E0E0);
  
  // ========== BUDAYAGO SPECIFIC COLORS ==========
  /// Cultural heritage inspired colors
  static const Color batikBrown = Color(0xFF8B4513);
  static const Color batikGold = Color(0xFFD4AF37);
  static const Color wayang = Color(0xFF654321);
  static const Color traditional = Color(0xFF8B7355);
  
  // ========== GRADIENT COLORS ==========
  static const List<Color> primaryGradient = [
    primary,
    primaryDark,
  ];
  
  static const List<Color> accentGradient = [
    accent,
    accentDark,
  ];
  
  static const List<Color> culturalGradient = [
    batikBrown,
    batikGold,
  ];
}