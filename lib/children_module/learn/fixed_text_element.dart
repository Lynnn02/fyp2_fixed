import 'package:flutter/material.dart';
import '../../models/note_content.dart';

// Helper method to fix the TextElement rendering
Widget buildTextElement(TextElement element, double Function() getFontSizeForAge, Color Function(String) parseColor) {
  // Extract title and description
  String title = '';
  String description = element.content;
  
  if (element.content.contains('\n')) {
    final parts = element.content.split('\n');
    title = parts.first.trim();
    description = parts.sublist(1).join('\n').trim();
  } else if (element.content.contains('. ')) {
    final parts = element.content.split('. ');
    title = parts.first.trim() + '.';
    description = parts.sublist(1).join('. ').trim();
  }
  
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (title.isNotEmpty && description.isNotEmpty)
        Text(
          description,
          style: TextStyle(
            fontSize: getFontSizeForAge(),
            fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
            color: element.textColor != null ? parseColor(element.textColor!) : Colors.black,
          ),
          textAlign: TextAlign.center,
        )
      else
        Text(
          element.content,
          style: TextStyle(
            fontSize: getFontSizeForAge(),
            fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
            color: element.textColor != null ? parseColor(element.textColor!) : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
    ],
  );
}
