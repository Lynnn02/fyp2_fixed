import 'package:flutter/material.dart';

// Colors
const Color primaryColor = Color(0xFF4CAF50);
const Color secondaryColor = Color(0xFFFF9800);
const Color accentColor = Color(0xFF2196F3);
const Color backgroundColor = Color(0xFFF5F5F5);
const Color errorColor = Color(0xFFE57373);
const Color successColor = Color(0xFF81C784);

// Text Styles
const TextStyle headingStyle = TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);

const TextStyle subheadingStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.w600,
  color: Colors.black87,
);

const TextStyle bodyStyle = TextStyle(
  fontSize: 16.0,
  color: Colors.black87,
);

const TextStyle captionStyle = TextStyle(
  fontSize: 14.0,
  color: Colors.black54,
);

// Age-specific text styles
TextStyle getAgeAppropriateTextStyle(int age) {
  switch (age) {
    case 4:
      return const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
        height: 1.5,
      );
    case 5:
      return const TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
        height: 1.4,
      );
    case 6:
      return const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
        height: 1.3,
      );
    default:
      return const TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
        height: 1.3,
      );
  }
}

// Spacing
const double kSpacing = 16.0;
const double kSpacingSmall = 8.0;
const double kSpacingLarge = 24.0;

// Decorations
BoxDecoration roundedBoxDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10.0,
      spreadRadius: 0.0,
      offset: const Offset(0, 2),
    ),
  ],
);

// Button Styles
final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: primaryColor,
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  ),
);

final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: secondaryColor,
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  ),
);

// Input Decoration
InputDecoration inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  );
}

// Age-specific colors
Color getAgeColor(int age) {
  switch (age) {
    case 4:
      return Colors.green;
    case 5:
      return Colors.blue;
    case 6:
      return Colors.purple;
    default:
      return Colors.teal;
  }
}
