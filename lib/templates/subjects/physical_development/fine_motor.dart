import 'dart:math';

/// Template for Physical Development - Fine Motor Skills chapter
class FineMotorTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup, int rounds) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: Simple matching with 4 basic fine motor skills
      instructions = 'Match the fine motor skill with its picture.';
      difficulty = 'easy';
      pairs = [
        {'word': 'Drawing', 'emoji': '✏️', 'description': 'Making marks on paper', 'malay_word': 'Melukis'},
        {'word': 'Clapping', 'emoji': '👏', 'description': 'Bringing hands together', 'malay_word': 'Bertepuk'},
        {'word': 'Folding', 'emoji': '📄', 'description': 'Bending paper', 'malay_word': 'Melipat'},
        {'word': 'Pouring', 'emoji': '🍵', 'description': 'Moving liquid', 'malay_word': 'Menuang'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 6 fine motor skills
      instructions = 'Match the fine motor skill with its picture and description.';
      difficulty = 'medium';
      pairs = [
        {'word': 'Drawing', 'emoji': '✏️', 'description': 'Using a pencil to make marks', 'malay_word': 'Melukis'},
        {'word': 'Cutting', 'emoji': '✂️', 'description': 'Using scissors to cut paper', 'malay_word': 'Menggunting'},
        {'word': 'Folding', 'emoji': '📄', 'description': 'Creasing paper neatly', 'malay_word': 'Melipat'},
        {'word': 'Beading', 'emoji': '📿', 'description': 'Threading beads onto string', 'malay_word': 'Merangkai Manik'},
        {'word': 'Pouring', 'emoji': '🍵', 'description': 'Transferring liquid between containers', 'malay_word': 'Menuang'},
        {'word': 'Zipping', 'emoji': '🧥', 'description': 'Using a zipper to close clothing', 'malay_word': 'Menarik Zip'},
      ];
    } else {
      // Age 6: Complex matching with all 8 fine motor skills
      instructions = 'Match the fine motor skill with its picture, description, and Malay translation.';
      difficulty = 'hard';
      pairs = [
        {'word': 'Drawing', 'emoji': '✏️', 'description': 'Using a pencil or crayon to make marks', 'malay_word': 'Melukis'},
        {'word': 'Cutting', 'emoji': '✂️', 'description': 'Using scissors to cut paper', 'malay_word': 'Menggunting'},
        {'word': 'Buttoning', 'emoji': '👕', 'description': 'Fastening buttons on clothes', 'malay_word': 'Mengancingkan'},
        {'word': 'Tying', 'emoji': '👟', 'description': 'Making knots with laces', 'malay_word': 'Mengikat'},
        {'word': 'Beading', 'emoji': '📿', 'description': 'Threading beads onto string', 'malay_word': 'Merangkai Manik'},
        {'word': 'Folding', 'emoji': '📄', 'description': 'Creasing paper neatly', 'malay_word': 'Melipat'},
        {'word': 'Pouring', 'emoji': '🍵', 'description': 'Transferring liquid from one container to another', 'malay_word': 'Menuang'},
        {'word': 'Zipping', 'emoji': '🧥', 'description': 'Using a zipper to close clothing', 'malay_word': 'Menarik Zip'},
      ];
    }
    
    return {
      'title': 'Physical Development - Fine Motor Skills',
      'instructions': instructions,
      'pairs': pairs,
      'rounds': rounds,
      'metadata': {
        'subject': 'Physical Development',
        'chapter': 'Fine Motor Skills',
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
      instructions = 'Sort these activities into easy and harder groups.';
      difficulty = 'easy';
      categories = [
        {'name': 'Easy Skills', 'description': 'Skills that are easier to do', 'emoji': '👏', 'color': 'green'},
        {'name': 'Harder Skills', 'description': 'Skills that need more practice', 'emoji': '✏️', 'color': 'yellow'},
      ];
      items = [
        {'name': 'Scribbling', 'category': 'Easy Skills', 'emoji': '✏️', 'word': 'Scribbling', 'malay_word': 'Mencoreng'},
        {'name': 'Clapping', 'category': 'Easy Skills', 'emoji': '👏', 'word': 'Clapping', 'malay_word': 'Bertepuk'},
        {'name': 'Drawing Lines', 'category': 'Harder Skills', 'emoji': '📏', 'word': 'Drawing Lines', 'malay_word': 'Melukis Garisan'},
        {'name': 'Using Scissors', 'category': 'Harder Skills', 'emoji': '✂️', 'word': 'Using Scissors', 'malay_word': 'Menggunakan Gunting'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 2 categories and 6 items
      instructions = 'Sort the activities by their difficulty level.';
      difficulty = 'medium';
      categories = [
        {'name': 'Easy Skills', 'description': 'Skills that are easier to master', 'emoji': '👏', 'color': 'green'},
        {'name': 'Medium Skills', 'description': 'Skills that need more practice', 'emoji': '✏️', 'color': 'yellow'},
      ];
      items = [
        {'name': 'Scribbling', 'category': 'Easy Skills', 'emoji': '✏️', 'word': 'Scribbling', 'malay_word': 'Mencoreng'},
        {'name': 'Clapping', 'category': 'Easy Skills', 'emoji': '👏', 'word': 'Clapping', 'malay_word': 'Bertepuk'},
        {'name': 'Stacking Blocks', 'category': 'Easy Skills', 'emoji': '🧱', 'word': 'Stacking Blocks', 'malay_word': 'Menyusun Blok'},
        {'name': 'Drawing Lines', 'category': 'Medium Skills', 'emoji': '📏', 'word': 'Drawing Lines', 'malay_word': 'Melukis Garisan'},
        {'name': 'Using Scissors', 'category': 'Medium Skills', 'emoji': '✂️', 'word': 'Using Scissors', 'malay_word': 'Menggunakan Gunting'},
        {'name': 'Stringing Beads', 'category': 'Medium Skills', 'emoji': '📿', 'word': 'Stringing Beads', 'malay_word': 'Merangkai Manik'},
      ];
    } else {
      // Age 6: Complex sorting with 3 categories and all 9 items
      instructions = 'Sort the activities by their difficulty level and explain why in Malay and English.';
      difficulty = 'hard';
      categories = [
        {'name': 'Easy Skills', 'description': 'Skills that are easier to master', 'emoji': '👏', 'color': 'green'},
        {'name': 'Medium Skills', 'description': 'Skills that need more practice', 'emoji': '✏️', 'color': 'yellow'},
        {'name': 'Challenging Skills', 'description': 'Skills that need lots of practice', 'emoji': '👟', 'color': 'red'},
      ];
      items = [
        {'name': 'Scribbling', 'category': 'Easy Skills', 'emoji': '✏️', 'word': 'Scribbling', 'malay_word': 'Mencoreng'},
        {'name': 'Clapping', 'category': 'Easy Skills', 'emoji': '👏', 'word': 'Clapping', 'malay_word': 'Bertepuk'},
        {'name': 'Stacking Blocks', 'category': 'Easy Skills', 'emoji': '🧱', 'word': 'Stacking Blocks', 'malay_word': 'Menyusun Blok'},
        {'name': 'Drawing Lines', 'category': 'Medium Skills', 'emoji': '📏', 'word': 'Drawing Lines', 'malay_word': 'Melukis Garisan'},
        {'name': 'Using Scissors', 'category': 'Medium Skills', 'emoji': '✂️', 'word': 'Using Scissors', 'malay_word': 'Menggunakan Gunting'},
        {'name': 'Stringing Beads', 'category': 'Medium Skills', 'emoji': '📿', 'word': 'Stringing Beads', 'malay_word': 'Merangkai Manik'},
        {'name': 'Buttoning Clothes', 'category': 'Challenging Skills', 'emoji': '👕', 'word': 'Buttoning Clothes', 'malay_word': 'Mengancingkan Pakaian'},
        {'name': 'Tying Shoelaces', 'category': 'Challenging Skills', 'emoji': '👟', 'word': 'Tying Shoelaces', 'malay_word': 'Mengikat Tali Kasut'},
        {'name': 'Using Chopsticks', 'category': 'Challenging Skills', 'emoji': '🥢', 'word': 'Using Chopsticks', 'malay_word': 'Menggunakan Penyepit'},
      ];
    }
    
    return {
      'title': 'Physical Development - Fine Motor Skills',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'rounds': rounds,
      'metadata': {
        'subject': 'Physical Development',
        'chapter': 'Fine Motor Skills',
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
      instructions = 'Trace these simple letters to practice your fine motor skills.';
      difficulty = 'easy';
      items = [
        {
          'character': 'D',
          'difficulty': 1,
          'instruction': 'Trace the letter D for Draw',
          'emoji': '✏️',
          'word': 'Draw',
          'malay_word': 'Lukis',
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
          'character': 'C',
          'difficulty': 1,
          'instruction': 'Trace the letter C for Cut',
          'emoji': '✂️',
          'word': 'Cut',
          'malay_word': 'Gunting',
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
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 3 letters
      instructions = 'Trace these letters to practice your fine motor skills. Follow the arrows.';
      difficulty = 'medium';
      items = [
        {
          'character': 'D',
          'difficulty': 1,
          'instruction': 'Trace the letter D for Draw - Lukis',
          'emoji': '✏️',
          'word': 'Draw',
          'malay_word': 'Lukis',
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
          'character': 'C',
          'difficulty': 1,
          'instruction': 'Trace the letter C for Cut - Gunting',
          'emoji': '✂️',
          'word': 'Cut',
          'malay_word': 'Gunting',
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
          'character': 'F',
          'difficulty': 1,
          'instruction': 'Trace the letter F for Fold - Lipat',
          'emoji': '📄',
          'word': 'Fold',
          'malay_word': 'Lipat',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
          ]
        },
      ];
    } else {
      // Age 6: Complex tracing with all 5 letters and bilingual instructions
      instructions = 'Trace these letters to practice your fine motor skills. Follow the arrows and learn the words in both English and Malay.';
      difficulty = 'hard';
      items = [
        {
          'character': 'D',
          'difficulty': 1,
          'instruction': 'Trace the letter D for Draw - Lukis',
          'emoji': '✏️',
          'word': 'Draw',
          'malay_word': 'Lukis',
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
          'character': 'C',
          'difficulty': 1,
          'instruction': 'Trace the letter C for Cut - Gunting',
          'emoji': '✂️',
          'word': 'Cut',
          'malay_word': 'Gunting',
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
          'character': 'F',
          'difficulty': 1,
          'instruction': 'Trace the letter F for Fold - Lipat',
          'emoji': '📄',
          'word': 'Fold',
          'malay_word': 'Lipat',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.6, 'y': 0.5},
          ]
        },
        {
          'character': 'B',
          'difficulty': 1,
          'instruction': 'Trace the letter B for Button - Kancing',
          'emoji': '👕',
          'word': 'Button',
          'malay_word': 'Kancing',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.6, 'y': 0.4},
            {'x': 0.7, 'y': 0.6},
            {'x': 0.6, 'y': 0.8},
            {'x': 0.3, 'y': 0.8},
          ]
        },
        {
          'character': 'T',
          'difficulty': 1,
          'instruction': 'Trace the letter T for Tie - Ikat',
          'emoji': '👟',
          'word': 'Tie',
          'malay_word': 'Ikat',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.7, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.5, 'y': 0.8},
          ]
        },
      ];
    }
    
    return {
      'title': 'Physical Development - Fine Motor Skills',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'Physical Development',
        'chapter': 'Fine Motor Skills',
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
      // Age 4: Simple matching with 3 basic tools
      instructions = 'Match the fine motor skill with its tool.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'pencil', 'color': 'yellow', 'name': 'Drawing', 'malay_shape': 'Melukis', 'malay_color': 'Kuning', 'word': 'Drawing', 'malay_word': 'Melukis'},
        {'shape': 'scissors', 'color': 'red', 'name': 'Cutting', 'malay_shape': 'Menggunting', 'malay_color': 'Merah', 'word': 'Cutting', 'malay_word': 'Menggunting'},
        {'shape': 'paper', 'color': 'white', 'name': 'Folding', 'malay_shape': 'Melipat', 'malay_color': 'Putih', 'word': 'Folding', 'malay_word': 'Melipat'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: Medium complexity with 5 tools
      instructions = 'Match the fine motor skill with its tool and color.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'pencil', 'color': 'yellow', 'name': 'Drawing', 'malay_shape': 'Melukis', 'malay_color': 'Kuning', 'word': 'Drawing', 'malay_word': 'Melukis'},
        {'shape': 'scissors', 'color': 'red', 'name': 'Cutting', 'malay_shape': 'Menggunting', 'malay_color': 'Merah', 'word': 'Cutting', 'malay_word': 'Menggunting'},
        {'shape': 'bead', 'color': 'purple', 'name': 'Beading', 'malay_shape': 'Merangkai Manik', 'malay_color': 'Ungu', 'word': 'Beading', 'malay_word': 'Merangkai Manik'},
        {'shape': 'paper', 'color': 'white', 'name': 'Folding', 'malay_shape': 'Melipat', 'malay_color': 'Putih', 'word': 'Folding', 'malay_word': 'Melipat'},
        {'shape': 'teapot', 'color': 'brown', 'name': 'Pouring', 'malay_shape': 'Menuang', 'malay_color': 'Coklat', 'word': 'Pouring', 'malay_word': 'Menuang'},
      ];
    } else {
      // Age 6: Complex matching with all 8 tools and bilingual names
      instructions = 'Match the fine motor skill with its tool, color, and Malay translation.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'pencil', 'color': 'yellow', 'name': 'Drawing', 'malay_shape': 'Melukis', 'malay_color': 'Kuning', 'word': 'Drawing', 'malay_word': 'Melukis'},
        {'shape': 'scissors', 'color': 'red', 'name': 'Cutting', 'malay_shape': 'Menggunting', 'malay_color': 'Merah', 'word': 'Cutting', 'malay_word': 'Menggunting'},
        {'shape': 'button', 'color': 'blue', 'name': 'Buttoning', 'malay_shape': 'Mengancingkan', 'malay_color': 'Biru', 'word': 'Buttoning', 'malay_word': 'Mengancingkan'},
        {'shape': 'shoelace', 'color': 'green', 'name': 'Tying', 'malay_shape': 'Mengikat', 'malay_color': 'Hijau', 'word': 'Tying', 'malay_word': 'Mengikat'},
        {'shape': 'bead', 'color': 'purple', 'name': 'Beading', 'malay_shape': 'Merangkai Manik', 'malay_color': 'Ungu', 'word': 'Beading', 'malay_word': 'Merangkai Manik'},
        {'shape': 'paper', 'color': 'white', 'name': 'Folding', 'malay_shape': 'Melipat', 'malay_color': 'Putih', 'word': 'Folding', 'malay_word': 'Melipat'},
        {'shape': 'teapot', 'color': 'brown', 'name': 'Pouring', 'malay_shape': 'Menuang', 'malay_color': 'Coklat', 'word': 'Pouring', 'malay_word': 'Menuang'},
        {'shape': 'zipper', 'color': 'black', 'name': 'Zipping', 'malay_shape': 'Menarik Zip', 'malay_color': 'Hitam', 'word': 'Zipping', 'malay_word': 'Menarik Zip'},
      ];
    }
    
    return {
      'title': 'Physical Development - Fine Motor Skills',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'Physical Development',
        'chapter': 'Fine Motor Skills',
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
