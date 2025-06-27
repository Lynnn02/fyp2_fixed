import 'package:flutter/material.dart';

class LanguageDetector {
  static final List<String> rtlLanguages = ['ar', 'he', 'fa', 'ur', 'ps', 'sd'];
  
  static bool isRTL(String text) {
    // Simple detection based on common RTL language characters
    final arabicRange = RegExp(r'[\u0600-\u06FF]');
    final hebrewRange = RegExp(r'[\u0590-\u05FF]');
    final farsiRange = RegExp(r'[\u0750-\u077F]');
    
    if (arabicRange.hasMatch(text) || hebrewRange.hasMatch(text) || farsiRange.hasMatch(text)) {
      return true;
    }
    
    return false;
  }
  
  static Future<String> detectLanguage(String text) async {
    // In a real implementation, this would use a language detection API
    // For now, we'll use a simple check for RTL characters
    if (isRTL(text)) {
      return 'ar'; // Default to Arabic if RTL
    }
    return 'en'; // Default to English
  }
  
  static String getFontFamilyForLanguage(String language) {
    switch (language) {
      case 'ar':
        return 'Amiri';
      case 'he':
        return 'FrankRuehl';
      case 'zh':
      case 'ja':
        return 'NotoSansSC';
      default:
        return 'Roboto';
    }
  }
  
  static double getFontSizeAdjustmentForLanguage(String language) {
    switch (language) {
      case 'ar':
      case 'he':
        return 2.0; // Slightly larger for RTL languages
      case 'zh':
      case 'ja':
        return 1.5; // Slightly larger for CJK languages
      default:
        return 0.0;
    }
  }
}
