import 'package:flutter/material.dart';

/// Provides game content for "Bahasa Malaysia - Perkataan Mudah" subject
class PerkataanMudahTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: 5 simple pairs with basic words
      instructions = 'Padankan perkataan.';
      difficulty = 'easy';
      pairs = [
        {'word': 'Kucing', 'emoji': '🐱', 'description': 'Haiwan'},
        {'word': 'Anjing', 'emoji': '🐶', 'description': 'Haiwan'},
        {'word': 'Rumah', 'emoji': '🏠', 'description': 'Tempat'},
        {'word': 'Pokok', 'emoji': '🌳', 'description': 'Tumbuhan'},
        {'word': 'Bunga', 'emoji': '🌸', 'description': 'Tumbuhan'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 pairs with medium complexity
      instructions = 'Padankan perkataan dengan gambar yang betul.';
      difficulty = 'medium';
      pairs = [
        {'word': 'Kucing', 'emoji': '🐱', 'description': 'Haiwan peliharaan'},
        {'word': 'Anjing', 'emoji': '🐶', 'description': 'Haiwan peliharaan'},
        {'word': 'Rumah', 'emoji': '🏠', 'description': 'Tempat tinggal'},
        {'word': 'Pokok', 'emoji': '🌳', 'description': 'Tumbuhan'},
        {'word': 'Bunga', 'emoji': '🌸', 'description': 'Tumbuhan'},
        {'word': 'Matahari', 'emoji': '☀️', 'description': 'Di langit'},
      ];
    } else {
      // Age 6: 8 pairs with higher complexity
      instructions = 'Padankan perkataan dengan gambar dan deskripsi yang betul.';
      difficulty = 'hard';
      pairs = [
        {'word': 'Kucing', 'emoji': '🐱', 'description': 'Haiwan peliharaan'},
        {'word': 'Anjing', 'emoji': '🐶', 'description': 'Haiwan peliharaan'},
        {'word': 'Rumah', 'emoji': '🏠', 'description': 'Tempat tinggal'},
        {'word': 'Pokok', 'emoji': '🌳', 'description': 'Tumbuhan'},
        {'word': 'Bunga', 'emoji': '🌸', 'description': 'Tumbuhan'},
        {'word': 'Matahari', 'emoji': '☀️', 'description': 'Di langit'},
        {'word': 'Bulan', 'emoji': '🌙', 'description': 'Di langit'},
        {'word': 'Bintang', 'emoji': '⭐', 'description': 'Di langit'},
      ];
    }
    
    return {
      'title': 'Bahasa Malaysia - Perkataan Mudah',
      'instructions': instructions,
      'pairs': pairs,
      'metadata': {
        'subject': 'Bahasa Malaysia',
        'chapter': 'Perkataan Mudah',
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
      {'name': 'Haiwan', 'description': 'Nama-nama haiwan', 'emoji': '🐾', 'color': 'brown'},
      {'name': 'Buah-buahan', 'description': 'Nama-nama buah', 'emoji': '🍎', 'color': 'red'},
      {'name': 'Sayur-sayuran', 'description': 'Nama-nama sayur', 'emoji': '🥦', 'color': 'green'},
    ];
    
    if (ageGroup == 4) {
      // Age 4: 5 items with simple instructions
      instructions = 'Susun perkataan.';
      difficulty = 'easy';
      items = [
        {'name': 'Kucing', 'category': 'Haiwan', 'imageUrl': '', 'emoji': '🐱'},
        {'name': 'Epal', 'category': 'Buah-buahan', 'imageUrl': '', 'emoji': '🍎'},
        {'name': 'Lobak', 'category': 'Sayur-sayuran', 'imageUrl': '', 'emoji': '🥕'},
        {'name': 'Anjing', 'category': 'Haiwan', 'imageUrl': '', 'emoji': '🐶'},
        {'name': 'Pisang', 'category': 'Buah-buahan', 'imageUrl': '', 'emoji': '🍌'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 items with more detailed instructions
      instructions = 'Susun perkataan mengikut kategori yang betul.';
      difficulty = 'medium';
      items = [
        {'name': 'Kucing', 'category': 'Haiwan', 'imageUrl': '', 'emoji': '🐱'},
        {'name': 'Epal', 'category': 'Buah-buahan', 'imageUrl': '', 'emoji': '🍎'},
        {'name': 'Lobak', 'category': 'Sayur-sayuran', 'imageUrl': '', 'emoji': '🥕'},
        {'name': 'Anjing', 'category': 'Haiwan', 'imageUrl': '', 'emoji': '🐶'},
        {'name': 'Pisang', 'category': 'Buah-buahan', 'imageUrl': '', 'emoji': '🍌'},
        {'name': 'Tomato', 'category': 'Sayur-sayuran', 'imageUrl': '', 'emoji': '🍅'},
      ];
    } else {
      // Age 6: 9 items with complex instructions
      instructions = 'Susun perkataan mengikut kategori haiwan, buah-buahan dan sayur-sayuran yang betul.';
      difficulty = 'hard';
      items = [
        {'name': 'Kucing', 'category': 'Haiwan', 'imageUrl': '', 'emoji': '🐱'},
        {'name': 'Epal', 'category': 'Buah-buahan', 'imageUrl': '', 'emoji': '🍎'},
        {'name': 'Lobak', 'category': 'Sayur-sayuran', 'imageUrl': '', 'emoji': '🥕'},
        {'name': 'Anjing', 'category': 'Haiwan', 'imageUrl': '', 'emoji': '🐶'},
        {'name': 'Pisang', 'category': 'Buah-buahan', 'imageUrl': '', 'emoji': '🍌'},
        {'name': 'Tomato', 'category': 'Sayur-sayuran', 'imageUrl': '', 'emoji': '🍅'},
        {'name': 'Arnab', 'category': 'Haiwan', 'imageUrl': '', 'emoji': '🐰'},
        {'name': 'Oren', 'category': 'Buah-buahan', 'imageUrl': '', 'emoji': '🍊'},
        {'name': 'Brokoli', 'category': 'Sayur-sayuran', 'imageUrl': '', 'emoji': '🥦'},
      ];
    }
    
    return {
      'title': 'Bahasa Malaysia - Perkataan Mudah',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'metadata': {
        'subject': 'Bahasa Malaysia',
        'chapter': 'Perkataan Mudah',
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
      // Age 4: 2 simple words with basic instructions
      instructions = 'Jejak perkataan.';
      difficulty = 'easy';
      items = [
        {
          'character': 'Ibu',
          'difficulty': 1,
          'instruction': 'Jejak "Ibu"',
          'emoji': '👩',
          'word': 'Mother',
          'malay_word': 'Ibu',
          'pathPoints': [
            {'x': 0.2, 'y': 0.3},
            {'x': 0.2, 'y': 0.7},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.7},
          ]
        },
        {
          'character': 'Bapa',
          'difficulty': 1,
          'instruction': 'Jejak "Bapa"',
          'emoji': '👨',
          'word': 'Father',
          'malay_word': 'Bapa',
          'pathPoints': [
            {'x': 0.2, 'y': 0.3},
            {'x': 0.2, 'y': 0.7},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.7},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 2 words with medium complexity
      instructions = 'Jejak perkataan mengikut titik.';
      difficulty = 'medium';
      items = [
        {
          'character': 'Ibu',
          'difficulty': 1,
          'instruction': 'Jejak perkataan "Ibu"',
          'emoji': '👩',
          'word': 'Mother',
          'malay_word': 'Ibu',
          'pathPoints': [
            {'x': 0.2, 'y': 0.3},
            {'x': 0.2, 'y': 0.7},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.6, 'y': 0.7},
          ]
        },
        {
          'character': 'Bapa',
          'difficulty': 1,
          'instruction': 'Jejak perkataan "Bapa"',
          'emoji': '👨',
          'word': 'Father',
          'malay_word': 'Bapa',
          'pathPoints': [
            {'x': 0.2, 'y': 0.3},
            {'x': 0.2, 'y': 0.7},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.6, 'y': 0.5},
          ]
        },
      ];
    } else {
      // Age 6: 3 words with higher complexity
      instructions = 'Jejak perkataan mengikut titik dengan teliti.';
      difficulty = 'hard';
      items = [
        {
          'character': 'Ibu',
          'difficulty': 1,
          'instruction': 'Jejak perkataan "Ibu"',
          'emoji': '👩',
          'word': 'Mother',
          'malay_word': 'Ibu',
          'pathPoints': [
            {'x': 0.2, 'y': 0.3},
            {'x': 0.2, 'y': 0.7},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.8, 'y': 0.5},
          ]
        },
        {
          'character': 'Bapa',
          'difficulty': 1,
          'instruction': 'Jejak perkataan "Bapa"',
          'emoji': '👨',
          'word': 'Father',
          'malay_word': 'Bapa',
          'pathPoints': [
            {'x': 0.2, 'y': 0.3},
            {'x': 0.2, 'y': 0.7},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.8, 'y': 0.3},
            {'x': 0.8, 'y': 0.7},
          ]
        },
        {
          'character': 'Adik',
          'difficulty': 2,
          'instruction': 'Jejak perkataan "Adik"',
          'emoji': '👧',
          'word': 'Younger Sibling',
          'malay_word': 'Adik',
          'pathPoints': [
            {'x': 0.2, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
          ]
        },
      ];
    }
    
    return {
      'title': 'Bahasa Malaysia - Perkataan Mudah',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Bahasa Malaysia',
        'chapter': 'Perkataan Mudah',
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
      instructions = 'Padankan bentuk.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Bulatan', 'malay_shape': 'Bulatan', 'malay_color': 'Merah'},
        {'shape': 'square', 'color': 'blue', 'name': 'Segi Empat', 'malay_shape': 'Segi Empat', 'malay_color': 'Biru'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Segi Tiga', 'malay_shape': 'Segi Tiga', 'malay_color': 'Hijau'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Segi Empat Tepat', 'malay_shape': 'Segi Empat Tepat', 'malay_color': 'Kuning'},
        {'shape': 'star', 'color': 'purple', 'name': 'Bintang', 'malay_shape': 'Bintang', 'malay_color': 'Ungu'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 shapes with more detailed instructions
      instructions = 'Padankan bentuk dengan perkataan yang betul.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Bulatan Merah', 'malay_shape': 'Bulatan', 'malay_color': 'Merah'},
        {'shape': 'square', 'color': 'blue', 'name': 'Segi Empat Biru', 'malay_shape': 'Segi Empat', 'malay_color': 'Biru'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Segi Tiga Hijau', 'malay_shape': 'Segi Tiga', 'malay_color': 'Hijau'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Segi Empat Tepat Kuning', 'malay_shape': 'Segi Empat Tepat', 'malay_color': 'Kuning'},
        {'shape': 'star', 'color': 'purple', 'name': 'Bintang Ungu', 'malay_shape': 'Bintang', 'malay_color': 'Ungu'},
        {'shape': 'heart', 'color': 'pink', 'name': 'Hati Merah Jambu', 'malay_shape': 'Hati', 'malay_color': 'Merah Jambu'},
      ];
    } else {
      // Age 6: 8 shapes with complex instructions
      instructions = 'Padankan bentuk dan warna dengan perkataan yang betul.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Bulatan Merah', 'malay_shape': 'Bulatan', 'malay_color': 'Merah'},
        {'shape': 'square', 'color': 'blue', 'name': 'Segi Empat Biru', 'malay_shape': 'Segi Empat', 'malay_color': 'Biru'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Segi Tiga Hijau', 'malay_shape': 'Segi Tiga', 'malay_color': 'Hijau'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Segi Empat Tepat Kuning', 'malay_shape': 'Segi Empat Tepat', 'malay_color': 'Kuning'},
        {'shape': 'star', 'color': 'purple', 'name': 'Bintang Ungu', 'malay_shape': 'Bintang', 'malay_color': 'Ungu'},
        {'shape': 'heart', 'color': 'pink', 'name': 'Hati Merah Jambu', 'malay_shape': 'Hati', 'malay_color': 'Merah Jambu'},
        {'shape': 'oval', 'color': 'orange', 'name': 'Bujur Oren', 'malay_shape': 'Bujur', 'malay_color': 'Oren'},
        {'shape': 'diamond', 'color': 'teal', 'name': 'Berlian Hijau Kebiruan', 'malay_shape': 'Berlian', 'malay_color': 'Hijau Kebiruan'},
      ];
    }
    
    return {
      'title': 'Bahasa Malaysia - Perkataan Mudah',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Bahasa Malaysia',
        'chapter': 'Perkataan Mudah',
        'ageGroup': ageGroup,
        'difficulty': difficulty,
      }
    };
  }
  
  /// Get content for specific game type
  static Map<String, dynamic> getContent(String gameType, int ageGroup, int rounds) {
    switch (gameType) {
      case 'matching':
        return getMatchingContent(ageGroup);
      case 'sorting':
        return getSortingContent(ageGroup);
      case 'tracing':
        return getTracingContent(ageGroup);
      case 'shape_color':
        return getShapeColorContent(ageGroup, rounds);
      default:
        return getMatchingContent(ageGroup);
    }
  }
}
