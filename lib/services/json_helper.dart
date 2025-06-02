import 'dart:convert';
import '../models/subject.dart';
import 'gemini_service.dart';

// Helper functions for JSON parsing and fallback content generation

// Clean JSON string to handle formatting issues
String cleanJsonString(String jsonStr) {
  // Remove comments (both single-line and multi-line)
  var cleaned = jsonStr.replaceAll(RegExp(r'//.*'), '');
  cleaned = cleaned.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
  
  // Fix trailing commas in arrays and objects
  cleaned = cleaned.replaceAll(RegExp(r',\s*\}'), '}');
  cleaned = cleaned.replaceAll(RegExp(r',\s*\]'), ']');
  
  // Replace any non-standard quotes
  cleaned = cleaned.replaceAll(''', '\'');
  cleaned = cleaned.replaceAll(''', '\'');
  cleaned = cleaned.replaceAll('"', '\"');
  cleaned = cleaned.replaceAll('"', '\"');
  
  return cleaned;
}

// Parse JSON safely with fallback
Map<String, dynamic>? parseJsonSafely(String jsonStr) {
  try {
    // Clean the JSON string first
    String cleanedJson = cleanJsonString(jsonStr);
    
    // Parse the cleaned JSON
    return jsonDecode(cleanedJson) as Map<String, dynamic>;
  } catch (e) {
    print('Error parsing JSON: $e');
    print('Problematic JSON: ${jsonStr.substring(0, jsonStr.length > 100 ? 100 : jsonStr.length)}...');
    return null;
  }
}

// Create fallback note content when Gemini fails
Map<String, dynamic> createFallbackNoteContent(
  Subject subject, 
  Chapter chapter, 
  int ageGroup,
  Map<String, List<String>> imageUrls,
  Map<String, List<String>> audioUrls,
  String subjectContext
) {
  final List<String> subjectImages = imageUrls[subjectContext] ?? imageUrls['default']!;
  final List<String> subjectAudio = audioUrls[subjectContext] ?? audioUrls['default']!;
  
  // Determine page count based on age
  int pageCount;
  switch (ageGroup) {
    case 4: pageCount = 10; break;
    case 5: pageCount = 15; break;
    case 6: pageCount = 20; break;
    default: pageCount = 10;
  }
  
  // Create basic elements for the fallback note
  final List<Map<String, dynamic>> elements = [];
  
  // Add title page
  elements.add({
    'type': 'text',
    'content': 'Learning about ${chapter.name}',
    'isBold': true,
    'isItalic': false
  });
  
  elements.add({
    'type': 'image',
    'imageUrl': subjectImages[0],
    'caption': 'Learning about ${chapter.name}'
  });
  
  elements.add({
    'type': 'text',
    'content': 'Let\'s learn about ${chapter.name} together!',
    'isBold': false,
    'isItalic': false
  });
  
  // Add content pages (simplified)
  for (int i = 1; i < pageCount; i++) {
    elements.add({
      'type': 'text',
      'content': 'Page ${i+1}',
      'isBold': true,
      'isItalic': false
    });
    
    elements.add({
      'type': 'image',
      'imageUrl': subjectImages[i % subjectImages.length],
      'caption': 'Image for page ${i+1}'
    });
    
    elements.add({
      'type': 'text',
      'content': 'This is content for page ${i+1} about ${chapter.name}.',
      'isBold': false,
      'isItalic': false
    });
    
    // Add audio element occasionally
    if (i % 3 == 0) {
      elements.add({
        'type': 'audio',
        'audioUrl': subjectAudio[i % subjectAudio.length],
        'title': 'Audio for page ${i+1}'
      });
    }
  }
  
  return {
    'title': 'Learning about ${chapter.name}',
    'description': 'Educational content to help children learn about ${chapter.name}',
    'elements': elements
  };
}
