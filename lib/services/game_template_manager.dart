import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../models/score.dart';

class GameTemplateManager {
  final GeminiService _geminiService = GeminiService();
  
  // Game difficulty configurations by age
  final Map<int, GameDifficultyConfig> _difficultyConfigs = {
    4: GameDifficultyConfig(
      rounds: 5,
      fontSize: 24.0,
      itemSize: 120.0,
      feedbackDuration: 2000,
      optionsCount: 2,
      imageTextRatio: 0.7, // 70% images, 30% text
      soundEffectsVolume: 1.0,
      animationSpeed: 0.7, // Slower animations
      pointsPerCorrectAnswer: 10,
    ),
    5: GameDifficultyConfig(
      rounds: 7,
      fontSize: 20.0,
      itemSize: 100.0,
      feedbackDuration: 1500,
      optionsCount: 3,
      imageTextRatio: 0.5, // 50% images, 50% text
      soundEffectsVolume: 0.8,
      animationSpeed: 1.0, // Normal animations
      pointsPerCorrectAnswer: 8,
    ),
    6: GameDifficultyConfig(
      rounds: 10,
      fontSize: 18.0,
      itemSize: 80.0,
      feedbackDuration: 1000,
      optionsCount: 4,
      imageTextRatio: 0.4, // 40% images, 60% text
      soundEffectsVolume: 0.7,
      animationSpeed: 1.2, // Faster animations
      pointsPerCorrectAnswer: 5,
    ),
  };
  
  // Get difficulty configuration for a specific age
  GameDifficultyConfig getDifficultyConfig(int age) {
    // Default to age 4 config if age not found
    return _difficultyConfigs[age] ?? _difficultyConfigs[4]!;
  }
  
  // Generate game content based on template type, subject, chapter, and age
  Future<Map<String, dynamic>> generateGameContent({
    required String templateType,
    required String subjectName,
    required String chapterName,
    required int ageGroup,
  }) async {
    // Get the appropriate prompt based on template type
    final prompt = _getPromptForTemplate(
      templateType: templateType,
      subjectName: subjectName,
      chapterName: chapterName,
      ageGroup: ageGroup,
    );
    
    try {
      // Generate content using Gemini
      final response = await _geminiService.generateContent(prompt);
      
      // Parse the response and extract JSON content
      final jsonContent = _extractJsonFromResponse(response);
      
      if (jsonContent != null) {
        // Add metadata to the content
        jsonContent['metadata'] = {
          'templateType': templateType,
          'subjectName': subjectName,
          'chapterName': chapterName,
          'ageGroup': ageGroup,
          'generatedAt': DateTime.now().toIso8601String(),
        };
        
        return jsonContent;
      } else {
        // Return fallback content if JSON parsing fails
        return _getFallbackContent(templateType, subjectName, ageGroup);
      }
    } catch (e) {
      print('Error generating game content: $e');
      return _getFallbackContent(templateType, subjectName, ageGroup);
    }
  }
  
  // Extract JSON from Gemini response
  Map<String, dynamic>? _extractJsonFromResponse(String response) {
    try {
      // Look for JSON content between markers or try to parse the whole response
      if (response.contains('{') && response.contains('}')) {
        final jsonStart = response.indexOf('{');
        final jsonEnd = response.lastIndexOf('}') + 1;
        final jsonString = response.substring(jsonStart, jsonEnd);
        
        return json.decode(jsonString);
      } else if (response.contains('[') && response.contains(']')) {
        final jsonStart = response.indexOf('[');
        final jsonEnd = response.lastIndexOf(']') + 1;
        final jsonString = response.substring(jsonStart, jsonEnd);
        
        // Wrap array in an object
        return {'items': json.decode(jsonString)};
      }
    } catch (e) {
      print('Error parsing JSON from response: $e');
    }
    
    return null;
  }
  
  // Get the appropriate prompt for each template type
  String _getPromptForTemplate({
    required String templateType,
    required String subjectName,
    required String chapterName,
    required int ageGroup,
  }) {
    final config = getDifficultyConfig(ageGroup);
    
    switch (templateType) {
      case 'matching':
        return '''
        Create educational content for a matching game for ${ageGroup}-year-old children 
        studying ${subjectName}, chapter: ${chapterName}.
        
        Generate ${config.rounds} pairs of matching items that relate to this subject.
        For each pair, provide:
        1. A word or concept from the subject
        2. An emoji that represents this word/concept
        
        Format as JSON with this structure:
        {
          "pairs": [
            {
              "word": "Example Word",
              "emoji": "🔍"
            },
            ...more pairs...
          ]
        }
        ''';
        
      case 'picture_recognition':
        return '''
        Create educational content for a picture recognition game for ${ageGroup}-year-old children 
        studying ${subjectName}, chapter: ${chapterName}.
        
        Generate ${config.rounds} items that relate to this subject.
        For each item, provide:
        1. A name of a concept from the subject
        2. An emoji representing the concept
        3. 3-${config.optionsCount} options for answers (including the correct one)
        
        Format as JSON with this structure:
        {
          "items": [
            {
              "name": "Example Name",
              "emoji": "🔍",
              "options": ["Example Name", "Wrong Option 1", "Wrong Option 2"]
            },
            ...more items...
          ]
        }
        ''';
        
      case 'shape_color':
        return '''
        Create educational content for a shape and color game for ${ageGroup}-year-old children 
        studying ${subjectName}, chapter: ${chapterName}.
        
        Generate ${config.rounds} items that relate to this subject.
        For each item, provide:
        1. A shape name (choose from: circle, square, triangle, star, heart, rectangle, oval, pentagon, hexagon, diamond)
        2. A color name (choose from: red, blue, green, yellow, purple, orange, pink, teal, brown, indigo)
        3. A descriptive name that relates to the subject
        
        Format as JSON with this structure:
        {
          "shapes": [
            {
              "shape": "circle",
              "color": "red",
              "name": "Red Math Circle"
            },
            ...more shapes...
          ]
        }
        ''';
        
      case 'animal_sounds':
        return '''
        Create educational content for an animal sounds game for ${ageGroup}-year-old children 
        studying ${subjectName}, chapter: ${chapterName}.
        
        Generate ${config.rounds} items that relate to this subject.
        For each item, provide:
        1. A descriptive animal name that relates to the subject (e.g., "Counting Elephant" for math)
        2. An emoji representing the animal
        3. A sound the animal makes (written as text)
        4. ${config.optionsCount} options for what sound the animal makes (including the correct one)
        
        Format as JSON with this structure:
        {
          "animals": [
            {
              "name": "Counting Elephant",
              "emoji": "🐘",
              "sound": "One, two, three!",
              "options": ["One, two, three!", "Quack quack", "Roar!"]
            },
            ...more animals...
          ]
        }
        ''';
        
      default:
        return '''
        Create educational content for a game for ${ageGroup}-year-old children 
        studying ${subjectName}, chapter: ${chapterName}.
        
        Generate ${config.rounds} items that relate to this subject.
        For each item, provide:
        1. A name or concept from the subject
        2. An emoji representing the concept
        3. A brief description suitable for ${ageGroup}-year-olds
        
        Format as JSON.
        ''';
    }
  }
  
  // Get fallback content if generation fails
  Map<String, dynamic> _getFallbackContent(String templateType, String subjectName, int ageGroup) {
    final config = getDifficultyConfig(ageGroup);
    String subjectPrefix = '';
    
    // Try to make fallback content somewhat relevant to the subject
    if (subjectName.toLowerCase().contains('math')) {
      subjectPrefix = 'Math ';
    } else if (subjectName.toLowerCase().contains('science')) {
      subjectPrefix = 'Science ';
    } else if (subjectName.toLowerCase().contains('english')) {
      subjectPrefix = 'English ';
    }
    
    switch (templateType) {
      case 'matching':
        return {
          'pairs': [
            {'word': '${subjectPrefix}Apple', 'emoji': '🍎'},
            {'word': '${subjectPrefix}Banana', 'emoji': '🍌'},
            {'word': '${subjectPrefix}Cat', 'emoji': '🐱'},
            {'word': '${subjectPrefix}Dog', 'emoji': '🐶'},
            {'word': '${subjectPrefix}Elephant', 'emoji': '🐘'},
          ],
          'metadata': {
            'templateType': templateType,
            'subjectName': subjectName,
            'ageGroup': ageGroup,
            'isFallback': true,
          }
        };
        
      case 'picture_recognition':
        return {
          'items': [
            {
              'name': '${subjectPrefix}Dog',
              'emoji': '🐶',
              'options': ['Dog', 'Cat', 'Bird']
            },
            {
              'name': '${subjectPrefix}Cat',
              'emoji': '🐱',
              'options': ['Cat', 'Dog', 'Fish']
            },
            {
              'name': '${subjectPrefix}Apple',
              'emoji': '🍎',
              'options': ['Apple', 'Banana', 'Orange']
            },
            {
              'name': '${subjectPrefix}Banana',
              'emoji': '🍌',
              'options': ['Banana', 'Apple', 'Grapes']
            },
            {
              'name': '${subjectPrefix}Star',
              'emoji': '⭐',
              'options': ['Star', 'Moon', 'Sun']
            },
          ],
          'metadata': {
            'templateType': templateType,
            'subjectName': subjectName,
            'ageGroup': ageGroup,
            'isFallback': true,
          }
        };
        
      case 'shape_color':
        return {
          'shapes': [
            {'shape': 'circle', 'color': 'red', 'name': '${subjectPrefix}Red Circle'},
            {'shape': 'square', 'color': 'blue', 'name': '${subjectPrefix}Blue Square'},
            {'shape': 'triangle', 'color': 'green', 'name': '${subjectPrefix}Green Triangle'},
            {'shape': 'star', 'color': 'yellow', 'name': '${subjectPrefix}Yellow Star'},
            {'shape': 'heart', 'color': 'purple', 'name': '${subjectPrefix}Purple Heart'},
          ],
          'metadata': {
            'templateType': templateType,
            'subjectName': subjectName,
            'ageGroup': ageGroup,
            'isFallback': true,
          }
        };
        
      case 'animal_sounds':
        return {
          'animals': [
            {
              'name': '${subjectPrefix}Dog',
              'emoji': '🐶',
              'sound': 'Woof woof',
              'options': ['Woof woof', 'Meow', 'Quack']
            },
            {
              'name': '${subjectPrefix}Cat',
              'emoji': '🐱',
              'sound': 'Meow',
              'options': ['Meow', 'Woof woof', 'Moo']
            },
            {
              'name': '${subjectPrefix}Cow',
              'emoji': '🐄',
              'sound': 'Moo',
              'options': ['Moo', 'Quack', 'Neigh']
            },
            {
              'name': '${subjectPrefix}Duck',
              'emoji': '🦆',
              'sound': 'Quack',
              'options': ['Quack', 'Moo', 'Woof woof']
            },
            {
              'name': '${subjectPrefix}Horse',
              'emoji': '🐴',
              'sound': 'Neigh',
              'options': ['Neigh', 'Meow', 'Quack']
            },
          ],
          'metadata': {
            'templateType': templateType,
            'subjectName': subjectName,
            'ageGroup': ageGroup,
            'isFallback': true,
          }
        };
        
      default:
        return {
          'items': [
            {'name': '${subjectPrefix}Item 1', 'emoji': '🔍', 'description': 'Basic item 1'},
            {'name': '${subjectPrefix}Item 2', 'emoji': '📚', 'description': 'Basic item 2'},
            {'name': '${subjectPrefix}Item 3', 'emoji': '🎯', 'description': 'Basic item 3'},
            {'name': '${subjectPrefix}Item 4', 'emoji': '🧩', 'description': 'Basic item 4'},
            {'name': '${subjectPrefix}Item 5', 'emoji': '🎨', 'description': 'Basic item 5'},
          ],
          'metadata': {
            'templateType': templateType,
            'subjectName': subjectName,
            'ageGroup': ageGroup,
            'isFallback': true,
          }
        };
    }
  }
  
  // Get available game templates
  List<GameTemplateInfo> getAvailableTemplates(int ageGroup) {
    return [
      GameTemplateInfo(
        id: 'matching',
        name: 'Matching Game',
        description: _getTemplateDescription('matching', ageGroup),
        icon: Icons.extension,
        color: Colors.blue,
        ageGroup: ageGroup,
      ),
      GameTemplateInfo(
        id: 'picture_recognition',
        name: 'Picture Recognition',
        description: _getTemplateDescription('picture_recognition', ageGroup),
        icon: Icons.image,
        color: Colors.purple,
        ageGroup: ageGroup,
      ),
      GameTemplateInfo(
        id: 'shape_color',
        name: 'Shapes & Colors',
        description: _getTemplateDescription('shape_color', ageGroup),
        icon: Icons.category,
        color: Colors.teal,
        ageGroup: ageGroup,
      ),
      GameTemplateInfo(
        id: 'animal_sounds',
        name: 'Animal Sounds',
        description: _getTemplateDescription('animal_sounds', ageGroup),
        icon: Icons.pets,
        color: Colors.orange,
        ageGroup: ageGroup,
      ),
    ];
  }
  
  // Get age-appropriate template descriptions
  String _getTemplateDescription(String templateType, int ageGroup) {
    switch (templateType) {
      case 'matching':
        if (ageGroup == 4) {
          return 'Match pictures with words in a fun and colorful game!';
        } else if (ageGroup == 5) {
          return 'Match related items to build vocabulary and recognition skills.';
        } else {
          return 'Challenge memory and comprehension by matching related concepts.';
        }
        
      case 'picture_recognition':
        if (ageGroup == 4) {
          return 'Look at pictures and pick the right name!';
        } else if (ageGroup == 5) {
          return 'Identify pictures and select the correct name from options.';
        } else {
          return 'Test knowledge by identifying pictures and selecting the correct term.';
        }
        
      case 'shape_color':
        if (ageGroup == 4) {
          return 'Learn shapes and colors with big, bright pictures!';
        } else if (ageGroup == 5) {
          return 'Identify shapes and colors while learning subject vocabulary.';
        } else {
          return 'Connect shapes and colors to subject concepts for deeper learning.';
        }
        
      case 'animal_sounds':
        if (ageGroup == 4) {
          return 'Listen to animal sounds and guess the animal!';
        } else if (ageGroup == 5) {
          return 'Match animals with their sounds while learning subject concepts.';
        } else {
          return 'Connect animal themes to subject material through sound recognition.';
        }
        
      default:
        return 'A fun educational game for learning!';
    }
  }
  
  // Calculate points based on game performance and age
  int calculateGamePoints({
    required String gameType,
    required int correctAnswers,
    required int totalQuestions,
    required int ageGroup,
    required int timeSpentSeconds,
  }) {
    final config = getDifficultyConfig(ageGroup);
    
    // Base points for correct answers
    int points = correctAnswers * config.pointsPerCorrectAnswer;
    
    // Bonus for completing all questions
    if (correctAnswers == totalQuestions) {
      points += 10;
    }
    
    // Time efficiency bonus (if applicable)
    if (timeSpentSeconds > 0 && gameType != 'animal_sounds') {
      // Average time per question
      final avgTimePerQuestion = timeSpentSeconds / totalQuestions;
      
      // Bonus for quick responses (adjusted by age)
      if (avgTimePerQuestion < (7 - ageGroup)) {
        points += 5;
      }
    }
    
    return points;
  }
}

// Configuration class for age-specific game settings
class GameDifficultyConfig {
  final int rounds;
  final double fontSize;
  final double itemSize;
  final double feedbackDuration;
  final int optionsCount;
  final double imageTextRatio;
  final double soundEffectsVolume;
  final double animationSpeed;
  final int pointsPerCorrectAnswer;
  
  GameDifficultyConfig({
    required this.rounds,
    required this.fontSize,
    required this.itemSize,
    required this.feedbackDuration,
    required this.optionsCount,
    required this.imageTextRatio,
    required this.soundEffectsVolume,
    required this.animationSpeed,
    required this.pointsPerCorrectAnswer,
  });
}

// Class to represent game template information for selection screens
class GameTemplateInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int ageGroup;
  
  GameTemplateInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.ageGroup,
  });
}
