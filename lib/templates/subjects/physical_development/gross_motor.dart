import 'dart:math';

/// Template for Physical Development - Gross Motor Skills chapter
class GrossMotorTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: Simple matching with 4 basic gross motor skills
      instructions = 'Match the action with its picture.';
      difficulty = 'easy';
      pairs = [
        {'word': 'Running', 'emoji': '🏃', 'description': 'Moving quickly', 'malay_word': 'Berlari'},
        {'word': 'Jumping', 'emoji': '🦘', 'description': 'Going up and down', 'malay_word': 'Melompat'},
        {'word': 'Dancing', 'emoji': '💃', 'description': 'Moving to music', 'malay_word': 'Menari'},
        {'word': 'Swimming', 'emoji': '🏊', 'description': 'Moving in water', 'malay_word': 'Berenang'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 6 gross motor skills
      instructions = 'Match the action with its picture and description.';
      difficulty = 'medium';
      pairs = [
        {'word': 'Running', 'emoji': '🏃', 'description': 'Moving quickly on foot', 'malay_word': 'Berlari'},
        {'word': 'Jumping', 'emoji': '🦘', 'description': 'Pushing off the ground with legs', 'malay_word': 'Melompat'},
        {'word': 'Climbing', 'emoji': '🧗', 'description': 'Moving up using hands and feet', 'malay_word': 'Memanjat'},
        {'word': 'Dancing', 'emoji': '💃', 'description': 'Moving rhythmically to music', 'malay_word': 'Menari'},
        {'word': 'Swimming', 'emoji': '🏊', 'description': 'Moving through water', 'malay_word': 'Berenang'},
        {'word': 'Throwing', 'emoji': '🤾', 'description': 'Propelling an object through the air', 'malay_word': 'Membaling'},
      ];
    } else {
      // Age 6: Complex matching with all 8 gross motor skills
      instructions = 'Match the action with its picture, description, and Malay translation.';
      difficulty = 'hard';
      pairs = [
        {'word': 'Running', 'emoji': '🏃', 'description': 'Moving quickly on foot', 'malay_word': 'Berlari'},
        {'word': 'Jumping', 'emoji': '🦘', 'description': 'Pushing off the ground with legs', 'malay_word': 'Melompat'},
        {'word': 'Climbing', 'emoji': '🧗', 'description': 'Moving up using hands and feet', 'malay_word': 'Memanjat'},
        {'word': 'Dancing', 'emoji': '💃', 'description': 'Moving rhythmically to music', 'malay_word': 'Menari'},
        {'word': 'Swimming', 'emoji': '🏊', 'description': 'Moving through water using arms and legs', 'malay_word': 'Berenang'},
        {'word': 'Throwing', 'emoji': '🤾', 'description': 'Propelling an object through the air', 'malay_word': 'Membaling'},
        {'word': 'Kicking', 'emoji': '⚽', 'description': 'Striking with the foot', 'malay_word': 'Menendang'},
        {'word': 'Balancing', 'emoji': '🤸', 'description': 'Maintaining stability while standing or moving', 'malay_word': 'Mengimbangi'},
      ];
    }
    
    return {
      'title': 'Physical Development - Gross Motor Skills',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Physical Development',
        'chapter': 'Gross Motor Skills',
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
      // Age 4: Simple sorting with 2 categories and 4 items
      instructions = 'Sort these activities into leg and arm groups.';
      difficulty = 'easy';
      categories = [
        {'name': 'Leg Activities', 'description': 'Activities that use legs', 'emoji': '👟', 'color': 'blue'},
        {'name': 'Arm Activities', 'description': 'Activities that use arms', 'emoji': '💪', 'color': 'red'},
      ];
      items = [
        {'name': 'Running', 'category': 'Leg Activities', 'emoji': '🏃', 'word': 'Running', 'malay_word': 'Berlari'},
        {'name': 'Jumping', 'category': 'Leg Activities', 'emoji': '💨', 'word': 'Jumping', 'malay_word': 'Melompat'},
        {'name': 'Throwing', 'category': 'Arm Activities', 'emoji': '🏀', 'word': 'Throwing', 'malay_word': 'Melontar'},
        {'name': 'Catching', 'category': 'Arm Activities', 'emoji': '🥅', 'word': 'Catching', 'malay_word': 'Menangkap'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 2 categories and 6 items
      instructions = 'Sort the activities by the body parts they mainly use.';
      difficulty = 'medium';
      categories = [
        {'name': 'Leg Activities', 'description': 'Activities that mainly use legs', 'emoji': '👟', 'color': 'blue'},
        {'name': 'Arm Activities', 'description': 'Activities that mainly use arms', 'emoji': '💪', 'color': 'red'},
      ];
      items = [
        {'name': 'Running', 'category': 'Leg Activities', 'emoji': '🏃', 'word': 'Running', 'malay_word': 'Berlari'},
        {'name': 'Jumping', 'category': 'Leg Activities', 'emoji': '💨', 'word': 'Jumping', 'malay_word': 'Melompat'},
        {'name': 'Kicking', 'category': 'Leg Activities', 'emoji': '⚽', 'word': 'Kicking', 'malay_word': 'Menendang'},
        {'name': 'Throwing', 'category': 'Arm Activities', 'emoji': '🏀', 'word': 'Throwing', 'malay_word': 'Melontar'},
        {'name': 'Catching', 'category': 'Arm Activities', 'emoji': '🥅', 'word': 'Catching', 'malay_word': 'Menangkap'},
        {'name': 'Pushing', 'category': 'Arm Activities', 'emoji': '👊', 'word': 'Pushing', 'malay_word': 'Menolak'},
      ];
    } else {
      // Age 6: Complex sorting with 3 categories and all 9 items
      instructions = 'Sort the activities by the body parts they mainly use and explain why in Malay and English.';
      difficulty = 'hard';
      categories = [
        {'name': 'Leg Activities', 'description': 'Activities that mainly use legs', 'emoji': '👟', 'color': 'blue'},
        {'name': 'Arm Activities', 'description': 'Activities that mainly use arms', 'emoji': '💪', 'color': 'red'},
        {'name': 'Whole Body Activities', 'description': 'Activities that use the whole body', 'emoji': '🤸', 'color': 'green'},
      ];
      items = [
        {'name': 'Running', 'category': 'Leg Activities', 'emoji': '🏃', 'word': 'Running', 'malay_word': 'Berlari'},
        {'name': 'Jumping', 'category': 'Leg Activities', 'emoji': '💨', 'word': 'Jumping', 'malay_word': 'Melompat'},
        {'name': 'Kicking', 'category': 'Leg Activities', 'emoji': '⚽', 'word': 'Kicking', 'malay_word': 'Menendang'},
        {'name': 'Throwing', 'category': 'Arm Activities', 'emoji': '🏀', 'word': 'Throwing', 'malay_word': 'Melontar'},
        {'name': 'Catching', 'category': 'Arm Activities', 'emoji': '🥅', 'word': 'Catching', 'malay_word': 'Menangkap'},
        {'name': 'Pushing', 'category': 'Arm Activities', 'emoji': '👊', 'word': 'Pushing', 'malay_word': 'Menolak'},
        {'name': 'Dancing', 'category': 'Whole Body Activities', 'emoji': '💃', 'word': 'Dancing', 'malay_word': 'Menari'},
        {'name': 'Swimming', 'category': 'Whole Body Activities', 'emoji': '🏊', 'word': 'Swimming', 'malay_word': 'Berenang'},
        {'name': 'Climbing', 'category': 'Whole Body Activities', 'emoji': '🧗', 'word': 'Climbing', 'malay_word': 'Memanjat'},
      ];
    }
    
    return {
      'title': 'Physical Development - Gross Motor Skills',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Physical Development',
        'chapter': 'Gross Motor Skills',
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
      instructions = 'Trace these simple letters to learn about movement.';
      difficulty = 'easy';
      items = [
        {
          'character': 'R',
          'difficulty': 1,
          'instruction': 'Trace the letter R for Run',
          'emoji': '🏃',
          'word': 'Run',
          'malay_word': 'Lari',
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
      // Age 5: Medium complexity with 3 letters
      instructions = 'Trace these letters to learn about movement. Follow the arrows.';
      difficulty = 'medium';
      items = [
        {
          'character': 'R',
          'difficulty': 1,
          'instruction': 'Trace the letter R for Run - Lari',
          'emoji': '🏃',
          'word': 'Run',
          'malay_word': 'Lari',
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
          'character': 'J',
          'difficulty': 1,
          'instruction': 'Trace the letter J for Jump - Lompat',
          'emoji': '🦘',
          'word': 'Jump',
          'malay_word': 'Lompat',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.4, 'y': 0.8},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': 'C',
          'difficulty': 1,
          'instruction': 'Trace the letter C for Climb - Panjat',
          'emoji': '🧗',
          'word': 'Climb',
          'malay_word': 'Panjat',
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
    } else {
      // Age 6: Complex tracing with all 5 letters and bilingual instructions
      instructions = 'Trace these letters to learn about movement. Follow the arrows and learn the words in both English and Malay.';
      difficulty = 'hard';
      items = [
        {
          'character': 'R',
          'difficulty': 1,
          'instruction': 'Trace the letter R for Run - Lari',
          'emoji': '🏃',
          'word': 'Run',
          'malay_word': 'Lari',
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
          'character': 'J',
          'difficulty': 1,
          'instruction': 'Trace the letter J for Jump - Lompat',
          'emoji': '🦘',
          'word': 'Jump',
          'malay_word': 'Lompat',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.4, 'y': 0.8},
            {'x': 0.3, 'y': 0.7},
          ]
        },
        {
          'character': 'C',
          'difficulty': 1,
          'instruction': 'Trace the letter C for Climb - Panjat',
          'emoji': '🧗',
          'word': 'Climb',
          'malay_word': 'Panjat',
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
          'instruction': 'Trace the letter D for Dance - Tari',
          'emoji': '💃',
          'word': 'Dance',
          'malay_word': 'Tari',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': 'S',
          'difficulty': 1,
          'instruction': 'Trace the letter S for Swim - Renang',
          'emoji': '🏊',
          'word': 'Swim',
          'malay_word': 'Renang',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.5, 'y': 0.4},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.5, 'y': 0.6},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.5, 'y': 0.8},
            {'x': 0.6, 'y': 0.8},
            {'x': 0.7, 'y': 0.7},
          ]
        },
      ];
    }
    
    return {
      'title': 'Physical Development - Gross Motor Skills',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Physical Development',
        'chapter': 'Gross Motor Skills',
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
      // Age 4: Simple shapes with 4 basic activities
      instructions = 'Match the activity with its correct name.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'running', 'color': 'red', 'name': 'Running', 'malay_shape': 'Berlari', 'malay_color': 'Merah', 'word': 'Running', 'malay_word': 'Berlari'},
        {'shape': 'jumping', 'color': 'blue', 'name': 'Jumping', 'malay_shape': 'Melompat', 'malay_color': 'Biru', 'word': 'Jumping', 'malay_word': 'Melompat'},
        {'shape': 'dancing', 'color': 'purple', 'name': 'Dancing', 'malay_shape': 'Menari', 'malay_color': 'Ungu', 'word': 'Dancing', 'malay_word': 'Menari'},
        {'shape': 'swimming', 'color': 'cyan', 'name': 'Swimming', 'malay_shape': 'Berenang', 'malay_color': 'Biru Kehijauan', 'word': 'Swimming', 'malay_word': 'Berenang'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 6 activities and bilingual names
      instructions = 'Match the activity with its correct name in English and Malay.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'running', 'color': 'red', 'name': 'Running', 'malay_shape': 'Berlari', 'malay_color': 'Merah', 'word': 'Running', 'malay_word': 'Berlari'},
        {'shape': 'jumping', 'color': 'blue', 'name': 'Jumping', 'malay_shape': 'Melompat', 'malay_color': 'Biru', 'word': 'Jumping', 'malay_word': 'Melompat'},
        {'shape': 'climbing', 'color': 'green', 'name': 'Climbing', 'malay_shape': 'Memanjat', 'malay_color': 'Hijau', 'word': 'Climbing', 'malay_word': 'Memanjat'},
        {'shape': 'dancing', 'color': 'purple', 'name': 'Dancing', 'malay_shape': 'Menari', 'malay_color': 'Ungu', 'word': 'Dancing', 'malay_word': 'Menari'},
        {'shape': 'swimming', 'color': 'cyan', 'name': 'Swimming', 'malay_shape': 'Berenang', 'malay_color': 'Biru Kehijauan', 'word': 'Swimming', 'malay_word': 'Berenang'},
        {'shape': 'throwing', 'color': 'orange', 'name': 'Throwing', 'malay_shape': 'Membaling', 'malay_color': 'Oren', 'word': 'Throwing', 'malay_word': 'Membaling'},
      ];
    } else {
      // Age 6: Complex with all 8 activities, colors, and bilingual names
      instructions = 'Match the activity with its correct name and color in both English and Malay.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'running', 'color': 'red', 'name': 'Running', 'malay_shape': 'Berlari', 'malay_color': 'Merah', 'word': 'Running', 'malay_word': 'Berlari'},
        {'shape': 'jumping', 'color': 'blue', 'name': 'Jumping', 'malay_shape': 'Melompat', 'malay_color': 'Biru', 'word': 'Jumping', 'malay_word': 'Melompat'},
        {'shape': 'climbing', 'color': 'green', 'name': 'Climbing', 'malay_shape': 'Memanjat', 'malay_color': 'Hijau', 'word': 'Climbing', 'malay_word': 'Memanjat'},
        {'shape': 'dancing', 'color': 'purple', 'name': 'Dancing', 'malay_shape': 'Menari', 'malay_color': 'Ungu', 'word': 'Dancing', 'malay_word': 'Menari'},
        {'shape': 'swimming', 'color': 'cyan', 'name': 'Swimming', 'malay_shape': 'Berenang', 'malay_color': 'Biru Kehijauan', 'word': 'Swimming', 'malay_word': 'Berenang'},
        {'shape': 'throwing', 'color': 'orange', 'name': 'Throwing', 'malay_shape': 'Membaling', 'malay_color': 'Oren', 'word': 'Throwing', 'malay_word': 'Membaling'},
        {'shape': 'kicking', 'color': 'yellow', 'name': 'Kicking', 'malay_shape': 'Menendang', 'malay_color': 'Kuning', 'word': 'Kicking', 'malay_word': 'Menendang'},
        {'shape': 'balancing', 'color': 'pink', 'name': 'Balancing', 'malay_shape': 'Mengimbangi', 'malay_color': 'Merah Jambu', 'word': 'Balancing', 'malay_word': 'Mengimbangi'},
      ];
    }
    
    return {
      'title': 'Physical Development - Gross Motor Skills',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Physical Development',
        'chapter': 'Gross Motor Skills',
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
