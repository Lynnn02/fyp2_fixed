import 'dart:math';

/// Template for Math - Shapes & Patterns chapter
class ShapesPatternsTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: 3 basic shapes with simple descriptions
      instructions = 'Match the basic shapes with their names.';
      difficulty = 'easy';
      pairs = [
        {'word': 'Circle', 'emoji': '⭕', 'description': 'A round shape', 'malay_word': 'Bulatan'},
        {'word': 'Square', 'emoji': '🟥', 'description': 'A box shape', 'malay_word': 'Segi Empat'},
        {'word': 'Triangle', 'emoji': '🔺', 'description': 'A pointy shape', 'malay_word': 'Segi Tiga'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 5 shapes with more detailed descriptions
      instructions = 'Match the shapes with their names and descriptions.';
      difficulty = 'medium';
      pairs = [
        {'word': 'Circle', 'emoji': '⭕', 'description': 'A round shape with no corners', 'malay_word': 'Bulatan'},
        {'word': 'Square', 'emoji': '🟥', 'description': 'A shape with 4 equal sides', 'malay_word': 'Segi Empat'},
        {'word': 'Triangle', 'emoji': '🔺', 'description': 'A shape with 3 sides', 'malay_word': 'Segi Tiga'},
        {'word': 'Rectangle', 'emoji': '🟩', 'description': 'A shape with 4 sides, 2 long and 2 short', 'malay_word': 'Segi Empat Tepat'},
        {'word': 'Star', 'emoji': '⭐', 'description': 'A shape with 5 points', 'malay_word': 'Bintang'},
      ];
    } else {
      // Age 6: All 8 shapes with detailed descriptions
      instructions = 'Match the shapes with their names, descriptions, and Malay translations.';
      difficulty = 'hard';
      pairs = [
        {'word': 'Circle', 'emoji': '⭕', 'description': 'A round shape with no corners', 'malay_word': 'Bulatan'},
        {'word': 'Square', 'emoji': '🟥', 'description': 'A shape with 4 equal sides', 'malay_word': 'Segi Empat'},
        {'word': 'Triangle', 'emoji': '🔺', 'description': 'A shape with 3 sides', 'malay_word': 'Segi Tiga'},
        {'word': 'Rectangle', 'emoji': '🟩', 'description': 'A shape with 4 sides, 2 long and 2 short', 'malay_word': 'Segi Empat Tepat'},
        {'word': 'Star', 'emoji': '⭐', 'description': 'A shape with 5 points', 'malay_word': 'Bintang'},
        {'word': 'Heart', 'emoji': '❤️', 'description': 'A shape that represents love', 'malay_word': 'Hati'},
        {'word': 'Diamond', 'emoji': '💎', 'description': 'A shape with 4 equal sides but tilted', 'malay_word': 'Berlian'},
        {'word': 'Oval', 'emoji': '🥚', 'description': 'An elongated circle', 'malay_word': 'Bujur'},
      ];
    }
    
    return {
      'title': 'Math - Shapes & Patterns',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Math',
        'chapter': 'Shapes & Patterns',
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
    
    if (ageGroup == 4) {
      // Age 4: Simple sorting with 4 basic shapes
      instructions = 'Sort the shapes by their type.';
      difficulty = 'easy';
      categories = [
        {'name': 'Round Shapes', 'description': 'Shapes with curves', 'emoji': '⭕', 'color': 'blue'},
        {'name': 'Pointy Shapes', 'description': 'Shapes with points', 'emoji': '🔺', 'color': 'red'},
      ];
      items = [
        {'name': 'Circle', 'category': 'Round Shapes', 'emoji': '⭕', 'word': 'Circle', 'malay_word': 'Bulatan'},
        {'name': 'Square', 'category': 'Pointy Shapes', 'emoji': '🟥', 'word': 'Square', 'malay_word': 'Segi Empat'},
        {'name': 'Triangle', 'category': 'Pointy Shapes', 'emoji': '🔺', 'word': 'Triangle', 'malay_word': 'Segi Tiga'},
        {'name': 'Oval', 'category': 'Round Shapes', 'emoji': '🥚', 'word': 'Oval', 'malay_word': 'Bujur'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 6 shapes
      instructions = 'Sort the shapes into round and angular categories.';
      difficulty = 'medium';
      categories = [
        {'name': 'Round Shapes', 'description': 'Shapes with curves and no corners', 'emoji': '⭕', 'color': 'blue'},
        {'name': 'Angular Shapes', 'description': 'Shapes with straight lines and corners', 'emoji': '🟥', 'color': 'green'},
      ];
      items = [
        {'name': 'Circle', 'category': 'Round Shapes', 'emoji': '⭕', 'word': 'Circle', 'malay_word': 'Bulatan'},
        {'name': 'Oval', 'category': 'Round Shapes', 'emoji': '🥚', 'word': 'Oval', 'malay_word': 'Bujur'},
        {'name': 'Heart', 'category': 'Round Shapes', 'emoji': '❤️', 'word': 'Heart', 'malay_word': 'Hati'},
        {'name': 'Square', 'category': 'Angular Shapes', 'emoji': '🟥', 'word': 'Square', 'malay_word': 'Segi Empat'},
        {'name': 'Triangle', 'category': 'Angular Shapes', 'emoji': '🔺', 'word': 'Triangle', 'malay_word': 'Segi Tiga'},
        {'name': 'Rectangle', 'category': 'Angular Shapes', 'emoji': '🟩', 'word': 'Rectangle', 'malay_word': 'Segi Empat Tepat'},
      ];
    } else {
      // Age 6: Complex sorting with all 8 shapes and 3 categories
      instructions = 'Sort the shapes into round, angular, and special categories.';
      difficulty = 'hard';
      categories = [
        {'name': 'Round Shapes', 'description': 'Shapes with curves and no corners', 'emoji': '⭕', 'color': 'blue'},
        {'name': 'Angular Shapes', 'description': 'Shapes with straight lines and corners', 'emoji': '🟥', 'color': 'green'},
        {'name': 'Special Shapes', 'description': 'Shapes with both curves and points', 'emoji': '❤️', 'color': 'purple'},
      ];
      items = [
        {'name': 'Circle', 'category': 'Round Shapes', 'emoji': '⭕', 'word': 'Circle', 'malay_word': 'Bulatan'},
        {'name': 'Oval', 'category': 'Round Shapes', 'emoji': '🥚', 'word': 'Oval', 'malay_word': 'Bujur'},
        {'name': 'Square', 'category': 'Angular Shapes', 'emoji': '🟥', 'word': 'Square', 'malay_word': 'Segi Empat'},
        {'name': 'Triangle', 'category': 'Angular Shapes', 'emoji': '🔺', 'word': 'Triangle', 'malay_word': 'Segi Tiga'},
        {'name': 'Rectangle', 'category': 'Angular Shapes', 'emoji': '🟩', 'word': 'Rectangle', 'malay_word': 'Segi Empat Tepat'},
        {'name': 'Heart', 'category': 'Special Shapes', 'emoji': '❤️', 'word': 'Heart', 'malay_word': 'Hati'},
        {'name': 'Diamond', 'category': 'Special Shapes', 'emoji': '💎', 'word': 'Diamond', 'malay_word': 'Berlian'},
        {'name': 'Star', 'category': 'Special Shapes', 'emoji': '⭐', 'word': 'Star', 'malay_word': 'Bintang'},
      ];
    }
    
    return {
      'title': 'Math - Shapes & Patterns',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Math',
        'chapter': 'Shapes & Patterns',
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
    
    if (ageGroup == 4) {
      // Age 4: 2 simple shapes (circle and square)
      instructions = 'Trace these simple shapes.';
      difficulty = 'easy';
      items = [
        {
          'character': '○',
          'difficulty': 1,
          'instruction': 'Trace the circle - Bulatan',
          'emoji': '⭕',
          'word': 'Circle',
          'malay_word': 'Bulatan',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.8, 'y': 0.5},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.2, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.5, 'y': 0.2},
          ]
        },
        {
          'character': '□',
          'difficulty': 1,
          'instruction': 'Trace the square - Segi Empat',
          'emoji': '🟥',
          'word': 'Square',
          'malay_word': 'Segi Empat',
          'pathPoints': [
            {'x': 0.3, 'y': 0.3},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.3, 'y': 0.3},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 4 shapes (circle, square, triangle, rectangle)
      instructions = 'Trace these shapes following the correct stroke order.';
      difficulty = 'medium';
      items = [
        {
          'character': '○',
          'difficulty': 1,
          'instruction': 'Trace the circle - Bulatan',
          'emoji': '⭕',
          'word': 'Circle',
          'malay_word': 'Bulatan',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.8, 'y': 0.5},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.2, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.5, 'y': 0.2},
          ]
        },
        {
          'character': '□',
          'difficulty': 1,
          'instruction': 'Trace the square - Segi Empat',
          'emoji': '🟥',
          'word': 'Square',
          'malay_word': 'Segi Empat',
          'pathPoints': [
            {'x': 0.3, 'y': 0.3},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.3, 'y': 0.3},
          ]
        },
        {
          'character': '△',
          'difficulty': 1,
          'instruction': 'Trace the triangle - Segi Tiga',
          'emoji': '🔺',
          'word': 'Triangle',
          'malay_word': 'Segi Tiga',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.8, 'y': 0.7},
            {'x': 0.2, 'y': 0.7},
            {'x': 0.5, 'y': 0.2},
          ]
        },
        {
          'character': '▭',
          'difficulty': 1,
          'instruction': 'Trace the rectangle - Segi Empat Tepat',
          'emoji': '🟩',
          'word': 'Rectangle',
          'malay_word': 'Segi Empat Tepat',
          'pathPoints': [
            {'x': 0.3, 'y': 0.3},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.3, 'y': 0.6},
            {'x': 0.3, 'y': 0.3},
          ]
        },
      ];
    } else {
      // Age 6: All 5 shapes including the more complex star
      instructions = 'Trace these shapes following the correct stroke order and direction.';
      difficulty = 'hard';
      items = [
        {
          'character': '○',
          'difficulty': 1,
          'instruction': 'Trace the circle - Bulatan',
          'emoji': '⭕',
          'word': 'Circle',
          'malay_word': 'Bulatan',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.8, 'y': 0.5},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.2, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.5, 'y': 0.2},
          ]
        },
        {
          'character': '□',
          'difficulty': 1,
          'instruction': 'Trace the square - Segi Empat',
          'emoji': '🟥',
          'word': 'Square',
          'malay_word': 'Segi Empat',
          'pathPoints': [
            {'x': 0.3, 'y': 0.3},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.3, 'y': 0.3},
          ]
        },
        {
          'character': '△',
          'difficulty': 1,
          'instruction': 'Trace the triangle - Segi Tiga',
          'emoji': '🔺',
          'word': 'Triangle',
          'malay_word': 'Segi Tiga',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.8, 'y': 0.7},
            {'x': 0.2, 'y': 0.7},
            {'x': 0.5, 'y': 0.2},
          ]
        },
        {
          'character': '▭',
          'difficulty': 1,
          'instruction': 'Trace the rectangle - Segi Empat Tepat',
          'emoji': '🟩',
          'word': 'Rectangle',
          'malay_word': 'Segi Empat Tepat',
          'pathPoints': [
            {'x': 0.3, 'y': 0.3},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.3, 'y': 0.6},
            {'x': 0.3, 'y': 0.3},
          ]
        },
        {
          'character': '★',
          'difficulty': 2,
          'instruction': 'Trace the star - Bintang',
          'emoji': '⭐',
          'word': 'Star',
          'malay_word': 'Bintang',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.8, 'y': 0.4},
            {'x': 0.65, 'y': 0.55},
            {'x': 0.7, 'y': 0.8},
            {'x': 0.5, 'y': 0.65},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.35, 'y': 0.55},
            {'x': 0.2, 'y': 0.4},
            {'x': 0.4, 'y': 0.4},
            {'x': 0.5, 'y': 0.2},
          ]
        },
      ];
    }
    
    return {
      'title': 'Math - Shapes & Patterns',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Math',
        'chapter': 'Shapes & Patterns',
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
    
    if (ageGroup == 4) {
      // Age 4: 3 basic shapes with primary colors
      instructions = 'Find the shape with the correct color.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Red Circle', 'malay_shape': 'Bulatan', 'malay_color': 'Merah'},
        {'shape': 'square', 'color': 'blue', 'name': 'Blue Square', 'malay_shape': 'Segi Empat', 'malay_color': 'Biru'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Green Triangle', 'malay_shape': 'Segi Tiga', 'malay_color': 'Hijau'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 5 shapes with more colors
      instructions = 'Find the shape that completes the pattern with the correct color.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Red Circle', 'malay_shape': 'Bulatan', 'malay_color': 'Merah'},
        {'shape': 'square', 'color': 'blue', 'name': 'Blue Square', 'malay_shape': 'Segi Empat', 'malay_color': 'Biru'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Green Triangle', 'malay_shape': 'Segi Tiga', 'malay_color': 'Hijau'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Yellow Rectangle', 'malay_shape': 'Segi Empat Tepat', 'malay_color': 'Kuning'},
        {'shape': 'star', 'color': 'purple', 'name': 'Purple Star', 'malay_shape': 'Bintang', 'malay_color': 'Ungu'},
      ];
    } else {
      // Age 6: All 8 shapes with various colors
      instructions = 'Find the shape that completes the pattern with the correct color and name in both languages.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Red Circle', 'malay_shape': 'Bulatan', 'malay_color': 'Merah'},
        {'shape': 'square', 'color': 'blue', 'name': 'Blue Square', 'malay_shape': 'Segi Empat', 'malay_color': 'Biru'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Green Triangle', 'malay_shape': 'Segi Tiga', 'malay_color': 'Hijau'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Yellow Rectangle', 'malay_shape': 'Segi Empat Tepat', 'malay_color': 'Kuning'},
        {'shape': 'star', 'color': 'purple', 'name': 'Purple Star', 'malay_shape': 'Bintang', 'malay_color': 'Ungu'},
        {'shape': 'heart', 'color': 'pink', 'name': 'Pink Heart', 'malay_shape': 'Hati', 'malay_color': 'Merah Jambu'},
        {'shape': 'diamond', 'color': 'orange', 'name': 'Orange Diamond', 'malay_shape': 'Berlian', 'malay_color': 'Oren'},
        {'shape': 'oval', 'color': 'teal', 'name': 'Teal Oval', 'malay_shape': 'Bujur', 'malay_color': 'Hijau Kebiruan'},
      ];
    }
    
    return {
      'title': 'Math - Shapes & Patterns',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Math',
        'chapter': 'Shapes & Patterns',
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
