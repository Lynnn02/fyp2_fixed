import 'package:flutter/material.dart';

/// Provides game content for "English - Sight Words" subject
class SightWordsTemplate {
  /// Get matching game content
  static Map<String, dynamic> getMatchingContent(int ageGroup) {
    List<Map<String, dynamic>> pairs = [];
    String instructions = '';
    String difficulty = '';
    
    if (ageGroup == 4) {
      // Age 4: 4 simple sight words with basic instructions
      instructions = 'Match the word with its picture.';
      difficulty = 'easy';
      pairs = [
        {'word': 'the', 'emoji': '👉', 'description': 'Pointing'},
        {'word': 'and', 'emoji': '🔄', 'description': 'Connecting'},
        {'word': 'a', 'emoji': '1️⃣', 'description': 'One'},
        {'word': 'to', 'emoji': '🏁', 'description': 'Going to'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 sight words with medium complexity
      instructions = 'Match the sight word with its corresponding image.';
      difficulty = 'medium';
      pairs = [
        {'word': 'the', 'emoji': '👉', 'description': 'Pointing (the book)'},
        {'word': 'and', 'emoji': '🔄', 'description': 'Connecting things'},
        {'word': 'a', 'emoji': '1️⃣', 'description': 'One of something'},
        {'word': 'to', 'emoji': '🏁', 'description': 'Going towards'},
        {'word': 'is', 'emoji': '✅', 'description': 'Equals sign'},
        {'word': 'you', 'emoji': '👤', 'description': 'Person'},
      ];
    } else {
      // Age 6: 8 sight words with higher complexity
      instructions = 'Match the sight word with its corresponding meaning and image.';
      difficulty = 'hard';
      pairs = [
        {'word': 'the', 'emoji': '👉', 'description': 'Pointing (the book)'},
        {'word': 'and', 'emoji': '🔄', 'description': 'Connecting things'},
        {'word': 'a', 'emoji': '1️⃣', 'description': 'One of something'},
        {'word': 'to', 'emoji': '🏁', 'description': 'Going towards'},
        {'word': 'is', 'emoji': '✅', 'description': 'Equals sign'},
        {'word': 'you', 'emoji': '👤', 'description': 'Person'},
        {'word': 'that', 'emoji': '👇', 'description': 'Pointing at something'},
        {'word': 'it', 'emoji': '🎁', 'description': 'An object'},
      ];
    }
    
    return {
      'title': 'English - Sight Words',
      'instructions': instructions,
      'pairs': pairs,
      'metadata': {
        'subject': 'English',
        'chapter': 'Sight Words',
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
      {'name': 'Action Words', 'description': 'Words that show action', 'emoji': '🏃', 'color': 'green'},
      {'name': 'Describing Words', 'description': 'Words that describe things', 'emoji': '🎨', 'color': 'purple'},
    ];
    
    if (ageGroup == 4) {
      // Age 4: 4 items with simple instructions and 2 categories
      instructions = 'Sort the words.';
      difficulty = 'easy';
      items = [
        {'name': 'run', 'category': 'Action Words', 'imageUrl': '', 'emoji': '🏃'},
        {'name': 'big', 'category': 'Describing Words', 'imageUrl': '', 'emoji': '📏'},
        {'name': 'jump', 'category': 'Action Words', 'imageUrl': '', 'emoji': '⬆️'},
        {'name': 'small', 'category': 'Describing Words', 'imageUrl': '', 'emoji': '🔍'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 items with more detailed instructions and 2 categories
      instructions = 'Sort the sight words into the correct categories.';
      difficulty = 'medium';
      items = [
        {'name': 'run', 'category': 'Action Words', 'imageUrl': '', 'emoji': '🏃'},
        {'name': 'big', 'category': 'Describing Words', 'imageUrl': '', 'emoji': '📏'},
        {'name': 'jump', 'category': 'Action Words', 'imageUrl': '', 'emoji': '⬆️'},
        {'name': 'small', 'category': 'Describing Words', 'imageUrl': '', 'emoji': '🔍'},
        {'name': 'eat', 'category': 'Action Words', 'imageUrl': '', 'emoji': '🍽️'},
        {'name': 'happy', 'category': 'Describing Words', 'imageUrl': '', 'emoji': '😊'},
      ];
    } else {
      // Age 6: 9 items with complex instructions and 3 categories
      instructions = 'Sort the sight words into action, describing, and connecting categories.';
      difficulty = 'hard';
      // Add the third category for age 6
      categories.add({'name': 'Connecting Words', 'description': 'Words that connect ideas', 'emoji': '🔄', 'color': 'blue'});
      items = [
        {'name': 'run', 'category': 'Action Words', 'imageUrl': '', 'emoji': '🏃'},
        {'name': 'big', 'category': 'Describing Words', 'imageUrl': '', 'emoji': '📏'},
        {'name': 'and', 'category': 'Connecting Words', 'imageUrl': '', 'emoji': '🔄'},
        {'name': 'jump', 'category': 'Action Words', 'imageUrl': '', 'emoji': '⬆️'},
        {'name': 'small', 'category': 'Describing Words', 'imageUrl': '', 'emoji': '🔍'},
        {'name': 'but', 'category': 'Connecting Words', 'imageUrl': '', 'emoji': '⚖️'},
        {'name': 'eat', 'category': 'Action Words', 'imageUrl': '', 'emoji': '🍽️'},
        {'name': 'happy', 'category': 'Describing Words', 'imageUrl': '', 'emoji': '😊'},
        {'name': 'or', 'category': 'Connecting Words', 'imageUrl': '', 'emoji': '🔀'},
      ];
    }
    
    return {
      'title': 'English - Sight Words',
      'instructions': instructions,
      'categories': categories,
      'items': items,
      'metadata': {
        'subject': 'English',
        'chapter': 'Sight Words',
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
      // Age 4: 2 simple sight words with basic instructions
      instructions = 'Trace the words.';
      difficulty = 'easy';
      items = [
        {
          'content': 'the',
          'difficulty': 1,
          'instruction': 'Trace "the"',
          'emoji': '👉',
          'pathPoints': [
            {'x': 0.1, 'y': 0.3},
            {'x': 0.1, 'y': 0.7},
            {'x': 0.1, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
          ]
        },
        {
          'content': 'a',
          'difficulty': 1,
          'instruction': 'Trace "a"',
          'emoji': '1️⃣',
          'pathPoints': [
            {'x': 0.3, 'y': 0.3},
            {'x': 0.5, 'y': 0.2},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.5, 'y': 0.6},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
          ]
        },
      ];
    } else if (ageGroup == 5) {
      // Age 5: 3 sight words with medium complexity
      instructions = 'Trace the sight words by following the lines.';
      difficulty = 'medium';
      items = [
        {
          'content': 'the',
          'difficulty': 1,
          'instruction': 'Trace the word "the"',
          'emoji': '👉',
          'pathPoints': [
            {'x': 0.1, 'y': 0.3},
            {'x': 0.1, 'y': 0.7},
            {'x': 0.1, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
          ]
        },
        {
          'content': 'and',
          'difficulty': 2,
          'instruction': 'Trace the word "and"',
          'emoji': '🔄',
          'pathPoints': [
            {'x': 0.1, 'y': 0.7},
            {'x': 0.1, 'y': 0.3},
            {'x': 0.1, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
          ]
        },
        {
          'content': 'to',
          'difficulty': 1,
          'instruction': 'Trace the word "to"',
          'emoji': '🏁',
          'pathPoints': [
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.5, 'y': 0.5},
          ]
        },
      ];
    } else {
      // Age 6: 3 sight words with higher complexity
      instructions = 'Trace the sight words by following the dots carefully.';
      difficulty = 'hard';
      items = [
        {
          'content': 'the',
          'difficulty': 1,
          'instruction': 'Trace the word "the"',
          'emoji': '👉',
          'pathPoints': [
            {'x': 0.1, 'y': 0.3},
            {'x': 0.1, 'y': 0.7},
            {'x': 0.1, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
            {'x': 0.7, 'y': 0.5},
            {'x': 0.9, 'y': 0.5},
          ]
        },
        {
          'content': 'and',
          'difficulty': 2,
          'instruction': 'Trace the word "and"',
          'emoji': '🔄',
          'pathPoints': [
            {'x': 0.1, 'y': 0.7},
            {'x': 0.1, 'y': 0.3},
            {'x': 0.1, 'y': 0.5},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.3, 'y': 0.3},
            {'x': 0.3, 'y': 0.7},
            {'x': 0.5, 'y': 0.3},
            {'x': 0.5, 'y': 0.7},
            {'x': 0.5, 'y': 0.5},
            {'x': 0.7, 'y': 0.3},
            {'x': 0.7, 'y': 0.7},
          ]
        },
        {
          'content': 'you',
          'difficulty': 2,
          'instruction': 'Trace the word "you"',
          'emoji': '👤',
          'pathPoints': [
            {'x': 0.2, 'y': 0.3},
            {'x': 0.3, 'y': 0.5},
            {'x': 0.4, 'y': 0.7},
            {'x': 0.6, 'y': 0.3},
            {'x': 0.6, 'y': 0.7},
            {'x': 0.8, 'y': 0.3},
            {'x': 0.8, 'y': 0.5},
            {'x': 0.8, 'y': 0.7},
          ]
        },
      ];
    }
    
    return {
      'title': 'English - Sight Words',
      'instructions': instructions,
      'items': items,
      'metadata': {
        'subject': 'English',
        'chapter': 'Sight Words',
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
      // Age 4: 4 simple shapes with basic instructions
      instructions = 'Find the shape for each word.';
      difficulty = 'easy';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Circle "the"'},
        {'shape': 'square', 'color': 'blue', 'name': 'Square "and"'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Triangle "a"'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Rectangle "to"'},
      ];
    } else if (ageGroup == 5) {
      // Age 5: 6 shapes with more detailed instructions
      instructions = 'Find the shape that represents the sight word.';
      difficulty = 'medium';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Red Circle "the"'},
        {'shape': 'square', 'color': 'blue', 'name': 'Blue Square "and"'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Green Triangle "a"'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Yellow Rectangle "to"'},
        {'shape': 'star', 'color': 'purple', 'name': 'Purple Star "is"'},
        {'shape': 'heart', 'color': 'pink', 'name': 'Pink Heart "you"'},
      ];
    } else {
      // Age 6: 8 shapes with complex instructions
      instructions = 'Find the shape and color that represents each sight word.';
      difficulty = 'hard';
      shapes = [
        {'shape': 'circle', 'color': 'red', 'name': 'Red Circle "the"'},
        {'shape': 'square', 'color': 'blue', 'name': 'Blue Square "and"'},
        {'shape': 'triangle', 'color': 'green', 'name': 'Green Triangle "a"'},
        {'shape': 'rectangle', 'color': 'yellow', 'name': 'Yellow Rectangle "to"'},
        {'shape': 'star', 'color': 'purple', 'name': 'Purple Star "is"'},
        {'shape': 'heart', 'color': 'pink', 'name': 'Pink Heart "you"'},
        {'shape': 'oval', 'color': 'orange', 'name': 'Orange Oval "that"'},
        {'shape': 'diamond', 'color': 'teal', 'name': 'Teal Diamond "it"'},
      ];
    }
    
    return {
      'title': 'English - Sight Words',
      'instructions': instructions,
      'shapes': shapes,
      'rounds': rounds,
      'metadata': {
        'subject': 'English',
        'chapter': 'Sight Words',
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
