import 'dart:math';

/// Template for Iqraa - Basic Reading chapter
/// This template includes Arabic script for basic reading with proper font specification
class IqraaBasicReadingTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: 4 simple words with basic instructions
      instructions = 'Match the word with its meaning.';
      difficulty = 'easy';
      pairs = [
        {'word': 'Kitab', 'emoji': 'كِتَاب', 'description': 'Book', 'malay_word': 'Buku', 'arabic_word': 'كِتَاب'},
        {'word': 'Qalam', 'emoji': 'قَلَم', 'description': 'Pen', 'malay_word': 'Pen', 'arabic_word': 'قَلَم'},
        {'word': 'Bayt', 'emoji': 'بَيْت', 'description': 'House', 'malay_word': 'Rumah', 'arabic_word': 'بَيْت'},
        {'word': 'Ma\'', 'emoji': 'مَاء', 'description': 'Water', 'malay_word': 'Air', 'arabic_word': 'مَاء'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 words with medium complexity
      instructions = 'Match the Arabic word with its pronunciation.';
      difficulty = 'medium';
      pairs = [
        {'word': 'Kitab', 'emoji': 'كِتَاب', 'description': 'Book', 'malay_word': 'Buku', 'arabic_word': 'كِتَاب'},
        {'word': 'Qalam', 'emoji': 'قَلَم', 'description': 'Pen', 'malay_word': 'Pen', 'arabic_word': 'قَلَم'},
        {'word': 'Bayt', 'emoji': 'بَيْت', 'description': 'House', 'malay_word': 'Rumah', 'arabic_word': 'بَيْت'},
        {'word': 'Masjid', 'emoji': 'مَسْجِد', 'description': 'Mosque', 'malay_word': 'Masjid', 'arabic_word': 'مَسْجِد'},
        {'word': 'Walad', 'emoji': 'وَلَد', 'description': 'Boy', 'malay_word': 'Budak Lelaki', 'arabic_word': 'وَلَد'},
        {'word': 'Ma\'', 'emoji': 'مَاء', 'description': 'Water', 'malay_word': 'Air', 'arabic_word': 'مَاء'},
      ];
    } else {
      // Age 6: 8 words with higher complexity
      instructions = 'Match the Arabic word with its pronunciation and meaning.';
      difficulty = 'hard';
      pairs = [
        {'word': 'Kitab', 'emoji': 'كِتَاب', 'description': 'Book', 'malay_word': 'Buku', 'arabic_word': 'كِتَاب'},
        {'word': 'Qalam', 'emoji': 'قَلَم', 'description': 'Pen', 'malay_word': 'Pen', 'arabic_word': 'قَلَم'},
        {'word': 'Bayt', 'emoji': 'بَيْت', 'description': 'House', 'malay_word': 'Rumah', 'arabic_word': 'بَيْت'},
        {'word': 'Masjid', 'emoji': 'مَسْجِد', 'description': 'Mosque', 'malay_word': 'Masjid', 'arabic_word': 'مَسْجِد'},
        {'word': 'Madrasah', 'emoji': 'مَدْرَسَة', 'description': 'School', 'malay_word': 'Sekolah', 'arabic_word': 'مَدْرَسَة'},
        {'word': 'Walad', 'emoji': 'وَلَد', 'description': 'Boy', 'malay_word': 'Budak Lelaki', 'arabic_word': 'وَلَد'},
        {'word': 'Bint', 'emoji': 'بِنْت', 'description': 'Girl', 'malay_word': 'Budak Perempuan', 'arabic_word': 'بِنْت'},
        {'word': 'Ma\'', 'emoji': 'مَاء', 'description': 'Water', 'malay_word': 'Air', 'arabic_word': 'مَاء'},
      ];
    }
    
    return {
      'title': 'Iqraa - Basic Reading',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Iqraa',
        'chapter': 'Basic Reading',
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
      instructions = 'Sort the words into two groups.';
      difficulty = 'easy';
      categories = [
        {'name': 'People', 'description': 'Words for people', 'emoji': 'وَلَد', 'color': 'blue'},
        {'name': 'Objects', 'description': 'Words for things', 'emoji': 'كِتَاب', 'color': 'red'},
      ];
      items = [
        {'name': 'Walad', 'category': 'People', 'emoji': 'وَلَد', 'word': 'Walad', 'malay_word': 'Budak Lelaki', 'arabic_word': 'وَلَد'},
        {'name': 'Bint', 'category': 'People', 'emoji': 'بِنْت', 'word': 'Bint', 'malay_word': 'Budak Perempuan', 'arabic_word': 'بِنْت'},
        {'name': 'Kitab', 'category': 'Objects', 'emoji': 'كِتَاب', 'word': 'Kitab', 'malay_word': 'Buku', 'arabic_word': 'كِتَاب'},
        {'name': 'Qalam', 'category': 'Objects', 'emoji': 'قَلَم', 'word': 'Qalam', 'malay_word': 'Pen', 'arabic_word': 'قَلَم'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 2 categories with 6 items
      instructions = 'Sort the Arabic words by their categories.';
      difficulty = 'medium';
      categories = [
        {'name': 'People', 'description': 'Words related to people', 'emoji': 'وَلَد', 'color': 'blue'},
        {'name': 'Places', 'description': 'Words related to places', 'emoji': 'مَسْجِد', 'color': 'green'},
      ];
      items = [
        {'name': 'Walad', 'category': 'People', 'emoji': 'وَلَد', 'word': 'Walad', 'malay_word': 'Budak Lelaki', 'arabic_word': 'وَلَد'},
        {'name': 'Bint', 'category': 'People', 'emoji': 'بِنْت', 'word': 'Bint', 'malay_word': 'Budak Perempuan', 'arabic_word': 'بِنْت'},
        {'name': 'Mu\'allim', 'category': 'People', 'emoji': 'مُعَلِّم', 'word': 'Mu\'allim', 'malay_word': 'Guru', 'arabic_word': 'مُعَلِّم'},
        {'name': 'Bayt', 'category': 'Places', 'emoji': 'بَيْت', 'word': 'Bayt', 'malay_word': 'Rumah', 'arabic_word': 'بَيْت'},
        {'name': 'Masjid', 'category': 'Places', 'emoji': 'مَسْجِد', 'word': 'Masjid', 'malay_word': 'Masjid', 'arabic_word': 'مَسْجِد'},
        {'name': 'Madrasah', 'category': 'Places', 'emoji': 'مَدْرَسَة', 'word': 'Madrasah', 'malay_word': 'Sekolah', 'arabic_word': 'مَدْرَسَة'},
      ];
    } else {
      // Age 6: 3 categories with 9 items
      instructions = 'Sort the Arabic words by their categories: people, places, or objects.';
      difficulty = 'hard';
      categories = [
        {'name': 'People', 'description': 'Words related to people', 'emoji': 'وَلَد', 'color': 'blue'},
        {'name': 'Places', 'description': 'Words related to places', 'emoji': 'مَسْجِد', 'color': 'green'},
        {'name': 'Objects', 'description': 'Words related to objects', 'emoji': 'كِتَاب', 'color': 'red'},
      ];
      items = [
        {'name': 'Walad', 'category': 'People', 'emoji': 'وَلَد', 'word': 'Walad', 'malay_word': 'Budak Lelaki', 'arabic_word': 'وَلَد'},
        {'name': 'Bint', 'category': 'People', 'emoji': 'بِنْت', 'word': 'Bint', 'malay_word': 'Budak Perempuan', 'arabic_word': 'بِنْت'},
        {'name': 'Mu\'allim', 'category': 'People', 'emoji': 'مُعَلِّم', 'word': 'Mu\'allim', 'malay_word': 'Guru', 'arabic_word': 'مُعَلِّم'},
        {'name': 'Bayt', 'category': 'Places', 'emoji': 'بَيْت', 'word': 'Bayt', 'malay_word': 'Rumah', 'arabic_word': 'بَيْت'},
        {'name': 'Masjid', 'category': 'Places', 'emoji': 'مَسْجِد', 'word': 'Masjid', 'malay_word': 'Masjid', 'arabic_word': 'مَسْجِد'},
        {'name': 'Madrasah', 'category': 'Places', 'emoji': 'مَدْرَسَة', 'word': 'Madrasah', 'malay_word': 'Sekolah', 'arabic_word': 'مَدْرَسَة'},
        {'name': 'Kitab', 'category': 'Objects', 'emoji': 'كِتَاب', 'word': 'Kitab', 'malay_word': 'Buku', 'arabic_word': 'كِتَاب'},
        {'name': 'Qalam', 'category': 'Objects', 'emoji': 'قَلَم', 'word': 'Qalam', 'malay_word': 'Pen', 'arabic_word': 'قَلَم'},
        {'name': 'Ma\'', 'category': 'Objects', 'emoji': 'مَاء', 'word': 'Ma\'', 'malay_word': 'Air', 'arabic_word': 'مَاء'},
      ];
    }
    
    return {
      'title': 'Iqraa - Basic Reading',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Iqraa',
        'chapter': 'Basic Reading',
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
      instructions = 'Trace these simple Arabic words.';
      difficulty = 'easy';
      items = [
        {
          'character': 'كِتَاب',
          'difficulty': 1,
          'instruction': 'Trace the word Kitab (Book)',
          'emoji': '📕',
          'word': 'Kitab',
          'malay_word': 'Buku',
          'arabic_word': 'كِتَاب',
          'pathPoints': [
            {'x': 0.8, 'y': 0.3},
            {'x': 0.8, 'y': 0.7},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.7},
          ]
        },
        {
          'character': 'قَلَم',
          'difficulty': 1,
          'instruction': 'Trace the word Qalam (Pen)',
          'emoji': '✏️',
          'word': 'Qalam',
          'malay_word': 'Pen',
          'arabic_word': 'قَلَم',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 3 medium complexity words
      instructions = 'Trace these Arabic words carefully.';
      difficulty = 'medium';
      items = [
        {
          'character': 'كِتَاب',
          'difficulty': 2,
          'instruction': 'Trace the word Kitab (Book)',
          'emoji': '📕',
          'word': 'Kitab',
          'malay_word': 'Buku',
          'arabic_word': 'كِتَاب',
          'pathPoints': [
            {'x': 0.8, 'y': 0.3},
            {'x': 0.8, 'y': 0.7},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.2, 'y': 0.5},
          ]
        },
        {
          'character': 'بَيْت',
          'difficulty': 2,
          'instruction': 'Trace the word Bayt (House)',
          'emoji': '🏠',
          'word': 'Bayt',
          'malay_word': 'Rumah',
          'arabic_word': 'بَيْت',
          'pathPoints': [
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
          ]
        },
        {
          'character': 'مَاء',
          'difficulty': 2,
          'instruction': 'Trace the word Ma\' (Water)',
          'emoji': '💧',
          'word': 'Ma\'',
          'malay_word': 'Air',
          'arabic_word': 'مَاء',
          'pathPoints': [
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
          ]
        },
      ];
    } else {
      // Age 6: 5 complex words
      instructions = 'Trace these Arabic words following the correct stroke order.';
      difficulty = 'hard';
      items = [
        {
          'character': 'كِتَاب',
          'difficulty': 3,
          'instruction': 'Trace the word Kitab (Book)',
          'emoji': '📕',
          'word': 'Kitab',
          'malay_word': 'Buku',
          'arabic_word': 'كِتَاب',
          'pathPoints': [
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
        {
          'character': 'قَلَم',
          'difficulty': 3,
          'instruction': 'Trace the word Qalam (Pen)',
          'emoji': '✏️',
          'word': 'Qalam',
          'malay_word': 'Pen',
          'arabic_word': 'قَلَم',
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
          'character': 'بَيْت',
          'difficulty': 3,
          'instruction': 'Trace the word Bayt (House)',
          'emoji': '🏠',
          'word': 'Bayt',
          'malay_word': 'Rumah',
          'arabic_word': 'بَيْت',
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
          'character': 'مَسْجِد',
          'difficulty': 3,
          'instruction': 'Trace the word Masjid (Mosque)',
          'emoji': '🕌',
          'word': 'Masjid',
          'malay_word': 'Masjid',
          'arabic_word': 'مَسْجِد',
          'pathPoints': [
            {'x': 0.9, 'y': 0.5},
            {'x': 0.9, 'y': 0.3},
            {'x': 0.9, 'y': 0.7},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.1, 'y': 0.5},
            {'x': 0.1, 'y': 0.3},
            {'x': 0.1, 'y': 0.7},
          ]
        },
        {
          'character': 'مَاء',
          'difficulty': 3,
          'instruction': 'Trace the word Ma\' (Water)',
          'emoji': '💧',
          'word': 'Ma\'',
          'malay_word': 'Air',
          'arabic_word': 'مَاء',
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
      ];
    }
    
    return {
      'title': 'Iqraa - Basic Reading',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Iqraa',
        'chapter': 'Basic Reading',
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
      instructions = 'Match the word with its picture.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'kitab', 'color': 'red', 'name': 'Book', 'malay_shape': 'Buku', 'malay_color': 'Merah', 'arabic_shape': 'كِتَاب', 'word': 'Kitab', 'malay_word': 'Buku'},
        {'shape': 'qalam', 'color': 'blue', 'name': 'Pen', 'malay_shape': 'Pen', 'malay_color': 'Biru', 'arabic_shape': 'قَلَم', 'word': 'Qalam', 'malay_word': 'Pen'},
        {'shape': 'bayt', 'color': 'green', 'name': 'House', 'malay_shape': 'Rumah', 'malay_color': 'Hijau', 'arabic_shape': 'بَيْت', 'word': 'Bayt', 'malay_word': 'Rumah'},
        {'shape': 'ma', 'color': 'cyan', 'name': 'Water', 'malay_shape': 'Air', 'malay_color': 'Biru Kehijauan', 'arabic_shape': 'مَاء', 'word': 'Ma\'', 'malay_word': 'Air'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 shapes with medium complexity
      instructions = 'Match the Arabic word with its meaning and color.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'kitab', 'color': 'red', 'name': 'Book', 'malay_shape': 'Buku', 'malay_color': 'Merah', 'arabic_shape': 'كِتَاب', 'word': 'Kitab', 'malay_word': 'Buku'},
        {'shape': 'qalam', 'color': 'blue', 'name': 'Pen', 'malay_shape': 'Pen', 'malay_color': 'Biru', 'arabic_shape': 'قَلَم', 'word': 'Qalam', 'malay_word': 'Pen'},
        {'shape': 'bayt', 'color': 'green', 'name': 'House', 'malay_shape': 'Rumah', 'malay_color': 'Hijau', 'arabic_shape': 'بَيْت', 'word': 'Bayt', 'malay_word': 'Rumah'},
        {'shape': 'masjid', 'color': 'yellow', 'name': 'Mosque', 'malay_shape': 'Masjid', 'malay_color': 'Kuning', 'arabic_shape': 'مَسْجِد', 'word': 'Masjid', 'malay_word': 'Masjid'},
        {'shape': 'walad', 'color': 'orange', 'name': 'Boy', 'malay_shape': 'Budak Lelaki', 'malay_color': 'Oren', 'arabic_shape': 'وَلَد', 'word': 'Walad', 'malay_word': 'Budak Lelaki'},
        {'shape': 'ma', 'color': 'cyan', 'name': 'Water', 'malay_shape': 'Air', 'malay_color': 'Biru Kehijauan', 'arabic_shape': 'مَاء', 'word': 'Ma\'', 'malay_word': 'Air'},
      ];
    } else {
      // Age 6: 8 shapes with higher complexity
      instructions = 'Match the Arabic word with its meaning, color, and pronunciation.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'kitab', 'color': 'red', 'name': 'Book', 'malay_shape': 'Buku', 'malay_color': 'Merah', 'arabic_shape': 'كِتَاب', 'word': 'Kitab', 'malay_word': 'Buku'},
        {'shape': 'qalam', 'color': 'blue', 'name': 'Pen', 'malay_shape': 'Pen', 'malay_color': 'Biru', 'arabic_shape': 'قَلَم', 'word': 'Qalam', 'malay_word': 'Pen'},
        {'shape': 'bayt', 'color': 'green', 'name': 'House', 'malay_shape': 'Rumah', 'malay_color': 'Hijau', 'arabic_shape': 'بَيْت', 'word': 'Bayt', 'malay_word': 'Rumah'},
        {'shape': 'masjid', 'color': 'yellow', 'name': 'Mosque', 'malay_shape': 'Masjid', 'malay_color': 'Kuning', 'arabic_shape': 'مَسْجِد', 'word': 'Masjid', 'malay_word': 'Masjid'},
        {'shape': 'madrasah', 'color': 'purple', 'name': 'School', 'malay_shape': 'Sekolah', 'malay_color': 'Ungu', 'arabic_shape': 'مَدْرَسَة', 'word': 'Madrasah', 'malay_word': 'Sekolah'},
        {'shape': 'walad', 'color': 'orange', 'name': 'Boy', 'malay_shape': 'Budak Lelaki', 'malay_color': 'Oren', 'arabic_shape': 'وَلَد', 'word': 'Walad', 'malay_word': 'Budak Lelaki'},
        {'shape': 'bint', 'color': 'pink', 'name': 'Girl', 'malay_shape': 'Budak Perempuan', 'malay_color': 'Merah Jambu', 'arabic_shape': 'بِنْت', 'word': 'Bint', 'malay_word': 'Budak Perempuan'},
        {'shape': 'ma', 'color': 'cyan', 'name': 'Water', 'malay_shape': 'Air', 'malay_color': 'Biru Kehijauan', 'arabic_shape': 'مَاء', 'word': 'Ma\'', 'malay_word': 'Air'},
      ];
    }
    
    return {
      'title': 'Iqraa - Basic Reading',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Iqraa',
        'chapter': 'Basic Reading',
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
