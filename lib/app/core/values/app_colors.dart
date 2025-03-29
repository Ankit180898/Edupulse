import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static Color primaryColor = const Color(0xFF1976D2); // Primary blue color
  static Color primaryLightColor = const Color(0xFF42A5F5); // Lighter shade of primary
  static Color primaryDarkColor = const Color(0xFF1565C0); // Darker shade of primary
  
  // Accent colors
  static Color accentColor = const Color(0xFF00BCD4); // Cyan accent color
  static Color accentLightColor = const Color(0xFF4DD0E1); // Lighter shade of accent
  static Color accentDarkColor = const Color(0xFF0097A7); // Darker shade of accent
  
  // Background colors
  static Color bgColor = const Color(0xFFF5F7FA); // Light gray background
  static Color cardColor = Colors.white; // White card background
  static Color dialogColor = Colors.white; // White dialog background
  
  // Text colors
  static Color primaryTextColor = const Color(0xFF212121); // Dark text color
  static Color secondaryTextColor = const Color(0xFF757575); // Gray text color
  static Color tertiaryTextColor = const Color(0xFFBDBDBD); // Light gray text color
  static Color inverseTextColor = Colors.white; // White text color
  
  // Status colors
  static Color successColor = const Color(0xFF4CAF50); // Green success color
  static Color warningColor = const Color(0xFFFFC107); // Orange warning color
  static Color errorColor = const Color(0xFFF44336); // Red error color
  static Color infoColor = const Color(0xFF2196F3); // Blue info color
  
  // Border colors
  static Color borderColor = const Color(0xFFE0E0E0); // Light gray border color
  static Color dividerColor = const Color(0xFFEEEEEE); // Slightly lighter gray divider
  
  // Shadow colors
  static Color shadowColor = const Color(0x40000000); // Black shadow with opacity
  
  // Feature-specific colors
  static Color noteColor = const Color(0xFF2196F3); // Blue for notes
  static Color flashcardColor = const Color(0xFF9C27B0); // Purple for flashcards
  static Color mcqColor = const Color(0xFF673AB7); // Deep purple for MCQs
  static Color examColor = const Color(0xFFFF9800); // Orange for exams
  static Color subscriptionColor = const Color(0xFF4CAF50); // Green for subscription
  
  // Level colors for flashcards
  static Color level1Color = const Color(0xFFF44336); // Red for level 1
  static Color level2Color = const Color(0xFFFF9800); // Orange for level 2
  static Color level3Color = const Color(0xFFFFEB3B); // Yellow for level 3
  static Color level4Color = const Color(0xFF8BC34A); // Light green for level 4
  static Color level5Color = const Color(0xFF4CAF50); // Green for level 5
  
  // Tag colors
  static List<Color> tagColors = [
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFF44336), // Red
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFF9800), // Orange
    const Color(0xFF795548), // Brown
    const Color(0xFF607D8B), // Blue Grey
  ];
  
  // Get a random tag color
  static Color getRandomTagColor() {
    return tagColors[DateTime.now().millisecondsSinceEpoch % tagColors.length];
  }
  
  // Get color for subscription tier
  static Color getSubscriptionColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'free':
        return const Color(0xFF9E9E9E); // Gray for free
      case 'monthly':
        return const Color(0xFF2196F3); // Blue for monthly
      case 'quarterly':
        return const Color(0xFF673AB7); // Deep purple for quarterly
      case 'yearly':
        return const Color(0xFF4CAF50); // Green for yearly
      default:
        return primaryColor;
    }
  }
  
  // Get color for level indicator
  static Color getLevelColor(int level) {
    switch (level) {
      case 1:
        return level1Color;
      case 2:
        return level2Color;
      case 3:
        return level3Color;
      case 4:
        return level4Color;
      case 5:
        return level5Color;
      default:
        return level3Color;
    }
  }
}