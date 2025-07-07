import 'dart:math';

/// Template for Iqraa - Hijaiyah Letters chapter
/// This template includes Arabic script for Hijaiyah letters with proper font specification
class HijaiyahLettersTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: 4 simple letters with basic instructions
      instructions = 'Match the letter with its name.';
      difficulty = 'easy';
      pairs = [
        {
          'word': 'Alif', 'emoji': 'ا', 
          'title': 'Alif', 'letter': 'ا',
          'description': 'First letter', 
          'malay_word': 'Alif', 'arabic_word': 'ألف',
          'image_asset': 'assets/flashcards/hijaiyah/alif.png'
        },
        {
          'word': 'Ba', 'emoji': 'ب', 
          'title': 'Ba', 'letter': 'ب',
          'description': 'Second letter', 
          'malay_word': 'Ba', 'arabic_word': 'باء',
          'image_asset': 'assets/flashcards/hijaiyah/ba.png'
        },
        {
          'word': 'Ta', 'emoji': 'ت', 
          'title': 'Ta', 'letter': 'ت',
          'description': 'Third letter', 
          'malay_word': 'Ta', 'arabic_word': 'تاء',
          'image_asset': 'assets/flashcards/hijaiyah/ta.png'
        },
        {
          'word': 'Jim', 'emoji': 'ج', 
          'title': 'Jim', 'letter': 'ج',
          'description': 'Fifth letter', 
          'malay_word': 'Jim', 'arabic_word': 'جيم',
          'image_asset': 'assets/flashcards/hijaiyah/jim.png'
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 letters with medium complexity
      instructions = 'Match the Hijaiyah letter with its name.';
      difficulty = 'medium';
      pairs = [
        {
          'word': 'Alif', 'emoji': 'ا', 
          'title': 'Alif', 'letter': 'ا',
          'description': 'First letter of the Hijaiyah alphabet', 
          'malay_word': 'Alif', 'arabic_word': 'ألف',
          'image_asset': 'assets/flashcards/hijaiyah/alif.png'
        },
        {
          'word': 'Ba', 'emoji': 'ب', 
          'title': 'Ba', 'letter': 'ب',
          'description': 'Second letter of the Hijaiyah alphabet', 
          'malay_word': 'Ba', 'arabic_word': 'باء',
          'image_asset': 'assets/flashcards/hijaiyah/ba.png'
        },
        {
          'word': 'Ta', 'emoji': 'ت', 
          'title': 'Ta', 'letter': 'ت',
          'description': 'Third letter of the Hijaiyah alphabet', 
          'malay_word': 'Ta', 'arabic_word': 'تاء',
          'image_asset': 'assets/flashcards/hijaiyah/ta.png'
        },
        {
          'word': 'Jim', 'emoji': 'ج', 
          'title': 'Jim', 'letter': 'ج',
          'description': 'Fifth letter of the Hijaiyah alphabet', 
          'malay_word': 'Jim', 'arabic_word': 'جيم',
          'image_asset': 'assets/flashcards/hijaiyah/jim.png'
        },
        {
          'word': 'Ha', 'emoji': 'ح', 
          'title': 'Ha', 'letter': 'ح',
          'description': 'Sixth letter of the Hijaiyah alphabet', 
          'malay_word': 'Ha', 'arabic_word': 'حاء',
          'image_asset': 'assets/flashcards/hijaiyah/ha.png'
        },
        {
          'word': 'Dal', 'emoji': 'د', 
          'title': 'Dal', 'letter': 'د',
          'description': 'Eighth letter of the Hijaiyah alphabet', 
          'malay_word': 'Dal', 'arabic_word': 'دال',
          'image_asset': 'assets/flashcards/hijaiyah/dal.png'
        },
      ];
    } else {
      // Age 6: 8 letters with higher complexity
      instructions = 'Match the Hijaiyah letter with its name and position in the alphabet.';
      difficulty = 'hard';
      pairs = [
        {
          'word': 'Alif', 'emoji': 'ا', 
          'title': 'Alif', 'letter': 'ا',
          'description': 'First letter of the Hijaiyah alphabet', 
          'malay_word': 'Alif', 'arabic_word': 'ألف',
          'image_asset': 'assets/flashcards/hijaiyah/alif.png'
        },
        {
          'word': 'Ba', 'emoji': 'ب', 
          'title': 'Ba', 'letter': 'ب',
          'description': 'Second letter of the Hijaiyah alphabet', 
          'malay_word': 'Ba', 'arabic_word': 'باء',
          'image_asset': 'assets/flashcards/hijaiyah/ba.png'
        },
        {
          'word': 'Ta', 'emoji': 'ت', 
          'title': 'Ta', 'letter': 'ت',
          'description': 'Third letter of the Hijaiyah alphabet', 
          'malay_word': 'Ta', 'arabic_word': 'تاء',
          'image_asset': 'assets/flashcards/hijaiyah/ta.png'
        },
        {
          'word': 'Tsa', 'emoji': 'ث', 
          'title': 'Tsa', 'letter': 'ث',
          'description': 'Fourth letter of the Hijaiyah alphabet', 
          'malay_word': 'Tsa', 'arabic_word': 'ثاء',
          'image_asset': 'assets/flashcards/hijaiyah/tsa.png'
        },
        {
          'word': 'Jim', 'emoji': 'ج', 
          'title': 'Jim', 'letter': 'ج',
          'description': 'Fifth letter of the Hijaiyah alphabet', 
          'malay_word': 'Jim', 'arabic_word': 'جيم',
          'image_asset': 'assets/flashcards/hijaiyah/jim.png'
        },
        {
          'word': 'Ha', 'emoji': 'ح', 
          'title': 'Ha', 'letter': 'ح',
          'description': 'Sixth letter of the Hijaiyah alphabet', 
          'malay_word': 'Ha', 'arabic_word': 'حاء',
          'image_asset': 'assets/flashcards/hijaiyah/ha.png'
        },
        {
          'word': 'Kha', 'emoji': 'خ', 
          'title': 'Kha', 'letter': 'خ',
          'description': 'Seventh letter of the Hijaiyah alphabet', 
          'malay_word': 'Kha', 'arabic_word': 'خاء',
          'image_asset': 'assets/flashcards/hijaiyah/kha.png'
        },
        {
          'word': 'Dal', 'emoji': 'د', 
          'title': 'Dal', 'letter': 'د',
          'description': 'Eighth letter of the Hijaiyah alphabet', 
          'malay_word': 'Dal', 'arabic_word': 'دال',
          'image_asset': 'assets/flashcards/hijaiyah/dal.png'
        },
      ];
    }
    
    return {
      'title': 'Iqraa - Hijaiyah Letters',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Iqraa',
        'chapter': 'Hijaiyah Letters',
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
      instructions = 'Sort the letters into two groups.';
      difficulty = 'easy';
      categories = [
        {'name': 'Beginning Letters', 'description': 'First letters', 'emoji': 'ا', 'color': 'blue'},
        {'name': 'End Letters', 'description': 'Last letters', 'emoji': 'ي', 'color': 'red'},
      ];
      items = [
        {'name': 'Alif', 'category': 'Beginning Letters', 'emoji': 'ا', 'word': 'Alif', 'malay_word': 'Alif', 'arabic_word': 'ألف'},
        {'name': 'Ba', 'category': 'Beginning Letters', 'emoji': 'ب', 'word': 'Ba', 'malay_word': 'Ba', 'arabic_word': 'باء'},
        {'name': 'Mim', 'category': 'End Letters', 'emoji': 'م', 'word': 'Mim', 'malay_word': 'Mim', 'arabic_word': 'ميم'},
        {'name': 'Ya', 'category': 'End Letters', 'emoji': 'ي', 'word': 'Ya', 'malay_word': 'Ya', 'arabic_word': 'ياء'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 2 categories with 6 items
      instructions = 'Sort the Hijaiyah letters by their position in the alphabet.';
      difficulty = 'medium';
      categories = [
        {'name': 'Beginning Letters', 'description': 'Letters at the beginning of the Hijaiyah alphabet', 'emoji': 'ا', 'color': 'blue'},
        {'name': 'End Letters', 'description': 'Letters at the end of the Hijaiyah alphabet', 'emoji': 'م', 'color': 'red'},
      ];
      items = [
        {'name': 'Alif', 'category': 'Beginning Letters', 'emoji': 'ا', 'word': 'Alif', 'malay_word': 'Alif', 'arabic_word': 'ألف'},
        {'name': 'Ba', 'category': 'Beginning Letters', 'emoji': 'ب', 'word': 'Ba', 'malay_word': 'Ba', 'arabic_word': 'باء'},
        {'name': 'Ta', 'category': 'Beginning Letters', 'emoji': 'ت', 'word': 'Ta', 'malay_word': 'Ta', 'arabic_word': 'تاء'},
        {'name': 'Mim', 'category': 'End Letters', 'emoji': 'م', 'word': 'Mim', 'malay_word': 'Mim', 'arabic_word': 'ميم'},
        {'name': 'Nun', 'category': 'End Letters', 'emoji': 'ن', 'word': 'Nun', 'malay_word': 'Nun', 'arabic_word': 'نون'},
        {'name': 'Ya', 'category': 'End Letters', 'emoji': 'ي', 'word': 'Ya', 'malay_word': 'Ya', 'arabic_word': 'ياء'},
      ];
    } else {
      // Age 6: 3 categories with 9 items
      instructions = 'Sort the Hijaiyah letters by their position in the alphabet: beginning, middle, or end.';
      difficulty = 'hard';
      categories = [
        {'name': 'Beginning Letters', 'description': 'Letters at the beginning of the Hijaiyah alphabet', 'emoji': 'ا', 'color': 'blue'},
        {'name': 'Middle Letters', 'description': 'Letters in the middle of the Hijaiyah alphabet', 'emoji': 'ف', 'color': 'green'},
        {'name': 'End Letters', 'description': 'Letters at the end of the Hijaiyah alphabet', 'emoji': 'م', 'color': 'red'},
      ];
      items = [
        {'name': 'Alif', 'category': 'Beginning Letters', 'emoji': 'ا', 'word': 'Alif', 'malay_word': 'Alif', 'arabic_word': 'ألف'},
        {'name': 'Ba', 'category': 'Beginning Letters', 'emoji': 'ب', 'word': 'Ba', 'malay_word': 'Ba', 'arabic_word': 'باء'},
        {'name': 'Ta', 'category': 'Beginning Letters', 'emoji': 'ت', 'word': 'Ta', 'malay_word': 'Ta', 'arabic_word': 'تاء'},
        {'name': 'Fa', 'category': 'Middle Letters', 'emoji': 'ف', 'word': 'Fa', 'malay_word': 'Fa', 'arabic_word': 'فاء'},
        {'name': 'Qaf', 'category': 'Middle Letters', 'emoji': 'ق', 'word': 'Qaf', 'malay_word': 'Qaf', 'arabic_word': 'قاف'},
        {'name': 'Kaf', 'category': 'Middle Letters', 'emoji': 'ك', 'word': 'Kaf', 'malay_word': 'Kaf', 'arabic_word': 'كاف'},
        {'name': 'Mim', 'category': 'End Letters', 'emoji': 'م', 'word': 'Mim', 'malay_word': 'Mim', 'arabic_word': 'ميم'},
        {'name': 'Nun', 'category': 'End Letters', 'emoji': 'ن', 'word': 'Nun', 'malay_word': 'Nun', 'arabic_word': 'نون'},
        {'name': 'Ya', 'category': 'End Letters', 'emoji': 'ي', 'word': 'Ya', 'malay_word': 'Ya', 'arabic_word': 'ياء'},
      ];
    }
    
    return {
      'title': 'Iqraa - Hijaiyah Letters',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Iqraa',
        'chapter': 'Hijaiyah Letters',
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
      instructions = 'Trace the letter.';
      difficulty = 'easy';
      items = [
        {
          'character': 'ا',
          'difficulty': 1,
          'instruction': 'Trace Alif',
          'emoji': 'ا',
          'word': 'Alif',
          'malay_word': 'Alif',
          'arabic_word': 'ألف',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'ب',
          'difficulty': 1,
          'instruction': 'Trace Ba',
          'emoji': 'ب',
          'word': 'Ba',
          'malay_word': 'Ba',
          'arabic_word': 'باء',
          'pathPoints': [
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.7},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 3 letters with medium complexity
      instructions = 'Trace the Hijaiyah letters.';
      difficulty = 'medium';
      items = [
        {
          'character': 'ا',
          'difficulty': 1,
          'instruction': 'Trace the letter Alif',
          'emoji': 'ا',
          'word': 'Alif',
          'malay_word': 'Alif',
          'arabic_word': 'ألف',
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
          'arabic_word': 'باء',
          'pathPoints': [
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
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
          'arabic_word': 'تاء',
          'pathPoints': [
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.6, 'y': 0.3},
          ]
        },
      ];
    } else {
      // Age 6: 3 letters with higher complexity
      instructions = 'Trace the Hijaiyah letters carefully following the dots.';
      difficulty = 'hard';
      items = [
        {
          'character': 'ج',
          'difficulty': 2,
          'instruction': 'Trace the letter Jim carefully',
          'emoji': 'ج',
          'word': 'Jim',
          'malay_word': 'Jim',
          'arabic_word': 'جيم',
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
          'character': 'د',
          'difficulty': 2,
          'instruction': 'Trace the letter Dal precisely',
          'emoji': 'د',
          'word': 'Dal',
          'malay_word': 'Dal',
          'arabic_word': 'دال',
          'pathPoints': [
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
          ]
        },
        {
          'character': 'ر',
          'difficulty': 2,
          'instruction': 'Trace the letter Ra with precision',
          'emoji': 'ر',
          'word': 'Ra',
          'malay_word': 'Ra',
          'arabic_word': 'راء',
          'pathPoints': [
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.6},
            {'x': 0.5, 'y': 0.6},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.3, 'y': 0.8},
          ]
        },
      ];
    }
    
    return {
      'title': 'Iqraa - Hijaiyah Letters',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Iqraa',
        'chapter': 'Hijaiyah Letters',
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
      instructions = 'Match the letter with its name.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'alif', 'color': 'red', 'name': 'Alif', 'malay_shape': 'Alif', 'malay_color': 'Merah', 'arabic_shape': 'ا', 'arabic_name': 'ألف', 'word': 'Alif', 'malay_word': 'Alif'},
        {'shape': 'ba', 'color': 'blue', 'name': 'Ba', 'malay_shape': 'Ba', 'malay_color': 'Biru', 'arabic_shape': 'ب', 'arabic_name': 'باء', 'word': 'Ba', 'malay_word': 'Ba'},
        {'shape': 'ta', 'color': 'green', 'name': 'Ta', 'malay_shape': 'Ta', 'malay_color': 'Hijau', 'arabic_shape': 'ت', 'arabic_name': 'تاء', 'word': 'Ta', 'malay_word': 'Ta'},
        {'shape': 'jim', 'color': 'purple', 'name': 'Jim', 'malay_shape': 'Jim', 'malay_color': 'Ungu', 'arabic_shape': 'ج', 'arabic_name': 'جيم', 'word': 'Jim', 'malay_word': 'Jim'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 shapes with color names and more detailed instructions
      instructions = 'Match the Hijaiyah letter with its correct name and color.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'alif', 'color': 'red', 'name': 'Alif (Red)', 'malay_shape': 'Alif', 'malay_color': 'Merah', 'arabic_shape': 'ا', 'arabic_name': 'ألف', 'word': 'Alif', 'malay_word': 'Alif'},
        {'shape': 'ba', 'color': 'blue', 'name': 'Ba (Blue)', 'malay_shape': 'Ba', 'malay_color': 'Biru', 'arabic_shape': 'ب', 'arabic_name': 'باء', 'word': 'Ba', 'malay_word': 'Ba'},
        {'shape': 'ta', 'color': 'green', 'name': 'Ta (Green)', 'malay_shape': 'Ta', 'malay_color': 'Hijau', 'arabic_shape': 'ت', 'arabic_name': 'تاء', 'word': 'Ta', 'malay_word': 'Ta'},
        {'shape': 'jim', 'color': 'purple', 'name': 'Jim (Purple)', 'malay_shape': 'Jim', 'malay_color': 'Ungu', 'arabic_shape': 'ج', 'arabic_name': 'جيم', 'word': 'Jim', 'malay_word': 'Jim'},
        {'shape': 'ha', 'color': 'orange', 'name': 'Ha (Orange)', 'malay_shape': 'Ha', 'malay_color': 'Oren', 'arabic_shape': 'ح', 'arabic_name': 'حاء', 'word': 'Ha', 'malay_word': 'Ha'},
        {'shape': 'dal', 'color': 'brown', 'name': 'Dal (Brown)', 'malay_shape': 'Dal', 'malay_color': 'Coklat', 'arabic_shape': 'د', 'arabic_name': 'دال', 'word': 'Dal', 'malay_word': 'Dal'},
      ];
    } else {
      // Age 6: 8 shapes with full color names and complex instructions
      instructions = 'Match the Hijaiyah letter with its correct name, color, and position in the alphabet.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'alif', 'color': 'red', 'name': 'Alif (Red)', 'malay_shape': 'Alif', 'malay_color': 'Merah', 'arabic_shape': 'ا', 'arabic_name': 'ألف', 'word': 'Alif', 'malay_word': 'Alif'},
        {'shape': 'ba', 'color': 'blue', 'name': 'Ba (Blue)', 'malay_shape': 'Ba', 'malay_color': 'Biru', 'arabic_shape': 'ب', 'arabic_name': 'باء', 'word': 'Ba', 'malay_word': 'Ba'},
        {'shape': 'ta', 'color': 'green', 'name': 'Ta (Green)', 'malay_shape': 'Ta', 'malay_color': 'Hijau', 'arabic_shape': 'ت', 'arabic_name': 'تاء', 'word': 'Ta', 'malay_word': 'Ta'},
        {'shape': 'tsa', 'color': 'yellow', 'name': 'Tsa (Yellow)', 'malay_shape': 'Tsa', 'malay_color': 'Kuning', 'arabic_shape': 'ث', 'arabic_name': 'ثاء', 'word': 'Tsa', 'malay_word': 'Tsa'},
        {'shape': 'jim', 'color': 'purple', 'name': 'Jim (Purple)', 'malay_shape': 'Jim', 'malay_color': 'Ungu', 'arabic_shape': 'ج', 'arabic_name': 'جيم', 'word': 'Jim', 'malay_word': 'Jim'},
        {'shape': 'ha', 'color': 'orange', 'name': 'Ha (Orange)', 'malay_shape': 'Ha', 'malay_color': 'Oren', 'arabic_shape': 'ح', 'arabic_name': 'حاء', 'word': 'Ha', 'malay_word': 'Ha'},
        {'shape': 'kha', 'color': 'pink', 'name': 'Kha (Pink)', 'malay_shape': 'Kha', 'malay_color': 'Merah Jambu', 'arabic_shape': 'خ', 'arabic_name': 'خاء', 'word': 'Kha', 'malay_word': 'Kha'},
        {'shape': 'dal', 'color': 'brown', 'name': 'Dal (Brown)', 'malay_shape': 'Dal', 'malay_color': 'Coklat', 'arabic_shape': 'د', 'arabic_name': 'دال', 'word': 'Dal', 'malay_word': 'Dal'},
      ];
    }
    
    return {
      'title': 'Iqraa - Hijaiyah Letters',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Iqraa',
        'chapter': 'Hijaiyah Letters',
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
