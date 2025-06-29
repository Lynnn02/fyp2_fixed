import 'dart:math';

/// Template for Jawi - Simple Writing chapter
/// This template includes Arabic script for Jawi words with proper font specification
class JawiSimpleWritingTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: 4 simple words with basic instructions
      instructions = 'Match the Jawi word with its meaning.';
      difficulty = 'easy';
      pairs = [
        {'word': 'Ibu', 'emoji': 'ايبو', 'description': 'Mother', 'malay_word': 'Ibu', 'jawi_word': 'ايبو'},
        {'word': 'Bapa', 'emoji': 'باڤ', 'description': 'Father', 'malay_word': 'Bapa', 'jawi_word': 'باڤ'},
        {'word': 'Mata', 'emoji': 'مات', 'description': 'Eye', 'malay_word': 'Mata', 'jawi_word': 'مات'},
        {'word': 'Kaki', 'emoji': 'كاكي', 'description': 'Foot', 'malay_word': 'Kaki', 'jawi_word': 'كاكي'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 words with medium complexity
      instructions = 'Match the Jawi word with its meaning and pronunciation.';
      difficulty = 'medium';
      pairs = [
        {'word': 'Ibu', 'emoji': 'ايبو', 'description': 'Mother', 'malay_word': 'Ibu', 'jawi_word': 'ايبو'},
        {'word': 'Bapa', 'emoji': 'باڤ', 'description': 'Father', 'malay_word': 'Bapa', 'jawi_word': 'باڤ'},
        {'word': 'Mata', 'emoji': 'مات', 'description': 'Eye', 'malay_word': 'Mata', 'jawi_word': 'مات'},
        {'word': 'Kaki', 'emoji': 'كاكي', 'description': 'Foot', 'malay_word': 'Kaki', 'jawi_word': 'كاكي'},
        {'word': 'Rumah', 'emoji': 'رومه', 'description': 'House', 'malay_word': 'Rumah', 'jawi_word': 'رومه'},
        {'word': 'Sekolah', 'emoji': 'سكوله', 'description': 'School', 'malay_word': 'Sekolah', 'jawi_word': 'سكوله'},
      ];
    } else {
      // Age 6: 8 words with higher complexity
      instructions = 'Match the Jawi word with its meaning, pronunciation, and usage.';
      difficulty = 'hard';
      pairs = [
        {'word': 'Ibu', 'emoji': 'ايبو', 'description': 'Mother', 'malay_word': 'Ibu', 'jawi_word': 'ايبو'},
        {'word': 'Bapa', 'emoji': 'باڤ', 'description': 'Father', 'malay_word': 'Bapa', 'jawi_word': 'باڤ'},
        {'word': 'Mata', 'emoji': 'مات', 'description': 'Eye', 'malay_word': 'Mata', 'jawi_word': 'مات'},
        {'word': 'Kaki', 'emoji': 'كاكي', 'description': 'Foot', 'malay_word': 'Kaki', 'jawi_word': 'كاكي'},
        {'word': 'Rumah', 'emoji': 'رومه', 'description': 'House', 'malay_word': 'Rumah', 'jawi_word': 'رومه'},
        {'word': 'Sekolah', 'emoji': 'سكوله', 'description': 'School', 'malay_word': 'Sekolah', 'jawi_word': 'سكوله'},
        {'word': 'Kucing', 'emoji': 'كوچيڠ', 'description': 'Cat', 'malay_word': 'Kucing', 'jawi_word': 'كوچيڠ'},
        {'word': 'Bunga', 'emoji': 'بوڠا', 'description': 'Flower', 'malay_word': 'Bunga', 'jawi_word': 'بوڠا'},
      ];
    }
    
    return {
      'title': 'Jawi - Simple Writing',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Jawi',
        'chapter': 'Simple Writing',
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
      instructions = 'Sort the Jawi words into two groups.';
      difficulty = 'easy';
      categories = [
        {'name': 'Body Parts', 'description': 'Words related to body parts', 'emoji': 'مات', 'color': 'blue'},
        {'name': 'Family', 'description': 'Words related to family members', 'emoji': 'ايبو', 'color': 'green'},
      ];
      items = [
        {'name': 'Mata', 'category': 'Body Parts', 'emoji': 'مات', 'word': 'Mata', 'malay_word': 'Mata', 'jawi_word': 'مات'},
        {'name': 'Kaki', 'category': 'Body Parts', 'emoji': 'كاكي', 'word': 'Kaki', 'malay_word': 'Kaki', 'jawi_word': 'كاكي'},
        {'name': 'Ibu', 'category': 'Family', 'emoji': 'ايبو', 'word': 'Ibu', 'malay_word': 'Ibu', 'jawi_word': 'ايبو'},
        {'name': 'Bapa', 'category': 'Family', 'emoji': 'باڤ', 'word': 'Bapa', 'malay_word': 'Bapa', 'jawi_word': 'باڤ'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 2 categories with 6 items
      instructions = 'Sort the Jawi words by their categories.';
      difficulty = 'medium';
      categories = [
        {'name': 'Body Parts', 'description': 'Words related to body parts', 'emoji': 'مات', 'color': 'blue'},
        {'name': 'Family', 'description': 'Words related to family members', 'emoji': 'ايبو', 'color': 'green'},
      ];
      items = [
        {'name': 'Mata', 'category': 'Body Parts', 'emoji': 'مات', 'word': 'Mata', 'malay_word': 'Mata', 'jawi_word': 'مات'},
        {'name': 'Kaki', 'category': 'Body Parts', 'emoji': 'كاكي', 'word': 'Kaki', 'malay_word': 'Kaki', 'jawi_word': 'كاكي'},
        {'name': 'Tangan', 'category': 'Body Parts', 'emoji': 'تاڠن', 'word': 'Tangan', 'malay_word': 'Tangan', 'jawi_word': 'تاڠن'},
        {'name': 'Ibu', 'category': 'Family', 'emoji': 'ايبو', 'word': 'Ibu', 'malay_word': 'Ibu', 'jawi_word': 'ايبو'},
        {'name': 'Bapa', 'category': 'Family', 'emoji': 'باڤ', 'word': 'Bapa', 'malay_word': 'Bapa', 'jawi_word': 'باڤ'},
        {'name': 'Adik', 'category': 'Family', 'emoji': 'اديق', 'word': 'Adik', 'malay_word': 'Adik', 'jawi_word': 'اديق'},
      ];
    } else {
      // Age 6: 3 categories with 9 items
      instructions = 'Sort the Jawi words by their categories and meanings.';
      difficulty = 'hard';
      categories = [
        {'name': 'Body Parts', 'description': 'Words related to body parts', 'emoji': 'مات', 'color': 'blue'},
        {'name': 'Family', 'description': 'Words related to family members', 'emoji': 'ايبو', 'color': 'green'},
        {'name': 'Places', 'description': 'Words related to places', 'emoji': 'رومه', 'color': 'red'},
      ];
      items = [
        {'name': 'Mata', 'category': 'Body Parts', 'emoji': 'مات', 'word': 'Mata', 'malay_word': 'Mata', 'jawi_word': 'مات'},
        {'name': 'Kaki', 'category': 'Body Parts', 'emoji': 'كاكي', 'word': 'Kaki', 'malay_word': 'Kaki', 'jawi_word': 'كاكي'},
        {'name': 'Tangan', 'category': 'Body Parts', 'emoji': 'تاڠن', 'word': 'Tangan', 'malay_word': 'Tangan', 'jawi_word': 'تاڠن'},
        {'name': 'Ibu', 'category': 'Family', 'emoji': 'ايبو', 'word': 'Ibu', 'malay_word': 'Ibu', 'jawi_word': 'ايبو'},
        {'name': 'Bapa', 'category': 'Family', 'emoji': 'باڤ', 'word': 'Bapa', 'malay_word': 'Bapa', 'jawi_word': 'باڤ'},
        {'name': 'Adik', 'category': 'Family', 'emoji': 'اديق', 'word': 'Adik', 'malay_word': 'Adik', 'jawi_word': 'اديق'},
        {'name': 'Rumah', 'category': 'Places', 'emoji': 'رومه', 'word': 'Rumah', 'malay_word': 'Rumah', 'jawi_word': 'رومه'},
        {'name': 'Sekolah', 'category': 'Places', 'emoji': 'سكوله', 'word': 'Sekolah', 'malay_word': 'Sekolah', 'jawi_word': 'سكوله'},
        {'name': 'Pasar', 'category': 'Places', 'emoji': 'ڤاسر', 'word': 'Pasar', 'malay_word': 'Pasar', 'jawi_word': 'ڤاسر'},
      ];
    }
    
    return {
      'title': 'Jawi - Simple Writing',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Jawi',
        'chapter': 'Simple Writing',
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
      // Age 4: 2 simple words with basic instructions
      instructions = 'Trace these simple Jawi words.';
      difficulty = 'easy';
      items = [
        {
          'character': 'ايبو',
          'difficulty': 1,
          'instruction': 'Trace the word Ibu (Mother)',
          'emoji': 'ايبو',
          'word': 'Ibu',
          'malay_word': 'Ibu',
          'jawi_word': 'ايبو',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': 'باڤ',
          'difficulty': 1,
          'instruction': 'Trace the word Bapa (Father)',
          'emoji': 'باڤ',
          'word': 'Bapa',
          'malay_word': 'Bapa',
          'jawi_word': 'باڤ',
          'pathPoints': [
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.7},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 3 medium complexity words
      instructions = 'Trace these Jawi words carefully.';
      difficulty = 'medium';
      items = [
        {
          'character': 'ايبو',
          'difficulty': 1,
          'instruction': 'Trace the word Ibu (Mother)',
          'emoji': 'ايبو',
          'word': 'Ibu',
          'malay_word': 'Ibu',
          'jawi_word': 'ايبو',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': 'باڤ',
          'difficulty': 1,
          'instruction': 'Trace the word Bapa (Father)',
          'emoji': 'باڤ',
          'word': 'Bapa',
          'malay_word': 'Bapa',
          'jawi_word': 'باڤ',
          'pathPoints': [
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': 'مات',
          'difficulty': 2,
          'instruction': 'Trace the word Mata (Eye)',
          'emoji': 'مات',
          'word': 'Mata',
          'malay_word': 'Mata',
          'jawi_word': 'مات',
          'pathPoints': [
            {'x': 0.7, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.7},
          ]
        },
      ];
    } else {
      // Age 6: 5 complex words
      instructions = 'Trace these Jawi words following the correct stroke order.';
      difficulty = 'hard';
      items = [
        {
          'character': 'ايبو',
          'difficulty': 1,
          'instruction': 'Trace the word Ibu (Mother)',
          'emoji': 'ايبو',
          'word': 'Ibu',
          'malay_word': 'Ibu',
          'jawi_word': 'ايبو',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': 'باڤ',
          'difficulty': 1,
          'instruction': 'Trace the word Bapa (Father)',
          'emoji': 'باڤ',
          'word': 'Bapa',
          'malay_word': 'Bapa',
          'jawi_word': 'باڤ',
          'pathPoints': [
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': 'مات',
          'difficulty': 2,
          'instruction': 'Trace the word Mata (Eye)',
          'emoji': 'مات',
          'word': 'Mata',
          'malay_word': 'Mata',
          'jawi_word': 'مات',
          'pathPoints': [
            {'x': 0.7, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': 'رومه',
          'difficulty': 2,
          'instruction': 'Trace the word Rumah (House)',
          'emoji': 'رومه',
          'word': 'Rumah',
          'malay_word': 'Rumah',
          'jawi_word': 'رومه',
          'pathPoints': [
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': 'كوچيڠ',
          'difficulty': 3,
          'instruction': 'Trace the word Kucing (Cat)',
          'emoji': 'كوچيڠ',
          'word': 'Kucing',
          'malay_word': 'Kucing',
          'jawi_word': 'كوچيڠ',
          'pathPoints': [
            {'x': 0.8, 'y': 0.5},
            {'x': 0.8, 'y': 0.3},
            {'x': 0.8, 'y': 0.7},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.2, 'y': 0.5},
            {'x': 0.2, 'y': 0.3},
            {'x': 0.2, 'y': 0.7},
          ]
        },
      ];
    }
    
    return {
      'title': 'Jawi - Simple Writing',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Jawi',
        'chapter': 'Simple Writing',
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
      instructions = 'Match the Jawi word with its meaning.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'ibu', 'color': 'red', 'name': 'Ibu', 'malay_shape': 'Ibu', 'malay_color': 'Merah', 'jawi_word': 'ايبو', 'word': 'Ibu', 'malay_word': 'Ibu'},
        {'shape': 'bapa', 'color': 'blue', 'name': 'Bapa', 'malay_shape': 'Bapa', 'malay_color': 'Biru', 'jawi_word': 'باڤ', 'word': 'Bapa', 'malay_word': 'Bapa'},
        {'shape': 'mata', 'color': 'green', 'name': 'Mata', 'malay_shape': 'Mata', 'malay_color': 'Hijau', 'jawi_word': 'مات', 'word': 'Mata', 'malay_word': 'Mata'},
        {'shape': 'kaki', 'color': 'yellow', 'name': 'Kaki', 'malay_shape': 'Kaki', 'malay_color': 'Kuning', 'jawi_word': 'كاكي', 'word': 'Kaki', 'malay_word': 'Kaki'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 shapes with medium complexity
      instructions = 'Match the Jawi word with its meaning and color.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'ibu', 'color': 'red', 'name': 'Ibu', 'malay_shape': 'Ibu', 'malay_color': 'Merah', 'jawi_word': 'ايبو', 'word': 'Ibu', 'malay_word': 'Ibu'},
        {'shape': 'bapa', 'color': 'blue', 'name': 'Bapa', 'malay_shape': 'Bapa', 'malay_color': 'Biru', 'jawi_word': 'باڤ', 'word': 'Bapa', 'malay_word': 'Bapa'},
        {'shape': 'mata', 'color': 'green', 'name': 'Mata', 'malay_shape': 'Mata', 'malay_color': 'Hijau', 'jawi_word': 'مات', 'word': 'Mata', 'malay_word': 'Mata'},
        {'shape': 'kaki', 'color': 'yellow', 'name': 'Kaki', 'malay_shape': 'Kaki', 'malay_color': 'Kuning', 'jawi_word': 'كاكي', 'word': 'Kaki', 'malay_word': 'Kaki'},
        {'shape': 'rumah', 'color': 'purple', 'name': 'Rumah', 'malay_shape': 'Rumah', 'malay_color': 'Ungu', 'jawi_word': 'رومه', 'word': 'Rumah', 'malay_word': 'Rumah'},
        {'shape': 'sekolah', 'color': 'orange', 'name': 'Sekolah', 'malay_shape': 'Sekolah', 'malay_color': 'Oren', 'jawi_word': 'سكوله', 'word': 'Sekolah', 'malay_word': 'Sekolah'},
      ];
    } else {
      // Age 6: 8 shapes with higher complexity
      instructions = 'Match the Jawi word with its meaning, color, and pronunciation.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'ibu', 'color': 'red', 'name': 'Ibu', 'malay_shape': 'Ibu', 'malay_color': 'Merah', 'jawi_word': 'ايبو', 'word': 'Ibu', 'malay_word': 'Ibu'},
        {'shape': 'bapa', 'color': 'blue', 'name': 'Bapa', 'malay_shape': 'Bapa', 'malay_color': 'Biru', 'jawi_word': 'باڤ', 'word': 'Bapa', 'malay_word': 'Bapa'},
        {'shape': 'mata', 'color': 'green', 'name': 'Mata', 'malay_shape': 'Mata', 'malay_color': 'Hijau', 'jawi_word': 'مات', 'word': 'Mata', 'malay_word': 'Mata'},
        {'shape': 'kaki', 'color': 'yellow', 'name': 'Kaki', 'malay_shape': 'Kaki', 'malay_color': 'Kuning', 'jawi_word': 'كاكي', 'word': 'Kaki', 'malay_word': 'Kaki'},
        {'shape': 'rumah', 'color': 'purple', 'name': 'Rumah', 'malay_shape': 'Rumah', 'malay_color': 'Ungu', 'jawi_word': 'رومه', 'word': 'Rumah', 'malay_word': 'Rumah'},
        {'shape': 'sekolah', 'color': 'orange', 'name': 'Sekolah', 'malay_shape': 'Sekolah', 'malay_color': 'Oren', 'jawi_word': 'سكوله', 'word': 'Sekolah', 'malay_word': 'Sekolah'},
        {'shape': 'kucing', 'color': 'pink', 'name': 'Kucing', 'malay_shape': 'Kucing', 'malay_color': 'Merah Jambu', 'jawi_word': 'كوچيڠ', 'word': 'Kucing', 'malay_word': 'Kucing'},
        {'shape': 'bunga', 'color': 'white', 'name': 'Bunga', 'malay_shape': 'Bunga', 'malay_color': 'Putih', 'jawi_word': 'بوڠا', 'word': 'Bunga', 'malay_word': 'Bunga'},
      ];
    }
    
    return {
      'title': 'Jawi - Simple Writing',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Jawi',
        'chapter': 'Simple Writing',
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
