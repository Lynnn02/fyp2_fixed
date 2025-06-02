import 'package:flutter/material.dart';

/// A utility class that defines consistent colors for the application
class AppColors {
  // Primary brand colors
  static const Color primaryColor = Color(0xFF2196F3);  // Blue
  static const Color secondaryColor = Color(0xFF4CAF50);  // Green
  static const Color accentColor = Color(0xFFFF9800);  // Orange
  
  // Activity type colors - visually appealing and accessible
  static const Color gameColor = Color(0xFF4CAF50);  // Green - represents interactive learning
  static const Color noteColor = Color(0xFF2196F3);  // Blue - represents reading/study materials
  static const Color videoColor = Color(0xFFFF9800);  // Orange - represents video content
  static const Color otherColor = Color(0xFF9E9E9E);  // Grey - for miscellaneous activities
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // Background colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Get color for activity type
  static Color getActivityTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'game':
        return gameColor;
      case 'note':
        return noteColor;
      case 'video':
        return videoColor;
      default:
        return otherColor;
    }
  }
  
  // Get a map of activity type colors
  static Map<String, Color> getActivityTypeColorMap() {
    return {
      'game': gameColor,
      'note': noteColor,
      'video': videoColor,
      'other': otherColor,
    };
  }
}
