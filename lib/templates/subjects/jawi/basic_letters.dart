import 'dart:math';

/// Template for Jawi - Basic Letters chapter
/// This template includes Arabic script for Jawi letters
class JawiBasicLettersTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: 4 simple letters with basic instructions
      instructions = 'Match the Jawi letter with its name.';
      difficulty = 'easy';
      pairs = [
        {
          'word': 'Alif', 'emoji': 'ا', 
          'title': 'Alif', 'letter': 'ا',
          'description': 'First letter of the Jawi alphabet', 
          'malay_word': 'Alif',
          'image_asset': 'assets/flashcards/jawi/alif.png'
        },
        {
          'word': 'Ba', 'emoji': 'ب', 
          'title': 'Ba', 'letter': 'ب',
          'description': 'Second letter of the Jawi alphabet', 
          'malay_word': 'Ba',
          'image_asset': 'assets/flashcards/jawi/ba.png'
        },
        {
          'word': 'Ta', 'emoji': 'ت', 
          'title': 'Ta', 'letter': 'ت',
          'description': 'Third letter of the Jawi alphabet', 
          'malay_word': 'Ta',
          'image_asset': 'assets/flashcards/jawi/ta.png'
        },
        {
          'word': 'Jim', 'emoji': 'ج', 
          'title': 'Jim', 'letter': 'ج',
          'description': 'Fifth letter of the Jawi alphabet', 
          'malay_word': 'Jim',
          'image_asset': 'assets/flashcards/jawi/jim.png'
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 letters with medium complexity
      instructions = 'Match the Jawi letter with its name and position.';
      difficulty = 'medium';
      pairs = [
        {
          'word': 'Alif', 'emoji': 'ا', 
          'title': 'Alif', 'letter': 'ا',
          'description': 'First letter of the Jawi alphabet', 
          'malay_word': 'Alif',
          'image_asset': 'assets/flashcards/jawi/alif.png'
        },
        {
          'word': 'Ba', 'emoji': 'ب', 
          'title': 'Ba', 'letter': 'ب',
          'description': 'Second letter of the Jawi alphabet', 
          'malay_word': 'Ba',
          'image_asset': 'assets/flashcards/jawi/ba.png'
        },
        {
          'word': 'Ta', 'emoji': 'ت', 
          'title': 'Ta', 'letter': 'ت',
          'description': 'Third letter of the Jawi alphabet', 
          'malay_word': 'Ta',
          'image_asset': 'assets/flashcards/jawi/ta.png'
        },
        {
          'word': 'Jim', 'emoji': 'ج', 
          'title': 'Jim', 'letter': 'ج',
          'description': 'Fifth letter of the Jawi alphabet', 
          'malay_word': 'Jim',
          'image_asset': 'assets/flashcards/jawi/jim.png'
        },
        {
          'word': 'Dal', 'emoji': 'د', 
          'title': 'Dal', 'letter': 'د',
          'description': 'Eighth letter of the Jawi alphabet', 
          'malay_word': 'Dal',
          'image_asset': 'assets/flashcards/jawi/dal.png'
        },
        {
          'word': 'Ra', 'emoji': 'ر', 
          'title': 'Ra', 'letter': 'ر',
          'description': 'Tenth letter of the Jawi alphabet', 
          'malay_word': 'Ra',
          'image_asset': 'assets/flashcards/jawi/ra.png'
        },
      ];
    } else {
      // Age 6: 8 letters with higher complexity
      instructions = 'Match the Jawi letter with its name and position in the alphabet.';
      difficulty = 'hard';
      pairs = [
        {
          'word': 'Alif', 'emoji': 'ا', 
          'title': 'Alif', 'letter': 'ا',
          'description': 'First letter of the Jawi alphabet', 
          'malay_word': 'Alif',
          'image_asset': 'assets/flashcards/jawi/alif.png'
        },
        {
          'word': 'Ba', 'emoji': 'ب', 
          'title': 'Ba', 'letter': 'ب',
          'description': 'Second letter of the Jawi alphabet', 
          'malay_word': 'Ba',
          'image_asset': 'assets/flashcards/jawi/ba.png'
        },
        {
          'word': 'Ta', 'emoji': 'ت', 
          'title': 'Ta', 'letter': 'ت',
          'description': 'Third letter of the Jawi alphabet', 
          'malay_word': 'Ta',
          'image_asset': 'assets/flashcards/jawi/ta.png'
        },
        {
          'word': 'Jim', 'emoji': 'ج', 
          'title': 'Jim', 'letter': 'ج',
          'description': 'Fifth letter of the Jawi alphabet', 
          'malay_word': 'Jim',
          'image_asset': 'assets/flashcards/jawi/jim.png'
        },
        {
          'word': 'Dal', 'emoji': 'د', 
          'title': 'Dal', 'letter': 'د',
          'description': 'Eighth letter of the Jawi alphabet', 
          'malay_word': 'Dal',
          'image_asset': 'assets/flashcards/jawi/dal.png'
        },
        {
          'word': 'Ra', 'emoji': 'ر', 
          'title': 'Ra', 'letter': 'ر',
          'description': 'Tenth letter of the Jawi alphabet', 
          'malay_word': 'Ra',
          'image_asset': 'assets/flashcards/jawi/ra.png'
        },
        {
          'word': 'Sin', 'emoji': 'س', 
          'title': 'Sin', 'letter': 'س',
          'description': 'Twelfth letter of the Jawi alphabet', 
          'malay_word': 'Sin',
          'image_asset': 'assets/flashcards/jawi/sin.png'
        },
        {
          'word': 'Mim', 'emoji': 'م', 
          'title': 'Mim', 'letter': 'م',
          'description': 'Twenty-fourth letter of the Jawi alphabet', 
          'malay_word': 'Mim',
          'image_asset': 'assets/flashcards/jawi/mim.png'
        },
      ];
    }
    
    return {
      'title': 'Jawi - Basic Letters',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Jawi',
        'chapter': 'Basic Letters',
        'ageGroup': ageGroup,
        'difficulty': difficulty,
        'fontFamily': 'Scheherazade', // Arabic script font
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
      // Age 4: 2 categories with 4 items
      instructions = 'Sort the Jawi letters into two groups.';
      difficulty = 'easy';
      categories = [
        {'name': 'Beginning Letters', 'description': 'First letters', 'emoji': 'ا', 'color': 'blue'},
        {'name': 'End Letters', 'description': 'Last letters', 'emoji': 'م', 'color': 'red'},
      ];
      items = [
        {'name': 'Alif', 'category': 'Beginning Letters', 'emoji': 'ا', 'word': 'Alif', 'malay_word': 'Alif'},
        {'name': 'Ba', 'category': 'Beginning Letters', 'emoji': 'ب', 'word': 'Ba', 'malay_word': 'Ba'},
        {'name': 'Mim', 'category': 'End Letters', 'emoji': 'م', 'word': 'Mim', 'malay_word': 'Mim'},
        {'name': 'Ya', 'category': 'End Letters', 'emoji': 'ي', 'word': 'Ya', 'malay_word': 'Ya'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 2 categories with 8 items
      instructions = 'Sort the Jawi letters by their position in the alphabet.';
      difficulty = 'medium';
      categories = [
        {'name': 'Beginning Letters', 'description': 'Letters at the beginning of the Jawi alphabet', 'emoji': 'ا', 'color': 'blue'},
        {'name': 'End Letters', 'description': 'Letters at the end of the Jawi alphabet', 'emoji': 'م', 'color': 'red'},
      ];
      items = [
        {'name': 'Alif', 'category': 'Beginning Letters', 'emoji': 'ا', 'word': 'Alif', 'malay_word': 'Alif'},
        {'name': 'Ba', 'category': 'Beginning Letters', 'emoji': 'ب', 'word': 'Ba', 'malay_word': 'Ba'},
        {'name': 'Ta', 'category': 'Beginning Letters', 'emoji': 'ت', 'word': 'Ta', 'malay_word': 'Ta'},
        {'name': 'Jim', 'category': 'Beginning Letters', 'emoji': 'ج', 'word': 'Jim', 'malay_word': 'Jim'},
        {'name': 'Mim', 'category': 'End Letters', 'emoji': 'م', 'word': 'Mim', 'malay_word': 'Mim'},
        {'name': 'Nun', 'category': 'End Letters', 'emoji': 'ن', 'word': 'Nun', 'malay_word': 'Nun'},
        {'name': 'Wau', 'category': 'End Letters', 'emoji': 'و', 'word': 'Wau', 'malay_word': 'Wau'},
        {'name': 'Ya', 'category': 'End Letters', 'emoji': 'ي', 'word': 'Ya', 'malay_word': 'Ya'},
      ];
    } else {
      // Age 6: 3 categories with 12 items
      instructions = 'Sort the Jawi letters by their position in the alphabet: beginning, middle, or end.';
      difficulty = 'hard';
      categories = [
        {'name': 'Beginning Letters', 'description': 'Letters at the beginning of the Jawi alphabet', 'emoji': 'ا', 'color': 'blue'},
        {'name': 'Middle Letters', 'description': 'Letters in the middle of the Jawi alphabet', 'emoji': 'ف', 'color': 'green'},
        {'name': 'End Letters', 'description': 'Letters at the end of the Jawi alphabet', 'emoji': 'م', 'color': 'red'},
      ];
      items = [
        {'name': 'Alif', 'category': 'Beginning Letters', 'emoji': 'ا', 'word': 'Alif', 'malay_word': 'Alif'},
        {'name': 'Ba', 'category': 'Beginning Letters', 'emoji': 'ب', 'word': 'Ba', 'malay_word': 'Ba'},
        {'name': 'Ta', 'category': 'Beginning Letters', 'emoji': 'ت', 'word': 'Ta', 'malay_word': 'Ta'},
        {'name': 'Jim', 'category': 'Beginning Letters', 'emoji': 'ج', 'word': 'Jim', 'malay_word': 'Jim'},
        {'name': 'Fa', 'category': 'Middle Letters', 'emoji': 'ف', 'word': 'Fa', 'malay_word': 'Fa'},
        {'name': 'Qaf', 'category': 'Middle Letters', 'emoji': 'ق', 'word': 'Qaf', 'malay_word': 'Qaf'},
        {'name': 'Kaf', 'category': 'Middle Letters', 'emoji': 'ك', 'word': 'Kaf', 'malay_word': 'Kaf'},
        {'name': 'Lam', 'category': 'Middle Letters', 'emoji': 'ل', 'word': 'Lam', 'malay_word': 'Lam'},
        {'name': 'Mim', 'category': 'End Letters', 'emoji': 'م', 'word': 'Mim', 'malay_word': 'Mim'},
        {'name': 'Nun', 'category': 'End Letters', 'emoji': 'ن', 'word': 'Nun', 'malay_word': 'Nun'},
        {'name': 'Wau', 'category': 'End Letters', 'emoji': 'و', 'word': 'Wau', 'malay_word': 'Wau'},
        {'name': 'Ya', 'category': 'End Letters', 'emoji': 'ي', 'word': 'Ya', 'malay_word': 'Ya'},
      ];
    }
    
    return {
      'title': 'Jawi - Basic Letters',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Jawi',
        'chapter': 'Basic Letters',
        'ageGroup': ageGroup,
        'difficulty': difficulty,
        'fontFamily': 'Scheherazade', // Arabic script font
      }
    };
  }

  /// Get tracing game content
  static Map<String, dynamic> getTracingContent(int ageGroup) {
    List<Map<String, dynamic>> items = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: 2 simple letters with basic instructions
      instructions = 'Trace these simple Jawi letters.';
      difficulty = 'easy';
      items = [
        {
          'character': 'ا',
          'difficulty': 1,
          'instruction': 'Trace the letter Alif',
          'emoji': 'ا',
          'word': 'Alif',
          'malay_word': 'Alif',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'ب',
          'difficulty': 1,
          'instruction': 'Trace the letter Ba',
          'emoji': 'ب',
          'word': 'Ba',
          'malay_word': 'Ba',
          'pathPoints': [
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.7},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 3 medium complexity letters
      instructions = 'Trace these Jawi letters carefully.';
      difficulty = 'medium';
      items = [
        {
          'character': 'ا',
          'difficulty': 1,
          'instruction': 'Trace the letter Alif',
          'emoji': 'ا',
          'word': 'Alif',
          'malay_word': 'Alif',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'ب',
          'difficulty': 1,
          'instruction': 'Trace the letter Ba',
          'emoji': 'ب',
          'word': 'Ba',
          'malay_word': 'Ba',
          'pathPoints': [
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'ت',
          'difficulty': 1,
          'instruction': 'Trace the letter Ta',
          'emoji': 'ت',
          'word': 'Ta',
          'malay_word': 'Ta',
          'pathPoints': [
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.6, 'y': 0.3},
          ]
        },
      ];
    } else {
      // Age 6: 5 complex letters
      instructions = 'Trace these Jawi letters following the correct stroke order.';
      difficulty = 'hard';
      items = [
        {
          'character': 'ا',
          'difficulty': 1,
          'instruction': 'Trace the letter Alif',
          'emoji': 'ا',
          'word': 'Alif',
          'malay_word': 'Alif',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'ب',
          'difficulty': 2,
          'instruction': 'Trace the letter Ba',
          'emoji': 'ب',
          'word': 'Ba',
          'malay_word': 'Ba',
          'pathPoints': [
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.5, 'y': 0.9},
          ]
        },
        {
          'character': 'ت',
          'difficulty': 2,
          'instruction': 'Trace the letter Ta',
          'emoji': 'ت',
          'word': 'Ta',
          'malay_word': 'Ta',
          'pathPoints': [
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.6, 'y': 0.3},
          ]
        },
        {
          'character': 'ج',
          'difficulty': 3,
          'instruction': 'Trace the letter Jim',
          'emoji': 'ج',
          'word': 'Jim',
          'malay_word': 'Jim',
          'pathPoints': [
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.3, 'y': 0.9},
            {'x': 0.5, 'y': 0.9},
          ]
        },
        {
          'character': 'م',
          'difficulty': 3,
          'instruction': 'Trace the letter Mim',
          'emoji': 'م',
          'word': 'Mim',
          'malay_word': 'Mim',
          'pathPoints': [
            {'x': 0.3, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
          ]
        },
      ];
    }
    
    return {
      'title': 'Jawi - Basic Letters',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Jawi',
        'chapter': 'Basic Letters',
        'ageGroup': ageGroup,
        'difficulty': difficulty,
        'fontFamily': 'Scheherazade', // Arabic script font
      }
    };
  }

  /// Get shape and color game content
  static Map<String, dynamic> getShapeColorContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> shapes = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: 4 simple shapes with basic instructions
      instructions = 'Match the Jawi letter with its name.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'alif', 'color': 'red', 'name': 'Alif', 'malay_shape': 'ا', 'malay_color': 'Merah', 'word': 'Alif', 'malay_word': 'Alif'},
        {'shape': 'ba', 'color': 'blue', 'name': 'Ba', 'malay_shape': 'ب', 'malay_color': 'Biru', 'word': 'Ba', 'malay_word': 'Ba'},
        {'shape': 'ta', 'color': 'green', 'name': 'Ta', 'malay_shape': 'ت', 'malay_color': 'Hijau', 'word': 'Ta', 'malay_word': 'Ta'},
        {'shape': 'jim', 'color': 'yellow', 'name': 'Jim', 'malay_shape': 'ج', 'malay_color': 'Kuning', 'word': 'Jim', 'malay_word': 'Jim'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 shapes with medium complexity
      instructions = 'Match the Jawi letter with its name and color.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'alif', 'color': 'red', 'name': 'Alif', 'malay_shape': 'ا', 'malay_color': 'Merah', 'word': 'Alif', 'malay_word': 'Alif'},
        {'shape': 'ba', 'color': 'blue', 'name': 'Ba', 'malay_shape': 'ب', 'malay_color': 'Biru', 'word': 'Ba', 'malay_word': 'Ba'},
        {'shape': 'ta', 'color': 'green', 'name': 'Ta', 'malay_shape': 'ت', 'malay_color': 'Hijau', 'word': 'Ta', 'malay_word': 'Ta'},
        {'shape': 'jim', 'color': 'yellow', 'name': 'Jim', 'malay_shape': 'ج', 'malay_color': 'Kuning', 'word': 'Jim', 'malay_word': 'Jim'},
        {'shape': 'dal', 'color': 'purple', 'name': 'Dal', 'malay_shape': 'د', 'malay_color': 'Ungu', 'word': 'Dal', 'malay_word': 'Dal'},
        {'shape': 'ra', 'color': 'orange', 'name': 'Ra', 'malay_shape': 'ر', 'malay_color': 'Oren', 'word': 'Ra', 'malay_word': 'Ra'},
      ];
    } else {
      // Age 6: 8 shapes with higher complexity
      instructions = 'Match the Jawi letter with its name, color, and pronunciation.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'alif', 'color': 'red', 'name': 'Alif', 'malay_shape': 'ا', 'malay_color': 'Merah', 'word': 'Alif', 'malay_word': 'Alif'},
        {'shape': 'ba', 'color': 'blue', 'name': 'Ba', 'malay_shape': 'ب', 'malay_color': 'Biru', 'word': 'Ba', 'malay_word': 'Ba'},
        {'shape': 'ta', 'color': 'green', 'name': 'Ta', 'malay_shape': 'ت', 'malay_color': 'Hijau', 'word': 'Ta', 'malay_word': 'Ta'},
        {'shape': 'jim', 'color': 'yellow', 'name': 'Jim', 'malay_shape': 'ج', 'malay_color': 'Kuning', 'word': 'Jim', 'malay_word': 'Jim'},
        {'shape': 'dal', 'color': 'purple', 'name': 'Dal', 'malay_shape': 'د', 'malay_color': 'Ungu', 'word': 'Dal', 'malay_word': 'Dal'},
        {'shape': 'ra', 'color': 'orange', 'name': 'Ra', 'malay_shape': 'ر', 'malay_color': 'Oren', 'word': 'Ra', 'malay_word': 'Ra'},
        {'shape': 'sin', 'color': 'pink', 'name': 'Sin', 'malay_shape': 'س', 'malay_color': 'Merah Jambu', 'word': 'Sin', 'malay_word': 'Sin'},
        {'shape': 'mim', 'color': 'brown', 'name': 'Mim', 'malay_shape': 'م', 'malay_color': 'Coklat', 'word': 'Mim', 'malay_word': 'Mim'},
      ];
    }
    
    return {
      'title': 'Jawi - Basic Letters',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Jawi',
        'chapter': 'Basic Letters',
        'ageGroup': ageGroup,
        'difficulty': difficulty,
        'fontFamily': 'Scheherazade', // Arabic script font
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
