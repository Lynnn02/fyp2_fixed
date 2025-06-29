import 'package:flutter/material.dart';

/// Provides game content for "English - Alphabet & Phonics" subject
class AlphabetPhonicsTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: 5 simple pairs with basic instructions
      instructions = 'Match the letter with its picture.';
      difficulty = 'easy';
      pairs = [
        {'word': 'A', 'emoji': '🍎', 'description': 'Apple'},
        {'word': 'B', 'emoji': '🍌', 'description': 'Banana'},
        {'word': 'C', 'emoji': '🐱', 'description': 'Cat'},
        {'word': 'D', 'emoji': '🐶', 'description': 'Dog'},
        {'word': 'E', 'emoji': '🐘', 'description': 'Elephant'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 pairs with medium complexity
      instructions = 'Match the letter with its corresponding image.';
      difficulty = 'medium';
      pairs = [
        {'word': 'A', 'emoji': '🍎', 'description': 'Apple'},
        {'word': 'B', 'emoji': '🍌', 'description': 'Banana'},
        {'word': 'C', 'emoji': '🐱', 'description': 'Cat'},
        {'word': 'D', 'emoji': '🐶', 'description': 'Dog'},
        {'word': 'E', 'emoji': '🐘', 'description': 'Elephant'},
        {'word': 'F', 'emoji': '🐟', 'description': 'Fish'},
      ];
    } else {
      // Age 6: 8 pairs with higher complexity
      instructions = 'Match the letter with its corresponding image and sound.';
      difficulty = 'hard';
      pairs = [
        {'word': 'A', 'emoji': '🍎', 'description': 'Apple'},
        {'word': 'B', 'emoji': '🍌', 'description': 'Banana'},
        {'word': 'C', 'emoji': '🐱', 'description': 'Cat'},
        {'word': 'D', 'emoji': '🐶', 'description': 'Dog'},
        {'word': 'E', 'emoji': '🐘', 'description': 'Elephant'},
        {'word': 'F', 'emoji': '🐟', 'description': 'Fish'},
        {'word': 'G', 'emoji': '🦒', 'description': 'Giraffe'},
        {'word': 'H', 'emoji': '🏠', 'description': 'House'},
      ];
    }
    
    return {
      'title': 'English - Alphabet & Phonics',
      'instructions': instructions,
      'pairs': pairs,
      'metadata': {
        'subject': 'English',
        'chapter': 'Alphabet & Phonics',
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
      {'name': 'Vowels', 'description': 'Vowel letters', 'emoji': '🔤', 'color': 'red'},
      {'name': 'Consonants', 'description': 'Consonant letters', 'emoji': '🔠', 'color': 'blue'},
    ];
    
    if (ageGroup == 4) {
      // Age 4: 5 items with simple instructions
      instructions = 'Sort the letters.';
      difficulty = 'easy';
      items = [
        {'name': 'A', 'category': 'Vowels', 'imageUrl': '', 'emoji': '🅰️'},
        {'name': 'B', 'category': 'Consonants', 'imageUrl': '', 'emoji': '🅱️'},
        {'name': 'C', 'category': 'Consonants', 'imageUrl': '', 'emoji': '©️'},
        {'name': 'E', 'category': 'Vowels', 'imageUrl': '', 'emoji': '🅪'},
        {'name': 'O', 'category': 'Vowels', 'imageUrl': '', 'emoji': '⭕'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 7 items with more detailed instructions
      instructions = 'Sort the letters into the correct categories.';
      difficulty = 'medium';
      items = [
        {'name': 'A', 'category': 'Vowels', 'imageUrl': '', 'emoji': '🅰️'},
        {'name': 'B', 'category': 'Consonants', 'imageUrl': '', 'emoji': '🅱️'},
        {'name': 'C', 'category': 'Consonants', 'imageUrl': '', 'emoji': '©️'},
        {'name': 'D', 'category': 'Consonants', 'imageUrl': '', 'emoji': '🅩'},
        {'name': 'E', 'category': 'Vowels', 'imageUrl': '', 'emoji': '🅪'},
        {'name': 'I', 'category': 'Vowels', 'imageUrl': '', 'emoji': '🅮'},
        {'name': 'O', 'category': 'Vowels', 'imageUrl': '', 'emoji': '⭕'},
      ];
    } else {
      // Age 6: 9 items with complex instructions
      instructions = 'Sort the vowels and consonants into their correct categories.';
      difficulty = 'hard';
      items = [
        {'name': 'A', 'category': 'Vowels', 'imageUrl': '', 'emoji': '🅰️'},
        {'name': 'B', 'category': 'Consonants', 'imageUrl': '', 'emoji': '🅱️'},
        {'name': 'C', 'category': 'Consonants', 'imageUrl': '', 'emoji': '©️'},
        {'name': 'D', 'category': 'Consonants', 'imageUrl': '', 'emoji': '🅩'},
        {'name': 'E', 'category': 'Vowels', 'imageUrl': '', 'emoji': '🅪'},
        {'name': 'F', 'category': 'Consonants', 'imageUrl': '', 'emoji': '🅫'},
        {'name': 'I', 'category': 'Vowels', 'imageUrl': '', 'emoji': '🅮'},
        {'name': 'O', 'category': 'Vowels', 'imageUrl': '', 'emoji': '⭕'},
        {'name': 'U', 'category': 'Vowels', 'imageUrl': '', 'emoji': '🅺'},
      ];
    }
    
    return {
      'title': 'English - Alphabet & Phonics',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'metadata': {
        'subject': 'English',
        'chapter': 'Alphabet & Phonics',
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
      // Age 4: 2 simple letters with basic instructions
      instructions = 'Trace the letters.';
      difficulty = 'easy';
      items = [
        {
          'character': 'A',
          'difficulty': 1,
          'instruction': 'Trace A',
          'emoji': '🍎',
          'word': 'Apple',
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
          'instruction': 'Trace B',
          'emoji': '🍌',
          'word': 'Banana',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.6, 'y': 0.5},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 3 letters with medium complexity
      instructions = 'Trace the letters by following the lines.';
      difficulty = 'medium';
      items = [
        {
          'character': 'A',
          'difficulty': 1,
          'instruction': 'Trace the letter A',
          'emoji': '🍎',
          'word': 'Apple',
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
          'instruction': 'Trace the letter B',
          'emoji': '🍌',
          'word': 'Banana',
          'pathPoints': [
            {'x': 0.3, 'y': 0.2},
            {'x': 0.3, 'y': 0.8},
            {'x': 0.3, 'y': 0.2},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.7, 'y': 0.4},
            {'x': 0.6, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
          ]
        },
        {
          'character': 'C',
          'difficulty': 1,
          'instruction': 'Trace the letter C',
          'emoji': '🐱',
          'word': 'Cat',
          'pathPoints': [
            {'x': 0.7, 'y': 0.3},
            {'x': 0.6, 'y': 0.2},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.4, 'y': 0.3},
            {'x': 0.3, 'y': 0.4},
            {'x': 0.3, 'y': 0.6},
          ]
        },
      ];
    } else {
      // Age 6: 3 letters with higher complexity
      instructions = 'Trace the letters by following the dots carefully.';
      difficulty = 'hard';
      items = [
        {
          'character': 'A',
          'difficulty': 1,
          'instruction': 'Trace the letter A for Apple',
          'emoji': '🍎',
          'word': 'Apple',
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
          'instruction': 'Trace the letter B for Banana',
          'emoji': '🍌',
          'word': 'Banana',
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
          'instruction': 'Trace the letter C for Cat',
          'emoji': '🐱',
          'word': 'Cat',
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
      'title': 'English - Alphabet & Phonics',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'English',
        'chapter': 'Alphabet & Phonics',
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
      instructions = 'Find the shape for each letter.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Circle A'},
        {'shape': 'square', 'color': 'blue', 'name': 'Square B'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Triangle C'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Rectangle D'},
        {'shape': 'star', 'color': 'purple', 'name': 'Star E'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 shapes with more detailed instructions
      instructions = 'Find the shape that represents the letter.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Red Circle A'},
        {'shape': 'square', 'color': 'blue', 'name': 'Blue Square B'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Green Triangle C'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Yellow Rectangle D'},
        {'shape': 'star', 'color': 'purple', 'name': 'Purple Star E'},
        {'shape': 'heart', 'color': 'pink', 'name': 'Pink Heart F'},
      ];
    } else {
      // Age 6: 8 shapes with complex instructions
      instructions = 'Find the shape and color that represents each letter of the alphabet.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Red Circle A'},
        {'shape': 'square', 'color': 'blue', 'name': 'Blue Square B'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Green Triangle C'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Yellow Rectangle D'},
        {'shape': 'star', 'color': 'purple', 'name': 'Purple Star E'},
        {'shape': 'heart', 'color': 'pink', 'name': 'Pink Heart F'},
        {'shape': 'oval', 'color': 'orange', 'name': 'Orange Oval G'},
        {'shape': 'diamond', 'color': 'teal', 'name': 'Teal Diamond H'},
      ];
    }
    
    return {
      'title': 'English - Alphabet & Phonics',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'English',
        'chapter': 'Alphabet & Phonics',
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
