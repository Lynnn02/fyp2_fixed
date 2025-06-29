import 'dart:math';

/// Template for Art & Craft - Simple Lines & Patterns chapter
class SimplePatternsTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    // Age-specific content
    if (ageGroup == 4) {
      // Age 4: Exactly 5 items with one-word descriptions
      instructions = 'Match the patterns.';
      difficulty = 'easy';
      pairs = [
        {'word': 'Line', 'emoji': '━━━', 'description': 'Straight', 'malay_word': 'Garis'},
        {'word': 'Curve', 'emoji': '〰️', 'description': 'Wavy', 'malay_word': 'Lengkung'},
        {'word': 'Zigzag', 'emoji': '⚡', 'description': 'Sharp', 'malay_word': 'Zigzag'},
        {'word': 'Spiral', 'emoji': '🌀', 'description': 'Round', 'malay_word': 'Lingkaran'},
        {'word': 'Dots', 'emoji': '⋯', 'description': 'Points', 'malay_word': 'Titik'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 items with short phrases
      instructions = 'Match the patterns with their names.';
      difficulty = 'medium';
      pairs = [
        {'word': 'Straight Line', 'emoji': '━━━', 'description': 'Goes in one direction', 'malay_word': 'Garis Lurus'},
        {'word': 'Curved Line', 'emoji': '〰️', 'description': 'Bends smoothly', 'malay_word': 'Garis Melengkung'},
        {'word': 'Zigzag', 'emoji': '⚡', 'description': 'Has sharp turns', 'malay_word': 'Zigzag'},
        {'word': 'Spiral', 'emoji': '🌀', 'description': 'Winds around a point', 'malay_word': 'Lingkaran'},
        {'word': 'Dots', 'emoji': '⋯', 'description': 'Small round marks', 'malay_word': 'Titik-titik'},
        {'word': 'Checkerboard', 'emoji': '🏁', 'description': 'Alternating squares', 'malay_word': 'Papan Catur'},
      ];
    } else {
      // Age 6: 8 items with full sentences
      instructions = 'Match the patterns with their names and descriptions.';
      difficulty = 'hard';
      pairs = [
        {'word': 'Straight Line', 'emoji': '━━━', 'description': 'A line that goes in one direction without curves', 'malay_word': 'Garis Lurus'},
        {'word': 'Curved Line', 'emoji': '〰️', 'description': 'A line that bends smoothly', 'malay_word': 'Garis Melengkung'},
        {'word': 'Zigzag', 'emoji': '⚡', 'description': 'A line with sharp turns', 'malay_word': 'Zigzag'},
        {'word': 'Spiral', 'emoji': '🌀', 'description': 'A line that winds around a center point', 'malay_word': 'Lingkaran'},
        {'word': 'Dots', 'emoji': '⋯', 'description': 'A series of small round marks', 'malay_word': 'Titik-titik'},
        {'word': 'Checkerboard', 'emoji': '🏁', 'description': 'A pattern of alternating squares', 'malay_word': 'Papan Catur'},
        {'word': 'Stripes', 'emoji': '🦓', 'description': 'Parallel lines of different colors', 'malay_word': 'Jalur-jalur'},
        {'word': 'Polka Dots', 'emoji': '👗', 'description': 'A pattern of evenly spaced dots', 'malay_word': 'Bintik-bintik'},
      ];
    }
    
    return {
      'title': 'Art & Craft - Simple Lines & Patterns',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Art & Craft',
        'chapter': 'Simple Lines & Patterns',
        'ageGroup': ageGroup,
        'difficulty': difficulty,
      }
    };
  }

  /// Get sorting game content
  static Map<String, dynamic> getSortingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> categories = [];
    List<Map<String, dynamic>> items = [];
    String instructions = '';
    String difficulty = '';
    
    // Age-specific content
    if (ageGroup == 4) {
      // Age 4: Exactly 5 items with simple categories
      instructions = 'Sort the patterns.';
      difficulty = 'easy';
      categories = [
        {'name': 'Lines', 'description': 'Lines', 'emoji': '━━━', 'color': 'blue'},
        {'name': 'Shapes', 'description': 'Shapes', 'emoji': '🏁', 'color': 'green'},
      ];
      items = [
        {'name': 'Line', 'category': 'Lines', 'emoji': '━━━', 'word': 'Line', 'malay_word': 'Garis'},
        {'name': 'Curve', 'category': 'Lines', 'emoji': '〰️', 'word': 'Curve', 'malay_word': 'Lengkung'},
        {'name': 'Zigzag', 'category': 'Lines', 'emoji': '⚡', 'word': 'Zigzag', 'malay_word': 'Zigzag'},
        {'name': 'Dots', 'category': 'Shapes', 'emoji': '⋯', 'word': 'Dots', 'malay_word': 'Titik'},
        {'name': 'Checker', 'category': 'Shapes', 'emoji': '🏁', 'word': 'Checker', 'malay_word': 'Papan Catur'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 items with more detailed categories
      instructions = 'Sort the patterns into their categories.';
      difficulty = 'medium';
      categories = [
        {'name': 'Lines', 'description': 'Types of lines', 'emoji': '━━━', 'color': 'blue'},
        {'name': 'Patterns', 'description': 'Repeated designs', 'emoji': '🏁', 'color': 'green'},
      ];
      items = [
        {'name': 'Straight Line', 'category': 'Lines', 'emoji': '━━━', 'word': 'Straight Line', 'malay_word': 'Garis Lurus'},
        {'name': 'Curved Line', 'category': 'Lines', 'emoji': '〰️', 'word': 'Curved Line', 'malay_word': 'Garis Melengkung'},
        {'name': 'Zigzag Line', 'category': 'Lines', 'emoji': '⚡', 'word': 'Zigzag Line', 'malay_word': 'Garis Zigzag'},
        {'name': 'Dots Pattern', 'category': 'Patterns', 'emoji': '⋯', 'word': 'Dots Pattern', 'malay_word': 'Corak Titik'},
        {'name': 'Checkerboard', 'category': 'Patterns', 'emoji': '🏁', 'word': 'Checkerboard', 'malay_word': 'Papan Catur'},
        {'name': 'Stripes', 'category': 'Patterns', 'emoji': '🦓', 'word': 'Stripes', 'malay_word': 'Jalur-jalur'},
      ];
    } else {
      // Age 6: 8 items with full categories
      instructions = 'Sort the patterns into their correct categories.';
      difficulty = 'hard';
      categories = [
        {'name': 'Lines', 'description': 'Different types of lines', 'emoji': '━━━', 'color': 'blue'},
        {'name': 'Patterns', 'description': 'Repeated designs', 'emoji': '🏁', 'color': 'green'},
      ];
      items = [
        {'name': 'Straight Line', 'category': 'Lines', 'emoji': '━━━', 'word': 'Straight Line', 'malay_word': 'Garis Lurus'},
        {'name': 'Curved Line', 'category': 'Lines', 'emoji': '〰️', 'word': 'Curved Line', 'malay_word': 'Garis Melengkung'},
        {'name': 'Zigzag Line', 'category': 'Lines', 'emoji': '⚡', 'word': 'Zigzag Line', 'malay_word': 'Garis Zigzag'},
        {'name': 'Spiral Line', 'category': 'Lines', 'emoji': '🌀', 'word': 'Spiral Line', 'malay_word': 'Garis Lingkaran'},
        {'name': 'Dots Pattern', 'category': 'Patterns', 'emoji': '⋯', 'word': 'Dots Pattern', 'malay_word': 'Corak Titik'},
        {'name': 'Checkerboard Pattern', 'category': 'Patterns', 'emoji': '🏁', 'word': 'Checkerboard Pattern', 'malay_word': 'Corak Papan Catur'},
        {'name': 'Stripes Pattern', 'category': 'Patterns', 'emoji': '🦓', 'word': 'Stripes Pattern', 'malay_word': 'Corak Jalur'},
        {'name': 'Polka Dots Pattern', 'category': 'Patterns', 'emoji': '👗', 'word': 'Polka Dots Pattern', 'malay_word': 'Corak Bintik'},
      ];
    }
    
    return {
      'title': 'Art & Craft - Simple Lines & Patterns',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Art & Craft',
        'chapter': 'Simple Lines & Patterns',
        'ageGroup': ageGroup,
        'difficulty': difficulty,
      }
    };
  }

  /// Get tracing game content
  static Map<String, dynamic> getTracingContent(int ageGroup) {
    List<Map<String, dynamic>> items = [];
    String instructions = '';
    String difficulty = '';
    
    // Age-specific content
    if (ageGroup == 4) {
      // Age 4: Exactly 5 items with simple instructions
      instructions = 'Trace the lines.';
      difficulty = 'easy';
      items = [
        {
          'character': '—',
          'difficulty': 1,
          'instruction': 'Trace line',
          'emoji': '━━━',
          'word': 'Line',
          'malay_word': 'Garis',
          'pathPoints': [
            {'x': 0.2, 'y': 0.5},
            {'x': 0.8, 'y': 0.5},
          ]
        },
        {
          'character': '~',
          'difficulty': 1,
          'instruction': 'Trace curve',
          'emoji': '〰️',
          'word': 'Curve',
          'malay_word': 'Lengkung',
          'pathPoints': [
            {'x': 0.2, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.8, 'y': 0.5},
          ]
        },
        {
          'character': 'Z',
          'difficulty': 1,
          'instruction': 'Trace zigzag',
          'emoji': '⚡',
          'word': 'Zigzag',
          'malay_word': 'Zigzag',
          'pathPoints': [
            {'x': 0.2, 'y': 0.3},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.6, 'y': 0.7},
          ]
        },
        {
          'character': '@',
          'difficulty': 1,
          'instruction': 'Trace spiral',
          'emoji': '🌀',
          'word': 'Spiral',
          'malay_word': 'Lingkaran',
          'pathPoints': [
            {'x': 0.5, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.5, 'y': 0.4},
            {'x': 0.4, 'y': 0.4},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.4, 'y': 0.6},
            {'x': 0.5, 'y': 0.6},
            {'x': 0.6, 'y': 0.6},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.6},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': '•',
          'difficulty': 1,
          'instruction': 'Trace dots',
          'emoji': '⋯',
          'word': 'Dots',
          'malay_word': 'Titik',
          'pathPoints': [
            {'x': 0.2, 'y': 0.5},
            {'x': 0.2, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.8, 'y': 0.5},
            {'x': 0.8, 'y': 0.5},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 items with short phrase instructions
      instructions = 'Trace the pattern lines.';
      difficulty = 'medium';
      items = [
        {
          'character': '—',
          'difficulty': 1,
          'instruction': 'Trace the straight line',
          'emoji': '━━━',
          'word': 'Straight Line',
          'malay_word': 'Garis Lurus',
          'pathPoints': [
            {'x': 0.2, 'y': 0.5},
            {'x': 0.8, 'y': 0.5},
          ]
        },
        {
          'character': '~',
          'difficulty': 1,
          'instruction': 'Trace the curved line',
          'emoji': '〰️',
          'word': 'Curved Line',
          'malay_word': 'Garis Melengkung',
          'pathPoints': [
            {'x': 0.2, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.8, 'y': 0.5},
          ]
        },
        {
          'character': 'Z',
          'difficulty': 1,
          'instruction': 'Trace the zigzag line',
          'emoji': '⚡',
          'word': 'Zigzag Line',
          'malay_word': 'Garis Zigzag',
          'pathPoints': [
            {'x': 0.2, 'y': 0.3},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.6, 'y': 0.7},
          ]
        },
        {
          'character': '@',
          'difficulty': 1,
          'instruction': 'Trace the spiral line',
          'emoji': '🌀',
          'word': 'Spiral Line',
          'malay_word': 'Garis Lingkaran',
          'pathPoints': [
            {'x': 0.5, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.5, 'y': 0.4},
            {'x': 0.4, 'y': 0.4},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.4, 'y': 0.6},
            {'x': 0.5, 'y': 0.6},
            {'x': 0.6, 'y': 0.6},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.6},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': '•',
          'difficulty': 1,
          'instruction': 'Trace the dots pattern',
          'emoji': '⋯',
          'word': 'Dots Pattern',
          'malay_word': 'Corak Titik',
          'pathPoints': [
            {'x': 0.2, 'y': 0.5},
            {'x': 0.2, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.8, 'y': 0.5},
            {'x': 0.8, 'y': 0.5},
          ]
        },
        {
          'character': '#',
          'difficulty': 2,
          'instruction': 'Trace the checkerboard',
          'emoji': '🏁',
          'word': 'Checkerboard',
          'malay_word': 'Papan Catur',
          'pathPoints': [
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
          ]
        },
      ];
    } else {
      // Age 6: 8 items with full sentence instructions
      instructions = 'Trace the pattern lines carefully following the dots.';
      difficulty = 'hard';
      items = [
        {
          'character': '—',
          'difficulty': 1,
          'instruction': 'Trace the straight line pattern carefully',
          'emoji': '━━━',
          'word': 'Straight Line',
          'malay_word': 'Garis Lurus',
          'pathPoints': [
            {'x': 0.2, 'y': 0.5},
            {'x': 0.8, 'y': 0.5},
          ]
        },
        {
          'character': '~',
          'difficulty': 1,
          'instruction': 'Trace the curved line pattern completely',
          'emoji': '〰️',
          'word': 'Curved Line',
          'malay_word': 'Garis Melengkung',
          'pathPoints': [
            {'x': 0.2, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.8, 'y': 0.5},
          ]
        },
        {
          'character': 'Z',
          'difficulty': 1,
          'instruction': 'Trace the zigzag line pattern from start to finish',
          'emoji': '⚡',
          'word': 'Zigzag Line',
          'malay_word': 'Garis Zigzag',
          'pathPoints': [
            {'x': 0.2, 'y': 0.3},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.6, 'y': 0.7},
          ]
        },
        {
          'character': '@',
          'difficulty': 2,
          'instruction': 'Trace the spiral line pattern starting from the center',
          'emoji': '🌀',
          'word': 'Spiral Line',
          'malay_word': 'Garis Lingkaran',
          'pathPoints': [
            {'x': 0.5, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.5, 'y': 0.4},
            {'x': 0.4, 'y': 0.4},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.4, 'y': 0.6},
            {'x': 0.5, 'y': 0.6},
            {'x': 0.6, 'y': 0.6},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.6},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': '•',
          'difficulty': 1,
          'instruction': 'Trace the dots pattern design from left to right',
          'emoji': '⋯',
          'word': 'Dots Pattern',
          'malay_word': 'Corak Titik',
          'pathPoints': [
            {'x': 0.2, 'y': 0.5},
            {'x': 0.2, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.8, 'y': 0.5},
            {'x': 0.8, 'y': 0.5},
          ]
        },
        {
          'character': '#',
          'difficulty': 2,
          'instruction': 'Trace the checkerboard pattern design completely',
          'emoji': '🏁',
          'word': 'Checkerboard Pattern',
          'malay_word': 'Corak Papan Catur',
          'pathPoints': [
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
          ]
        },
        {
          'character': '=',
          'difficulty': 2,
          'instruction': 'Trace the horizontal stripes pattern design carefully',
          'emoji': '🦓',
          'word': 'Stripes Pattern',
          'malay_word': 'Corak Jalur',
          'pathPoints': [
            {'x': 0.2, 'y': 0.3},
            {'x': 0.8, 'y': 0.3},
            {'x': 0.2, 'y': 0.4},
            {'x': 0.8, 'y': 0.4},
            {'x': 0.2, 'y': 0.5},
            {'x': 0.8, 'y': 0.5},
            {'x': 0.2, 'y': 0.6},
            {'x': 0.8, 'y': 0.6},
            {'x': 0.2, 'y': 0.7},
            {'x': 0.8, 'y': 0.7},
          ]
        },
        {
          'character': '*',
          'difficulty': 3,
          'instruction': 'Trace the star pattern design following all points',
          'emoji': '⭐',
          'word': 'Star Pattern',
          'malay_word': 'Corak Bintang',
          'pathPoints': [
            {'x': 0.5, 'y': 0.3},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.2, 'y': 0.5},
            {'x': 0.35, 'y': 0.6},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.7, 'y': 0.8},
            {'x': 0.65, 'y': 0.6},
            {'x': 0.8, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
          ]
        },
      ];
    }
    
    return {
      'title': 'Art & Craft - Simple Lines & Patterns',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Art & Craft',
        'chapter': 'Simple Lines & Patterns',
        'ageGroup': ageGroup,
        'difficulty': difficulty,
      }
    };
  }

  /// Get shape and color game content
  static Map<String, dynamic> getShapeColorContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> shapes = [];
    String instructions = '';
    String difficulty = '';
    
    // Age-specific content
    if (ageGroup == 4) {
      // Age 4: 5 items with one-word descriptions
      instructions = 'Match the pattern.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'straight_line', 'color': 'blue', 'name': 'Line', 'malay_shape': 'Garis', 'malay_color': 'Biru', 'word': 'Line', 'malay_word': 'Garis'},
        {'shape': 'curved_line', 'color': 'red', 'name': 'Curve', 'malay_shape': 'Lengkung', 'malay_color': 'Merah', 'word': 'Curve', 'malay_word': 'Lengkung'},
        {'shape': 'zigzag', 'color': 'yellow', 'name': 'Zigzag', 'malay_shape': 'Zigzag', 'malay_color': 'Kuning', 'word': 'Zigzag', 'malay_word': 'Zigzag'},
        {'shape': 'spiral', 'color': 'green', 'name': 'Spiral', 'malay_shape': 'Lingkaran', 'malay_color': 'Hijau', 'word': 'Spiral', 'malay_word': 'Lingkaran'},
        {'shape': 'dots', 'color': 'purple', 'name': 'Dots', 'malay_shape': 'Titik', 'malay_color': 'Ungu', 'word': 'Dots', 'malay_word': 'Titik'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 items with short phrase descriptions
      instructions = 'Match the pattern with its name.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'straight_line', 'color': 'blue', 'name': 'Straight Line', 'malay_shape': 'Garis Lurus', 'malay_color': 'Biru', 'word': 'Straight Line', 'malay_word': 'Garis Lurus'},
        {'shape': 'curved_line', 'color': 'red', 'name': 'Curved Line', 'malay_shape': 'Garis Melengkung', 'malay_color': 'Merah', 'word': 'Curved Line', 'malay_word': 'Garis Melengkung'},
        {'shape': 'zigzag', 'color': 'yellow', 'name': 'Zigzag Line', 'malay_shape': 'Garis Zigzag', 'malay_color': 'Kuning', 'word': 'Zigzag Line', 'malay_word': 'Garis Zigzag'},
        {'shape': 'spiral', 'color': 'green', 'name': 'Spiral Pattern', 'malay_shape': 'Corak Lingkaran', 'malay_color': 'Hijau', 'word': 'Spiral Pattern', 'malay_word': 'Corak Lingkaran'},
        {'shape': 'dots', 'color': 'purple', 'name': 'Dots Pattern', 'malay_shape': 'Corak Titik', 'malay_color': 'Ungu', 'word': 'Dots Pattern', 'malay_word': 'Corak Titik'},
        {'shape': 'checkerboard', 'color': 'black', 'name': 'Checkerboard', 'malay_shape': 'Papan Catur', 'malay_color': 'Hitam', 'word': 'Checkerboard', 'malay_word': 'Papan Catur'},
      ];
    } else {
      // Age 6: 8 items with full sentence descriptions
      instructions = 'Match the pattern with its correct name and description.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'straight_line', 'color': 'blue', 'name': 'Straight Line Pattern', 'malay_shape': 'Corak Garis Lurus', 'malay_color': 'Biru', 'word': 'A pattern with straight lines', 'malay_word': 'Corak dengan garis lurus'},
        {'shape': 'curved_line', 'color': 'red', 'name': 'Curved Line Pattern', 'malay_shape': 'Corak Garis Melengkung', 'malay_color': 'Merah', 'word': 'A pattern with curved lines', 'malay_word': 'Corak dengan garis melengkung'},
        {'shape': 'zigzag', 'color': 'yellow', 'name': 'Zigzag Line Pattern', 'malay_shape': 'Corak Garis Zigzag', 'malay_color': 'Kuning', 'word': 'A pattern with sharp turns', 'malay_word': 'Corak dengan selekoh tajam'},
        {'shape': 'spiral', 'color': 'green', 'name': 'Spiral Pattern', 'malay_shape': 'Corak Lingkaran', 'malay_color': 'Hijau', 'word': 'A pattern that curves around a center', 'malay_word': 'Corak yang melengkung di sekitar pusat'},
        {'shape': 'dots', 'color': 'purple', 'name': 'Dots Pattern', 'malay_shape': 'Corak Titik', 'malay_color': 'Ungu', 'word': 'A pattern made of small points', 'malay_word': 'Corak yang dibuat daripada titik kecil'},
        {'shape': 'checkerboard', 'color': 'black', 'name': 'Checkerboard Pattern', 'malay_shape': 'Corak Papan Catur', 'malay_color': 'Hitam', 'word': 'A pattern with alternating squares', 'malay_word': 'Corak dengan petak berselang-seli'},
        {'shape': 'stripes', 'color': 'orange', 'name': 'Stripes Pattern', 'malay_shape': 'Corak Jalur', 'malay_color': 'Oren', 'word': 'A pattern with parallel lines', 'malay_word': 'Corak dengan garis selari'},
        {'shape': 'polka_dots', 'color': 'pink', 'name': 'Polka Dots Pattern', 'malay_shape': 'Corak Bintik', 'malay_color': 'Merah Jambu', 'word': 'A pattern with evenly spaced dots', 'malay_word': 'Corak dengan titik berjarak sama'},
      ];
    }
    
    return {
      'title': 'Art & Craft - Simple Lines & Patterns',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Art & Craft',
        'chapter': 'Simple Lines & Patterns',
        'ageGroup': ageGroup,
        'difficulty': difficulty,
      }
    };
  }

  /// Get content for specific game type
  static Map<String, dynamic> getContent(String gameType, int ageGroup, int rounds) {
    switch (gameType.toLowerCase()) {
      case 'matching':
        return getMatchingContent(ageGroup, rounds);
      case 'sorting':
        return getSortingContent(ageGroup, rounds);
      case 'tracing':
        return getTracingContent(ageGroup);
      case 'shape_color':
        return getShapeColorContent(ageGroup, rounds);
      default:
        return {
          'error': 'Invalid game type',
          'validTypes': ['matching', 'sorting', 'tracing', 'shape_color'],
        };
    }
  }
}
