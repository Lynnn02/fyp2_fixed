import 'dart:math';

/// Template for Art & Craft - Color Exploration & Mixing chapter
class ColorExplorationTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    
    // Age-specific content
    if (ageGroup == 4) {
      // Age 4: Exactly 5 items with one-word descriptions
      pairs = [
        {'word': 'Red', 'emoji': '🔴', 'description': 'Apple', 'malay_word': 'Merah'},
        {'word': 'Blue', 'emoji': '🔵', 'description': 'Sky', 'malay_word': 'Biru'},
        {'word': 'Yellow', 'emoji': '🟡', 'description': 'Sun', 'malay_word': 'Kuning'},
        {'word': 'Green', 'emoji': '🟢', 'description': 'Grass', 'malay_word': 'Hijau'},
        {'word': 'Orange', 'emoji': '🟠', 'description': 'Fruit', 'malay_word': 'Oren'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 5-7 items with short phrases
      pairs = [
        {'word': 'Red', 'emoji': '🔴', 'description': 'Like an apple', 'malay_word': 'Merah'},
        {'word': 'Blue', 'emoji': '🔵', 'description': 'In the sky', 'malay_word': 'Biru'},
        {'word': 'Yellow', 'emoji': '🟡', 'description': 'Like the sun', 'malay_word': 'Kuning'},
        {'word': 'Green', 'emoji': '🟢', 'description': 'On the trees', 'malay_word': 'Hijau'},
        {'word': 'Orange', 'emoji': '🟠', 'description': 'Like a carrot', 'malay_word': 'Oren'},
        {'word': 'Purple', 'emoji': '🟣', 'description': 'Like grapes', 'malay_word': 'Ungu'},
        {'word': 'Pink', 'emoji': '🩷', 'description': 'Like cotton candy', 'malay_word': 'Merah Jambu'},
      ];
    } else {
      // Age 6: 7-10 items with full sentences
      pairs = [
        {'word': 'Red', 'emoji': '🔴', 'description': 'This is the color of apples and strawberries.', 'malay_word': 'Merah'},
        {'word': 'Blue', 'emoji': '🔵', 'description': 'This is the color of the sky and ocean.', 'malay_word': 'Biru'},
        {'word': 'Yellow', 'emoji': '🟡', 'description': 'This is the color of the sun and bananas.', 'malay_word': 'Kuning'},
        {'word': 'Green', 'emoji': '🟢', 'description': 'This is the color of grass and leaves.', 'malay_word': 'Hijau'},
        {'word': 'Orange', 'emoji': '🟠', 'description': 'This is the color of oranges and carrots.', 'malay_word': 'Oren'},
        {'word': 'Purple', 'emoji': '🟣', 'description': 'This is the color of grapes and eggplants.', 'malay_word': 'Ungu'},
        {'word': 'Pink', 'emoji': '🩷', 'description': 'This is the color of cotton candy and flamingos.', 'malay_word': 'Merah Jambu'},
        {'word': 'Brown', 'emoji': '🟤', 'description': 'This is the color of chocolate and tree trunks.', 'malay_word': 'Coklat'},
        {'word': 'White', 'emoji': '⚪', 'description': 'This is the color of clouds and snow.', 'malay_word': 'Putih'},
        {'word': 'Black', 'emoji': '⚫', 'description': 'This is the color of night and shadows.', 'malay_word': 'Hitam'},
      ];
    }
    
    return {
      'title': 'Art & Craft - Color Exploration & Mixing',
      'instructions': 'Match the colors with their names.',
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Art & Craft',
        'chapter': 'Color Exploration & Mixing',
        'ageGroup': ageGroup,
        'difficulty': ageGroup == 4 ? 'easy' : (ageGroup == 5 ? 'medium' : 'hard'),
      }
    };
  }

  /// Get sorting game content
  static Map<String, dynamic> getSortingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> categories = [];
    List<Map<String, dynamic>> items = [];
    
    // Age-specific categories
    if (ageGroup == 4) {
      // Simpler categories for age 4
      categories = [
        {'name': 'Warm Colors', 'description': 'Hot', 'emoji': '🔴', 'color': 'red'},
        {'name': 'Cool Colors', 'description': 'Cold', 'emoji': '🔵', 'color': 'blue'},
      ];
      
      // Exactly 5 items for age 4
      items = [
        {'name': 'Red', 'category': 'Warm Colors', 'emoji': '🔴', 'word': 'Red', 'malay_word': 'Merah'},
        {'name': 'Orange', 'category': 'Warm Colors', 'emoji': '🟠', 'word': 'Orange', 'malay_word': 'Oren'},
        {'name': 'Yellow', 'category': 'Warm Colors', 'emoji': '🟡', 'word': 'Yellow', 'malay_word': 'Kuning'},
        {'name': 'Blue', 'category': 'Cool Colors', 'emoji': '🔵', 'word': 'Blue', 'malay_word': 'Biru'},
        {'name': 'Green', 'category': 'Cool Colors', 'emoji': '🟢', 'word': 'Green', 'malay_word': 'Hijau'},
      ];
    } else if (ageGroup == 5) {
      // More detailed categories for age 5
      categories = [
        {'name': 'Primary Colors', 'description': 'Basic colors', 'emoji': '🔴', 'color': 'red'},
        {'name': 'Secondary Colors', 'description': 'Mixed colors', 'emoji': '🟢', 'color': 'green'},
      ];
      
      // 6 items for age 5
      items = [
        {'name': 'Red', 'category': 'Primary Colors', 'emoji': '🔴', 'word': 'Red', 'malay_word': 'Merah'},
        {'name': 'Blue', 'category': 'Primary Colors', 'emoji': '🔵', 'word': 'Blue', 'malay_word': 'Biru'},
        {'name': 'Yellow', 'category': 'Primary Colors', 'emoji': '🟡', 'word': 'Yellow', 'malay_word': 'Kuning'},
        {'name': 'Orange', 'category': 'Secondary Colors', 'emoji': '🟠', 'word': 'Orange', 'malay_word': 'Oren'},
        {'name': 'Green', 'category': 'Secondary Colors', 'emoji': '🟢', 'word': 'Green', 'malay_word': 'Hijau'},
        {'name': 'Purple', 'category': 'Secondary Colors', 'emoji': '🟣', 'word': 'Purple', 'malay_word': 'Ungu'},
      ];
    } else {
      // Full categories for age 6
      categories = [
        {'name': 'Primary Colors', 'description': 'Colors that cannot be made by mixing other colors', 'emoji': '🔴', 'color': 'red'},
        {'name': 'Secondary Colors', 'description': 'Colors made by mixing two primary colors', 'emoji': '🟢', 'color': 'green'},
        {'name': 'Neutral Colors', 'description': 'Colors that work well with other colors', 'emoji': '⚪', 'color': 'white'},
      ];
      
      // 9 items for age 6
      items = [
        {'name': 'Red', 'category': 'Primary Colors', 'emoji': '🔴', 'word': 'Red', 'malay_word': 'Merah'},
        {'name': 'Blue', 'category': 'Primary Colors', 'emoji': '🔵', 'word': 'Blue', 'malay_word': 'Biru'},
        {'name': 'Yellow', 'category': 'Primary Colors', 'emoji': '🟡', 'word': 'Yellow', 'malay_word': 'Kuning'},
        {'name': 'Orange', 'category': 'Secondary Colors', 'emoji': '🟠', 'word': 'Orange', 'malay_word': 'Oren'},
        {'name': 'Green', 'category': 'Secondary Colors', 'emoji': '🟢', 'word': 'Green', 'malay_word': 'Hijau'},
        {'name': 'Purple', 'category': 'Secondary Colors', 'emoji': '🟣', 'word': 'Purple', 'malay_word': 'Ungu'},
        {'name': 'White', 'category': 'Neutral Colors', 'emoji': '⚪', 'word': 'White', 'malay_word': 'Putih'},
        {'name': 'Black', 'category': 'Neutral Colors', 'emoji': '⚫', 'word': 'Black', 'malay_word': 'Hitam'},
        {'name': 'Brown', 'category': 'Neutral Colors', 'emoji': '🟤', 'word': 'Brown', 'malay_word': 'Coklat'},
      ];
    }
    
    return {
      'title': 'Art & Craft - Color Exploration & Mixing',
      'instructions': 'Sort the colors into their categories.',
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Art & Craft',
        'chapter': 'Color Exploration & Mixing',
        'ageGroup': ageGroup,
        'difficulty': ageGroup == 4 ? 'easy' : (ageGroup == 5 ? 'medium' : 'hard'),
      }
    };
  }

  /// Get tracing game content
  static Map<String, dynamic> getTracingContent(int ageGroup) {
    List<Map<String, dynamic>> items = [];
    
    // Age-specific content
    if (ageGroup == 4) {
      // Simpler tracing for age 4 - exactly 5 items
      items = [
        {
          'character': 'R',
          'difficulty': 1,
          'instruction': 'Trace R',
          'emoji': '🔴',
          'word': 'Red',
          'malay_word': 'Merah',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.5, 'y': 0.4},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'B',
          'difficulty': 1,
          'instruction': 'Trace B',
          'emoji': '🔵',
          'word': 'Blue',
          'malay_word': 'Biru',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.6, 'y': 0.8},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': 'Y',
          'difficulty': 1,
          'instruction': 'Trace Y',
          'emoji': '🟡',
          'word': 'Yellow',
          'malay_word': 'Kuning',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'G',
          'difficulty': 1,
          'instruction': 'Trace G',
          'emoji': '🟢',
          'word': 'Green',
          'malay_word': 'Hijau',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.3, 'y': 0.6},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.6, 'y': 0.8},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.5, 'y': 0.6},
          ]
        },
        {
          'character': 'O',
          'difficulty': 1,
          'instruction': 'Trace O',
          'emoji': '🟠',
          'word': 'Orange',
          'malay_word': 'Oren',
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
      ];
    } else if (ageGroup == 5) {
      // Medium complexity for age 5 - 5 items with short phrases
      items = [
        {
          'character': 'R',
          'difficulty': 1,
          'instruction': 'Trace R for Red',
          'emoji': '🔴',
          'word': 'Red',
          'malay_word': 'Merah',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.5, 'y': 0.4},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'B',
          'difficulty': 1,
          'instruction': 'Trace B for Blue',
          'emoji': '🔵',
          'word': 'Blue',
          'malay_word': 'Biru',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.6, 'y': 0.8},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': 'Y',
          'difficulty': 1,
          'instruction': 'Trace Y for Yellow',
          'emoji': '🟡',
          'word': 'Yellow',
          'malay_word': 'Kuning',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'G',
          'difficulty': 1,
          'instruction': 'Trace G for Green',
          'emoji': '🟢',
          'word': 'Green',
          'malay_word': 'Hijau',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.3, 'y': 0.6},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.6, 'y': 0.8},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.5, 'y': 0.6},
          ]
        },
        {
          'character': 'O',
          'difficulty': 1,
          'instruction': 'Trace O for Orange',
          'emoji': '🟠',
          'word': 'Orange',
          'malay_word': 'Oren',
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
          'character': 'P',
          'difficulty': 1,
          'instruction': 'Trace P for Purple',
          'emoji': '🟣',
          'word': 'Purple',
          'malay_word': 'Ungu',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
          ]
        },
      ];
    } else {
      // Full complexity for age 6 - 7 items with full sentences
      items = [
        {
          'character': 'R',
          'difficulty': 1,
          'instruction': 'Trace the letter R for Red',
          'emoji': '🔴',
          'word': 'Red',
          'malay_word': 'Merah',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.5, 'y': 0.4},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'B',
          'difficulty': 1,
          'instruction': 'Trace the letter B for Blue',
          'emoji': '🔵',
          'word': 'Blue',
          'malay_word': 'Biru',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.6, 'y': 0.8},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': 'Y',
          'difficulty': 1,
          'instruction': 'Trace the letter Y for Yellow',
          'emoji': '🟡',
          'word': 'Yellow',
          'malay_word': 'Kuning',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'G',
          'difficulty': 1,
          'instruction': 'Trace the letter G for Green',
          'emoji': '🟢',
          'word': 'Green',
          'malay_word': 'Hijau',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.3, 'y': 0.6},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.6, 'y': 0.8},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.5, 'y': 0.6},
          ]
        },
        {
          'character': 'O',
          'difficulty': 1,
          'instruction': 'Trace the letter O for Orange',
          'emoji': '🟠',
          'word': 'Orange',
          'malay_word': 'Oren',
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
          'character': 'P',
          'difficulty': 1,
          'instruction': 'Trace the letter P for Purple',
          'emoji': '🟣',
          'word': 'Purple',
          'malay_word': 'Ungu',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
          ]
        },
        {
          'character': 'W',
          'difficulty': 1,
          'instruction': 'Trace the letter W for White',
          'emoji': '⚪',
          'word': 'White',
          'malay_word': 'Putih',
          'pathPoints': [
            {'x': 0.2, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.8},
            {'x': 0.8, 'y': 0.2},
          ]
        },
      ];
    }
    
    return {
      'title': 'Art & Craft - Color Exploration & Mixing',
      'instructions': 'Trace the letters to learn about colors.',
      'items': items,
      'metadata': {
        'subject': 'Art & Craft',
        'chapter': 'Color Exploration & Mixing',
        'ageGroup': ageGroup,
        'difficulty': ageGroup == 4 ? 'easy' : (ageGroup == 5 ? 'medium' : 'hard'),
      }
    };
  }

  /// Get shape and color game content
  static Map<String, dynamic> getShapeColorContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> shapes = [];
    
    // Age-specific content
    if (ageGroup == 4) {
      // Age 4: Exactly 5 items with one-word descriptions
      shapes = [
        {'shape': 'red', 'color': 'red', 'name': 'Red', 'malay_shape': 'Merah', 'malay_color': 'Merah', 'word': 'Red', 'malay_word': 'Merah'},
        {'shape': 'blue', 'color': 'blue', 'name': 'Blue', 'malay_shape': 'Biru', 'malay_color': 'Biru', 'word': 'Blue', 'malay_word': 'Biru'},
        {'shape': 'yellow', 'color': 'yellow', 'name': 'Yellow', 'malay_shape': 'Kuning', 'malay_color': 'Kuning', 'word': 'Yellow', 'malay_word': 'Kuning'},
        {'shape': 'green', 'color': 'green', 'name': 'Green', 'malay_shape': 'Hijau', 'malay_color': 'Hijau', 'word': 'Green', 'malay_word': 'Hijau'},
        {'shape': 'orange', 'color': 'orange', 'name': 'Orange', 'malay_shape': 'Oren', 'malay_color': 'Oren', 'word': 'Orange', 'malay_word': 'Oren'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 items with short phrases
      shapes = [
        {'shape': 'red', 'color': 'red', 'name': 'Red', 'malay_shape': 'Merah', 'malay_color': 'Merah', 'word': 'Red', 'malay_word': 'Merah'},
        {'shape': 'blue', 'color': 'blue', 'name': 'Blue', 'malay_shape': 'Biru', 'malay_color': 'Biru', 'word': 'Blue', 'malay_word': 'Biru'},
        {'shape': 'yellow', 'color': 'yellow', 'name': 'Yellow', 'malay_shape': 'Kuning', 'malay_color': 'Kuning', 'word': 'Yellow', 'malay_word': 'Kuning'},
        {'shape': 'red_yellow', 'color': 'orange', 'name': 'Red + Yellow', 'malay_shape': 'Merah + Kuning', 'malay_color': 'Oren', 'word': 'Orange', 'malay_word': 'Oren'},
        {'shape': 'blue_yellow', 'color': 'green', 'name': 'Blue + Yellow', 'malay_shape': 'Biru + Kuning', 'malay_color': 'Hijau', 'word': 'Green', 'malay_word': 'Hijau'},
        {'shape': 'red_blue', 'color': 'purple', 'name': 'Red + Blue', 'malay_shape': 'Merah + Biru', 'malay_color': 'Ungu', 'word': 'Purple', 'malay_word': 'Ungu'},
      ];
    } else {
      // Age 6: 8 items with full sentences
      shapes = [
        {'shape': 'red', 'color': 'red', 'name': 'Red', 'malay_shape': 'Merah', 'malay_color': 'Merah', 'word': 'Red', 'malay_word': 'Merah'},
        {'shape': 'blue', 'color': 'blue', 'name': 'Blue', 'malay_shape': 'Biru', 'malay_color': 'Biru', 'word': 'Blue', 'malay_word': 'Biru'},
        {'shape': 'yellow', 'color': 'yellow', 'name': 'Yellow', 'malay_shape': 'Kuning', 'malay_color': 'Kuning', 'word': 'Yellow', 'malay_word': 'Kuning'},
        {'shape': 'red_yellow', 'color': 'orange', 'name': 'Red + Yellow = Orange', 'malay_shape': 'Merah + Kuning', 'malay_color': 'Oren', 'word': 'Orange', 'malay_word': 'Oren'},
        {'shape': 'blue_yellow', 'color': 'green', 'name': 'Blue + Yellow = Green', 'malay_shape': 'Biru + Kuning', 'malay_color': 'Hijau', 'word': 'Green', 'malay_word': 'Hijau'},
        {'shape': 'red_blue', 'color': 'purple', 'name': 'Red + Blue = Purple', 'malay_shape': 'Merah + Biru', 'malay_color': 'Ungu', 'word': 'Purple', 'malay_word': 'Ungu'},
        {'shape': 'red_white', 'color': 'pink', 'name': 'Red + White = Pink', 'malay_shape': 'Merah + Putih', 'malay_color': 'Merah Jambu', 'word': 'Pink', 'malay_word': 'Merah Jambu'},
        {'shape': 'mix_all', 'color': 'brown', 'name': 'Mix All = Brown', 'malay_shape': 'Campur Semua', 'malay_color': 'Coklat', 'word': 'Brown', 'malay_word': 'Coklat'},
      ];
    }
    
    String instructions = '';
    if (ageGroup == 4) {
      instructions = 'Match colors.';
    } else if (ageGroup == 5) {
      instructions = 'Match colors with their mixed results.';
    } else {
      instructions = 'Match the colors with their mixed results and names.';
    }
    
    return {
      'title': 'Art & Craft - Color Exploration & Mixing',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Art & Craft',
        'chapter': 'Color Exploration & Mixing',
        'ageGroup': ageGroup,
        'difficulty': ageGroup == 4 ? 'easy' : (ageGroup == 5 ? 'medium' : 'hard'),
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
