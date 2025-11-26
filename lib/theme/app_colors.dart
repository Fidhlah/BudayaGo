import 'package:flutter/material.dart';

/// ✅ COLOR PALETTE: Define all colors here
class AppColors {
  // ========== PRIMARY COLORS (Orange theme for BudayaGo) ==========
  static const Color primary = Color(0xFFFF9800); // Orange 500
  static const Color primaryLight = Color(0xFFFFB74D); // Orange 300
  static const Color primaryDark = Color(0xFFF57C00); // Orange 700
  static const Color primaryExtraLight = Color(0xFFFFE0B2); // Orange 100
  static const Color primarySurface = Color(0xFFFFF3E0); // Orange 50

  // ========== SECONDARY COLORS (Pink/Accent) ==========
  static const Color secondary = Color(0xFFEC407A); // Pink 400
  static const Color secondaryLight = Color(0xFFF48FB1); // Pink 200
  static const Color secondaryDark = Color(0xFFC2185B); // Pink 700

  // ========== ACCENT COLORS ==========
  static const Color accent = Color(0xFFEC407A); // Pink
  static const Color accentLight = Color(0xFFF48FB1);
  static const Color accentDark = Color(0xFFC2185B);

  // ========== PURPLE COLORS ==========
  static const Color purple = Color(0xFF9C27B0);
  static const Color purpleLight = Color(0xFFCE93D8);
  static const Color purpleDark = Color(0xFF7B1FA2);

  // ========== BLUE COLORS ==========
  static const Color blue = Color(0xFF2196F3);
  static const Color blueLight = Color(0xFF64B5F6);
  static const Color blueDark = Color(0xFF1976D2);

  // ========== SKY COLORS ==========
  static const Color skyLight = Color(0xFFC0FFFE);
  static const Color skyDark = Color(0xFF7DA0F9);

  // ========== GREEN COLORS ==========
  static const Color green = Color(0xFF4CAF50);
  static const Color greenLight = Color(0xFF81C784);
  static const Color greenDark = Color(0xFF388E3C);

  // ========== RED COLORS ==========
  static const Color red = Color(0xFFF44336);
  static const Color redLight = Color(0xFFE57373);
  static const Color redDark = Color(0xFFD32F2F);

  // ========== BROWN COLORS ==========
  static const Color brown = Color(0xFF795548);
  static const Color brownLight = Color(0xFFA1887F);
  static const Color brownDark = Color(0xFF5D4037);

  // ========== INDIGO COLORS ==========
  static const Color indigo = Color(0xFF3F51B5);
  static const Color indigoLight = Color(0xFF7986CB);
  static const Color indigoDark = Color(0xFF303F9F);

  // ========== NEUTRAL COLORS ==========
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5); // Grey 100
  static const Color surfaceVariant = Color(0xFFE0E0E0); // Grey 300
  static const Color surfaceDark = Color(0xFFEEEEEE); // Grey 200
  static const Color border = Color(0xFFBDBDBD); // Grey 400

  // ========== TEXT COLORS ==========
  static const Color textPrimary = Color(0xFF212121); // Grey 900
  static const Color textSecondary = Color(0xFF757575); // Grey 600
  static const Color textTertiary = Color(0xFF9E9E9E); // Grey 500
  static const Color textHint = Color(0xFFBDBDBD); // Grey 400
  static const Color textDisabled = Color(0xFFE0E0E0); // Grey 300

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
  /// Cultural heritage inspired colors - Batik theme
  static const Color batikBrown = Color(0xFF795548); // Brown
  static const Color wayang = Color(0xFF654321);
  static const Color traditional = Color(0xFF8B7355);

  // Batik/Orange shades (Primary branding colors for BudayaGo)
  static const Color batik = Color(0xFFFF9800); // Batik Orange 500
  static const Color batik50 = Color(0xFFFFF3E0);
  static const Color batik100 = Color(0xFFFFE0B2);
  static const Color batik200 = Color(0xFFFFCC80);
  static const Color batik300 = Color(0xFFFFB74D);
  static const Color batik400 = Color(0xFFFFA726);
  static const Color batik500 = Color(0xFFFF9800);
  static const Color batik600 = Color(0xFFFB8C00);
  static const Color batik700 = Color(0xFFF57C00);
  static const Color batik800 = Color(0xFFEF6C00);
  static const Color batikGold = batik300; // Alias for AppBar & accents

  // Orange aliases (kept for backward compatibility)
  static const Color orange = batik;
  static const Color orange50 = batik50;
  static const Color orange100 = batik100;
  static const Color orange200 = batik200;
  static const Color orange300 = batik300;
  static const Color orange400 = Color(0xFFEAA76D);
  static const Color orange500 = batik500;
  static const Color orange600 = batik600;
  static const Color orange700 = batik700;
  static const Color orange800 = batik800;

  // Grey shades (match current usage)
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Pink shades
  static const Color pink200 = Color(0xFFF48FB1);
  static const Color pink300 = Color(0xFFAA4046);
  static const Color pink400 = Color(0xFFEC407A);

  // ========== GRADIENT COLORS ==========
  static const List<Color> primaryGradient = [orange400, orange600];

  static const List<Color> accentGradient = [accent, accentDark];

  static const List<Color> culturalGradient = [batikBrown, batikGold];

  static const List<Color> orangePinkGradient = [orange400, pink300];

  static const List<Color> skyGradient = [skyLight, skyDark];

  static const List<Color> purpleBlueGradient = [purpleLight, blueLight];
}
