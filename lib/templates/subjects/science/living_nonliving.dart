import 'dart:math';

/// Template for Science - Living vs Non-living Things chapter
class LivingNonlivingTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: Simple matching with basic descriptions
      instructions = 'Match the items with their correct category: Living or Non-living.';
      difficulty = 'easy';
      pairs = [
        {'word': 'Living', 'emoji': '🐱', 'description': 'Cats move and eat', 'malay_word': 'Hidup'},
        {'word': 'Living', 'emoji': '🌳', 'description': 'Trees grow', 'malay_word': 'Hidup'},
        {'word': 'Non-living', 'emoji': '🪨', 'description': 'Rocks do not move', 'malay_word': 'Bukan Hidup'},
        {'word': 'Non-living', 'emoji': '🪑', 'description': 'Chairs do not eat', 'malay_word': 'Bukan Hidup'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with more items and detailed descriptions
      instructions = 'Match the items with their correct category. Learn why they are living or non-living.';
      difficulty = 'medium';
      pairs = [
        {'word': 'Living', 'emoji': '🐱', 'description': 'Cats are living animals that breathe and move', 'malay_word': 'Hidup'},
        {'word': 'Living', 'emoji': '🌳', 'description': 'Trees are living things that grow and need water', 'malay_word': 'Hidup'},
        {'word': 'Living', 'emoji': '🌸', 'description': 'Flowers are living plants that grow', 'malay_word': 'Hidup'},
        {'word': 'Non-living', 'emoji': '🪨', 'description': 'Rocks do not grow or need food', 'malay_word': 'Bukan Hidup'},
        {'word': 'Non-living', 'emoji': '🪑', 'description': 'Chairs are objects made by humans', 'malay_word': 'Bukan Hidup'},
        {'word': 'Non-living', 'emoji': '⚽', 'description': 'Balls do not grow or breathe', 'malay_word': 'Bukan Hidup'},
      ];
    } else {
      // Age 6: Complex with all items and comprehensive bilingual descriptions
      instructions = 'Match the items with their correct category and learn their characteristics in English and Malay.';
      difficulty = 'hard';
      pairs = [
        {'word': 'Living', 'emoji': '🐱', 'description': 'Cats are living animals that breathe, move, eat, and reproduce', 'malay_word': 'Hidup'},
        {'word': 'Living', 'emoji': '🌳', 'description': 'Trees are living things that grow, need water, and make their own food', 'malay_word': 'Hidup'},
        {'word': 'Living', 'emoji': '🌸', 'description': 'Flowers are living plants that grow and reproduce', 'malay_word': 'Hidup'},
        {'word': 'Living', 'emoji': '🐦', 'description': 'Birds are living animals that fly, eat, and lay eggs', 'malay_word': 'Hidup'},
        {'word': 'Non-living', 'emoji': '🪨', 'description': 'Rocks do not grow, breathe, or need food', 'malay_word': 'Bukan Hidup'},
        {'word': 'Non-living', 'emoji': '🪑', 'description': 'Chairs are objects made by humans and cannot move on their own', 'malay_word': 'Bukan Hidup'},
        {'word': 'Non-living', 'emoji': '⚽', 'description': 'Balls do not grow, breathe, or reproduce', 'malay_word': 'Bukan Hidup'},
        {'word': 'Non-living', 'emoji': '🚗', 'description': 'Cars are machines that do not grow or reproduce', 'malay_word': 'Bukan Hidup'},
      ];
    }
    
    return {
      'title': 'Science - Living vs Non-living Things',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Science',
        'chapter': 'Living vs Non-living Things',
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
    
    // Common categories for all age groups
    categories = [
      {'name': 'Living Things', 'description': 'Things that grow, breathe, and need food', 'emoji': '🌳', 'color': 'green'},
      {'name': 'Non-living Things', 'description': 'Things that do not grow or need food', 'emoji': '🪨', 'color': 'blue'},
    ];
    
    if (ageGroup == 4) {
      // Age 4: Simple sorting with fewer items
      instructions = 'Sort these things into living and non-living groups.';
      difficulty = 'easy';
      items = [
        {'name': 'Tree', 'category': 'Living Things', 'emoji': '🌳', 'word': 'Tree', 'malay_word': 'Pokok'},
        {'name': 'Dog', 'category': 'Living Things', 'emoji': '🐕', 'word': 'Dog', 'malay_word': 'Anjing'},
        {'name': 'Flower', 'category': 'Living Things', 'emoji': '🌸', 'word': 'Flower', 'malay_word': 'Bunga'},
        {'name': 'Rock', 'category': 'Non-living Things', 'emoji': '🪨', 'word': 'Rock', 'malay_word': 'Batu'},
        {'name': 'Chair', 'category': 'Non-living Things', 'emoji': '🪑', 'word': 'Chair', 'malay_word': 'Kerusi'},
        {'name': 'Ball', 'category': 'Non-living Things', 'emoji': '⚽', 'word': 'Ball', 'malay_word': 'Bola'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with more items and bilingual labels
      instructions = 'Sort the items into living and non-living categories. Learn their names in English and Malay.';
      difficulty = 'medium';
      items = [
        {'name': 'Tree', 'category': 'Living Things', 'emoji': '🌳', 'word': 'Tree', 'malay_word': 'Pokok'},
        {'name': 'Dog', 'category': 'Living Things', 'emoji': '🐕', 'word': 'Dog', 'malay_word': 'Anjing'},
        {'name': 'Flower', 'category': 'Living Things', 'emoji': '🌸', 'word': 'Flower', 'malay_word': 'Bunga'},
        {'name': 'Fish', 'category': 'Living Things', 'emoji': '🐠', 'word': 'Fish', 'malay_word': 'Ikan'},
        {'name': 'Rock', 'category': 'Non-living Things', 'emoji': '🪨', 'word': 'Rock', 'malay_word': 'Batu'},
        {'name': 'Chair', 'category': 'Non-living Things', 'emoji': '🪑', 'word': 'Chair', 'malay_word': 'Kerusi'},
        {'name': 'Ball', 'category': 'Non-living Things', 'emoji': '⚽', 'word': 'Ball', 'malay_word': 'Bola'},
        {'name': 'Car', 'category': 'Non-living Things', 'emoji': '🚗', 'word': 'Car', 'malay_word': 'Kereta'},
      ];
    } else {
      // Age 6: Complex with all items and comprehensive bilingual descriptions
      instructions = 'Sort the items into living and non-living categories. Explain why each belongs to its category in both English and Malay.';
      difficulty = 'hard';
      items = [
        {'name': 'Tree', 'category': 'Living Things', 'emoji': '🌳', 'word': 'Tree', 'malay_word': 'Pokok'},
        {'name': 'Dog', 'category': 'Living Things', 'emoji': '🐕', 'word': 'Dog', 'malay_word': 'Anjing'},
        {'name': 'Flower', 'category': 'Living Things', 'emoji': '🌸', 'word': 'Flower', 'malay_word': 'Bunga'},
        {'name': 'Fish', 'category': 'Living Things', 'emoji': '🐠', 'word': 'Fish', 'malay_word': 'Ikan'},
        {'name': 'Human', 'category': 'Living Things', 'emoji': '👦', 'word': 'Human', 'malay_word': 'Manusia'},
        {'name': 'Rock', 'category': 'Non-living Things', 'emoji': '🪨', 'word': 'Rock', 'malay_word': 'Batu'},
        {'name': 'Chair', 'category': 'Non-living Things', 'emoji': '🪑', 'word': 'Chair', 'malay_word': 'Kerusi'},
        {'name': 'Ball', 'category': 'Non-living Things', 'emoji': '⚽', 'word': 'Ball', 'malay_word': 'Bola'},
        {'name': 'Car', 'category': 'Non-living Things', 'emoji': '🚗', 'word': 'Car', 'malay_word': 'Kereta'},
        {'name': 'Book', 'category': 'Non-living Things', 'emoji': '📚', 'word': 'Book', 'malay_word': 'Buku'},
      ];
    }
    
    return {
      'title': 'Science - Living vs Non-living Things',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Science',
        'chapter': 'Living vs Non-living Things',
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
      // Age 4: Simple tracing with 2 basic letters
      instructions = 'Trace the letters to learn about living and non-living things.';
      difficulty = 'easy';
      items = [
        {
          'character': 'L',
          'difficulty': 1,
          'instruction': 'Trace the letter L for Living',
          'emoji': '🌱',
          'word': 'Living',
          'malay_word': 'Hidup',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'R',
          'difficulty': 1,
          'instruction': 'Trace the letter R for Rock',
          'emoji': '🪨',
          'word': 'Rock',
          'malay_word': 'Batu',
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
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 3 letters and bilingual instructions
      instructions = 'Trace the letters to learn about living and non-living things. Learn their names in English and Malay.';
      difficulty = 'medium';
      items = [
        {
          'character': 'L',
          'difficulty': 1,
          'instruction': 'Trace the letter L for Living - Hidup',
          'emoji': '🌱',
          'word': 'Living',
          'malay_word': 'Hidup',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'T',
          'difficulty': 1,
          'instruction': 'Trace the letter T for Tree - Pokok',
          'emoji': '🌳',
          'word': 'Tree',
          'malay_word': 'Pokok',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'R',
          'difficulty': 1,
          'instruction': 'Trace the letter R for Rock - Batu',
          'emoji': '🪨',
          'word': 'Rock',
          'malay_word': 'Batu',
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
      ];
    } else {
      // Age 6: Complex with all 5 letters and comprehensive bilingual instructions
      instructions = 'Trace the letters to learn about living and non-living things. Understand the characteristics of each in English and Malay.';
      difficulty = 'hard';
      items = [
        {
          'character': 'L',
          'difficulty': 1,
          'instruction': 'Trace the letter L for Living (Hidup) - things that grow and need food',
          'emoji': '🌱',
          'word': 'Living',
          'malay_word': 'Hidup',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'T',
          'difficulty': 1,
          'instruction': 'Trace the letter T for Tree (Pokok) - a living thing that grows',
          'emoji': '🌳',
          'word': 'Tree',
          'malay_word': 'Pokok',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'A',
          'difficulty': 1,
          'instruction': 'Trace the letter A for Animal (Haiwan) - living things that move and eat',
          'emoji': '🐕',
          'word': 'Animal',
          'malay_word': 'Haiwan',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.7, 'y': 0.8},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
          ]
        },
        {
          'character': 'R',
          'difficulty': 2,
          'instruction': 'Trace the letter R for Rock (Batu) - a non-living thing that does not grow',
          'emoji': '🪨',
          'word': 'Rock',
          'malay_word': 'Batu',
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
          'character': 'C',
          'difficulty': 1,
          'instruction': 'Trace the letter C for Car (Kereta) - a non-living thing made by humans',
          'emoji': '🚗',
          'word': 'Car',
          'malay_word': 'Kereta',
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
          ]
        },
      ];
    }
    
    return {
      'title': 'Science - Living vs Non-living Things',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Science',
        'chapter': 'Living vs Non-living Things',
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
      // Age 4: Simple with 4 basic shapes
      instructions = 'Identify if the object is living or non-living.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'tree', 'color': 'green', 'name': 'Tree (Living)', 'malay_shape': 'Pokok', 'malay_color': 'Hijau', 'word': 'Tree', 'malay_word': 'Pokok'},
        {'shape': 'dog', 'color': 'brown', 'name': 'Dog (Living)', 'malay_shape': 'Anjing', 'malay_color': 'Coklat', 'word': 'Dog', 'malay_word': 'Anjing'},
        {'shape': 'rock', 'color': 'gray', 'name': 'Rock (Non-living)', 'malay_shape': 'Batu', 'malay_color': 'Kelabu', 'word': 'Rock', 'malay_word': 'Batu'},
        {'shape': 'ball', 'color': 'red', 'name': 'Ball (Non-living)', 'malay_shape': 'Bola', 'malay_color': 'Merah', 'word': 'Ball', 'malay_word': 'Bola'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 6 shapes and bilingual names
      instructions = 'Identify if the object is living or non-living. Learn their names in English and Malay.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'tree', 'color': 'green', 'name': 'Tree (Living)', 'malay_shape': 'Pokok', 'malay_color': 'Hijau', 'word': 'Tree', 'malay_word': 'Pokok'},
        {'shape': 'dog', 'color': 'brown', 'name': 'Dog (Living)', 'malay_shape': 'Anjing', 'malay_color': 'Coklat', 'word': 'Dog', 'malay_word': 'Anjing'},
        {'shape': 'flower', 'color': 'pink', 'name': 'Flower (Living)', 'malay_shape': 'Bunga', 'malay_color': 'Merah Jambu', 'word': 'Flower', 'malay_word': 'Bunga'},
        {'shape': 'rock', 'color': 'gray', 'name': 'Rock (Non-living)', 'malay_shape': 'Batu', 'malay_color': 'Kelabu', 'word': 'Rock', 'malay_word': 'Batu'},
        {'shape': 'chair', 'color': 'brown', 'name': 'Chair (Non-living)', 'malay_shape': 'Kerusi', 'malay_color': 'Coklat', 'word': 'Chair', 'malay_word': 'Kerusi'},
        {'shape': 'ball', 'color': 'red', 'name': 'Ball (Non-living)', 'malay_shape': 'Bola', 'malay_color': 'Merah', 'word': 'Ball', 'malay_word': 'Bola'},
      ];
    } else {
      // Age 6: Complex with all 8 shapes, colors, and comprehensive bilingual descriptions
      instructions = 'Identify if the object is living or non-living. Learn their names, colors, and characteristics in English and Malay.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'tree', 'color': 'green', 'name': 'Tree (Living)', 'malay_shape': 'Pokok (Hidup)', 'malay_color': 'Hijau', 'word': 'Tree', 'malay_word': 'Pokok'},
        {'shape': 'dog', 'color': 'brown', 'name': 'Dog (Living)', 'malay_shape': 'Anjing (Hidup)', 'malay_color': 'Coklat', 'word': 'Dog', 'malay_word': 'Anjing'},
        {'shape': 'flower', 'color': 'pink', 'name': 'Flower (Living)', 'malay_shape': 'Bunga (Hidup)', 'malay_color': 'Merah Jambu', 'word': 'Flower', 'malay_word': 'Bunga'},
        {'shape': 'fish', 'color': 'blue', 'name': 'Fish (Living)', 'malay_shape': 'Ikan (Hidup)', 'malay_color': 'Biru', 'word': 'Fish', 'malay_word': 'Ikan'},
        {'shape': 'rock', 'color': 'gray', 'name': 'Rock (Non-living)', 'malay_shape': 'Batu (Bukan Hidup)', 'malay_color': 'Kelabu', 'word': 'Rock', 'malay_word': 'Batu'},
        {'shape': 'chair', 'color': 'brown', 'name': 'Chair (Non-living)', 'malay_shape': 'Kerusi (Bukan Hidup)', 'malay_color': 'Coklat', 'word': 'Chair', 'malay_word': 'Kerusi'},
        {'shape': 'ball', 'color': 'red', 'name': 'Ball (Non-living)', 'malay_shape': 'Bola (Bukan Hidup)', 'malay_color': 'Merah', 'word': 'Ball', 'malay_word': 'Bola'},
        {'shape': 'car', 'color': 'yellow', 'name': 'Car (Non-living)', 'malay_shape': 'Kereta (Bukan Hidup)', 'malay_color': 'Kuning', 'word': 'Car', 'malay_word': 'Kereta'},
      ];
    }
    
    return {
      'title': 'Science - Living vs Non-living Things',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Science',
        'chapter': 'Living vs Non-living Things',
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
