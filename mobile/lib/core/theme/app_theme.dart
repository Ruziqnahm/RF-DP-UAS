import 'package:flutter/material.dart';

class AppTheme {
  // Modern Color Palette
  static const primaryColor = Color(0xFF1976D2); // biru
  static const primaryBlue = Color(0xFF2196F3);
  static const primaryDark = Color(0xFF0D47A1);
  static const secondaryColor = Color(0xFFFF9800); // orange
  static const accentOrange = Color(0xFFFF9800);
  static const backgroundColor = Color(0xFFF5F5F5); // abu muda
  static const successGreen = Color(0xFF4CAF50);
  static const warningOrange = Color(0xFFFF9800);
  static const errorRed = Color(0xFFF44336);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2196F3),
      Color(0xFF1976D2),
      Color(0xFF0D47A1),
    ],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4CAF50),
      Color(0xFF388E3C),
    ],
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF9800),
      Color(0xFFF57C00),
    ],
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF9800),
      Color(0xFFFF6F00),
    ],
  );
  
  // Shadow Styles
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRounded = 30.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;
  
  // Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryBlue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    elevation: 2,
  );
  
  static ButtonStyle successButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: successGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    elevation: 2,
  );
  
  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryBlue,
    side: const BorderSide(color: primaryBlue, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
  );
  
  // Card Decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: cardShadow,
  );
  
  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: elevatedShadow,
  );
  
  // Glassmorphism Effect
  static BoxDecoration glassmorphism({double opacity = 0.2}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radiusLarge),
      border: Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1.5,
      ),
    );
  }
  
  // Input Decoration
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: errorRed),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
  
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
  );
}