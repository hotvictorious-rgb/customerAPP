import 'package:flutter/material.dart';

/// Victorious MARKET Sovereign Brand Palette
class AppColors {
  // Brand Core
  static const Color primaryPurple = Color(0xFF5E17EB);
  static const Color primaryDarkPurple = Color(0xFF3B0B99);
  static const Color primaryLightPurple = Color(0xFF8B5CF6);
  static const Color secondaryGold = Color(0xFFFFD700);
  static const Color secondaryGoldDark = Color(0xFFFFA000);
  static const Color secondaryGoldLight = Color(0xFFFFF3B0);

  // Surfaces & Backgrounds
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3F4F6);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = Color(0xFF5E17EB);

  // Royal Purple Gradient
  static const LinearGradient royalPurpleGradient = LinearGradient(
    colors: [primaryPurple, primaryDarkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gold Shimmer Gradient
  static const LinearGradient goldGradient = LinearGradient(
    colors: [secondaryGold, secondaryGoldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get purpleShadow => [
    BoxShadow(
      color: primaryPurple.withOpacity(0.25),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
