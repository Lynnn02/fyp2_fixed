import 'dart:math';

/// Template for Science - Five Senses chapter
class FiveSensesTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: Simple matching with basic descriptions
      instructions = 'Match the sense with the correct body part.';
      difficulty = 'easy';
      pairs = [
        {'word': 'Sight', 'emoji': '👁️', 'description': 'We see with our eyes', 'malay_word': 'Penglihatan'},
        {'word': 'Hearing', 'emoji': '👂', 'description': 'We hear with our ears', 'malay_word': 'Pendengaran'},
        {'word': 'Smell', 'emoji': '👃', 'description': 'We smell with our nose', 'malay_word': 'Bau'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 4 senses and more detailed descriptions
      instructions = 'Match the sense with the correct body part and its function.';
      difficulty = 'medium';
      pairs = [
        {'word': 'Sight', 'emoji': '👁️', 'description': 'We use our eyes to see colors and shapes', 'malay_word': 'Penglihatan'},
        {'word': 'Hearing', 'emoji': '👂', 'description': 'We use our ears to hear sounds', 'malay_word': 'Pendengaran'},
        {'word': 'Smell', 'emoji': '👃', 'description': 'We use our nose to smell scents', 'malay_word': 'Bau'},
        {'word': 'Taste', 'emoji': '👅', 'description': 'We use our tongue to taste food', 'malay_word': 'Rasa'},
      ];
    } else {
      // Age 6: Complex with all 5 senses and comprehensive bilingual descriptions
      instructions = 'Match the sense with the correct body part and learn its name in English and Malay.';
      difficulty = 'hard';
      pairs = [
        {'word': 'Sight', 'emoji': '👁️', 'description': 'We use our eyes to see colors, shapes, and movement', 'malay_word': 'Penglihatan'},
        {'word': 'Hearing', 'emoji': '👂', 'description': 'We use our ears to hear sounds and music', 'malay_word': 'Pendengaran'},
        {'word': 'Smell', 'emoji': '👃', 'description': 'We use our nose to smell different scents', 'malay_word': 'Bau'},
        {'word': 'Taste', 'emoji': '👅', 'description': 'We use our tongue to taste sweet, sour, salty, and bitter', 'malay_word': 'Rasa'},
        {'word': 'Touch', 'emoji': '👐', 'description': 'We use our skin to feel textures and temperature', 'malay_word': 'Sentuhan'},
      ];
    }
    
    return {
      'title': 'Science - Five Senses',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Science',
        'chapter': 'Five Senses',
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
      // Age 4: Simple sorting with 3 basic categories and 6 items
      instructions = 'Sort these things by which sense we use: seeing, hearing, or touching.';
      difficulty = 'easy';
      categories = [
        {'name': 'Sight', 'description': 'Things we see with our eyes', 'emoji': '👁️', 'color': 'blue'},
        {'name': 'Hearing', 'description': 'Things we hear with our ears', 'emoji': '👂', 'color': 'green'},
        {'name': 'Touch', 'description': 'Things we feel with our hands', 'emoji': '👐', 'color': 'purple'},
      ];
      items = [
        {'name': 'Rainbow', 'category': 'Sight', 'emoji': '🌈', 'word': 'Rainbow', 'malay_word': 'Pelangi'},
        {'name': 'Fireworks', 'category': 'Sight', 'emoji': '🎆', 'word': 'Fireworks', 'malay_word': 'Bunga Api'},
        {'name': 'Music', 'category': 'Hearing', 'emoji': '🎵', 'word': 'Music', 'malay_word': 'Muzik'},
        {'name': 'Thunder', 'category': 'Hearing', 'emoji': '⚡', 'word': 'Thunder', 'malay_word': 'Guruh'},
        {'name': 'Sand', 'category': 'Touch', 'emoji': '🏖️', 'word': 'Sand', 'malay_word': 'Pasir'},
        {'name': 'Ice', 'category': 'Touch', 'emoji': '🧊', 'word': 'Ice', 'malay_word': 'Ais'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 4 categories and 8 items
      instructions = 'Sort the items by which sense we use to experience them. Learn the English and Malay names.';
      difficulty = 'medium';
      categories = [
        {'name': 'Sight', 'description': 'Things we experience with our eyes', 'emoji': '👁️', 'color': 'blue'},
        {'name': 'Hearing', 'description': 'Things we experience with our ears', 'emoji': '👂', 'color': 'green'},
        {'name': 'Smell', 'description': 'Things we experience with our nose', 'emoji': '👃', 'color': 'yellow'},
        {'name': 'Taste', 'description': 'Things we experience with our tongue', 'emoji': '👅', 'color': 'red'},
      ];
      items = [
        {'name': 'Rainbow', 'category': 'Sight', 'emoji': '🌈', 'word': 'Rainbow', 'malay_word': 'Pelangi'},
        {'name': 'Fireworks', 'category': 'Sight', 'emoji': '🎆', 'word': 'Fireworks', 'malay_word': 'Bunga Api'},
        {'name': 'Music', 'category': 'Hearing', 'emoji': '🎵', 'word': 'Music', 'malay_word': 'Muzik'},
        {'name': 'Thunder', 'category': 'Hearing', 'emoji': '⚡', 'word': 'Thunder', 'malay_word': 'Guruh'},
        {'name': 'Flower', 'category': 'Smell', 'emoji': '🌸', 'word': 'Flower', 'malay_word': 'Bunga'},
        {'name': 'Perfume', 'category': 'Smell', 'emoji': '🧴', 'word': 'Perfume', 'malay_word': 'Minyak Wangi'},
        {'name': 'Ice Cream', 'category': 'Taste', 'emoji': '🍦', 'word': 'Ice Cream', 'malay_word': 'Aiskrim'},
        {'name': 'Lemon', 'category': 'Taste', 'emoji': '🍋', 'word': 'Lemon', 'malay_word': 'Lemon'},
      ];
    } else {
      // Age 6: Complex with all 5 categories and all 10 items with detailed descriptions
      instructions = 'Sort the items by which sense we use to experience them. Explain why each item belongs to its category in both English and Malay.';
      difficulty = 'hard';
      categories = [
        {'name': 'Sight', 'description': 'Things we experience with our eyes', 'emoji': '👁️', 'color': 'blue'},
        {'name': 'Hearing', 'description': 'Things we experience with our ears', 'emoji': '👂', 'color': 'green'},
        {'name': 'Smell', 'description': 'Things we experience with our nose', 'emoji': '👃', 'color': 'yellow'},
        {'name': 'Taste', 'description': 'Things we experience with our tongue', 'emoji': '👅', 'color': 'red'},
        {'name': 'Touch', 'description': 'Things we experience with our skin', 'emoji': '👐', 'color': 'purple'},
      ];
      items = [
        {'name': 'Rainbow', 'category': 'Sight', 'emoji': '🌈', 'word': 'Rainbow', 'malay_word': 'Pelangi'},
        {'name': 'Fireworks', 'category': 'Sight', 'emoji': '🎆', 'word': 'Fireworks', 'malay_word': 'Bunga Api'},
        {'name': 'Music', 'category': 'Hearing', 'emoji': '🎵', 'word': 'Music', 'malay_word': 'Muzik'},
        {'name': 'Thunder', 'category': 'Hearing', 'emoji': '⚡', 'word': 'Thunder', 'malay_word': 'Guruh'},
        {'name': 'Flower', 'category': 'Smell', 'emoji': '🌸', 'word': 'Flower', 'malay_word': 'Bunga'},
        {'name': 'Perfume', 'category': 'Smell', 'emoji': '🧴', 'word': 'Perfume', 'malay_word': 'Minyak Wangi'},
        {'name': 'Ice Cream', 'category': 'Taste', 'emoji': '🍦', 'word': 'Ice Cream', 'malay_word': 'Aiskrim'},
        {'name': 'Lemon', 'category': 'Taste', 'emoji': '🍋', 'word': 'Lemon', 'malay_word': 'Lemon'},
        {'name': 'Sand', 'category': 'Touch', 'emoji': '🏖️', 'word': 'Sand', 'malay_word': 'Pasir'},
        {'name': 'Ice', 'category': 'Touch', 'emoji': '🧊', 'word': 'Ice', 'malay_word': 'Ais'},
      ];
    }
    
    return {
      'title': 'Science - Five Senses',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Science',
        'chapter': 'Five Senses',
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
      instructions = 'Trace the letters for our sense organs.';
      difficulty = 'easy';
      items = [
        {
          'character': 'E',
          'difficulty': 1,
          'instruction': 'Trace the letter E for Eye',
          'emoji': '👁️',
          'word': 'Eye',
          'malay_word': 'Mata',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'E',
          'difficulty': 1,
          'instruction': 'Trace the letter E for Ear',
          'emoji': '👂',
          'word': 'Ear',
          'malay_word': 'Telinga',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.7, 'y': 0.8},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 3 letters and bilingual instructions
      instructions = 'Trace the letters for our sense organs. Learn their names in English and Malay.';
      difficulty = 'medium';
      items = [
        {
          'character': 'E',
          'difficulty': 1,
          'instruction': 'Trace the letter E for Eye - Mata',
          'emoji': '👁️',
          'word': 'Eye',
          'malay_word': 'Mata',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'N',
          'difficulty': 1,
          'instruction': 'Trace the letter N for Nose - Hidung',
          'emoji': '👃',
          'word': 'Nose',
          'malay_word': 'Hidung',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.8},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'T',
          'difficulty': 1,
          'instruction': 'Trace the letter T for Tongue - Lidah',
          'emoji': '👅',
          'word': 'Tongue',
          'malay_word': 'Lidah',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
      ];
    } else {
      // Age 6: Complex with all 5 letters and comprehensive bilingual instructions
      instructions = 'Trace the letters for our five sense organs. Learn about each sense and its organ in English and Malay.';
      difficulty = 'hard';
      items = [
        {
          'character': 'E',
          'difficulty': 1,
          'instruction': 'Trace the letter E for Eye - Mata (Sight - Penglihatan)',
          'emoji': '👁️',
          'word': 'Eye',
          'malay_word': 'Mata',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'E',
          'difficulty': 1,
          'instruction': 'Trace the letter E for Ear - Telinga (Hearing - Pendengaran)',
          'emoji': '👂',
          'word': 'Ear',
          'malay_word': 'Telinga',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'N',
          'difficulty': 1,
          'instruction': 'Trace the letter N for Nose - Hidung (Smell - Bau)',
          'emoji': '👃',
          'word': 'Nose',
          'malay_word': 'Hidung',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.8},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'T',
          'difficulty': 1,
          'instruction': 'Trace the letter T for Tongue - Lidah (Taste - Rasa)',
          'emoji': '👅',
          'word': 'Tongue',
          'malay_word': 'Lidah',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'H',
          'difficulty': 1,
          'instruction': 'Trace the letter H for Hand - Tangan (Touch - Sentuhan)',
          'emoji': '👐',
          'word': 'Hand',
          'malay_word': 'Tangan',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.7, 'y': 0.8},
          ]
        },
      ];
    }
    
    return {
      'title': 'Science - Five Senses',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Science',
        'chapter': 'Five Senses',
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
      // Age 4: Simple with 3 basic senses
      instructions = 'Match the sense organ with its name.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'eye', 'color': 'blue', 'name': 'Eye', 'malay_shape': 'Mata', 'malay_color': 'Biru', 'word': 'Eye', 'malay_word': 'Mata'},
        {'shape': 'ear', 'color': 'pink', 'name': 'Ear', 'malay_shape': 'Telinga', 'malay_color': 'Merah Jambu', 'word': 'Ear', 'malay_word': 'Telinga'},
        {'shape': 'nose', 'color': 'red', 'name': 'Nose', 'malay_shape': 'Hidung', 'malay_color': 'Merah', 'word': 'Nose', 'malay_word': 'Hidung'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 4 senses and sense function
      instructions = 'Match the sense organ with its name and function.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'eye', 'color': 'blue', 'name': 'Eye (Sight)', 'malay_shape': 'Mata', 'malay_color': 'Biru', 'word': 'Eye', 'malay_word': 'Mata'},
        {'shape': 'ear', 'color': 'pink', 'name': 'Ear (Hearing)', 'malay_shape': 'Telinga', 'malay_color': 'Merah Jambu', 'word': 'Ear', 'malay_word': 'Telinga'},
        {'shape': 'nose', 'color': 'red', 'name': 'Nose (Smell)', 'malay_shape': 'Hidung', 'malay_color': 'Merah', 'word': 'Nose', 'malay_word': 'Hidung'},
        {'shape': 'tongue', 'color': 'purple', 'name': 'Tongue (Taste)', 'malay_shape': 'Lidah', 'malay_color': 'Ungu', 'word': 'Tongue', 'malay_word': 'Lidah'},
      ];
    } else {
      // Age 6: Complex with all 5 senses, bilingual names and functions
      instructions = 'Match the sense organ with its name, function, and color in both English and Malay.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'eye', 'color': 'blue', 'name': 'Eye (Sight)', 'malay_shape': 'Mata (Penglihatan)', 'malay_color': 'Biru', 'word': 'Eye', 'malay_word': 'Mata'},
        {'shape': 'ear', 'color': 'pink', 'name': 'Ear (Hearing)', 'malay_shape': 'Telinga (Pendengaran)', 'malay_color': 'Merah Jambu', 'word': 'Ear', 'malay_word': 'Telinga'},
        {'shape': 'nose', 'color': 'red', 'name': 'Nose (Smell)', 'malay_shape': 'Hidung (Bau)', 'malay_color': 'Merah', 'word': 'Nose', 'malay_word': 'Hidung'},
        {'shape': 'tongue', 'color': 'purple', 'name': 'Tongue (Taste)', 'malay_shape': 'Lidah (Rasa)', 'malay_color': 'Ungu', 'word': 'Tongue', 'malay_word': 'Lidah'},
        {'shape': 'hand', 'color': 'yellow', 'name': 'Hand (Touch)', 'malay_shape': 'Tangan (Sentuhan)', 'malay_color': 'Kuning', 'word': 'Hand', 'malay_word': 'Tangan'},
      ];
    }
    
    return {
      'title': 'Science - Five Senses',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Science',
        'chapter': 'Five Senses',
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
