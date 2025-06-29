import 'package:flutter/material.dart';

/// Provides game content for "Bahasa Malaysia - Huruf & Kata Asas" subject
class HurufKataAsasTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: 5 simple pairs with basic huruf
      instructions = 'Padankan huruf.';
      difficulty = 'easy';
      pairs = [
        {'word': 'A', 'emoji': '🍎', 'description': 'Epal', 'malay_word': 'Epal'},
        {'word': 'B', 'emoji': '🍌', 'description': 'Pisang', 'malay_word': 'Pisang'},
        {'word': 'C', 'emoji': '🐱', 'description': 'Kucing', 'malay_word': 'Kucing'},
        {'word': 'D', 'emoji': '🦮', 'description': 'Anjing', 'malay_word': 'Anjing'},
        {'word': 'E', 'emoji': '🐘', 'description': 'Gajah', 'malay_word': 'Gajah'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 pairs with medium complexity
      instructions = 'Padankan huruf dengan gambar yang betul.';
      difficulty = 'medium';
      pairs = [
        {'word': 'A', 'emoji': '🍎', 'description': 'Epal', 'malay_word': 'Epal'},
        {'word': 'B', 'emoji': '🍌', 'description': 'Pisang', 'malay_word': 'Pisang'},
        {'word': 'C', 'emoji': '🐱', 'description': 'Kucing', 'malay_word': 'Kucing'},
        {'word': 'D', 'emoji': '🦮', 'description': 'Anjing', 'malay_word': 'Anjing'},
        {'word': 'E', 'emoji': '🐘', 'description': 'Gajah', 'malay_word': 'Gajah'},
        {'word': 'F', 'emoji': '🐟', 'description': 'Ikan', 'malay_word': 'Ikan'},
      ];
    } else {
      // Age 6: 8 pairs with higher complexity
      instructions = 'Padankan huruf dengan gambar dan perkataan yang betul.';
      difficulty = 'hard';
      pairs = [
        {'word': 'A', 'emoji': '🍎', 'description': 'Epal', 'malay_word': 'Epal'},
        {'word': 'B', 'emoji': '🍌', 'description': 'Pisang', 'malay_word': 'Pisang'},
        {'word': 'C', 'emoji': '🐱', 'description': 'Kucing', 'malay_word': 'Kucing'},
        {'word': 'D', 'emoji': '🦮', 'description': 'Anjing', 'malay_word': 'Anjing'},
        {'word': 'E', 'emoji': '🐘', 'description': 'Gajah', 'malay_word': 'Gajah'},
        {'word': 'F', 'emoji': '🐟', 'description': 'Ikan', 'malay_word': 'Ikan'},
        {'word': 'G', 'emoji': '🦒', 'description': 'Zirafah', 'malay_word': 'Zirafah'},
        {'word': 'H', 'emoji': '🦛', 'description': 'Badak Air', 'malay_word': 'Badak Air'},
      ];
    }
    
    return {
      'title': 'Bahasa Malaysia - Huruf & Kata Asas',
      'instructions': instructions,
      'pairs': pairs,
      'metadata': {
        'subject': 'Bahasa Malaysia',
        'chapter': 'Huruf & Kata Asas',
        'ageGroup': ageGroup,
        'difficulty': difficulty,
      }
    };
  }

  /// Get sorting game content
  static Map<String, dynamic> getSortingContent(int ageGroup) {
    List<Map<String, dynamic>> categories = [];
    List<Map<String, dynamic>> items = [];
    String instructions = '';
    String difficulty = '';
    
    // Common categories for all age groups
    categories = [
      {'name': 'Huruf Vokal', 'description': 'Huruf vokal dalam Bahasa Malaysia', 'emoji': '🔤', 'color': 'blue'},
      {'name': 'Huruf Konsonan', 'description': 'Huruf konsonan dalam Bahasa Malaysia', 'emoji': '🔠', 'color': 'green'},
    ];
    
    if (ageGroup == 4) {
      // Age 4: 5 items with simple instructions
      instructions = 'Susun huruf.';
      difficulty = 'easy';
      items = [
        {'name': 'A', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '🅰️'},
        {'name': 'B', 'category': 'Huruf Konsonan', 'imageUrl': '', 'emoji': '🅱️'},
        {'name': 'E', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '🇪'},
        {'name': 'I', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '🇮'},
        {'name': 'O', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '⭕'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 items with more detailed instructions
      instructions = 'Susun huruf mengikut kategori yang betul.';
      difficulty = 'medium';
      items = [
        {'name': 'A', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '🅰️'},
        {'name': 'B', 'category': 'Huruf Konsonan', 'imageUrl': '', 'emoji': '🅱️'},
        {'name': 'C', 'category': 'Huruf Konsonan', 'imageUrl': '', 'emoji': '©️'},
        {'name': 'E', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '🇪'},
        {'name': 'I', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '🇮'},
        {'name': 'O', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '⭕'},
      ];
    } else {
      // Age 6: 8 items with complex instructions
      instructions = 'Susun huruf mengikut kategori vokal dan konsonan yang betul.';
      difficulty = 'hard';
      items = [
        {'name': 'A', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '🅰️'},
        {'name': 'B', 'category': 'Huruf Konsonan', 'imageUrl': '', 'emoji': '🅱️'},
        {'name': 'C', 'category': 'Huruf Konsonan', 'imageUrl': '', 'emoji': '©️'},
        {'name': 'D', 'category': 'Huruf Konsonan', 'imageUrl': '', 'emoji': '🇩'},
        {'name': 'E', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '🇪'},
        {'name': 'F', 'category': 'Huruf Konsonan', 'imageUrl': '', 'emoji': '🇫'},
        {'name': 'I', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '🇮'},
        {'name': 'O', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '⭕'},
        {'name': 'U', 'category': 'Huruf Vokal', 'imageUrl': '', 'emoji': '🇺'},
      ];
    }
    
    return {
      'title': 'Bahasa Malaysia - Huruf & Kata Asas',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'metadata': {
        'subject': 'Bahasa Malaysia',
        'chapter': 'Huruf & Kata Asas',
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
      // Age 4: 5 simple letters with basic instructions
      instructions = 'Jejak huruf.';
      difficulty = 'easy';
      items = [
        {
          'character': 'A',
          'difficulty': 1,
          'instruction': 'Jejak huruf A',
          'emoji': '🍎',
          'word': 'Apple',
          'malay_word': 'Apel',
          'pathPoints': [
            {'x': 0.2, 'y': 0.8},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.8, 'y': 0.8},
            {'x': 0.35, 'y': 0.5},
            {'x': 0.65, 'y': 0.5},
          ]
        },
        {
          'character': 'B',
          'difficulty': 1,
          'instruction': 'Jejak huruf B',
          'emoji': '🐻',
          'word': 'Bear',
          'malay_word': 'Beruang',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': 'C',
          'difficulty': 1,
          'instruction': 'Jejak huruf C',
          'emoji': '🍒',
          'word': 'Cherry',
          'malay_word': 'Ceri',
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
        {
          'character': 'D',
          'difficulty': 1,
          'instruction': 'Jejak huruf D',
          'emoji': '🍍',
          'word': 'Durian',
          'malay_word': 'Durian',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': 'G',
          'difficulty': 2,
          'instruction': 'Jejak huruf G',
          'emoji': '🐘',
          'word': 'Elephant',
          'malay_word': 'Gajah',
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
          'character': 'P',
          'difficulty': 1,
          'instruction': 'Jejak huruf P',
          'emoji': '🍌',
          'word': 'Banana',
          'malay_word': 'Pisang',
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
          'character': 'I',
          'difficulty': 1,
          'instruction': 'Jejak huruf I',
          'emoji': '🍥',
          'word': 'Fish',
          'malay_word': 'Ikan',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'K',
          'difficulty': 2,
          'instruction': 'Jejak huruf K',
          'emoji': '🐱',
          'word': 'Cat',
          'malay_word': 'Kucing',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.8},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 letters with more detailed instructions
      instructions = 'Jejak huruf dengan mengikut garis.';
      difficulty = 'medium';
      items = [
        {
          'character': 'A',
          'difficulty': 1,
          'instruction': 'Jejak huruf A',
          'emoji': '🍎',
          'word': 'Apple',
          'malay_word': 'Epal',
          'pathPoints': [
            {'x': 0.2, 'y': 0.8},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.8, 'y': 0.8},
            {'x': 0.35, 'y': 0.5},
            {'x': 0.65, 'y': 0.5},
          ]
        },
        {
          'character': 'B',
          'difficulty': 1,
          'instruction': 'Jejak huruf B',
          'emoji': '🐻',
          'word': 'Bear',
          'malay_word': 'Beruang',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': 'C',
          'difficulty': 1,
          'instruction': 'Jejak huruf C',
          'emoji': '🍒',
          'word': 'Cherry',
          'malay_word': 'Ceri',
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
        {
          'character': 'D',
          'difficulty': 1,
          'instruction': 'Jejak huruf D',
          'emoji': '🍍',
          'word': 'Durian',
          'malay_word': 'Durian',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': 'G',
          'difficulty': 2,
          'instruction': 'Jejak huruf G',
          'emoji': '🐘',
          'word': 'Elephant',
          'malay_word': 'Gajah',
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
          'character': 'P',
          'difficulty': 1,
          'instruction': 'Jejak huruf P',
          'emoji': '🍌',
          'word': 'Banana',
          'malay_word': 'Pisang',
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
      // Age 6: 8 letters with complex instructions
      instructions = 'Jejak huruf dengan mengikut garis dengan teliti.';
      difficulty = 'hard';
      items = [
        {
          'character': 'A',
          'difficulty': 1,
          'instruction': 'Jejak huruf A dengan teliti',
          'emoji': '🍎',
          'word': 'Apple',
          'malay_word': 'Epal',
          'pathPoints': [
            {'x': 0.2, 'y': 0.8},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.8, 'y': 0.8},
            {'x': 0.35, 'y': 0.5},
            {'x': 0.65, 'y': 0.5},
          ]
        },
        {
          'character': 'B',
          'difficulty': 1,
          'instruction': 'Jejak huruf B dengan teliti',
          'emoji': '🐻',
          'word': 'Bear',
          'malay_word': 'Beruang',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': 'C',
          'difficulty': 1,
          'instruction': 'Jejak huruf C dengan teliti',
          'emoji': '🍒',
          'word': 'Cherry',
          'malay_word': 'Ceri',
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
        {
          'character': 'D',
          'difficulty': 1,
          'instruction': 'Jejak huruf D dengan teliti',
          'emoji': '🍍',
          'word': 'Durian',
          'malay_word': 'Durian',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': 'G',
          'difficulty': 2,
          'instruction': 'Jejak huruf G dengan teliti',
          'emoji': '🐘',
          'word': 'Elephant',
          'malay_word': 'Gajah',
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
          'character': 'P',
          'difficulty': 1,
          'instruction': 'Jejak huruf P dengan teliti',
          'emoji': '🍌',
          'word': 'Banana',
          'malay_word': 'Pisang',
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
          'character': 'I',
          'difficulty': 1,
          'instruction': 'Jejak huruf I dengan teliti',
          'emoji': '🍥',
          'word': 'Fish',
          'malay_word': 'Ikan',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
        {
          'character': 'K',
          'difficulty': 2,
          'instruction': 'Jejak huruf K dengan teliti',
          'emoji': '🐱',
          'word': 'Cat',
          'malay_word': 'Kucing',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.8},
          ]
        },
      ];
    }
    
    return {
      'title': 'Bahasa Malaysia - Huruf & Kata Asas',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Bahasa Malaysia',
        'chapter': 'Huruf & Kata Asas',
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
      // Age 4: 5 simple shapes with basic instructions
      instructions = 'Cari bentuk huruf.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'A', 'malay_shape': 'Bulatan', 'malay_color': 'Merah'},
        {'shape': 'square', 'color': 'blue', 'name': 'B', 'malay_shape': 'Segi Empat', 'malay_color': 'Biru'},
        {'shape': 'triangle', 'color': 'green', 'name': 'C', 'malay_shape': 'Segi Tiga', 'malay_color': 'Hijau'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'D', 'malay_shape': 'Segi Empat Tepat', 'malay_color': 'Kuning'},
        {'shape': 'star', 'color': 'purple', 'name': 'E', 'malay_shape': 'Bintang', 'malay_color': 'Ungu'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 shapes with more detailed instructions
      instructions = 'Cari bentuk yang mewakili huruf.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Bulatan A', 'malay_shape': 'Bulatan', 'malay_color': 'Merah'},
        {'shape': 'square', 'color': 'blue', 'name': 'Segi Empat B', 'malay_shape': 'Segi Empat', 'malay_color': 'Biru'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Segi Tiga C', 'malay_shape': 'Segi Tiga', 'malay_color': 'Hijau'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Segi Empat Tepat D', 'malay_shape': 'Segi Empat Tepat', 'malay_color': 'Kuning'},
        {'shape': 'star', 'color': 'purple', 'name': 'Bintang E', 'malay_shape': 'Bintang', 'malay_color': 'Ungu'},
        {'shape': 'heart', 'color': 'pink', 'name': 'Hati F', 'malay_shape': 'Hati', 'malay_color': 'Merah Jambu'},
      ];
    } else {
      // Age 6: 8 shapes with complex instructions
      instructions = 'Cari bentuk dan warna yang mewakili huruf dengan betul.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Bulatan A', 'malay_shape': 'Bulatan', 'malay_color': 'Merah'},
        {'shape': 'square', 'color': 'blue', 'name': 'Segi Empat B', 'malay_shape': 'Segi Empat', 'malay_color': 'Biru'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Segi Tiga C', 'malay_shape': 'Segi Tiga', 'malay_color': 'Hijau'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Segi Empat Tepat D', 'malay_shape': 'Segi Empat Tepat', 'malay_color': 'Kuning'},
        {'shape': 'star', 'color': 'purple', 'name': 'Bintang E', 'malay_shape': 'Bintang', 'malay_color': 'Ungu'},
        {'shape': 'heart', 'color': 'pink', 'name': 'Hati F', 'malay_shape': 'Hati', 'malay_color': 'Merah Jambu'},
        {'shape': 'oval', 'color': 'orange', 'name': 'Bujur G', 'malay_shape': 'Bujur', 'malay_color': 'Oren'},
        {'shape': 'diamond', 'color': 'teal', 'name': 'Berlian H', 'malay_shape': 'Berlian', 'malay_color': 'Hijau Kebiruan'},
      ];
    }
    
    return {
      'title': 'Bahasa Malaysia - Huruf & Kata Asas',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Bahasa Malaysia',
        'chapter': 'Huruf & Kata Asas',
        'ageGroup': ageGroup,
        'difficulty': difficulty,
      }
    };
  }
  
  /// Get content for specific game type
  static Map<String, dynamic> getContent(String gameType, int ageGroup, int rounds) {
    print('🔍 HurufKataAsasTemplate: Getting content for game type: $gameType');
    Map<String, dynamic> content;
    
    switch (gameType) {
      case 'matching':
        content = getMatchingContent(ageGroup);
        break;
      case 'sorting':
        content = getSortingContent(ageGroup);
        break;
      case 'tracing':
        content = getTracingContent(ageGroup);
        break;
      case 'shape_color':
        content = getShapeColorContent(ageGroup, rounds);
        break;
      default:
        content = getMatchingContent(ageGroup);
        break;
    }
    
    print('📦 HurufKataAsasTemplate: Content generated for $gameType');
    print('📦 Content keys: ${content.keys.toList()}');
    return content;
  }
}
