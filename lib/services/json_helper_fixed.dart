import 'dart:convert';
import 'dart:math';
import '../models/subject.dart';

// Enhanced JSON helper functions for robust parsing

// Clean JSON string to handle formatting issues
String cleanJsonString(String jsonStr) {
  try {
    // First, try to parse it directly - if it works, no need for cleaning
    jsonDecode(jsonStr);
    return jsonStr;
  } catch (e) {
    // If direct parsing fails, try cleaning
    try {
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
      
      // Remove control characters that are not allowed in JSON strings
      cleaned = cleaned.replaceAll(RegExp(r'[\x00-\x1F]'), '');
      
      // Handle escaped characters that might be problematic
      cleaned = cleaned.replaceAll('\\n', '\n');
      cleaned = cleaned.replaceAll('\\r', '\r');
      cleaned = cleaned.replaceAll('\\t', '\t');
      
      // Test if the cleaned JSON is valid
      try {
        jsonDecode(cleaned);
        return cleaned;
      } catch (e2) {
        // If still not valid, return null to trigger fallback
        print('Cleaned JSON is still invalid: $e2');
        throw e2;
      }
    } catch (e3) {
      // If cleaning fails, return null to trigger fallback
      print('JSON cleaning failed: $e3');
      throw e3;
    }
  }
}

// Parse JSON safely with fallback
Map<String, dynamic>? parseJsonSafely(String jsonStr) {
  try {
    // First try direct parsing
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (directError) {
      // If direct parsing fails, try cleaning
      try {
        String cleanedJson = cleanJsonString(jsonStr);
        return jsonDecode(cleanedJson) as Map<String, dynamic>;
      } catch (cleanError) {
        // If cleaning fails, try manual parsing
        print('Error parsing JSON after cleaning: $cleanError');
        print('Problematic JSON: ${jsonStr.substring(0, jsonStr.length > 100 ? 100 : jsonStr.length)}...');
        
        try {
          return manualJsonParse(jsonStr);
        } catch (manualError) {
          print('Manual parsing also failed: $manualError');
          // If all parsing methods fail, return null to trigger fallback
          return null;
        }
      }
    }
  } catch (e) {
    print('Error in parseJsonSafely: $e');
    return null;
  }
}

// Manual JSON parsing for extreme cases
Map<String, dynamic>? manualJsonParse(String jsonStr) {
  // This is a simplified approach for the specific structure we expect
  Map<String, dynamic> result = {};
  
  // Extract title
  final titleMatch = RegExp(r'"title"\s*:\s*"([^"]*)"').firstMatch(jsonStr);
  if (titleMatch != null && titleMatch.groupCount >= 1) {
    result['title'] = titleMatch.group(1);
  } else {
    result['title'] = 'Learning Note';
  }
  
  // Extract description
  final descMatch = RegExp(r'"description"\s*:\s*"([^"]*)"').firstMatch(jsonStr);
  if (descMatch != null && descMatch.groupCount >= 1) {
    result['description'] = descMatch.group(1);
  } else {
    result['description'] = 'Educational content for children';
  }
  
  // Create a basic elements array
  result['elements'] = [
    {
      'type': 'text',
      'content': result['title'],
      'isBold': true,
      'isItalic': false
    },
    {
      'type': 'text',
      'content': result['description'],
      'isBold': false,
      'isItalic': false
    }
  ];
  
  return result;
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
  
  // Create age-appropriate elements for the fallback note
  final List<Map<String, dynamic>> elements = [];
  
  // Determine font size and content complexity based on age
  String fontSizePrefix = '';
  String contentComplexity = '';
  
  switch (ageGroup) {
    case 4:
      fontSizePrefix = '# ';
      contentComplexity = 'simple';
      break;
    case 5:
      fontSizePrefix = '## ';
      contentComplexity = 'moderate';
      break;
    case 6:
      fontSizePrefix = '### ';
      contentComplexity = 'advanced';
      break;
    default:
      fontSizePrefix = '## ';
      contentComplexity = 'moderate';
  }
  
  // Create engaging content based on subject and chapter
  final String chapterLower = chapter.name.toLowerCase();
  final String subjectLower = subject.name.toLowerCase();
  
  // Determine if this is alphabet/letter related
  bool isAlphabetRelated = chapterLower.contains('huruf') || 
                          chapterLower.contains('letter') || 
                          chapterLower.contains('alphabet') ||
                          chapterLower.contains('abjad');
  
  // Determine if this is number related
  bool isNumberRelated = chapterLower.contains('number') || 
                        chapterLower.contains('nombor') || 
                        chapterLower.contains('angka') ||
                        chapterLower.contains('math');
  
  // Determine if this is color related
  bool isColorRelated = chapterLower.contains('color') || 
                       chapterLower.contains('warna') || 
                       chapterLower.contains('colour');
  
  // Determine if this is shape related
  bool isShapeRelated = chapterLower.contains('shape') || 
                       chapterLower.contains('bentuk') || 
                       chapterLower.contains('form');
  
  // Determine if this is animal related
  bool isAnimalRelated = chapterLower.contains('animal') || 
                        chapterLower.contains('haiwan') || 
                        chapterLower.contains('binatang');
  
  // Add colorful title page
  elements.add({
    'type': 'text',
    'content': '$fontSizePrefix${chapter.name} Flashcards',
    'isBold': true,
    'isItalic': false
  });
  
  elements.add({
    'type': 'image',
    'imageUrl': subjectImages[0],
    'caption': 'Welcome to ${chapter.name} Flashcards!'
  });
  
  elements.add({
    'type': 'text',
    'content': 'Let\'s learn about ${chapter.name} together with these fun flashcards!',
    'isBold': false,
    'isItalic': false
  });
  
  // Add audio introduction for the first page
  elements.add({
    'type': 'audio',
    'audioUrl': subjectAudio[0],
    'title': 'Introduction to ${chapter.name}'
  });
  
  // Generate content based on the type of subject
  if (isAlphabetRelated) {
    // Create alphabet flashcards
    List<String> letters = [];
    
    // Arabic/Jawi letters if relevant
    if (subjectContext == 'jawi') {
      // Use transliteration instead of actual Arabic characters to avoid font issues
      letters = ['Alif', 'Ba', 'Ta', 'Tha', 'Jim', 'Ha', 'Kha', 'Dal', 'Dhal', 'Ra'];
    } else {
      // English letters
      letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    }
    
    // Create a flashcard for each letter (up to page limit)
    for (int i = 0; i < min(letters.length, pageCount - 1); i++) {
      // Page header
      elements.add({
        'type': 'text',
        'content': '$fontSizePrefix Letter ${letters[i]}',
        'isBold': true,
        'isItalic': false
      });
      
      // Letter image
      elements.add({
        'type': 'image',
        'imageUrl': subjectImages[i % subjectImages.length],
        'caption': 'Letter ${letters[i]}'
      });
      
      // Letter description
      String description = '';
      if (ageGroup == 4) {
        description = '${letters[i]} is a letter. Can you trace it with your finger?';
      } else if (ageGroup == 5) {
        description = '${letters[i]} is a letter. Can you think of a word that starts with ${letters[i]}?';
      } else {
        description = '${letters[i]} is a letter. Can you write three words that start with ${letters[i]}?';
      }
      
      elements.add({
        'type': 'text',
        'content': description,
        'isBold': false,
        'isItalic': false
      });
      
      // Add audio for pronunciation
      elements.add({
        'type': 'audio',
        'audioUrl': subjectAudio[i % subjectAudio.length],
        'title': 'Pronunciation of ${letters[i]}'
      });
    }
  } else if (isNumberRelated) {
    // Create number flashcards
    for (int i = 1; i <= min(10, pageCount - 1); i++) {
      // Page header
      elements.add({
        'type': 'text',
        'content': '$fontSizePrefix Number $i',
        'isBold': true,
        'isItalic': false
      });
      
      // Number image
      elements.add({
        'type': 'image',
        'imageUrl': subjectImages[i % subjectImages.length],
        'caption': '$i'
      });
      
      // Number description
      String description = '';
      if (ageGroup == 4) {
        description = 'This is number $i. Can you count to $i?';
      } else if (ageGroup == 5) {
        description = 'This is number $i. Can you show $i fingers?';
      } else {
        description = 'This is number $i. Can you find $i objects around you?';
      }
      
      elements.add({
        'type': 'text',
        'content': description,
        'isBold': false,
        'isItalic': false
      });
      
      // Add audio occasionally
      if (i % 2 == 0) {
        elements.add({
          'type': 'audio',
          'audioUrl': subjectAudio[i % subjectAudio.length],
          'title': 'Counting to $i'
        });
      }
    }
  } else if (isColorRelated) {
    // Create color flashcards
    List<String> colors = ['Red', 'Blue', 'Green', 'Yellow', 'Orange', 'Purple', 'Pink', 'Brown', 'Black', 'White'];
    
    for (int i = 0; i < min(colors.length, pageCount - 1); i++) {
      // Page header
      elements.add({
        'type': 'text',
        'content': '$fontSizePrefix Color: ${colors[i]}',
        'isBold': true,
        'isItalic': false
      });
      
      // Color image
      elements.add({
        'type': 'image',
        'imageUrl': subjectImages[i % subjectImages.length],
        'caption': '${colors[i]} color'
      });
      
      // Color description
      String description = '';
      if (ageGroup == 4) {
        description = 'This is the color ${colors[i]}. Can you point to something ${colors[i]}?';
      } else if (ageGroup == 5) {
        description = 'This is the color ${colors[i]}. What things do you know that are ${colors[i]}?';
      } else {
        description = 'This is the color ${colors[i]}. Can you name three things that are usually ${colors[i]}?';
      }
      
      elements.add({
        'type': 'text',
        'content': description,
        'isBold': false,
        'isItalic': false
      });
      
      // Add audio occasionally
      if (i % 3 == 0) {
        elements.add({
          'type': 'audio',
          'audioUrl': subjectAudio[i % subjectAudio.length],
          'title': 'Learning about ${colors[i]}'
        });
      }
    }
  } else if (isShapeRelated) {
    // Create shape flashcards
    List<String> shapes = ['Circle', 'Square', 'Triangle', 'Rectangle', 'Oval', 'Diamond', 'Star', 'Heart', 'Pentagon', 'Hexagon'];
    
    for (int i = 0; i < min(shapes.length, pageCount - 1); i++) {
      // Page header
      elements.add({
        'type': 'text',
        'content': '$fontSizePrefix Shape: ${shapes[i]}',
        'isBold': true,
        'isItalic': false
      });
      
      // Shape image
      elements.add({
        'type': 'image',
        'imageUrl': subjectImages[i % subjectImages.length],
        'caption': '${shapes[i]} shape'
      });
      
      // Shape description
      String description = '';
      if (ageGroup == 4) {
        description = 'This is a ${shapes[i]}. Can you draw a ${shapes[i]} in the air?';
      } else if (ageGroup == 5) {
        description = 'This is a ${shapes[i]}. Can you find something shaped like a ${shapes[i]}?';
      } else {
        description = 'This is a ${shapes[i]}. How many sides does a ${shapes[i]} have?';
      }
      
      elements.add({
        'type': 'text',
        'content': description,
        'isBold': false,
        'isItalic': false
      });
      
      // Add audio occasionally
      if (i % 3 == 0) {
        elements.add({
          'type': 'audio',
          'audioUrl': subjectAudio[i % subjectAudio.length],
          'title': 'Learning about ${shapes[i]}'
        });
      }
    }
  } else if (isAnimalRelated) {
    // Create animal flashcards
    List<String> animals = ['Lion', 'Elephant', 'Giraffe', 'Monkey', 'Tiger', 'Bear', 'Zebra', 'Kangaroo', 'Penguin', 'Dolphin'];
    
    for (int i = 0; i < min(animals.length, pageCount - 1); i++) {
      // Page header
      elements.add({
        'type': 'text',
        'content': '$fontSizePrefix Animal: ${animals[i]}',
        'isBold': true,
        'isItalic': false
      });
      
      // Animal image
      elements.add({
        'type': 'image',
        'imageUrl': subjectImages[i % subjectImages.length],
        'caption': '${animals[i]}'
      });
      
      // Animal description
      String description = '';
      if (ageGroup == 4) {
        description = 'This is a ${animals[i]}. What sound does a ${animals[i]} make?';
      } else if (ageGroup == 5) {
        description = 'This is a ${animals[i]}. Where does a ${animals[i]} live?';
      } else {
        description = 'This is a ${animals[i]}. What does a ${animals[i]} eat? How does it move?';
      }
      
      elements.add({
        'type': 'text',
        'content': description,
        'isBold': false,
        'isItalic': false
      });
      
      // Add audio for animal sounds
      elements.add({
        'type': 'audio',
        'audioUrl': subjectAudio[i % subjectAudio.length],
        'title': '${animals[i]} sounds'
      });
    }
  } else {
    // Generic flashcards for other subjects
    List<String> topics = [
      'Introduction', 'Key Concept 1', 'Key Concept 2', 'Key Concept 3', 
      'Examples', 'Practice', 'Fun Facts', 'Activity', 'Review', 'Quiz'
    ];
    
    for (int i = 0; i < min(topics.length, pageCount - 1); i++) {
      // Page header
      elements.add({
        'type': 'text',
        'content': '$fontSizePrefix ${topics[i]}',
        'isBold': true,
        'isItalic': false
      });
      
      // Topic image
      elements.add({
        'type': 'image',
        'imageUrl': subjectImages[i % subjectImages.length],
        'caption': '${chapter.name}: ${topics[i]}'
      });
      
      // Topic description
      String description = '';
      if (ageGroup == 4) {
        description = 'Let\'s learn about ${chapter.name} - ${topics[i]}. This is fun!';
      } else if (ageGroup == 5) {
        description = 'Here we\'ll explore ${chapter.name} - ${topics[i]}. Can you remember what we learned?';
      } else {
        description = 'In this section on ${chapter.name} - ${topics[i]}, we\'ll discover important facts and concepts.';
      }
      
      elements.add({
        'type': 'text',
        'content': description,
        'isBold': false,
        'isItalic': false
      });
      
      // Add audio occasionally
      if (i % 3 == 0) {
        elements.add({
          'type': 'audio',
          'audioUrl': subjectAudio[i % subjectAudio.length],
          'title': 'Learning about ${topics[i]}'
        });
      }
    }
  }
  
  // Add a fun review page at the end
  elements.add({
    'type': 'text',
    'content': '$fontSizePrefix Great Job!',
    'isBold': true,
    'isItalic': false
  });
  
  elements.add({
    'type': 'image',
    'imageUrl': subjectImages[subjectImages.length - 1],
    'caption': 'You did it!'
  });
  
  elements.add({
    'type': 'text',
    'content': 'You\'ve learned all about ${chapter.name}! Can you remember what you learned?',
    'isBold': false,
    'isItalic': false
  });
  
  elements.add({
    'type': 'audio',
    'audioUrl': subjectAudio[subjectAudio.length - 1],
    'title': 'Congratulations!'
  });
  
  return {
    'title': '${chapter.name} Flashcards',
    'description': 'Fun and educational flashcards to help children learn about ${chapter.name}',
    'elements': elements
  };
}
