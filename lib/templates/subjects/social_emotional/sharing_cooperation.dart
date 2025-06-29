import 'dart:math';

/// Template for Social & Emotional Learning - Sharing & Cooperation chapter
class SharingCooperationTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: Simple with 4 basic social skills
      instructions = 'Match the sharing skill with its picture.';
      difficulty = 'easy';
      pairs = [
        {'word': 'Sharing', 'emoji': '🤝', 'description': 'Letting others use your toys', 'malay_word': 'Berkongsi'},
        {'word': 'Helping', 'emoji': '🆓', 'description': 'Helping others', 'malay_word': 'Membantu'},
        {'word': 'Teamwork', 'emoji': '👥', 'description': 'Working together', 'malay_word': 'Kerjasama'},
        {'word': 'Taking Turns', 'emoji': '🔄', 'description': 'Waiting for your turn', 'malay_word': 'Bergilir'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 6 social skills and bilingual labels
      instructions = 'Match the social skill with its example. Learn their names in English and Malay.';
      difficulty = 'medium';
      pairs = [
        {'word': 'Sharing', 'emoji': '🤝', 'description': 'Letting others use your things', 'malay_word': 'Berkongsi'},
        {'word': 'Helping', 'emoji': '🆓', 'description': 'Assisting others when they need it', 'malay_word': 'Membantu'},
        {'word': 'Teamwork', 'emoji': '👥', 'description': 'Working together to achieve a goal', 'malay_word': 'Kerja Berpasukan'},
        {'word': 'Taking Turns', 'emoji': '🔄', 'description': 'Waiting for your chance', 'malay_word': 'Bergilir-gilir'},
        {'word': 'Listening', 'emoji': '👂', 'description': 'Paying attention when others speak', 'malay_word': 'Mendengar'},
        {'word': 'Kindness', 'emoji': '❤️', 'description': 'Being friendly to others', 'malay_word': 'Kebaikan'},
      ];
    } else {
      // Age 6: Complex with all 8 social skills and comprehensive bilingual descriptions
      instructions = 'Match the social skill with its example. Learn about different ways to cooperate with others in English and Malay.';
      difficulty = 'hard';
      pairs = [
        {'word': 'Sharing', 'emoji': '🤝', 'description': 'Letting others use your things', 'malay_word': 'Berkongsi'},
        {'word': 'Helping', 'emoji': '🆓', 'description': 'Assisting others when they need it', 'malay_word': 'Membantu'},
        {'word': 'Teamwork', 'emoji': '👥', 'description': 'Working together to achieve a goal', 'malay_word': 'Kerja Berpasukan'},
        {'word': 'Taking Turns', 'emoji': '🔄', 'description': 'Waiting for your chance and letting others have a turn', 'malay_word': 'Bergilir-gilir'},
        {'word': 'Listening', 'emoji': '👂', 'description': 'Paying attention when others speak', 'malay_word': 'Mendengar'},
        {'word': 'Kindness', 'emoji': '❤️', 'description': 'Being friendly and considerate', 'malay_word': 'Kebaikan'},
        {'word': 'Patience', 'emoji': '⏳', 'description': 'Waiting calmly without getting upset', 'malay_word': 'Kesabaran'},
        {'word': 'Respect', 'emoji': '🙏', 'description': 'Treating others with care and courtesy', 'malay_word': 'Hormat'},
      ];
    }
    
    return {
      'title': 'Social & Emotional Learning - Sharing & Cooperation',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Social & Emotional Learning',
        'chapter': 'Sharing & Cooperation',
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
    
    // Categories are the same across all age groups
    categories = [
      {'name': 'Good Sharing', 'description': 'Behaviors that show good sharing and cooperation', 'emoji': '👍', 'color': 'green'},
      {'name': 'Needs Improvement', 'description': 'Behaviors that could be improved', 'emoji': '👎', 'color': 'red'},
    ];
    
    if (ageGroup == 4) {
      // Age 4: Simple with 4 basic behaviors
      instructions = 'Sort the behaviors into good sharing or needs work.';
      difficulty = 'easy';
      items = [
        {'name': 'Taking turns', 'category': 'Good Sharing', 'malay_name': 'Bergilir-gilir'},
        {'name': 'Sharing toys', 'category': 'Good Sharing', 'malay_name': 'Berkongsi mainan'},
        {'name': 'Grabbing toys', 'category': 'Needs Improvement', 'malay_name': 'Merebut mainan'},
        {'name': 'Not sharing', 'category': 'Needs Improvement', 'malay_name': 'Tidak berkongsi'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 6 behaviors and bilingual labels
      instructions = 'Sort the behaviors into good sharing or needs improvement. Learn their names in English and Malay.';
      difficulty = 'medium';
      items = [
        {'name': 'Taking turns on the slide', 'category': 'Good Sharing', 'malay_name': 'Bergilir-gilir di gelongsor'},
        {'name': 'Sharing toys with friends', 'category': 'Good Sharing', 'malay_name': 'Berkongsi mainan dengan kawan'},
        {'name': 'Helping clean up together', 'category': 'Good Sharing', 'malay_name': 'Membantu membersihkan bersama'},
        {'name': 'Grabbing toys from others', 'category': 'Needs Improvement', 'malay_name': 'Merebut mainan daripada orang lain'},
        {'name': 'Refusing to take turns', 'category': 'Needs Improvement', 'malay_name': 'Enggan bergilir-gilir'},
        {'name': 'Not helping with cleanup', 'category': 'Needs Improvement', 'malay_name': 'Tidak membantu dengan pembersihan'},
      ];
    } else {
      // Age 6: Complex with all 8 behaviors and comprehensive bilingual descriptions
      instructions = 'Sort the behaviors into good sharing or needs improvement. Learn about different ways to cooperate with others in English and Malay.';
      difficulty = 'hard';
      items = [
        {'name': 'Taking turns on the slide', 'category': 'Good Sharing', 'malay_name': 'Bergilir-gilir di gelongsor'},
        {'name': 'Sharing toys with friends', 'category': 'Good Sharing', 'malay_name': 'Berkongsi mainan dengan kawan'},
        {'name': 'Helping clean up together', 'category': 'Good Sharing', 'malay_name': 'Membantu membersihkan bersama'},
        {'name': 'Listening when others speak', 'category': 'Good Sharing', 'malay_name': 'Mendengar apabila orang lain bercakap'},
        {'name': 'Grabbing toys from others', 'category': 'Needs Improvement', 'malay_name': 'Merebut mainan daripada orang lain'},
        {'name': 'Refusing to take turns', 'category': 'Needs Improvement', 'malay_name': 'Enggan bergilir-gilir'},
        {'name': 'Interrupting when others talk', 'category': 'Needs Improvement', 'malay_name': 'Mengganggu ketika orang lain bercakap'},
        {'name': 'Not helping with cleanup', 'category': 'Needs Improvement', 'malay_name': 'Tidak membantu dengan pembersihan'},
      ];
    }
    
    return {
      'title': 'Social & Emotional Learning - Sharing & Cooperation',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Social & Emotional Learning',
        'chapter': 'Sharing & Cooperation',
        'ageGroup': ageGroup,
        'difficulty': 'medium',
      }
    };
  }

  /// Get tracing game content
  static Map<String, dynamic> getTracingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> paths = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: Simple with shorter words
      instructions = 'Trace the word SHARE.';
      difficulty = 'easy';
      paths = [
        {
          'word': 'SHARE',
          'malay_word': 'KONGSI',
          'paths': [
            'M 50 100 L 70 50 L 90 100',
            'M 60 75 L 80 75',
            'M 120 50 C 140 50, 160 70, 160 85 C 160 100, 140 120, 120 120 C 100 120, 80 100, 80 85 C 80 70, 100 50, 120 50',
            'M 180 50 L 180 120',
            'M 180 50 L 220 50',
            'M 180 85 L 210 85',
            'M 240 50 L 240 120',
            'M 240 50 C 280 50, 280 120, 240 120'
          ]
        }
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with two words
      instructions = 'Trace the words related to sharing and cooperation. Learn them in English and Malay.';
      difficulty = 'medium';
      paths = [
        {
          'word': 'SHARE',
          'malay_word': 'KONGSI',
          'paths': [
            'M 50 100 L 70 50 L 90 100',
            'M 60 75 L 80 75',
            'M 120 50 C 140 50, 160 70, 160 85 C 160 100, 140 120, 120 120 C 100 120, 80 100, 80 85 C 80 70, 100 50, 120 50',
            'M 180 50 L 180 120',
            'M 180 50 L 220 50',
            'M 180 85 L 210 85',
            'M 240 50 L 240 120',
            'M 240 50 C 280 50, 280 120, 240 120'
          ]
        },
        {
          'word': 'TEAM',
          'malay_word': 'PASUKAN',
          'paths': [
            'M 50 50 L 90 50',
            'M 70 50 L 70 120',
            'M 110 50 L 110 120',
            'M 110 50 L 150 50',
            'M 110 85 L 140 85',
            'M 170 50 L 170 120',
            'M 170 50 L 210 50',
            'M 170 85 L 200 85',
            'M 230 50 L 230 120',
            'M 230 50 L 270 120',
            'M 270 50 L 270 120'
          ]
        }
      ];
    } else {
      // Age 6: Complex with all words and comprehensive bilingual instructions
      instructions = 'Trace these important words about sharing and cooperation. Learn how to write them in both English and Malay.';
      difficulty = 'hard';
      paths = [
        {
          'word': 'SHARE',
          'malay_word': 'KONGSI',
          'paths': [
            'M 50 100 L 70 50 L 90 100',
            'M 60 75 L 80 75',
            'M 120 50 C 140 50, 160 70, 160 85 C 160 100, 140 120, 120 120 C 100 120, 80 100, 80 85 C 80 70, 100 50, 120 50',
            'M 180 50 L 180 120',
            'M 180 50 L 220 50',
            'M 180 85 L 210 85',
            'M 240 50 L 240 120',
            'M 240 50 C 280 50, 280 120, 240 120'
          ]
        },
        {
          'word': 'TEAM',
          'malay_word': 'PASUKAN',
          'paths': [
            'M 50 50 L 90 50',
            'M 70 50 L 70 120',
            'M 110 50 L 110 120',
            'M 110 50 L 150 50',
            'M 110 85 L 140 85',
            'M 170 50 L 170 120',
            'M 170 50 L 210 50',
            'M 170 85 L 200 85',
            'M 230 50 L 230 120',
            'M 230 50 L 270 120',
            'M 270 50 L 270 120'
          ]
        },
        {
          'word': 'HELP',
          'malay_word': 'BANTU',
          'paths': [
            'M 50 50 L 50 120',
            'M 50 85 L 90 85',
            'M 90 50 L 90 120',
            'M 110 50 L 110 120',
            'M 110 50 L 150 50',
            'M 110 85 L 150 85',
            'M 170 50 L 170 120',
            'M 170 50 L 210 50',
            'M 170 85 L 210 85',
            'M 230 50 C 250 50, 270 70, 270 85 C 270 100, 250 120, 230 120'
          ]
        }
      ];
    }
    
    return {
      'title': 'Social & Emotional Learning - Sharing & Cooperation',
      'instructions': instructions,
      'paths': paths,
      'rounds': rounds,
      'metadata': {
        'subject': 'Social & Emotional Learning',
        'chapter': 'Sharing & Cooperation',
        'ageGroup': ageGroup,
        'difficulty': difficulty
      }
    };
  }

  /// Get shape and color game content
  static Map<String, dynamic> getShapeColorContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> shapes = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: Simple with 4 basic social skills
      instructions = 'Match the sharing skill with the correct symbol.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'sharing', 'color': 'blue', 'name': 'Sharing', 'malay_shape': 'Berkongsi', 'malay_color': 'Biru', 'word': 'Sharing', 'malay_word': 'Berkongsi'},
        {'shape': 'helping', 'color': 'red', 'name': 'Helping', 'malay_shape': 'Membantu', 'malay_color': 'Merah', 'word': 'Helping', 'malay_word': 'Membantu'},
        {'shape': 'teamwork', 'color': 'green', 'name': 'Teamwork', 'malay_shape': 'Kerjasama', 'malay_color': 'Hijau', 'word': 'Teamwork', 'malay_word': 'Kerjasama'},
        {'shape': 'taking_turns', 'color': 'yellow', 'name': 'Taking Turns', 'malay_shape': 'Bergilir', 'malay_color': 'Kuning', 'word': 'Taking Turns', 'malay_word': 'Bergilir'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 6 social skills and bilingual labels
      instructions = 'Match the social skill with the correct symbol. Learn their names in English and Malay.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'sharing', 'color': 'blue', 'name': 'Sharing', 'malay_shape': 'Berkongsi', 'malay_color': 'Biru', 'word': 'Sharing', 'malay_word': 'Berkongsi'},
        {'shape': 'helping', 'color': 'red', 'name': 'Helping', 'malay_shape': 'Membantu', 'malay_color': 'Merah', 'word': 'Helping', 'malay_word': 'Membantu'},
        {'shape': 'teamwork', 'color': 'green', 'name': 'Teamwork', 'malay_shape': 'Kerja Berpasukan', 'malay_color': 'Hijau', 'word': 'Teamwork', 'malay_word': 'Kerja Berpasukan'},
        {'shape': 'taking_turns', 'color': 'yellow', 'name': 'Taking Turns', 'malay_shape': 'Bergilir-gilir', 'malay_color': 'Kuning', 'word': 'Taking Turns', 'malay_word': 'Bergilir-gilir'},
        {'shape': 'listening', 'color': 'purple', 'name': 'Listening', 'malay_shape': 'Mendengar', 'malay_color': 'Ungu', 'word': 'Listening', 'malay_word': 'Mendengar'},
        {'shape': 'kindness', 'color': 'pink', 'name': 'Kindness', 'malay_shape': 'Kebaikan', 'malay_color': 'Merah Jambu', 'word': 'Kindness', 'malay_word': 'Kebaikan'},
      ];
    } else {
      // Age 6: Complex with all 8 social skills and comprehensive bilingual descriptions
      instructions = 'Match the social skill with the correct symbol. Learn about different cooperation skills in English and Malay.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'sharing', 'color': 'blue', 'name': 'Sharing - Giving to others', 'malay_shape': 'Berkongsi - Memberi kepada orang lain', 'malay_color': 'Biru', 'word': 'Sharing', 'malay_word': 'Berkongsi'},
        {'shape': 'helping', 'color': 'red', 'name': 'Helping - Assisting others', 'malay_shape': 'Membantu - Menolong orang lain', 'malay_color': 'Merah', 'word': 'Helping', 'malay_word': 'Membantu'},
        {'shape': 'teamwork', 'color': 'green', 'name': 'Teamwork - Working together', 'malay_shape': 'Kerja Berpasukan - Bekerja bersama', 'malay_color': 'Hijau', 'word': 'Teamwork', 'malay_word': 'Kerja Berpasukan'},
        {'shape': 'taking_turns', 'color': 'yellow', 'name': 'Taking Turns - Waiting for your turn', 'malay_shape': 'Bergilir-gilir - Menunggu giliran anda', 'malay_color': 'Kuning', 'word': 'Taking Turns', 'malay_word': 'Bergilir-gilir'},
        {'shape': 'listening', 'color': 'purple', 'name': 'Listening - Paying attention', 'malay_shape': 'Mendengar - Memberi perhatian', 'malay_color': 'Ungu', 'word': 'Listening', 'malay_word': 'Mendengar'},
        {'shape': 'kindness', 'color': 'pink', 'name': 'Kindness - Being nice to others', 'malay_shape': 'Kebaikan - Bersikap baik kepada orang lain', 'malay_color': 'Merah Jambu', 'word': 'Kindness', 'malay_word': 'Kebaikan'},
        {'shape': 'patience', 'color': 'orange', 'name': 'Patience - Waiting calmly', 'malay_shape': 'Kesabaran - Menunggu dengan tenang', 'malay_color': 'Oren', 'word': 'Patience', 'malay_word': 'Kesabaran'},
        {'shape': 'respect', 'color': 'brown', 'name': 'Respect - Treating others well', 'malay_shape': 'Hormat - Melayan orang lain dengan baik', 'malay_color': 'Coklat', 'word': 'Respect', 'malay_word': 'Hormat'},
      ];
    }
    
    return {
      'title': 'Social & Emotional Learning - Sharing & Cooperation',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Social & Emotional Learning',
        'chapter': 'Sharing & Cooperation',
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
        return getTracingContent(ageGroup, rounds);
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
