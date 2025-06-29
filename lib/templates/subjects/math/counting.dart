import 'dart:math';

/// Template for Math - Counting chapter
class CountingTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: 5 simple numbers (1-5)
      instructions = 'Match the numbers with the correct quantity.';
      difficulty = 'easy';
      pairs = [
        {'word': 'One', 'emoji': '1️⃣', 'description': 'One object', 'malay_word': 'Satu'},
        {'word': 'Two', 'emoji': '2️⃣', 'description': 'Two objects', 'malay_word': 'Dua'},
        {'word': 'Three', 'emoji': '3️⃣', 'description': 'Three objects', 'malay_word': 'Tiga'},
        {'word': 'Four', 'emoji': '4️⃣', 'description': 'Four objects', 'malay_word': 'Empat'},
        {'word': 'Five', 'emoji': '5️⃣', 'description': 'Five objects', 'malay_word': 'Lima'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 7 numbers (1-7)
      instructions = 'Match the numbers with their names and quantities.';
      difficulty = 'medium';
      pairs = [
        {'word': 'One', 'emoji': '1️⃣', 'description': 'One object', 'malay_word': 'Satu'},
        {'word': 'Two', 'emoji': '2️⃣', 'description': 'Two objects', 'malay_word': 'Dua'},
        {'word': 'Three', 'emoji': '3️⃣', 'description': 'Three objects', 'malay_word': 'Tiga'},
        {'word': 'Four', 'emoji': '4️⃣', 'description': 'Four objects', 'malay_word': 'Empat'},
        {'word': 'Five', 'emoji': '5️⃣', 'description': 'Five objects', 'malay_word': 'Lima'},
        {'word': 'Six', 'emoji': '6️⃣', 'description': 'Six objects', 'malay_word': 'Enam'},
        {'word': 'Seven', 'emoji': '7️⃣', 'description': 'Seven objects', 'malay_word': 'Tujuh'},
      ];
    } else {
      // Age 6: All 10 numbers (1-10)
      instructions = 'Match the numbers with their names, quantities, and positions in counting sequence.';
      difficulty = 'hard';
      pairs = [
        {'word': 'One', 'emoji': '1️⃣', 'description': 'First number', 'malay_word': 'Satu'},
        {'word': 'Two', 'emoji': '2️⃣', 'description': 'Second number', 'malay_word': 'Dua'},
        {'word': 'Three', 'emoji': '3️⃣', 'description': 'Third number', 'malay_word': 'Tiga'},
        {'word': 'Four', 'emoji': '4️⃣', 'description': 'Fourth number', 'malay_word': 'Empat'},
        {'word': 'Five', 'emoji': '5️⃣', 'description': 'Fifth number', 'malay_word': 'Lima'},
        {'word': 'Six', 'emoji': '6️⃣', 'description': 'Sixth number', 'malay_word': 'Enam'},
        {'word': 'Seven', 'emoji': '7️⃣', 'description': 'Seventh number', 'malay_word': 'Tujuh'},
        {'word': 'Eight', 'emoji': '8️⃣', 'description': 'Eighth number', 'malay_word': 'Lapan'},
        {'word': 'Nine', 'emoji': '9️⃣', 'description': 'Ninth number', 'malay_word': 'Sembilan'},
        {'word': 'Ten', 'emoji': '🔟', 'description': 'Tenth number', 'malay_word': 'Sepuluh'},
      ];
    }
    
    return {
      'title': 'Math - Counting',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Math',
        'chapter': 'Counting',
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
      // Age 4: Simple sorting with 5 numbers (1-5) in one category
      instructions = 'Put the numbers in order from 1 to 5.';
      difficulty = 'easy';
      categories = [
        {'name': 'Numbers', 'description': 'Numbers from 1 to 5', 'emoji': '1️⃣', 'color': 'blue'},
      ];
      items = [
        {'name': '1', 'category': 'Numbers', 'emoji': '1️⃣', 'word': 'One', 'malay_word': 'Satu'},
        {'name': '2', 'category': 'Numbers', 'emoji': '2️⃣', 'word': 'Two', 'malay_word': 'Dua'},
        {'name': '3', 'category': 'Numbers', 'emoji': '3️⃣', 'word': 'Three', 'malay_word': 'Tiga'},
        {'name': '4', 'category': 'Numbers', 'emoji': '4️⃣', 'word': 'Four', 'malay_word': 'Empat'},
        {'name': '5', 'category': 'Numbers', 'emoji': '5️⃣', 'word': 'Five', 'malay_word': 'Lima'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Two categories with 7 numbers (1-7)
      instructions = 'Sort the numbers into small (1-3) and medium (4-7) groups.';
      difficulty = 'medium';
      categories = [
        {'name': 'Small Numbers', 'description': 'Numbers from 1 to 3', 'emoji': '1️⃣', 'color': 'blue'},
        {'name': 'Medium Numbers', 'description': 'Numbers from 4 to 7', 'emoji': '4️⃣', 'color': 'green'},
      ];
      items = [
        {'name': '1', 'category': 'Small Numbers', 'emoji': '1️⃣', 'word': 'One', 'malay_word': 'Satu'},
        {'name': '2', 'category': 'Small Numbers', 'emoji': '2️⃣', 'word': 'Two', 'malay_word': 'Dua'},
        {'name': '3', 'category': 'Small Numbers', 'emoji': '3️⃣', 'word': 'Three', 'malay_word': 'Tiga'},
        {'name': '4', 'category': 'Medium Numbers', 'emoji': '4️⃣', 'word': 'Four', 'malay_word': 'Empat'},
        {'name': '5', 'category': 'Medium Numbers', 'emoji': '5️⃣', 'word': 'Five', 'malay_word': 'Lima'},
        {'name': '6', 'category': 'Medium Numbers', 'emoji': '6️⃣', 'word': 'Six', 'malay_word': 'Enam'},
        {'name': '7', 'category': 'Medium Numbers', 'emoji': '7️⃣', 'word': 'Seven', 'malay_word': 'Tujuh'},
      ];
    } else {
      // Age 6: Three categories with all 10 numbers
      instructions = 'Sort the numbers into small (1-3), medium (4-7), and large (8-10) groups.';
      difficulty = 'hard';
      categories = [
        {'name': 'Small Numbers', 'description': 'Numbers from 1 to 3', 'emoji': '1️⃣', 'color': 'blue'},
        {'name': 'Medium Numbers', 'description': 'Numbers from 4 to 7', 'emoji': '4️⃣', 'color': 'green'},
        {'name': 'Large Numbers', 'description': 'Numbers from 8 to 10', 'emoji': '8️⃣', 'color': 'red'},
      ];
      items = [
        {'name': '1', 'category': 'Small Numbers', 'emoji': '1️⃣', 'word': 'One', 'malay_word': 'Satu'},
        {'name': '2', 'category': 'Small Numbers', 'emoji': '2️⃣', 'word': 'Two', 'malay_word': 'Dua'},
        {'name': '3', 'category': 'Small Numbers', 'emoji': '3️⃣', 'word': 'Three', 'malay_word': 'Tiga'},
        {'name': '4', 'category': 'Medium Numbers', 'emoji': '4️⃣', 'word': 'Four', 'malay_word': 'Empat'},
        {'name': '5', 'category': 'Medium Numbers', 'emoji': '5️⃣', 'word': 'Five', 'malay_word': 'Lima'},
        {'name': '6', 'category': 'Medium Numbers', 'emoji': '6️⃣', 'word': 'Six', 'malay_word': 'Enam'},
        {'name': '7', 'category': 'Medium Numbers', 'emoji': '7️⃣', 'word': 'Seven', 'malay_word': 'Tujuh'},
        {'name': '8', 'category': 'Large Numbers', 'emoji': '8️⃣', 'word': 'Eight', 'malay_word': 'Lapan'},
        {'name': '9', 'category': 'Large Numbers', 'emoji': '9️⃣', 'word': 'Nine', 'malay_word': 'Sembilan'},
        {'name': '10', 'category': 'Large Numbers', 'emoji': '🔟', 'word': 'Ten', 'malay_word': 'Sepuluh'},
      ];
    }
    
    return {
      'title': 'Math - Counting',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Math',
        'chapter': 'Counting',
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
      // Age 4: 3 simple numbers (1-3)
      instructions = 'Trace these simple numbers.';
      difficulty = 'easy';
      items = [
        {
          'character': '1',
          'difficulty': 1,
          'instruction': 'Trace number 1 - One',
          'emoji': '1️⃣',
          'word': 'One',
          'malay_word': 'Satu',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': '2',
          'difficulty': 1,
          'instruction': 'Trace number 2 - Two',
          'emoji': '2️⃣',
          'word': 'Two',
          'malay_word': 'Dua',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': '3',
          'difficulty': 1,
          'instruction': 'Trace number 3 - Three',
          'emoji': '3️⃣',
          'word': 'Three',
          'malay_word': 'Tiga',
          'pathPoints': [
            {'x': 0.3, 'y': 0.3},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.3, 'y': 0.7},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 5 numbers (1-5)
      instructions = 'Trace these numbers following the correct stroke order.';
      difficulty = 'medium';
      items = [
        {
          'character': '1',
          'difficulty': 1,
          'instruction': 'Trace number 1 - One',
          'emoji': '1️⃣',
          'word': 'One',
          'malay_word': 'Satu',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': '2',
          'difficulty': 1,
          'instruction': 'Trace number 2 - Two',
          'emoji': '2️⃣',
          'word': 'Two',
          'malay_word': 'Dua',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': '3',
          'difficulty': 2,
          'instruction': 'Trace number 3 - Three',
          'emoji': '3️⃣',
          'word': 'Three',
          'malay_word': 'Tiga',
          'pathPoints': [
            {'x': 0.3, 'y': 0.3},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': '4',
          'difficulty': 2,
          'instruction': 'Trace number 4 - Four',
          'emoji': '4️⃣',
          'word': 'Four',
          'malay_word': 'Empat',
          'pathPoints': [
            {'x': 0.7, 'y': 0.2},
            {'x': 0.7, 'y': 0.8},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
          ]
        },
        {
          'character': '5',
          'difficulty': 2,
          'instruction': 'Trace number 5 - Five',
          'emoji': '5️⃣',
          'word': 'Five',
          'malay_word': 'Lima',
          'pathPoints': [
            {'x': 0.7, 'y': 0.2},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.8},
            {'x': 0.3, 'y': 0.8},
          ]
        },
      ];
    } else {
      // Age 6: All numbers 1-10 with higher complexity
      instructions = 'Trace these numbers following the correct stroke order and direction.';
      difficulty = 'hard';
      items = [
        {
          'character': '1',
          'difficulty': 1,
          'instruction': 'Trace number 1 - One',
          'emoji': '1️⃣',
          'word': 'One',
          'malay_word': 'Satu',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': '2',
          'difficulty': 1,
          'instruction': 'Trace number 2 - Two',
          'emoji': '2️⃣',
          'word': 'Two',
          'malay_word': 'Dua',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': '3',
          'difficulty': 2,
          'instruction': 'Trace number 3 - Three',
          'emoji': '3️⃣',
          'word': 'Three',
          'malay_word': 'Tiga',
          'pathPoints': [
            {'x': 0.3, 'y': 0.3},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': '4',
          'difficulty': 2,
          'instruction': 'Trace number 4 - Four',
          'emoji': '4️⃣',
          'word': 'Four',
          'malay_word': 'Empat',
          'pathPoints': [
            {'x': 0.7, 'y': 0.2},
            {'x': 0.7, 'y': 0.8},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
          ]
        },
        {
          'character': '5',
          'difficulty': 2,
          'instruction': 'Trace number 5 - Five',
          'emoji': '5️⃣',
          'word': 'Five',
          'malay_word': 'Lima',
          'pathPoints': [
            {'x': 0.7, 'y': 0.2},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.8},
            {'x': 0.3, 'y': 0.8}
          ]
        },
        {
          'shape': 'hexagon',
          'color': 'orange',
          'text': '6',
          'word': 'Six',
          'malay_word': 'Enam',
          'emoji': '6️⃣',
        },
        {
          'shape': 'star',
          'color': 'pink',
          'text': '7',
          'word': 'Seven',
          'malay_word': 'Tujuh',
          'emoji': '7️⃣',
        },
      ];
    }
    
    return {
      'title': 'Math - Counting',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Math',
        'chapter': 'Counting',
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
      // Age 4: 5 simple numbers (1-5)
      instructions = 'Count the objects and select the correct number.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'number', 'color': 'blue', 'name': '1', 'malay_shape': '1', 'malay_color': 'Biru', 'word': '1', 'malay_word': 'Satu'},
        {'shape': 'number', 'color': 'red', 'name': '2', 'malay_shape': '2', 'malay_color': 'Merah', 'word': '2', 'malay_word': 'Dua'},
        {'shape': 'number', 'color': 'green', 'name': '3', 'malay_shape': '3', 'malay_color': 'Hijau', 'word': '3', 'malay_word': 'Tiga'},
        {'shape': 'number', 'color': 'yellow', 'name': '4', 'malay_shape': '4', 'malay_color': 'Kuning', 'word': '4', 'malay_word': 'Empat'},
        {'shape': 'number', 'color': 'purple', 'name': '5', 'malay_shape': '5', 'malay_color': 'Ungu', 'word': '5', 'malay_word': 'Lima'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 7 numbers (1-7)
      instructions = 'Count the objects and select the correct number with its name.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'number', 'color': 'blue', 'name': '1', 'malay_shape': '1', 'malay_color': 'Biru', 'word': '1', 'malay_word': 'Satu'},
        {'shape': 'number', 'color': 'red', 'name': '2', 'malay_shape': '2', 'malay_color': 'Merah', 'word': '2', 'malay_word': 'Dua'},
        {'shape': 'number', 'color': 'green', 'name': '3', 'malay_shape': '3', 'malay_color': 'Hijau', 'word': '3', 'malay_word': 'Tiga'},
        {'shape': 'number', 'color': 'yellow', 'name': '4', 'malay_shape': '4', 'malay_color': 'Kuning', 'word': '4', 'malay_word': 'Empat'},
        {'shape': 'number', 'color': 'purple', 'name': '5', 'malay_shape': '5', 'malay_color': 'Ungu', 'word': '5', 'malay_word': 'Lima'},
        {'shape': 'number', 'color': 'orange', 'name': '6', 'malay_shape': '6', 'malay_color': 'Oren', 'word': '6', 'malay_word': 'Enam'},
        {'shape': 'number', 'color': 'pink', 'name': '7', 'malay_shape': '7', 'malay_color': 'Merah Jambu', 'word': '7', 'malay_word': 'Tujuh'},
      ];
    } else {
      // Age 6: All 10 numbers (1-10)
      instructions = 'Count the objects and select the correct number with its name in both languages.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'number', 'color': 'blue', 'name': '1', 'malay_shape': '1', 'malay_color': 'Biru', 'word': '1', 'malay_word': 'Satu'},
        {'shape': 'number', 'color': 'red', 'name': '2', 'malay_shape': '2', 'malay_color': 'Merah', 'word': '2', 'malay_word': 'Dua'},
        {'shape': 'number', 'color': 'green', 'name': '3', 'malay_shape': '3', 'malay_color': 'Hijau', 'word': '3', 'malay_word': 'Tiga'},
        {'shape': 'number', 'color': 'yellow', 'name': '4', 'malay_shape': '4', 'malay_color': 'Kuning', 'word': '4', 'malay_word': 'Empat'},
        {'shape': 'number', 'color': 'purple', 'name': '5', 'malay_shape': '5', 'malay_color': 'Ungu', 'word': '5', 'malay_word': 'Lima'},
        {'shape': 'number', 'color': 'orange', 'name': '6', 'malay_shape': '6', 'malay_color': 'Oren', 'word': '6', 'malay_word': 'Enam'},
        {'shape': 'number', 'color': 'pink', 'name': '7', 'malay_shape': '7', 'malay_color': 'Merah Jambu', 'word': '7', 'malay_word': 'Tujuh'},
        {'shape': 'number', 'color': 'brown', 'name': '8', 'malay_shape': '8', 'malay_color': 'Coklat', 'word': '8', 'malay_word': 'Lapan'},
        {'shape': 'number', 'color': 'black', 'name': '9', 'malay_shape': '9', 'malay_color': 'Hitam', 'word': '9', 'malay_word': 'Sembilan'},
        {'shape': 'number', 'color': 'teal', 'name': '10', 'malay_shape': '10', 'malay_color': 'Hijau Kebiruan', 'word': '10', 'malay_word': 'Sepuluh'},
      ];
    }
    
    return {
      'title': 'Math - Counting',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Math',
        'chapter': 'Counting',
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
