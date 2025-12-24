/// 👑 Gold Nightmare App Theme
///
/// نظام الثيم الملكي الكامل

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  // ============================================================================
  // MAIN THEME
  // ============================================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Colors
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.royalGold,
      colorScheme: _colorScheme,

      // Typography
      textTheme: _textTheme,

      // App Bar
      appBarTheme: _appBarTheme,

      // Card
      cardTheme: _cardTheme,

      // Button
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,

      // Input
      inputDecorationTheme: _inputDecorationTheme,

      // Bottom Navigation
      bottomNavigationBarTheme: _bottomNavigationBarTheme,

      // Divider
      dividerTheme: _dividerTheme,

      // Icon
      iconTheme: _iconTheme,

      // Other
      splashColor: AppColors.royalGold.withValues(alpha: 0.1),
      highlightColor: AppColors.royalGold.withValues(alpha: 0.05),
    );
  }

  // ============================================================================
  // COLOR SCHEME
  // ============================================================================

  static ColorScheme get _colorScheme {
    return const ColorScheme.dark(
      primary: AppColors.royalGold,
      secondary: AppColors.imperialPurple,
      surface: AppColors.backgroundSecondary,
      error: AppColors.error,
      onPrimary: AppColors.blackObsidian,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: AppColors.textPrimary,
    );
  }

  // ============================================================================
  // TEXT THEME
  // ============================================================================

  static TextTheme get _textTheme {
    return const TextTheme(
      // Display
      displayLarge: AppTypography.displayLarge,
      displayMedium: AppTypography.displayMedium,
      displaySmall: AppTypography.displaySmall,

      // Headline
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      headlineSmall: AppTypography.headlineSmall,

      // Title
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,

      // Body
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,

      // Label
      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    );
  }

  // ============================================================================
  // APP BAR THEME
  // ============================================================================

  static AppBarTheme get _appBarTheme {
    return const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headlineSmall,
      iconTheme: IconThemeData(
        color: AppColors.royalGold,
        size: 24,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  // ============================================================================
  // CARD THEME
  // ============================================================================

  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: AppColors.backgroundSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.all(8),
    );
  }

  // ============================================================================
  // BUTTON THEMES
  // ============================================================================

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.royalGold,
        foregroundColor: AppColors.blackObsidian,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.buttonMedium,
      ),
    );
  }

  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.royalGold,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.buttonMedium,
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.royalGold,
        side: const BorderSide(color: AppColors.borderGold, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.buttonMedium,
      ),
    );
  }

  // ============================================================================
  // INPUT DECORATION THEME
  // ============================================================================

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.royalGold, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  // ============================================================================
  // BOTTOM NAVIGATION BAR THEME
  // ============================================================================

  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundSecondary,
      selectedItemColor: AppColors.royalGold,
      unselectedItemColor: AppColors.textTertiary,
      selectedLabelStyle: AppTypography.labelSmall,
      unselectedLabelStyle: AppTypography.labelSmall,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  // ============================================================================
  // DIVIDER THEME
  // ============================================================================

  static DividerThemeData get _dividerTheme {
    return const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    );
  }

  // ============================================================================
  // ICON THEME
  // ============================================================================

  static IconThemeData get _iconTheme {
    return const IconThemeData(
      color: AppColors.royalGold,
      size: 24,
    );
  }

  // ============================================================================
  // CUSTOM DECORATIONS
  // ============================================================================

  /// Gold Gradient Container Decoration
  static BoxDecoration get goldGradientDecoration {
    return BoxDecoration(
      gradient: AppColors.goldGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowGold,
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Royal Card Decoration
  static BoxDecoration get royalCardDecoration {
    return BoxDecoration(
      color: AppColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.borderGold,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDark,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Glass Morphism Decoration
  static BoxDecoration get glassMorphismDecoration {
    return BoxDecoration(
      color: AppColors.backgroundGlass,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.borderTransparent,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDark.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
