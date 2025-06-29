import 'dart:math';

/// Template for Social & Emotional Learning - Emotions & Expressions chapter
class EmotionsExpressionsTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: Simple with 4 basic emotions
      instructions = 'Match the emotion with its face.';
      difficulty = 'easy';
      pairs = [
        {'word': 'Happy', 'emoji': '😊', 'description': 'Feeling good', 'malay_word': 'Gembira'},
        {'word': 'Sad', 'emoji': '😢', 'description': 'Feeling unhappy', 'malay_word': 'Sedih'},
        {'word': 'Angry', 'emoji': '😠', 'description': 'Feeling mad', 'malay_word': 'Marah'},
        {'word': 'Scared', 'emoji': '😨', 'description': 'Feeling afraid', 'malay_word': 'Takut'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 6 emotions and bilingual labels
      instructions = 'Match the emotion with its expression. Learn the names in English and Malay.';
      difficulty = 'medium';
      pairs = [
        {'word': 'Happy', 'emoji': '😊', 'description': 'Feeling joy or pleasure', 'malay_word': 'Gembira'},
        {'word': 'Sad', 'emoji': '😢', 'description': 'Feeling unhappy', 'malay_word': 'Sedih'},
        {'word': 'Angry', 'emoji': '😠', 'description': 'Feeling upset', 'malay_word': 'Marah'},
        {'word': 'Scared', 'emoji': '😨', 'description': 'Feeling afraid', 'malay_word': 'Takut'},
        {'word': 'Surprised', 'emoji': '😲', 'description': 'Feeling startled', 'malay_word': 'Terkejut'},
        {'word': 'Excited', 'emoji': '🤩', 'description': 'Feeling very happy', 'malay_word': 'Teruja'},
      ];
    } else {
      // Age 6: Complex with all 8 emotions and comprehensive bilingual descriptions
      instructions = 'Match the emotion with its expression. Learn about different feelings in English and Malay.';
      difficulty = 'hard';
      pairs = [
        {'word': 'Happy', 'emoji': '😊', 'description': 'Feeling joy or pleasure', 'malay_word': 'Gembira'},
        {'word': 'Sad', 'emoji': '😢', 'description': 'Feeling unhappy or sorrowful', 'malay_word': 'Sedih'},
        {'word': 'Angry', 'emoji': '😠', 'description': 'Feeling strong displeasure', 'malay_word': 'Marah'},
        {'word': 'Scared', 'emoji': '😨', 'description': 'Feeling afraid or frightened', 'malay_word': 'Takut'},
        {'word': 'Surprised', 'emoji': '😲', 'description': 'Feeling astonished or startled', 'malay_word': 'Terkejut'},
        {'word': 'Excited', 'emoji': '🤩', 'description': 'Feeling very enthusiastic and eager', 'malay_word': 'Teruja'},
        {'word': 'Tired', 'emoji': '😴', 'description': 'Feeling in need of rest or sleep', 'malay_word': 'Letih'},
        {'word': 'Confused', 'emoji': '😕', 'description': 'Feeling puzzled or uncertain', 'malay_word': 'Keliru'},
      ];
    }
    
    return {
      'title': 'Social & Emotional Learning - Emotions & Expressions',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Social & Emotional Learning',
        'chapter': 'Emotions & Expressions',
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
      // Age 4: Simple with 2 categories and 4 basic emotions
      instructions = 'Sort the feelings into happy or sad.';
      difficulty = 'easy';
      categories = [
        {'name': 'Happy Feelings', 'description': 'Feelings that make us smile', 'emoji': '😊', 'color': 'green'},
        {'name': 'Sad Feelings', 'description': 'Feelings that don\'t make us smile', 'emoji': '😢', 'color': 'blue'},
      ];
      items = [
        {'name': 'Happy', 'category': 'Happy Feelings', 'emoji': '😊', 'word': 'Happy', 'malay_word': 'Gembira'},
        {'name': 'Excited', 'category': 'Happy Feelings', 'emoji': '🤩', 'word': 'Excited', 'malay_word': 'Teruja'},
        {'name': 'Sad', 'category': 'Sad Feelings', 'emoji': '😢', 'word': 'Sad', 'malay_word': 'Sedih'},
        {'name': 'Angry', 'category': 'Sad Feelings', 'emoji': '😠', 'word': 'Angry', 'malay_word': 'Marah'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 2 categories and 6 emotions
      instructions = 'Sort the emotions into pleasant or challenging. Learn their names in English and Malay.';
      difficulty = 'medium';
      categories = [
        {'name': 'Pleasant Emotions', 'description': 'Emotions that make us feel good', 'emoji': '😊', 'color': 'green'},
        {'name': 'Challenging Emotions', 'description': 'Emotions that can be difficult', 'emoji': '😢', 'color': 'blue'},
      ];
      items = [
        {'name': 'Happy', 'category': 'Pleasant Emotions', 'emoji': '😊', 'word': 'Happy', 'malay_word': 'Gembira'},
        {'name': 'Excited', 'category': 'Pleasant Emotions', 'emoji': '🤩', 'word': 'Excited', 'malay_word': 'Teruja'},
        {'name': 'Calm', 'category': 'Pleasant Emotions', 'emoji': '😌', 'word': 'Calm', 'malay_word': 'Tenang'},
        {'name': 'Sad', 'category': 'Challenging Emotions', 'emoji': '😢', 'word': 'Sad', 'malay_word': 'Sedih'},
        {'name': 'Angry', 'category': 'Challenging Emotions', 'emoji': '😠', 'word': 'Angry', 'malay_word': 'Marah'},
        {'name': 'Scared', 'category': 'Challenging Emotions', 'emoji': '😨', 'word': 'Scared', 'malay_word': 'Takut'},
      ];
    } else {
      // Age 6: Complex with all 10 emotions and comprehensive bilingual descriptions
      instructions = 'Sort the emotions into their categories. Understand how different emotions affect us in English and Malay.';
      difficulty = 'hard';
      categories = [
        {'name': 'Pleasant Emotions', 'description': 'Emotions that make us feel good', 'emoji': '😊', 'color': 'green'},
        {'name': 'Challenging Emotions', 'description': 'Emotions that can be difficult', 'emoji': '😢', 'color': 'blue'},
      ];
      items = [
        {'name': 'Happy', 'category': 'Pleasant Emotions', 'emoji': '😊', 'word': 'Happy', 'malay_word': 'Gembira'},
        {'name': 'Excited', 'category': 'Pleasant Emotions', 'emoji': '🤩', 'word': 'Excited', 'malay_word': 'Teruja'},
        {'name': 'Calm', 'category': 'Pleasant Emotions', 'emoji': '😌', 'word': 'Calm', 'malay_word': 'Tenang'},
        {'name': 'Proud', 'category': 'Pleasant Emotions', 'emoji': '😎', 'word': 'Proud', 'malay_word': 'Bangga'},
        {'name': 'Loved', 'category': 'Pleasant Emotions', 'emoji': '🥰', 'word': 'Loved', 'malay_word': 'Disayangi'},
        {'name': 'Sad', 'category': 'Challenging Emotions', 'emoji': '😢', 'word': 'Sad', 'malay_word': 'Sedih'},
        {'name': 'Angry', 'category': 'Challenging Emotions', 'emoji': '😠', 'word': 'Angry', 'malay_word': 'Marah'},
        {'name': 'Scared', 'category': 'Challenging Emotions', 'emoji': '😨', 'word': 'Scared', 'malay_word': 'Takut'},
        {'name': 'Confused', 'category': 'Challenging Emotions', 'emoji': '😕', 'word': 'Confused', 'malay_word': 'Keliru'},
        {'name': 'Tired', 'category': 'Challenging Emotions', 'emoji': '😴', 'word': 'Tired', 'malay_word': 'Letih'},
      ];
    }
    
    return {
      'title': 'Social & Emotional Learning - Emotions & Expressions',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Social & Emotional Learning',
        'chapter': 'Emotions & Expressions',
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
      // Age 4: Simple with 2 basic emotion letters
      instructions = 'Trace the letters to learn about feelings.';
      difficulty = 'easy';
      items = [
        {
          'character': 'H',
          'difficulty': 1,
          'instruction': 'Trace the letter H for Happy',
          'emoji': '😊',
          'word': 'Happy',
          'malay_word': 'Gembira',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'S',
          'difficulty': 1,
          'instruction': 'Trace the letter S for Sad',
          'emoji': '😢',
          'word': 'Sad',
          'malay_word': 'Sedih',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.4},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.6, 'y': 0.8},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.4, 'y': 0.7},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 3 emotion letters and bilingual instructions
      instructions = 'Trace the letters to learn about emotions. Learn their names in English and Malay.';
      difficulty = 'medium';
      items = [
        {
          'character': 'H',
          'difficulty': 1,
          'instruction': 'Trace the letter H for Happy - Gembira',
          'emoji': '😊',
          'word': 'Happy',
          'malay_word': 'Gembira',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'S',
          'difficulty': 1,
          'instruction': 'Trace the letter S for Sad - Sedih',
          'emoji': '😢',
          'word': 'Sad',
          'malay_word': 'Sedih',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.4},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.6, 'y': 0.8},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.4, 'y': 0.7},
          ]
        },
        {
          'character': 'A',
          'difficulty': 1,
          'instruction': 'Trace the letter A for Angry - Marah',
          'emoji': '😠',
          'word': 'Angry',
          'malay_word': 'Marah',
          'pathPoints': [
            {'x': 0.5, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.7, 'y': 0.8},
            {'x': 0.4, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
          ]
        },
      ];
    } else {
      // Age 6: Complex with all 5 emotion letters and comprehensive bilingual instructions
      instructions = 'Trace the letters to learn about emotions and their expressions. Understand how emotions feel in English and Malay.';
      difficulty = 'hard';
      items = [
        {
          'character': 'H',
          'difficulty': 1,
          'instruction': 'Trace the letter H for Happy (Gembira) - when we feel good inside',
          'emoji': '😊',
          'word': 'Happy',
          'malay_word': 'Gembira',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.7, 'y': 0.8},
          ]
        },
        {
          'character': 'S',
          'difficulty': 1,
          'instruction': 'Trace the letter S for Sad (Sedih) - when we feel unhappy',
          'emoji': '😢',
          'word': 'Sad',
          'malay_word': 'Sedih',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.4, 'y': 0.4},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.6, 'y': 0.8},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.4, 'y': 0.7},
          ]
        },
        {
          'character': 'A',
          'difficulty': 1,
          'instruction': 'Trace the letter A for Angry (Marah) - when we feel upset about something',
          'emoji': '😠',
          'word': 'Angry',
          'malay_word': 'Marah',
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
          'character': 'E',
          'difficulty': 1,
          'instruction': 'Trace the letter E for Excited (Teruja) - when we feel very happy about something',
          'emoji': '🤩',
          'word': 'Excited',
          'malay_word': 'Teruja',
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
          'character': 'C',
          'difficulty': 1,
          'instruction': 'Trace the letter C for Calm (Tenang) - when we feel peaceful and relaxed',
          'emoji': '😌',
          'word': 'Calm',
          'malay_word': 'Tenang',
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
      'title': 'Social & Emotional Learning - Emotions & Expressions',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Social & Emotional Learning',
        'chapter': 'Emotions & Expressions',
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
      // Age 4: Simple with 4 basic emotions
      instructions = 'Match the feeling with its face.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'happy', 'color': 'yellow', 'name': 'Happy', 'malay_shape': 'Gembira', 'malay_color': 'Kuning', 'word': 'Happy', 'malay_word': 'Gembira'},
        {'shape': 'sad', 'color': 'blue', 'name': 'Sad', 'malay_shape': 'Sedih', 'malay_color': 'Biru', 'word': 'Sad', 'malay_word': 'Sedih'},
        {'shape': 'angry', 'color': 'red', 'name': 'Angry', 'malay_shape': 'Marah', 'malay_color': 'Merah', 'word': 'Angry', 'malay_word': 'Marah'},
        {'shape': 'scared', 'color': 'purple', 'name': 'Scared', 'malay_shape': 'Takut', 'malay_color': 'Ungu', 'word': 'Scared', 'malay_word': 'Takut'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 6 emotions and bilingual labels
      instructions = 'Match the emotion with the correct expression. Learn their names in English and Malay.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'happy', 'color': 'yellow', 'name': 'Happy', 'malay_shape': 'Gembira', 'malay_color': 'Kuning', 'word': 'Happy', 'malay_word': 'Gembira'},
        {'shape': 'sad', 'color': 'blue', 'name': 'Sad', 'malay_shape': 'Sedih', 'malay_color': 'Biru', 'word': 'Sad', 'malay_word': 'Sedih'},
        {'shape': 'angry', 'color': 'red', 'name': 'Angry', 'malay_shape': 'Marah', 'malay_color': 'Merah', 'word': 'Angry', 'malay_word': 'Marah'},
        {'shape': 'scared', 'color': 'purple', 'name': 'Scared', 'malay_shape': 'Takut', 'malay_color': 'Ungu', 'word': 'Scared', 'malay_word': 'Takut'},
        {'shape': 'surprised', 'color': 'orange', 'name': 'Surprised', 'malay_shape': 'Terkejut', 'malay_color': 'Oren', 'word': 'Surprised', 'malay_word': 'Terkejut'},
        {'shape': 'excited', 'color': 'pink', 'name': 'Excited', 'malay_shape': 'Teruja', 'malay_color': 'Merah Jambu', 'word': 'Excited', 'malay_word': 'Teruja'},
      ];
    } else {
      // Age 6: Complex with all 8 emotions and comprehensive bilingual descriptions
      instructions = 'Match the emotion with the correct expression. Learn to identify different emotions in English and Malay.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'happy', 'color': 'yellow', 'name': 'Happy - Feeling joy', 'malay_shape': 'Gembira - Rasa kegembiraan', 'malay_color': 'Kuning', 'word': 'Happy', 'malay_word': 'Gembira'},
        {'shape': 'sad', 'color': 'blue', 'name': 'Sad - Feeling unhappy', 'malay_shape': 'Sedih - Rasa kesedihan', 'malay_color': 'Biru', 'word': 'Sad', 'malay_word': 'Sedih'},
        {'shape': 'angry', 'color': 'red', 'name': 'Angry - Feeling upset', 'malay_shape': 'Marah - Rasa kemarahan', 'malay_color': 'Merah', 'word': 'Angry', 'malay_word': 'Marah'},
        {'shape': 'scared', 'color': 'purple', 'name': 'Scared - Feeling afraid', 'malay_shape': 'Takut - Rasa ketakutan', 'malay_color': 'Ungu', 'word': 'Scared', 'malay_word': 'Takut'},
        {'shape': 'surprised', 'color': 'orange', 'name': 'Surprised - Feeling startled', 'malay_shape': 'Terkejut - Rasa kejutan', 'malay_color': 'Oren', 'word': 'Surprised', 'malay_word': 'Terkejut'},
        {'shape': 'excited', 'color': 'pink', 'name': 'Excited - Feeling enthusiastic', 'malay_shape': 'Teruja - Rasa keterujaan', 'malay_color': 'Merah Jambu', 'word': 'Excited', 'malay_word': 'Teruja'},
        {'shape': 'calm', 'color': 'green', 'name': 'Calm - Feeling peaceful', 'malay_shape': 'Tenang - Rasa ketenangan', 'malay_color': 'Hijau', 'word': 'Calm', 'malay_word': 'Tenang'},
        {'shape': 'confused', 'color': 'brown', 'name': 'Confused - Feeling puzzled', 'malay_shape': 'Keliru - Rasa kekeliruan', 'malay_color': 'Coklat', 'word': 'Confused', 'malay_word': 'Keliru'},
      ];
    }
    
    return {
      'title': 'Social & Emotional Learning - Emotions & Expressions',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Social & Emotional Learning',
        'chapter': 'Emotions & Expressions',
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
