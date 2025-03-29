import 'package:edupulse/app/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  // Text Styles using Google Fonts
  static TextStyle get heading1 => GoogleFonts.nunitoSans(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
    height: 1.3,
  );
  
  static TextStyle get heading2 => GoogleFonts.nunitoSans(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
    height: 1.3,
  );
  
  static TextStyle get heading3 => GoogleFonts.nunitoSans(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
    height: 1.3,
  );
  
  static TextStyle get heading4 => GoogleFonts.nunitoSans(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
    height: 1.3,
  );
  
  static TextStyle get subheading => GoogleFonts.nunitoSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryTextColor,
    height: 1.3,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.nunitoSans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryTextColor,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.nunitoSans(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryTextColor,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => GoogleFonts.nunitoSans(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryTextColor,
    height: 1.5,
  );
  
  static TextStyle get caption => GoogleFonts.nunitoSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryTextColor,
    letterSpacing: 0.4,
  );
  
  static TextStyle get buttonText => GoogleFonts.nunitoSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.inverseTextColor,
    letterSpacing: 0.5,
  );
  
  static TextStyle get linkText => GoogleFonts.nunitoSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
    decoration: TextDecoration.underline,
  );
  
  // Input Decorations
  static InputDecoration get inputDecoration => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.errorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.errorColor, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: GoogleFonts.nunitoSans(color: AppColors.tertiaryTextColor),
  );
  
  static InputDecoration searchInputDecoration({required String hintText}) => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: hintText,
    hintStyle: GoogleFonts.nunitoSans(color: AppColors.tertiaryTextColor),
    prefixIcon: Icon(Icons.search, color: AppColors.secondaryTextColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
  );
  
  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    textStyle: GoogleFonts.nunitoSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );
  
  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryColor,
    side: BorderSide(color: AppColors.primaryColor),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    textStyle: GoogleFonts.nunitoSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );
  
  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: AppColors.primaryColor,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: GoogleFonts.nunitoSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );
  
  // Card Styles
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowColor.withOpacity(0.1),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration get roundedBoxDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
  );
  
  // Chip Styles
  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: Colors.grey.shade100,
    disabledColor: Colors.grey.shade200,
    selectedColor: AppColors.primaryColor.withOpacity(0.2),
    secondarySelectedColor: AppColors.primaryColor.withOpacity(0.2),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: GoogleFonts.nunitoSans(
      fontSize: 14,
      color: AppColors.primaryTextColor,
    ),
    secondaryLabelStyle: GoogleFonts.nunitoSans(
      fontSize: 14,
      color: AppColors.primaryColor,
    ),
    brightness: Brightness.light,
  );
  
  // Animation Durations
  static Duration get defaultDuration => const Duration(milliseconds: 300);
  static Duration get slowDuration => const Duration(milliseconds: 500);
  static Duration get fastDuration => const Duration(milliseconds: 150);
  
  // Other Common Styles
  static BoxDecoration get gradientDecoration => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppColors.primaryColor,
        AppColors.primaryLightColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
  );
  
  static BoxDecoration tagDecoration(Color color) => BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: color.withOpacity(0.3)),
  );
  
  static BoxShadow get defaultShadow => BoxShadow(
    color: AppColors.shadowColor.withOpacity(0.1),
    blurRadius: 6,
    offset: const Offset(0, 2),
  );
}
