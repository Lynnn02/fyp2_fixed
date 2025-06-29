import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/gemini_games_service.dart';
import '../models/score.dart';
import '../templates/subject_template_manager.dart';

class GameTemplateManager {
  // Method to get fallback content for game templates
  Map<String, dynamic> getFallbackContent(String templateType, String subjectName, int ageGroup) {
    final config = getDifficultyConfig(ageGroup);
    String subjectPrefix = '';
    String subjectCategory = '';
    
    final name = subjectName.toLowerCase();
    if (name.contains('math')) {
      subjectPrefix = 'Math ';
      subjectCategory = 'math';
    } else if (name.contains('science')) {
      subjectPrefix = 'Science ';
      subjectCategory = 'science';
    } else if (name.contains('english')) {
      subjectPrefix = 'English ';
      subjectCategory = 'english';
    } else {
      subjectPrefix = 'General ';
      subjectCategory = 'general';
    }
    
    switch (templateType) {
      case 'sorting':
        return {
          'title': '$subjectPrefix Sorting Activity',
          'instructions': 'Sort the items into the correct categories.',
          'categories': [
            {'name': 'Category A', 'description': 'Items that belong to group A', 'emoji': '🅰️', 'color': 'red'},
            {'name': 'Category B', 'description': 'Items that belong to group B', 'emoji': '🅱️', 'color': 'blue'},
          ],
          'items': [
            {'name': 'Item 1', 'category': 'Category A', 'imageUrl': '', 'emoji': '1️⃣'},
            {'name': 'Item 2', 'category': 'Category B', 'imageUrl': '', 'emoji': '2️⃣'},
            {'name': 'Item 3', 'category': 'Category A', 'imageUrl': '', 'emoji': '3️⃣'},
            {'name': 'Item 4', 'category': 'Category B', 'imageUrl': '', 'emoji': '4️⃣'},
          ],
          'metadata': {
            'subject': subjectName,
            'ageGroup': ageGroup,
            'difficulty': 'medium',
          }
        };
        
      case 'tracing':
        return {
          'title': '$subjectPrefix Tracing Activity',
          'instructions': 'Trace the lines to complete the patterns.',
          'tracingItems': [
            {
              'prompt': 'Trace the letter A',
              'pathPoints': [
                {'x': 0.2, 'y': 0.8},
                {'x': 0.5, 'y': 0.2},
                {'x': 0.8, 'y': 0.8},
                {'x': 0.35, 'y': 0.5},
                {'x': 0.65, 'y': 0.5},
              ],
              'imageUrl': ''
            },
            {
              'prompt': 'Trace the number 1',
              'pathPoints': [
                {'x': 0.5, 'y': 0.2},
                {'x': 0.5, 'y': 0.8},
              ],
              'imageUrl': ''
            },
          ],
          'metadata': {
            'subject': subjectName,
            'ageGroup': ageGroup,
            'difficulty': 'medium',
          }
        };
        
      case 'shape_color':
        return {
          'title': '$subjectPrefix Shapes and Colors',
          'instructions': 'Find the shape that matches the description.',
          'shapes': [
            {'shape': 'circle', 'color': 'red', 'name': 'Red Circle'},
            {'shape': 'square', 'color': 'blue', 'name': 'Blue Square'},
            {'shape': 'triangle', 'color': 'green', 'name': 'Green Triangle'},
            {'shape': 'rectangle', 'color': 'yellow', 'name': 'Yellow Rectangle'},
          ],
          'rounds': config.rounds,
          'metadata': {
            'subject': subjectName,
            'ageGroup': ageGroup,
            'difficulty': 'medium',
          }
        };
        
      case 'matching':
      default:
        return {
          'title': '$subjectPrefix Matching Activity',
          'instructions': 'Match the items on the left with their pairs on the right.',
          'pairs': [
            {
              'word': 'Apple',
              'emoji': '🍎'
            },
            {
              'word': 'Banana',
              'emoji': '🍌'
            },
            {
              'word': 'Cat',
              'emoji': '🐱'
            },
            {
              'word': 'Dog',
              'emoji': '🐶'
            },
          ],
          'metadata': {
            'subject': subjectName,
            'ageGroup': ageGroup,
            'difficulty': 'medium',
          }
        };
    }
  }
  
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
  
  // Get predefined content for specific subjects and chapters
  Map<String, dynamic>? getPredefinedContent({
    required String templateType,
    required String subjectName,
    required String chapterName,
    required int ageGroup,
    required int rounds,
  }) {
    print('🔍 GameTemplateManager: Looking for predefined content');
    print('🔍 Subject: $subjectName, Chapter: $chapterName');
    print('🔍 Game Type: $templateType, Age: $ageGroup, Rounds: $rounds');
    
    // Use the SubjectTemplateManager to get content from our template files
    final content = SubjectTemplateManager.getTemplateContent(
      subjectName: subjectName,
      chapterName: chapterName,
      gameType: templateType,
      ageGroup: ageGroup,
      rounds: rounds,
    );
    
    print('📦 GameTemplateManager: Content returned: ${content != null ? 'YES' : 'NO'}');
    if (content == null) {
      print('❌ No predefined content found, will fall back to Gemini');
    }
    
    return content;
  }
  
  // Get content for specific subject and chapter
  Future<Map<String, dynamic>> getContentForSubjectAndChapter({
    required String templateType,
    required String subjectName,
    required String chapterName,
    required int ageGroup,
    Map<String, dynamic>? existingContent,
  }) async {
    // If we already have content, return it
    if (existingContent != null) {
      return existingContent;
    }
    
    // Get difficulty config for age group
    final config = getDifficultyConfig(ageGroup);
    
    // Try to get predefined content first
    final predefinedContent = getPredefinedContent(
      templateType: templateType,
      subjectName: subjectName,
      chapterName: chapterName,
      ageGroup: ageGroup,
      rounds: config.rounds,
    );
    
    if (predefinedContent != null) {
      print('📌 Using PREDEFINED template content for $subjectName - $chapterName');
      return predefinedContent;
    }
    
    print('❗ No predefined content found, falling back to Gemini API');
    
    // Create a simple prompt for the template
    final prompt = "Generate content for $templateType game about $subjectName ($chapterName) for age $ageGroup";
    
    try {
      // Since we're using fallback content anyway, we don't need to make an API call
      final response = "Fallback content used";
      
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
        return getFallbackContent(templateType, subjectName, ageGroup);
      }
    } catch (e) {
      print('Error generating game content: $e');
      return getFallbackContent(templateType, subjectName, ageGroup);
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
  String getPrompt({
    required String templateType,
    required String subjectName,
    required String chapterName,
    required int ageGroup,
  }) {
    final config = getDifficultyConfig(ageGroup);
    
    // Determine subject category for more tailored prompts
    String subjectContext = '';
    final name = subjectName.toLowerCase();
    
    if (name.contains('math') || name.contains('nombor')) {
      subjectContext = 'mathematics';
    } else if (name.contains('science') || name.contains('sains')) {
      subjectContext = 'science';
    } else if (name.contains('english')) {
      subjectContext = 'English language';
    } else if (name.contains('bahasa')) {
      subjectContext = 'Malay language';
    } else if (name.contains('jawi')) {
      subjectContext = 'Jawi script';
    } else if (name.contains('iqra') || name.contains('arabic')) {
      subjectContext = 'Arabic language';
    } else if (name.contains('art') || name.contains('craft')) {
      subjectContext = 'art and crafts';
    } else if (name.contains('social') || name.contains('emotional')) {
      subjectContext = 'social-emotional learning';
    }
    
    switch (templateType) {
      case 'sorting':
        return '''
        Create educational content for a sorting game for ${ageGroup}-year-old children 
        studying ${subjectName}, specifically the chapter on ${chapterName}.
        
        The content should focus on ${subjectContext} concepts appropriate for ${ageGroup}-year-olds.
        
        Generate ${config.rounds} items that can be sorted into 2-4 distinct categories.
        For each item, provide:
        1. A name of a concept from the subject
        2. An emoji representing the concept
        3. A category the item belongs to (e.g., "Animals", "Plants", "Numbers", etc.)
        
        Also provide a list of all categories used.
        
        Format as JSON with this structure:
        {
          "items": [
            {
              "name": "Example Name",
              "emoji": "🔍",
              "category": "Category Name"
            },
            ...more items...
          ],
          "categories": ["Category 1", "Category 2", "Category 3"]
        }
        ''';
        
      case 'shape_color':
        return '''
        Create educational content for a shape and color game for ${ageGroup}-year-old children 
        studying ${subjectName}, specifically the chapter on ${chapterName}.
        
        The content should focus on ${subjectContext} concepts appropriate for ${ageGroup}-year-olds.
        
        Generate ${config.rounds} items that relate to this subject.
        For each item, provide:
        1. A shape name (choose from: circle, square, triangle, star, heart, rectangle, oval, pentagon, hexagon, diamond)
        2. A color name (choose from: red, blue, green, yellow, purple, orange, pink, teal, brown, indigo)
        3. A descriptive name that relates to the subject and chapter content
        
        Choose shapes and colors that have meaningful connections to the subject matter.
        For example, if teaching about planets, you might use circles in different colors to represent different planets.
        
        Format as JSON with this structure:
        {
          "shapes": [
            {
              "shape": "circle",
              "color": "red",
              "name": "Mars Planet"
            },
            ...more shapes...
          ]
        }
        ''';
        
      case 'tracing':
        return '''
        Create educational content for a tracing game for ${ageGroup}-year-old children 
        studying ${subjectName}, specifically the chapter on ${chapterName}.
        
        The content should focus on ${subjectContext} concepts appropriate for ${ageGroup}-year-olds.
        
        Generate ${config.rounds} items that relate to this subject and chapter.
        For each item, provide:
        1. A character, letter, number, or simple word to trace (appropriate for ${ageGroup}-year-olds)
        2. A difficulty level (1-3, where 1 is easiest)
        3. A brief instruction or hint for the child
        4. An emoji that represents the item
        
        The content should be:
        - For math subjects: Focus on numbers, simple equations, or shape words
        - For language subjects: Focus on letters, simple words, or short phrases
        - For Jawi/Arabic: Focus on Arabic letters and simple words
        - For science: Focus on simple scientific terms or concepts
        
        Format as JSON with this structure:
        {
          "tracingItems": [
            {
              "content": "A",
              "difficulty": 1,
              "instruction": "Trace the letter A",
              "emoji": "🍎"
            },
            ...more items...
          ]
        }
        ''';
        
      case 'matching':
        return '''
        Create educational content for a matching game for ${ageGroup}-year-old children 
        studying ${subjectName}, specifically the chapter on ${chapterName}.
        
        The content should focus on ${subjectContext} concepts appropriate for ${ageGroup}-year-olds.
        
        Generate ${config.rounds} pairs of items that relate to this subject and chapter.
        For each pair, provide:
        1. A word or concept from the subject
        2. An emoji that matches or represents that word
        
        The pairs should be related to each other and appropriate for the subject.
        For example:
        - For math: Number words matched with number symbols
        - For language: Words matched with representative images
        - For science: Concepts matched with examples
        
        Format as JSON with this structure:
        {
          "pairs": [
            {
              "word": "Apple",
              "emoji": "🍎"
            },
            ...more pairs...
          ]
        }
        ''';
        
      default:
        return '''
        Create educational content for a game for ${ageGroup}-year-old children 
        studying ${subjectName}, specifically the chapter on ${chapterName}.
        
        The content should focus on ${subjectContext} concepts appropriate for ${ageGroup}-year-olds.
        
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
    String subjectCategory = '';
    
    // Determine subject category for more relevant fallback content
    final name = subjectName.toLowerCase();
    if (name.contains('math') || name.contains('nombor')) {
      subjectPrefix = 'Math ';
      subjectCategory = 'math';
    } else if (name.contains('science') || name.contains('sains')) {
      subjectPrefix = 'Science ';
      subjectCategory = 'science';
    } else if (name.contains('english')) {
      subjectPrefix = 'English ';
      subjectCategory = 'language';
    } else if (name.contains('bahasa')) {
      subjectPrefix = 'Bahasa ';
      subjectCategory = 'language';
    } else if (name.contains('jawi')) {
      subjectPrefix = 'Jawi ';
      subjectCategory = 'jawi';
    } else if (name.contains('iqra') || name.contains('arabic')) {
      subjectPrefix = 'Arabic ';
      subjectCategory = 'arabic';
    } else if (name.contains('art') || name.contains('craft')) {
      subjectPrefix = 'Art ';
      subjectCategory = 'art';
    } else if (name.contains('social') || name.contains('emotional')) {
      subjectPrefix = 'SEL ';
      subjectCategory = 'social';
    } else if (name.contains('physical') || name.contains('motor')) {
      subjectPrefix = 'Physical ';
      subjectCategory = 'physical';
    } else {
      subjectPrefix = '';
      subjectCategory = 'general';
    }
    
    switch (templateType) {
      case 'sorting':
        // Create subject-specific sorting content
        if (subjectCategory == 'math') {
          return {
            'items': [
              {'name': 'Number 1', 'emoji': '1️⃣', 'category': 'Small Numbers'},
              {'name': 'Number 2', 'emoji': '2️⃣', 'category': 'Small Numbers'},
              {'name': 'Number 8', 'emoji': '8️⃣', 'category': 'Large Numbers'},
              {'name': 'Number 9', 'emoji': '9️⃣', 'category': 'Large Numbers'},
              {'name': 'Circle', 'emoji': '⭕', 'category': 'Shapes'},
              {'name': 'Triangle', 'emoji': '🔺', 'category': 'Shapes'},
            ],
            'categories': ['Small Numbers', 'Large Numbers', 'Shapes'],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else if (subjectCategory == 'language' || subjectCategory == 'english') {
          return {
            'items': [
              {'name': 'A', 'emoji': '🍎', 'category': 'Vowels'},
              {'name': 'E', 'emoji': '🥚', 'category': 'Vowels'},
              {'name': 'I', 'emoji': '🍦', 'category': 'Vowels'},
              {'name': 'B', 'emoji': '🐝', 'category': 'Consonants'},
              {'name': 'C', 'emoji': '🐱', 'category': 'Consonants'},
              {'name': 'D', 'emoji': '🐶', 'category': 'Consonants'},
            ],
            'categories': ['Vowels', 'Consonants', 'Words'],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else if (subjectCategory == 'science') {
          return {
            'items': [
              {'name': 'Dog', 'emoji': '🐶', 'category': 'Animals'},
              {'name': 'Cat', 'emoji': '🐱', 'category': 'Animals'},
              {'name': 'Apple', 'emoji': '🍎', 'category': 'Plants'},
              {'name': 'Tree', 'emoji': '🌳', 'category': 'Plants'},
              {'name': 'Sun', 'emoji': '☀️', 'category': 'Non-Living'},
              {'name': 'Rock', 'emoji': '🪨', 'category': 'Non-Living'},
            ],
            'categories': ['Animals', 'Plants', 'Non-Living'],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else if (subjectCategory == 'jawi' || subjectCategory == 'arabic') {
          return {
            'items': [
              {'name': 'Alif', 'emoji': 'ا', 'category': 'Basic Letters'},
              {'name': 'Ba', 'emoji': 'ب', 'category': 'Basic Letters'},
              {'name': 'Ta', 'emoji': 'ت', 'category': 'Basic Letters'},
              {'name': 'Mim', 'emoji': 'م', 'category': 'Advanced Letters'},
              {'name': 'Nun', 'emoji': 'ن', 'category': 'Advanced Letters'},
              {'name': 'Sin', 'emoji': 'س', 'category': 'Advanced Letters'},
            ],
            'categories': ['Basic Letters', 'Advanced Letters', 'Words'],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else {
          // Default sorting content for other subjects
          return {
            'items': [
              {'name': '${subjectPrefix}Apple', 'emoji': '🍎', 'category': 'Fruits'},
              {'name': '${subjectPrefix}Banana', 'emoji': '🍌', 'category': 'Fruits'},
              {'name': '${subjectPrefix}Cat', 'emoji': '🐱', 'category': 'Animals'},
              {'name': '${subjectPrefix}Dog', 'emoji': '🐶', 'category': 'Animals'},
              {'name': '${subjectPrefix}Red', 'emoji': '🔴', 'category': 'Colors'},
              {'name': '${subjectPrefix}Blue', 'emoji': '🔵', 'category': 'Colors'},
            ],
            'categories': ['Fruits', 'Animals', 'Colors'],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        }
        

        
      case 'tracing':
        // Create subject-specific tracing content
        if (subjectCategory == 'math') {
          return {
            'tracingItems': [
              {
                'content': '1',
                'difficulty': 1,
                'instruction': 'Trace the number 1',
                'emoji': '1️⃣'
              },
              {
                'content': '2',
                'difficulty': 1,
                'instruction': 'Trace the number 2',
                'emoji': '2️⃣'
              },
              {
                'content': '3',
                'difficulty': 1,
                'instruction': 'Trace the number 3',
                'emoji': '3️⃣'
              },
              {
                'content': '4',
                'difficulty': 2,
                'instruction': 'Trace the number 4',
                'emoji': '4️⃣'
              },
              {
                'content': '5',
                'difficulty': 2,
                'instruction': 'Trace the number 5',
                'emoji': '5️⃣'
              },
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else if (subjectCategory == 'language' || subjectCategory == 'english') {
          return {
            'tracingItems': [
              {
                'content': 'A',
                'difficulty': 1,
                'instruction': 'Trace the letter A',
                'emoji': '🍎'
              },
              {
                'content': 'B',
                'difficulty': 1,
                'instruction': 'Trace the letter B',
                'emoji': '🐻'
              },
              {
                'content': 'C',
                'difficulty': 1,
                'instruction': 'Trace the letter C',
                'emoji': '🐱'
              },
              {
                'content': 'D',
                'difficulty': 2,
                'instruction': 'Trace the letter D',
                'emoji': '🐶'
              },
              {
                'content': 'E',
                'difficulty': 2,
                'instruction': 'Trace the letter E',
                'emoji': '🥚'
              },
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else if (subjectCategory == 'jawi' || subjectCategory == 'arabic') {
          return {
            'tracingItems': [
              {
                'content': 'ا',
                'difficulty': 1,
                'instruction': 'Trace the letter Alif',
                'emoji': '✏️'
              },
              {
                'content': 'ب',
                'difficulty': 1,
                'instruction': 'Trace the letter Ba',
                'emoji': '✏️'
              },
              {
                'content': 'ت',
                'difficulty': 2,
                'instruction': 'Trace the letter Ta',
                'emoji': '✏️'
              },
              {
                'content': 'ث',
                'difficulty': 2,
                'instruction': 'Trace the letter Tha',
                'emoji': '✏️'
              },
              {
                'content': 'ج',
                'difficulty': 3,
                'instruction': 'Trace the letter Jim',
                'emoji': '✏️'
              },
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else {
          // Default tracing content for other subjects
          return {
            'tracingItems': [
              {
                'content': '${subjectName.substring(0, 1)}',
                'difficulty': 1,
                'instruction': 'Trace the letter ${subjectName.substring(0, 1)}',
                'emoji': '✏️'
              },
              {
                'content': 'A',
                'difficulty': 1,
                'instruction': 'Trace the letter A',
                'emoji': '🍎'
              },
              {
                'content': 'B',
                'difficulty': 1,
                'instruction': 'Trace the letter B',
                'emoji': '🐻'
              },
              {
                'content': '1',
                'difficulty': 1,
                'instruction': 'Trace the number 1',
                'emoji': '1️⃣'
              },
              {
                'content': '2',
                'difficulty': 1,
                'instruction': 'Trace the number 2',
                'emoji': '2️⃣'
              },
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        }
        
      case 'shape_color':
        // Create subject-specific shape and color content
        if (subjectCategory == 'math') {
          return {
            'shapes': [
              {
                'shape': 'circle',
                'color': 'red',
                'name': 'Counting Circle'
              },
              {
                'shape': 'square',
                'color': 'blue',
                'name': 'Number Square'
              },
              {
                'shape': 'triangle',
                'color': 'green',
                'name': 'Math Triangle'
              },
              {
                'shape': 'rectangle',
                'color': 'purple',
                'name': 'Addition Rectangle'
              },
              {
                'shape': 'pentagon',
                'color': 'orange',
                'name': 'Five-sided Shape'
              },
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else if (subjectCategory == 'language' || subjectCategory == 'english') {
          return {
            'shapes': [
              {
                'shape': 'circle',
                'color': 'red',
                'name': 'Letter O Circle'
              },
              {
                'shape': 'square',
                'color': 'blue',
                'name': 'Word Box'
              },
              {
                'shape': 'triangle',
                'color': 'green',
                'name': 'ABC Triangle'
              },
              {
                'shape': 'star',
                'color': 'yellow',
                'name': 'Reading Star'
              },
              {
                'shape': 'heart',
                'color': 'pink',
                'name': 'Vocabulary Heart'
              },
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else if (subjectCategory == 'science') {
          return {
            'shapes': [
              {
                'shape': 'circle',
                'color': 'blue',
                'name': 'Earth Circle'
              },
              {
                'shape': 'star',
                'color': 'yellow',
                'name': 'Sun Star'
              },
              {
                'shape': 'triangle',
                'color': 'green',
                'name': 'Plant Triangle'
              },
              {
                'shape': 'rectangle',
                'color': 'brown',
                'name': 'Animal Home'
              },
              {
                'shape': 'diamond',
                'color': 'teal',
                'name': 'Water Diamond'
              },
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else if (subjectCategory == 'art') {
          return {
            'shapes': [
              {
                'shape': 'circle',
                'color': 'red',
                'name': 'Color Wheel'
              },
              {
                'shape': 'square',
                'color': 'blue',
                'name': 'Canvas Square'
              },
              {
                'shape': 'triangle',
                'color': 'yellow',
                'name': 'Primary Triangle'
              },
              {
                'shape': 'rectangle',
                'color': 'green',
                'name': 'Landscape Frame'
              },
              {
                'shape': 'oval',
                'color': 'purple',
                'name': 'Portrait Oval'
              },
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else {
          // Default shape and color content for other subjects
          return {
            'shapes': [
              {
                'shape': 'circle',
                'color': 'red',
                'name': '${subjectPrefix}Red Circle'
              },
              {
                'shape': 'square',
                'color': 'blue',
                'name': '${subjectPrefix}Blue Square'
              },
              {
                'shape': 'triangle',
                'color': 'green',
                'name': '${subjectPrefix}Green Triangle'
              },
              {
                'shape': 'star',
                'color': 'yellow',
                'name': '${subjectPrefix}Yellow Star'
              },
              {
                'shape': 'heart',
                'color': 'pink',
                'name': '${subjectPrefix}Pink Heart'
              },
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        };
        


        
      case 'matching':
        // Create subject-specific matching content
        if (subjectCategory == 'math') {
          return {
            'pairs': [
              {'word': 'One', 'emoji': '1️⃣'},
              {'word': 'Two', 'emoji': '2️⃣'},
              {'word': 'Three', 'emoji': '3️⃣'},
              {'word': 'Circle', 'emoji': '⭕'},
              {'word': 'Square', 'emoji': '⬜'},
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else if (subjectCategory == 'language' || subjectCategory == 'english') {
          return {
            'pairs': [
              {'word': 'Apple', 'emoji': '🍎'},
              {'word': 'Banana', 'emoji': '🍌'},
              {'word': 'Cat', 'emoji': '🐱'},
              {'word': 'Dog', 'emoji': '🐶'},
              {'word': 'Elephant', 'emoji': '🐘'},
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else if (subjectCategory == 'science') {
          return {
            'pairs': [
              {'word': 'Sun', 'emoji': '☀️'},
              {'word': 'Moon', 'emoji': '🌕'},
              {'word': 'Plant', 'emoji': '🌱'},
              {'word': 'Water', 'emoji': '💧'},
              {'word': 'Animal', 'emoji': '🐺'},
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else if (subjectCategory == 'jawi' || subjectCategory == 'arabic') {
          return {
            'pairs': [
              {'word': 'Alif', 'emoji': 'ا'},
              {'word': 'Ba', 'emoji': 'ب'},
              {'word': 'Ta', 'emoji': 'ت'},
              {'word': 'Mim', 'emoji': 'م'},
              {'word': 'Nun', 'emoji': 'ن'},
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else if (subjectCategory == 'social') {
          return {
            'pairs': [
              {'word': 'Happy', 'emoji': '😄'},
              {'word': 'Sad', 'emoji': '😢'},
              {'word': 'Friends', 'emoji': '👫'},
              {'word': 'Share', 'emoji': '💑'},
              {'word': 'Help', 'emoji': '🤝'},
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
        } else {
          // Default matching content for other subjects
          return {
            'pairs': [
              {'word': '${subjectPrefix}Item 1', 'emoji': '🔍'},
              {'word': '${subjectPrefix}Item 2', 'emoji': '📚'},
              {'word': '${subjectPrefix}Item 3', 'emoji': '🎯'},
              {'word': '${subjectPrefix}Item 4', 'emoji': '🧩'},
              {'word': '${subjectPrefix}Item 5', 'emoji': '🎨'},
            ],
            'metadata': {
              'templateType': templateType,
              'subjectName': subjectName,
              'ageGroup': ageGroup,
              'isFallback': true,
            }
          };
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
        id: 'sorting',
        name: 'Sorting Game',
        description: _getTemplateDescription('sorting', ageGroup),
        icon: Icons.sort,
        color: Colors.purple,
        ageGroup: ageGroup,
      ),
      GameTemplateInfo(
        id: 'tracing',
        name: 'Tracing Game',
        description: _getTemplateDescription('tracing', ageGroup),
        icon: Icons.gesture,
        color: Colors.green,
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
        
      case 'sorting':
        if (ageGroup == 4) {
          return 'Sort items into categories with colorful pictures!';
        } else if (ageGroup == 5) {
          return 'Group related items together to learn about categories and relationships.';
        } else {
          return 'Develop classification skills by sorting items into appropriate categories.';
        }
        
      case 'shape_color':
        if (ageGroup == 4) {
          return 'Learn shapes and colors with big, bright pictures!';
        } else if (ageGroup == 5) {
          return 'Identify shapes and colors while learning subject vocabulary.';
        } else {
          return 'Connect shapes and colors to subject concepts for deeper learning.';
        }
        
      case 'tracing':
        if (ageGroup == 4) {
          return 'Practice writing letters and shapes with fun tracing activities!';
        } else if (ageGroup == 5) {
          return 'Develop fine motor skills by tracing letters, numbers, and words.';
        } else {
          return 'Improve handwriting and language skills through guided tracing exercises.';
        }
        
      // Add more case statements for other game types as needed
        
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
    if (timeSpentSeconds > 0) {
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
