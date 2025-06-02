import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/subject.dart';

class GeminiService {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String model = 'gemini-1.5-pro';

  Future<String?> createGame(String moduleName, {required int targetAge}) async {
    try {
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''Create an educational game for children aged $targetAge years old based on the module: $moduleName.
              The game should be:
              1. Age-appropriate and engaging
              2. Interactive and fun
              3. Educational and aligned with the module content
              4. Include clear instructions and rules
              5. Have a scoring or reward system
              6. Include visual elements and animations (described)
              
              Format the response as a JSON object with the following structure:
              {
                "title": "Game Title",
                "description": "Brief game description",
                "instructions": ["Step 1", "Step 2", ...],
                "rules": ["Rule 1", "Rule 2", ...],
                "visualElements": {
                  "characters": ["Description of character 1", ...],
                  "backgrounds": ["Description of background 1", ...],
                  "animations": ["Description of animation 1", ...]
                },
                "scoring": {
                  "pointSystem": "Description of point system",
                  "rewards": ["Reward 1", ...]
                },
                "difficulty": "Easy/Medium/Hard based on age",
                "estimatedDuration": "Time in minutes"
              }'''
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
      return null;
    } catch (e) {
      print('Error creating game: $e');
      return null;
    }
  }

  Future<String?> createQuiz(String moduleName, {required int targetAge}) async {
    try {
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''Create an educational quiz for children aged $targetAge years old based on the module: $moduleName.
              The quiz should:
              1. Be age-appropriate and engaging
              2. Include a mix of question types (multiple choice, true/false)
              3. Have clear and simple language
              4. Include visual elements where appropriate
              5. Have varying difficulty levels
              6. Include positive feedback and encouragement
              
              Format the response as a JSON object with the following structure:
              {
                "title": "Quiz Title",
                "description": "Brief quiz description",
                "questions": [
                  {
                    "id": 1,
                    "type": "multiple_choice/true_false",
                    "question": "Question text",
                    "options": ["Option 1", ...],
                    "correctAnswer": "Correct option",
                    "explanation": "Why this is correct",
                    "visualPrompt": "Description of any visual element"
                  }
                ],
                "feedback": {
                  "excellent": "Message for 90-100% score",
                  "good": "Message for 70-89% score",
                  "needsPractice": "Message for below 70% score"
                },
                "difficulty": "Easy/Medium/Hard based on age",
                "estimatedDuration": "Time in minutes"
              }'''
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
      return null;
    } catch (e) {
      print('Error creating quiz: $e');
      return null;
    }
  }
  
  // Generate content for matching game based on subject and chapter
  Future<Map<String, dynamic>?> generateMatchingGameContent(Subject subject, Chapter chapter) async {
    try {
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''Create content for a matching game for children aged ${subject.moduleId} years old based on the subject: ${subject.name} and chapter: ${chapter.name}.
              
              The matching game pairs words with images (represented by emojis).
              
              Format the response as a JSON object with the following structure:
              {
                "title": "Matching Game: ${chapter.name}",
                "instructions": "Match the words with their corresponding images",
                "pairs": [
                  {
                    "word": "Word1",
                    "emoji": "🍎" 
                  },
                  {
                    "word": "Word2", 
                    "emoji": "🐱"
                  },
                  {
                    "word": "Word3", 
                    "emoji": "🚗"
                  },
                  {
                    "word": "Word4", 
                    "emoji": "🌳"
                  },
                  {
                    "word": "Word5", 
                    "emoji": "🏠"
                  },
                  {
                    "word": "Word6", 
                    "emoji": "🐶"
                  }
                ]
              }
              
              Notes:
              1. If the subject is related to language (English, Bahasa, etc.), use appropriate vocabulary words for that language.
              2. If the subject is "Iqra" or related to Arabic/Islamic studies, use appropriate Arabic/Jawi words.
              3. If the subject is math-related, use numbers and counting words.
              4. If the subject is science-related, use appropriate science terms.
              5. Make sure the content is age-appropriate for ${subject.moduleId}-year-old children.
              6. Choose emojis that clearly represent the words.
              7. Provide exactly 6 word-emoji pairs.
              '''
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON from the response
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = text.substring(jsonStart, jsonEnd);
          return jsonDecode(jsonStr) as Map<String, dynamic>;
        }
        return null;
      }
      return null;
    } catch (e) {
      print('Error generating matching game content: $e');
      return null;
    }
  }
  
  // Generate content for memory sequence game based on subject and chapter
  Future<Map<String, dynamic>?> generateMemorySequenceGameContent(Subject subject, Chapter chapter) async {
    try {
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''Create content for a memory sequence game for children aged ${subject.moduleId} years old based on the subject: ${subject.name} and chapter: ${chapter.name}.
              
              The memory sequence game shows a sequence of colored shapes with icons that the player must remember and repeat.
              
              Format the response as a JSON object with the following structure:
              {
                "title": "Memory Sequence Game: ${chapter.name}",
                "instructions": "Watch the pattern and repeat it by tapping the shapes in the same order",
                "theme": "A theme related to ${chapter.name}",
                "difficultyLevels": [
                  {
                    "level": 1,
                    "sequenceLength": 3,
                    "speed": "slow"
                  },
                  {
                    "level": 2,
                    "sequenceLength": 4,
                    "speed": "medium"
                  },
                  {
                    "level": 3,
                    "sequenceLength": 5,
                    "speed": "fast"
                  }
                ],
                "shapes": [
                  {
                    "icon": "star",
                    "color": "red",
                    "sound": "high note"
                  },
                  {
                    "icon": "heart",
                    "color": "blue",
                    "sound": "medium note"
                  },
                  {
                    "icon": "flower",
                    "color": "green",
                    "sound": "low note"
                  },
                  {
                    "icon": "sun",
                    "color": "yellow",
                    "sound": "chime"
                  },
                  {
                    "icon": "music",
                    "color": "purple",
                    "sound": "bell"
                  },
                  {
                    "icon": "animal",
                    "color": "orange",
                    "sound": "pop"
                  }
                ],
                "feedbackMessages": {
                  "correct": ["Great job!", "Well done!", "Excellent memory!"],
                  "incorrect": ["Try again!", "Oops! Watch carefully.", "Almost there!"]
                }
              }
              
              Notes:
              1. Make the theme related to the subject and chapter content.
              2. Ensure the difficulty levels are appropriate for ${subject.moduleId}-year-old children.
              3. Choose icons and colors that are visually distinct and appealing.
              4. Make the feedback messages encouraging and age-appropriate.
              '''
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON from the response
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = text.substring(jsonStart, jsonEnd);
          return jsonDecode(jsonStr) as Map<String, dynamic>;
        }
        return null;
      }
      return null;
    } catch (e) {
      print('Error generating memory sequence game content: $e');
      return null;
    }
  }
  
  // Generate content for counting game based on subject and chapter
  Future<Map<String, dynamic>?> generateCountingGameContent(Subject subject, Chapter chapter) async {
    try {
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''Create content for a counting game for children aged ${subject.moduleId} years old based on the subject: ${subject.name} and chapter: ${chapter.name}.
              
              The counting game shows a collection of items (represented by emojis) and asks the player to count them and select the correct answer.
              
              Format the response as a JSON object with the following structure:
              {
                "title": "Counting Game: ${chapter.name}",
                "instructions": "Count the items and select the correct answer",
                "theme": "A theme related to ${chapter.name}",
                "challenges": [
                  {
                    "emoji": "🍎",
                    "count": 3,
                    "question": "How many apples do you see?"
                  },
                  {
                    "emoji": "🐱",
                    "count": 5,
                    "question": "Count the cats!"
                  },
                  {
                    "emoji": "🌟",
                    "count": 4,
                    "question": "How many stars are there?"
                  },
                  {
                    "emoji": "🐠",
                    "count": 6,
                    "question": "Count the fish!"
                  },
                  {
                    "emoji": "🦋",
                    "count": 2,
                    "question": "How many butterflies can you see?"
                  },
                  {
                    "emoji": "🍦",
                    "count": 7,
                    "question": "Count the ice creams!"
                  }
                ],
                "feedbackMessages": {
                  "correct": ["Great job!", "Well done!", "Excellent counting!"],
                  "incorrect": ["Try again!", "Oops! Count carefully.", "Almost there!"]
                }
              }
              
              Notes:
              1. Make the theme related to the subject and chapter content.
              2. Choose items that are relevant to the subject (e.g., for a math subject, use countable objects; for language subjects, use objects that start with relevant letters).
              3. If the subject is "Iqra" or related to Arabic/Islamic studies, use appropriate themed items.
              4. Ensure the counting challenges are appropriate for ${subject.moduleId}-year-old children (numbers 1-10).
              5. Make the questions clear and age-appropriate.
              6. Choose emojis that are easily countable and recognizable.
              '''
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON from the response
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = text.substring(jsonStart, jsonEnd);
          return jsonDecode(jsonStr) as Map<String, dynamic>;
        }
        return null;
      }
      return null;
    } catch (e) {
      print('Error generating counting game content: $e');
      return null;
    }
  }
  
  // Generate content for puzzle game based on subject and chapter
  Future<Map<String, dynamic>?> generatePuzzleGameContent(Subject subject, Chapter chapter) async {
    try {
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''Create content for a simple puzzle game for children aged ${subject.moduleId} years old based on the subject: ${subject.name} and chapter: ${chapter.name}.
              
              The puzzle game shows a simple grid puzzle where children need to arrange pieces to form a complete image.
              
              Format the response as a JSON object with the following structure:
              {
                "title": "Puzzle Game: ${chapter.name}",
                "instructions": "Arrange the pieces to complete the puzzle",
                "ageGroup": ${subject.moduleId},
                "gridSize": 2,
                "puzzles": [
                  {
                    "word": "House",
                    "image": "🏠"
                  },
                  {
                    "word": "Cat",
                    "image": "🐱"
                  },
                  {
                    "word": "Sun",
                    "image": "☀️"
                  },
                  {
                    "word": "Tree",
                    "image": "🌳"
                  },
                  {
                    "word": "Ball",
                    "image": "⚽️"
                  },
                  {
                    "word": "Star",
                    "image": "🌟"
                  }
                ]
              }
              
              Notes:
              1. Make the puzzles related to the subject and chapter content.
              2. For age 4, use a 2x2 grid. For age 5, use a 2x2 or 3x3 grid. For age 6, use a 3x3 grid.
              3. Choose simple, recognizable images represented by emojis.
              4. Make sure the words are age-appropriate and relevant to the subject.
              5. If the subject is related to language (English, Bahasa, etc.), use appropriate vocabulary words.
              6. If the subject is "Iqra" or related to Arabic/Islamic studies, use appropriate Arabic/Jawi words.
              7. Provide at least 6 different puzzles that the game can randomly select from.
              '''
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON from the response
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = text.substring(jsonStart, jsonEnd);
          return jsonDecode(jsonStr) as Map<String, dynamic>;
        }
        return null;
      }
      return null;
    } catch (e) {
      print('Error generating puzzle game content: $e');
      return null;
    }
  }
  
  // Generate content for tracing game based on subject and chapter
  Future<Map<String, dynamic>?> generateTracingGameContent(Subject subject, Chapter chapter) async {
    // Check if this is a Jawi/Arabic subject to provide specialized content
    bool isJawiOrArabic = _isJawiOrArabicSubject(subject.name) || _isJawiOrArabicChapter(chapter.name);
    
    try {
      // Customize the prompt based on subject type
      String promptText;
      
      if (isJawiOrArabic) {
        // Special prompt for Jawi/Arabic subjects
        promptText = '''Create content for a Jawi letter tracing game for children aged ${subject.moduleId} years old based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The tracing game helps children practice writing Jawi letters by tracing them on the screen.
        
        Format the response as a JSON object with the following structure:
        {
          "title": "Tracing Jawi: ${chapter.name}",
          "instructions": "Trace the Jawi letters carefully to learn how to write them",
          "ageGroup": ${subject.moduleId},
          "items": [
            {
              "character": "ا",
              "name": "Alif",
              "sound": "A",
              "example": "Api",
              "emoji": "🔥",
              "difficulty": 1
            },
            {
              "character": "ب",
              "name": "Ba",
              "sound": "B",
              "example": "Bola",
              "emoji": "⚽",
              "difficulty": 1
            }
          ]
        }
        
        Important notes for Jawi tracing games for ${subject.moduleId}-year-old children:
        1. Include only basic, simple Jawi letters that are appropriate for beginners.
        2. For age 4, focus on the simplest letters like Alif (ا), Ba (ب), Ta (ت), etc.
        3. Use very simple, familiar example words that start with each letter.
        4. Choose clear, recognizable emojis that young children can understand.
        5. Set appropriate difficulty levels: 1 for simple letters (like Alif), 2 for slightly more complex ones.
        6. Provide 6-8 different letters to trace, focusing on the most fundamental ones.
        7. Make sure the content is age-appropriate and engaging for very young learners.
        8. For age 4, focus on recognition and basic tracing rather than complex writing.
        9. Include the romanized name of each letter (like "Alif") to help teachers explain.
        ''';
      } else {
        // Standard prompt for other subjects
        promptText = '''Create content for a letter tracing game for children aged ${subject.moduleId} years old based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The tracing game helps children practice writing letters or numbers by tracing them on the screen.
        
        Format the response as a JSON object with the following structure:
        {
          "title": "Tracing Game: ${chapter.name}",
          "instructions": "Trace the letters to learn how to write them",
          "ageGroup": ${subject.moduleId},
          "items": [
            {
              "character": "A",
              "word": "Apple",
              "emoji": "🍎",
              "difficulty": 1
            },
            {
              "character": "B",
              "word": "Ball",
              "emoji": "⚽️",
              "difficulty": 1
            }
          ]
        }
        
        Notes:
        1. Make the tracing items related to the subject and chapter content.
        2. For language subjects, use letters appropriate for that language.
        3. For math subjects, use numbers instead of letters.
        4. The difficulty level should be 1 for simple characters and 2 for more complex ones.
        5. Choose emojis that clearly represent the words.
        6. Make sure the words are age-appropriate and relevant to the subject.
        7. Provide at least 6 different items to trace.
        ''';
      }
      
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': promptText
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON from the response
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = text.substring(jsonStart, jsonEnd);
          final gameContent = jsonDecode(jsonStr) as Map<String, dynamic>;
          
          // For age 4 Jawi content, ensure we're only using the simplest letters
          if (isJawiOrArabic && subject.moduleId == 4) {
            // Make additional age-appropriate adjustments
            gameContent['instructions'] = 'Trace the Jawi letters with your finger. Follow the dotted lines carefully!';
            
            // Limit number of items for age 4
            if (gameContent['items'] != null && gameContent['items'] is List && (gameContent['items'] as List).length > 4) {
              gameContent['items'] = (gameContent['items'] as List).sublist(0, 4);
            }
          }
          
          return gameContent;
        }
        return null;
      }
      return null;
    } catch (e) {
      print('Error generating tracing game content: $e');
      return null;
    }
  }
  
  // Generate content for sorting game based on subject and chapter
  Future<Map<String, dynamic>?> generateSortingGameContent(Subject subject, Chapter chapter) async {
    try {
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''Create content for a sorting game for children aged ${subject.moduleId} years old based on the subject: ${subject.name} and chapter: ${chapter.name}.
              
              The sorting game asks children to sort items into different categories by dragging and dropping them.
              
              Format the response as a JSON object with the following structure:
              {
                "title": "Sorting Game: ${chapter.name}",
                "instructions": "Sort the items into the correct categories",
                "ageGroup": ${subject.moduleId},
                "categories": [
                  {
                    "name": "Fruits",
                    "emoji": "🍎",
                    "color": "red"
                  },
                  {
                    "name": "Animals",
                    "emoji": "🐶",
                    "color": "blue"
                  }
                ],
                "items": [
                  {
                    "name": "Apple",
                    "emoji": "🍎",
                    "category": "Fruits"
                  },
                  {
                    "name": "Banana",
                    "emoji": "🍌",
                    "category": "Fruits"
                  },
                  {
                    "name": "Orange",
                    "emoji": "🍊",
                    "category": "Fruits"
                  },
                  {
                    "name": "Dog",
                    "emoji": "🐶",
                    "category": "Animals"
                  },
                  {
                    "name": "Cat",
                    "emoji": "🐱",
                    "category": "Animals"
                  },
                  {
                    "name": "Elephant",
                    "emoji": "🐘",
                    "category": "Animals"
                  }
                ]
              }
              
              Notes:
              1. Make the categories and items related to the subject and chapter content.
              2. For language subjects, consider categories like "Starting with A" vs "Starting with B".
              3. For math subjects, consider categories like "Even Numbers" vs "Odd Numbers".
              4. For "Iqra" or Arabic/Islamic studies, use appropriate Arabic/Islamic categories.
              5. Choose 2-3 categories that are clearly distinct from each other.
              6. Provide at least 6 items to sort, with a balanced distribution across categories.
              7. Make sure the items are age-appropriate and relevant to the subject.
              8. Choose emojis that clearly represent the categories and items.
              '''
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON from the response
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = text.substring(jsonStart, jsonEnd);
          return jsonDecode(jsonStr) as Map<String, dynamic>;
        }
        return null;
      }
      return null;
    } catch (e) {
      print('Error generating sorting game content: $e');
      return null;
    }
  }
  
  // Analyze subject and chapter to determine the most suitable games
  Future<List<String>> getSuitableGameTypes(Subject subject, Chapter chapter) async {
    // Special case for Jawi/Arabic letter subjects - prioritize tracing games
    if (_isJawiOrArabicSubject(subject.name) || _isJawiOrArabicChapter(chapter.name)) {
      // For age 4, prioritize tracing and matching games for Jawi/Arabic letters
      if (subject.moduleId == 4) {
        return ['tracing', 'matching', 'memory'];
      } else {
        return ['tracing', 'sorting', 'matching'];
      }
    }
    
    try {
      // Get the age from the subject module ID
      final int ageGroup = subject.moduleId;
      
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''Analyze the following subject and chapter to determine the 3 most suitable educational games for children aged $ageGroup years old.
              
              Subject: ${subject.name}
              Chapter: ${chapter.name}
              Age: $ageGroup years old
              Chapter Content: ${chapter.notes ?? 'No additional content'}
              
              Available game types:
              1. matching - A game where children match words with pictures. Best for vocabulary, language learning, and basic associations.
              2. memory - A memory sequence game where children repeat patterns. Best for developing memory, attention, and pattern recognition.
              3. counting - A game where children count objects and select the correct answer. Best for early math, number recognition, and quantitative skills.
              4. puzzle - A simple puzzle game where children arrange pieces to form a complete image. Best for spatial awareness, problem-solving, and visual recognition.
              5. tracing - A game where children practice writing letters or numbers by tracing them. Best for fine motor skills, letter/number recognition, and handwriting.
              6. sorting - A game where children sort items into different categories. Best for classification skills, logical thinking, and concept understanding.
              
              Consider these age-specific learning needs:
              - Age 4: Very simple games, large visual elements, minimal text, basic concepts, immediate feedback
              - Age 5: Simple games with slightly more complexity, developing literacy, longer attention span
              - Age 6: More challenging games, emerging reading skills, greater problem-solving abilities
              
              Based on the subject, chapter content, and age group, rank the top 3 most suitable game types.
              Return ONLY a JSON array with the 3 game type IDs in order of suitability, like this:
              ["game1", "game2", "game3"]
              
              For example, if matching, tracing, and sorting are most suitable, return:
              ["matching", "tracing", "sorting"]
              '''
            }]
          }],
          'generationConfig': {
            'temperature': 0.3,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 256,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON array from the response
        final jsonStart = text.indexOf('[');
        final jsonEnd = text.lastIndexOf(']') + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = text.substring(jsonStart, jsonEnd);
          final gameTypes = jsonDecode(jsonStr) as List<dynamic>;
          return gameTypes.map((type) => type.toString()).toList();
        }
        
        // Fallback to default games if parsing fails
        return ['matching', 'memory', 'counting'];
      }
      return ['matching', 'memory', 'counting']; // Default fallback
    } catch (e) {
      print('Error determining suitable game types: $e');
      return ['matching', 'memory', 'counting']; // Default fallback on error
    }
  }
  
  // Helper method to check if a subject is related to Jawi or Arabic letters
  bool _isJawiOrArabicSubject(String subjectName) {
    final lowercaseName = subjectName.toLowerCase();
    return lowercaseName.contains('iqra') || 
           lowercaseName.contains('jawi') || 
           lowercaseName.contains('huruf') || 
           lowercaseName.contains('arabic') || 
           lowercaseName.contains('quran');
  }
  
  // Helper method to check if a chapter is related to Jawi or Arabic letters
  bool _isJawiOrArabicChapter(String chapterName) {
    final lowercaseName = chapterName.toLowerCase();
    return lowercaseName.contains('huruf') || 
           lowercaseName.contains('letter') || 
           lowercaseName.contains('jawi') || 
           lowercaseName.contains('arabic') || 
           lowercaseName.contains('alif') || 
           lowercaseName.contains('ba') ||
           lowercaseName.contains('hijaiyah');
  }
  
  // Generate game content based on game type
  Future<Map<String, dynamic>?> generateGameContent(String gameType, Subject subject, Chapter chapter) async {
    // Add age group to all game content generation
    final int ageGroup = subject.moduleId;
    Map<String, dynamic>? gameContent;
    
    // Get subject and chapter context for better content generation
    final subjectContext = _getSubjectContext(subject.name);
    final chapterContext = _getChapterContext(chapter.name);
    
    // Log what we're generating to help with debugging
    print('Generating $gameType game for ${subject.name} (${chapter.name}) - Age: $ageGroup');
    print('Subject context: $subjectContext, Chapter context: $chapterContext');
    
    // Add context information to be passed to all game content generators
    final Map<String, dynamic> contextInfo = {
      'subjectName': subject.name,
      'chapterName': chapter.name,
      'ageGroup': ageGroup,
      'subjectContext': subjectContext,
      'chapterContext': chapterContext,
      'notes': chapter.notes,
    };
    
    // Generate game content based on type
    switch (gameType) {
      case 'matching':
        gameContent = await generateMatchingGameContent(subject, chapter);
        break;
      case 'memory':
        gameContent = await generateMemorySequenceGameContent(subject, chapter);
        break;
      case 'counting':
        gameContent = await generateCountingGameContent(subject, chapter);
        break;
      case 'puzzle':
        gameContent = await generatePuzzleGameContent(subject, chapter);
        break;
      case 'tracing':
        gameContent = await generateTracingGameContent(subject, chapter);
        break;
      case 'sorting':
        gameContent = await generateSortingGameContent(subject, chapter);
        break;
      default:
        return null;
    }
    
    // If content generation failed, try the enhanced content generation as a fallback
    if (gameContent == null || gameContent.isEmpty) {
      print('Standard content generation failed for $gameType. Trying enhanced generation...');
      gameContent = await _generateEnhancedGameContent(gameType, subject, chapter, contextInfo);
    }
    
    // If we have content, add the age group and adjust difficulty
    if (gameContent != null) {
      // Add basic context information if not already present
      gameContent['ageGroup'] = ageGroup;
      gameContent['subjectName'] = subject.name;
      gameContent['chapterName'] = chapter.name;
      gameContent['subjectContext'] = subjectContext;
      gameContent['chapterContext'] = chapterContext;
      
      // Add age-specific adjustments to each game type
      switch (gameType) {
        case 'puzzle':
          // Adjust grid size based on age
          gameContent['gridSize'] = ageGroup <= 4 ? 2 : ageGroup <= 5 ? 3 : 4;
          
          // For age 4, ensure puzzle pieces are very simple
          if (ageGroup == 4) {
            gameContent['simplifiedPieces'] = true;
            gameContent['showOutlines'] = true; // Show outlines to help with placement
          }
          break;
          
        case 'memory':
          // Adjust sequence length and time based on age
          gameContent['initialSequenceLength'] = ageGroup <= 4 ? 2 : ageGroup <= 5 ? 3 : 4;
          gameContent['timePerLevel'] = ageGroup <= 4 ? 6 : ageGroup <= 5 ? 5 : 4;
          
          // For age 4, use larger, simpler shapes and more time
          if (ageGroup == 4) {
            gameContent['largerElements'] = true;
            gameContent['simplifiedShapes'] = true;
            gameContent['extraTimeBonus'] = 2; // Extra seconds for young children
          }
          break;
          
        case 'matching':
          // Adjust number of pairs based on age
          if (gameContent['pairs'] != null) {
            final pairs = gameContent['pairs'] as List;
            final int maxPairs = ageGroup <= 4 ? 3 : ageGroup <= 5 ? 5 : 7;
            if (pairs.length > maxPairs) {
              gameContent['pairs'] = pairs.sublist(0, maxPairs);
            }
            
            // For age 4, ensure matching items are very clear and obvious
            if (ageGroup == 4) {
              gameContent['showHints'] = true;
              gameContent['simplifiedMatching'] = true;
            }
          }
          break;
          
        case 'tracing':
          // Adjust complexity of tracing items based on age
          gameContent['complexity'] = ageGroup <= 4 ? 'very_simple' : ageGroup <= 5 ? 'simple' : 'medium';
          
          // For age 4, add special accommodations
          if (ageGroup == 4) {
            gameContent['widerTraceLines'] = true; // Wider lines for easier tracing
            gameContent['showGuidelines'] = true; // Show guidelines
            gameContent['slowAnimationSpeed'] = true; // Slower demonstration animations
          }
          break;
          
        case 'counting':
          // For age 4, limit the count range and add visual aids
          if (ageGroup == 4) {
            gameContent['maxCount'] = 5; // Only count up to 5 for age 4
            gameContent['showNumberLine'] = true; // Show a number line for reference
            gameContent['largerNumbers'] = true; // Larger number display
          } else if (ageGroup == 5) {
            gameContent['maxCount'] = 10;
          }
          break;
          
        case 'sorting':
          // For age 4, limit categories and make distinctions very clear
          if (ageGroup == 4) {
            gameContent['maxCategories'] = 2; // Only 2 categories for age 4
            gameContent['highContrast'] = true; // High contrast between categories
            gameContent['simplifiedSorting'] = true; // Very obvious sorting criteria
          }
          break;
      }
      
      // Content adjustments based on subject context
      if (subjectContext == 'jawi' || subjectContext == 'arabic') {
        // Special adjustments for Jawi/Arabic subjects
        if (gameType == 'tracing') {
          gameContent['arabicScript'] = true;
          gameContent['rightToLeft'] = true;
          
          // For age 4, focus only on the most basic letters
          if (ageGroup == 4) {
            gameContent['focusOnBasicLetters'] = true;
            gameContent['includeTransliteration'] = true; // Include Roman alphabet equivalents
          }
        } else if (gameType == 'matching') {
          // For matching games with Jawi/Arabic, match letters to sounds or images
          gameContent['matchLettersToSounds'] = true;
        }
      } else if (subjectContext == 'math') {
        // Math-specific adjustments
        if (gameType == 'counting') {
          gameContent['showEquations'] = ageGroup >= 5; // Show simple equations for age 5+
        } else if (gameType == 'matching') {
          gameContent['matchNumbersToQuantities'] = true; // Match numbers to quantities
        }
      } else if (subjectContext == 'science') {
        // Science-specific adjustments
        if (gameType == 'sorting') {
          gameContent['scientificCategories'] = true; // Use scientific categories
        }
      }
      
      // Add a title that includes the subject and chapter
      if (gameContent['title'] == null) {
        String gameTypeName = '';
        switch (gameType) {
          case 'matching': gameTypeName = 'Matching'; break;
          case 'memory': gameTypeName = 'Memory Sequence'; break;
          case 'counting': gameTypeName = 'Counting'; break;
          case 'puzzle': gameTypeName = 'Puzzle'; break;
          case 'tracing': gameTypeName = 'Tracing'; break;
          case 'sorting': gameTypeName = 'Sorting'; break;
        }
        gameContent['title'] = '$gameTypeName: ${chapter.name} (${subject.name})';
      }
      
      // Add age-appropriate instructions
      if (ageGroup == 4) {
        // Simplify instructions for age 4
        String simpleInstructions = gameContent['instructions'] ?? '';
        if (simpleInstructions.length > 50) {
          // Make instructions shorter and simpler for young children
          switch (gameType) {
            case 'matching': 
              simpleInstructions = 'Match the pairs that go together!'; 
              break;
            case 'memory': 
              simpleInstructions = 'Watch and repeat the pattern!'; 
              break;
            case 'counting': 
              simpleInstructions = 'Count the items and pick the right number!'; 
              break;
            case 'puzzle': 
              simpleInstructions = 'Put the pieces together to make a picture!'; 
              break;
            case 'tracing': 
              simpleInstructions = 'Follow the dots to trace the letter!'; 
              break;
            case 'sorting': 
              simpleInstructions = 'Put each item in the right group!'; 
              break;
          }
          gameContent['instructions'] = simpleInstructions;
        }
      }
    }



    return gameContent;
  }
  
  // Helper method to determine subject context
  String _getSubjectContext(String subjectName) {
    final name = subjectName.toLowerCase();
    
    if (_isJawiOrArabicSubject(subjectName)) {
      return 'jawi';
    } else if (name.contains('math') || name.contains('nombor') || name.contains('number')) {
      return 'math';
    } else if (name.contains('science') || name.contains('sains')) {
      return 'science';
    } else if (name.contains('english') || name.contains('bahasa inggeris')) {
      return 'english';
    } else if (name.contains('malay') || name.contains('bahasa melayu')) {
      return 'malay';
    }
    
    return 'general';
  }
  
  // Helper method to determine chapter context
  String _getChapterContext(String chapterName) {
    final name = chapterName.toLowerCase();
    
    if (_isJawiOrArabicChapter(chapterName)) {
      return 'jawi_letters';
    } else if (name.contains('number') || name.contains('nombor') || name.contains('count')) {
      return 'numbers';
    } else if (name.contains('shape') || name.contains('bentuk')) {
      return 'shapes';
    } else if (name.contains('color') || name.contains('colour') || name.contains('warna')) {
      return 'colors';
    } else if (name.contains('animal') || name.contains('haiwan')) {
      return 'animals';
    } else if (name.contains('food') || name.contains('makanan')) {
      return 'food';
    }
    
    return 'general';
  }
  
  // Enhanced game content generation that ensures appropriate content for any game type
  Future<Map<String, dynamic>?> _generateEnhancedGameContent(String gameType, Subject subject, Chapter chapter, Map<String, dynamic> contextInfo) async {
    final int ageGroup = subject.moduleId;
    final String subjectContext = contextInfo['subjectContext'];
    final String chapterContext = contextInfo['chapterContext'];
    
    // Create a custom prompt based on game type and context
    String customPrompt;
    
    // Determine if this is Jawi/Arabic content
    final bool isJawiContent = subjectContext == 'jawi' || chapterContext == 'jawi_letters';
    
    // Build a context-specific prompt for the game type
    switch (gameType) {
      case 'matching':
        if (isJawiContent) {
          customPrompt = '''Create content for a Jawi letter matching game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
          
          The matching game should pair Jawi letters with their sounds, names, or example words that are specifically relevant to this chapter.
          
          Chapter notes: ${chapter.notes ?? 'Basic Jawi letters'}
          
          Format the response as a JSON object with the following structure:
          {
            "title": "Jawi Matching: ${chapter.name}",
            "instructions": "Match each Jawi letter with its correct sound or example word.",
            "pairs": [
              {"emoji": "ا", "word": "Alif", "description": "First letter of Jawi alphabet"},
              {"emoji": "ب", "word": "Ba", "description": "Second letter of Jawi alphabet"}
            ]
          }
          
          Important notes:
          1. Create pairs that are SPECIFICALLY related to the chapter "${chapter.name}" - don't use generic content.
          2. Use the actual Jawi letters that would be taught in this specific chapter.
          3. For age 4, include only 3-4 pairs of the simplest letters.
          4. For age 5-6, include 5-6 pairs of appropriate difficulty.
          ''';        
        } else if (subjectContext == 'math') {
          customPrompt = '''Create content for a math matching game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
          
          The matching game should pair numbers with quantities, math symbols with their meanings, or simple equations with their answers that are specifically relevant to this chapter.
          
          Chapter notes: ${chapter.notes ?? 'Basic math concepts'}
          
          Format the response as a JSON object with the following structure:
          {
            "title": "Math Matching: ${chapter.name}",
            "instructions": "Match each number with the correct quantity.",
            "pairs": [
              {"emoji": "1", "word": "One", "description": "The number 1"},
              {"emoji": "2", "word": "Two", "description": "The number 2"}
            ]
          }
          
          Important notes:
          1. Create pairs that are SPECIFICALLY related to the chapter "${chapter.name}" - don't use generic content.
          2. Use math concepts that would be taught in this specific chapter.
          3. Adjust difficulty based on age: simpler for age 4, more complex for ages 5-6.
          ''';        
        } else {
          customPrompt = '''Create content for a matching game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
          
          The matching game should pair related items that are specifically relevant to this chapter.
          
          Chapter notes: ${chapter.notes ?? 'No additional notes'}
          
          Format the response as a JSON object with the following structure:
          {
            "title": "Matching Game: ${chapter.name}",
            "instructions": "Match each item with its pair.",
            "pairs": [
              {"emoji": "🍎", "word": "Apple", "description": "A red fruit"},
              {"emoji": "🍌", "word": "Banana", "description": "A yellow fruit"}
            ]
          }
          
          Important notes:
          1. Create pairs that are SPECIFICALLY related to the chapter "${chapter.name}" - don't use generic content.
          2. Make sure all content is age-appropriate for $ageGroup-year-old children.
          3. For age 4, use simple, familiar items with clear relationships.
          4. For age 5-6, you can use slightly more complex relationships.
          ''';        
        }
        break;
        
      case 'tracing':
        if (isJawiContent) {
          customPrompt = '''Create content for a Jawi letter tracing game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
          
          The tracing game helps children practice writing Jawi letters by tracing them on the screen.
          
          Chapter notes: ${chapter.notes ?? 'Basic Jawi letters'}
          
          Format the response as a JSON object with the following structure:
          {
            "title": "Tracing Jawi: ${chapter.name}",
            "instructions": "Trace the Jawi letters carefully to learn how to write them",
            "items": [
              {
                "character": "ا",
                "name": "Alif",
                "sound": "A",
                "example": "Api",
                "emoji": "🔥",
                "difficulty": 1
              },
              {
                "character": "ب",
                "name": "Ba",
                "sound": "B",
                "example": "Bola",
                "emoji": "⚽",
                "difficulty": 1
              }
            ]
          }
          
          Important notes for Jawi tracing games for $ageGroup-year-old children:
          1. Include only basic, simple Jawi letters that are appropriate for beginners.
          2. For age 4, focus on the simplest letters like Alif (ا), Ba (ب), Ta (ت), etc.
          3. Use very simple, familiar example words that start with each letter.
          4. Choose clear, recognizable emojis that young children can understand.
          5. Set appropriate difficulty levels: 1 for simple letters (like Alif), 2 for slightly more complex ones.
          6. Make sure the content is age-appropriate and engaging for young learners.
          ''';        
        } else {
          customPrompt = '''Create content for a letter or number tracing game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
          
          The tracing game helps children practice writing letters or numbers by tracing them on the screen.
          
          Chapter notes: ${chapter.notes ?? 'No additional notes'}
          
          Format the response as a JSON object with the following structure:
          {
            "title": "Tracing Game: ${chapter.name}",
            "instructions": "Trace the letters to learn how to write them",
            "items": [
              {
                "character": "A",
                "word": "Apple",
                "emoji": "🍎",
                "difficulty": 1
              },
              {
                "character": "B",
                "word": "Ball",
                "emoji": "⚽️",
                "difficulty": 1
              }
            ]
          }
          
          Important notes:
          1. Make the tracing items related to the subject and chapter content.
          2. For language subjects, use letters appropriate for that language.
          3. For math subjects, use numbers instead of letters.
          4. Make sure all content is age-appropriate for $ageGroup-year-old children.
          ''';        
        }
        break;
        
      case 'sorting':
        customPrompt = '''Create content for a sorting game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The sorting game helps children classify items into different categories.
        
        Chapter notes: ${chapter.notes ?? 'No additional notes'}
        
        Format the response as a JSON object with the following structure:
        {
          "title": "Sorting Game: ${chapter.name}",
          "instructions": "Sort the items into the correct categories",
          "categories": [
            {
              "name": "Category 1",
              "emoji": "🔴",
              "items": ["Item 1", "Item 2"]
            },
            {
              "name": "Category 2",
              "emoji": "🔵",
              "items": ["Item 3", "Item 4"]
            }
          ]
        }
        
        Important notes:
        1. Make the categories and items related to the subject and chapter content.
        2. For age 4, use only 2 simple categories with clear distinctions.
        3. For age 5-6, you can use 3-4 categories with more nuanced distinctions.
        4. Make sure all content is age-appropriate.
        ''';        
        break;
        
      case 'puzzle':
        customPrompt = '''Create content for a puzzle game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The puzzle game helps children arrange pieces to form a complete image.
        
        Chapter notes: ${chapter.notes ?? 'No additional notes'}
        
        Format the response as a JSON object with the following structure:
        {
          "title": "Puzzle Game: ${chapter.name}",
          "instructions": "Arrange the pieces to complete the picture",
          "gridSize": ${ageGroup <= 4 ? 2 : ageGroup <= 5 ? 3 : 4},
          "image": "Description of an age-appropriate image related to the subject",
          "difficulty": ${ageGroup <= 4 ? 1 : ageGroup <= 5 ? 2 : 3}
        }
        
        Important notes:
        1. The image should be related to the subject and chapter content.
        2. For age 4, use a very simple image with a 2x2 grid.
        3. For age 5, use a slightly more complex image with a 3x3 grid.
        4. For age 6, use a more detailed image with a 4x4 grid.
        5. Make sure all content is age-appropriate.
        ''';        
        break;
        
      case 'memory':
        customPrompt = '''Create content for a memory sequence game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The memory game helps children remember and repeat sequences of shapes, colors, or numbers.
        
        Chapter notes: ${chapter.notes ?? 'No additional notes'}
        
        Format the response as a JSON object with the following structure:
        {
          "title": "Memory Game: ${chapter.name}",
          "instructions": "Watch the sequence and repeat it",
          "initialSequenceLength": ${ageGroup <= 4 ? 2 : ageGroup <= 5 ? 3 : 4},
          "shapes": [
            {"icon": "🔴", "color": "red", "sound": "Red"},
            {"icon": "🔵", "color": "blue", "sound": "Blue"}
          ],
          "timePerLevel": ${ageGroup <= 4 ? 6 : ageGroup <= 5 ? 5 : 4}
        }
        
        Important notes:
        1. The shapes and colors should be related to the subject and chapter content when possible.
        2. For age 4, use very distinct shapes and colors with a short initial sequence.
        3. For age 5-6, you can use more shapes and slightly longer sequences.
        4. Make sure all content is age-appropriate.
        ''';        
        break;
        
      case 'counting':
        customPrompt = '''Create content for a counting game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The counting game helps children practice counting objects and recognizing numbers.
        
        Chapter notes: ${chapter.notes ?? 'No additional notes'}
        
        Format the response as a JSON object with the following structure:
        {
          "title": "Counting Game: ${chapter.name}",
          "instructions": "Count the objects and select the correct number",
          "maxCount": ${ageGroup <= 4 ? 5 : ageGroup <= 5 ? 10 : 20},
          "challenges": [
            {
              "emoji": "🍎",
              "count": 3,
              "question": "How many apples?"
            },
            {
              "emoji": "🐶",
              "count": 2,
              "question": "How many dogs?"
            }
          ]
        }
        
        Important notes:
        1. The objects should be related to the subject and chapter content when possible.
        2. For age 4, use counts from 1-5 with very simple objects.
        3. For age 5, use counts from 1-10.
        4. For age 6, use counts from 1-20.
        5. Make sure all content is age-appropriate.
        ''';        
        break;
        
      default:
        customPrompt = '''Create content for an educational game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The game should be age-appropriate and related to the subject and chapter content.
        
        Format the response as a JSON object with appropriate structure for the game type.
        ''';
    }
    
    try {
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': customPrompt
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON from the response
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = text.substring(jsonStart, jsonEnd);
          return jsonDecode(jsonStr) as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error in enhanced game content generation: $e');
      return null;
    }
  }
}

  // Generate memory sequence game content
  Future<Map<String, dynamic>?> generateMemorySequenceGameContent(Subject subject, Chapter chapter) async {
    try {
      final ageGroup = subject.moduleId;
      
      // Create a context-specific prompt based on subject and chapter
      String prompt;
      
      if (subjectContext == 'jawi' || chapterContext == 'jawi_letters') {
        // Special prompt for Jawi/Arabic content
        prompt = '''Create content for a memory sequence game for children aged $ageGroup learning Jawi letters based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The memory game should use Jawi letters or related symbols that are specifically relevant to this chapter.
        
        Chapter notes: ${chapter.notes ?? 'Basic Jawi letters'}
        
        Format the response as a JSON object with the following structure:
        {
          "title": "Jawi Memory Game: ${chapter.name}",
          "instructions": "Watch the sequence of Jawi letters and repeat it",
          "initialSequenceLength": ${ageGroup <= 4 ? 2 : ageGroup <= 5 ? 3 : 4},
          "shapes": [
            {"icon": "ا", "color": "red", "sound": "Alif"},
            {"icon": "ب", "color": "blue", "sound": "Ba"}
          ],
          "timePerLevel": ${ageGroup <= 4 ? 6 : ageGroup <= 5 ? 5 : 4}
        }
        
        Important notes:
        1. Create shapes/items that are SPECIFICALLY related to the chapter "${chapter.name}" - don't use generic content.
        2. Use the actual Jawi letters that would be taught in this specific chapter.
        3. Adjust difficulty based on age: simpler for age 4, more complex for ages 5-6.
        ''';
      } else if (subjectContext == 'math') {
        // Special prompt for math content
        prompt = '''Create content for a math memory sequence game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The memory game should use numbers, math symbols, or shapes that are specifically relevant to this chapter.
        
        Chapter notes: ${chapter.notes ?? 'Basic math concepts'}
        
        Format the response as a JSON object with the following structure:
        {
          "title": "Math Memory Game: ${chapter.name}",
          "instructions": "Watch the sequence and repeat it",
          "initialSequenceLength": ${ageGroup <= 4 ? 2 : ageGroup <= 5 ? 3 : 4},
          "shapes": [
            {"icon": "1", "color": "red", "sound": "One"},
            {"icon": "2", "color": "blue", "sound": "Two"}
          ],
          "timePerLevel": ${ageGroup <= 4 ? 6 : ageGroup <= 5 ? 5 : 4}
        }
        
        Important notes:
        1. Create shapes/items that are SPECIFICALLY related to the chapter "${chapter.name}" - don't use generic content.
        2. Use math concepts that would be taught in this specific chapter.
        3. Adjust difficulty based on age: simpler for age 4, more complex for ages 5-6.
        ''';
      } else {
        // General prompt for other subjects
        prompt = '''Create content for a memory sequence game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The memory game should use shapes, colors, or symbols that are specifically relevant to this chapter.
        
        Chapter notes: ${chapter.notes ?? 'No additional notes'}
        
        Format the response as a JSON object with the following structure:
        {
          "title": "Memory Game: ${chapter.name}",
          "instructions": "Watch the sequence and repeat it",
          "initialSequenceLength": ${ageGroup <= 4 ? 2 : ageGroup <= 5 ? 3 : 4},
          "shapes": [
            {"icon": "🔴", "color": "red", "sound": "Red"},
            {"icon": "🔵", "color": "blue", "sound": "Blue"}
          ],
          "timePerLevel": ${ageGroup <= 4 ? 6 : ageGroup <= 5 ? 5 : 4}
        }
        
        Important notes:
        1. Create shapes/items that are SPECIFICALLY related to the chapter "${chapter.name}" - don't use generic content.
        2. Make sure all content is age-appropriate for $ageGroup-year-old children.
        3. For age 4, use simple, distinct shapes and colors.
        4. For age 5-6, you can use slightly more complex shapes and patterns.
        ''';
      }
      
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': prompt
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON from the response
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = text.substring(jsonStart, jsonEnd);
          final Map<String, dynamic> gameContent = jsonDecode(jsonStr) as Map<String, dynamic>;
          
          // Ensure the initial sequence length is appropriate for the age
          if (gameContent.containsKey('initialSequenceLength')) {
            final int ageAppropriateLength = ageGroup <= 4 ? 2 : ageGroup <= 5 ? 3 : 4;
            gameContent['initialSequenceLength'] = ageAppropriateLength;
          }
          
          // Ensure the time per level is appropriate for the age
          if (gameContent.containsKey('timePerLevel')) {
            final int ageAppropriateTime = ageGroup <= 4 ? 6 : ageGroup <= 5 ? 5 : 4;
            gameContent['timePerLevel'] = ageAppropriateTime;
          }
          
          return gameContent;
        }
      }
      return null;
    } catch (e) {
      print('Error generating memory sequence game content: $e');
      return null;
    }
  }
  
  // Generate content for sorting game based on subject and chapter
  Future<Map<String, dynamic>?> generateSortingGameContent(Subject subject, Chapter chapter) async {
    try {
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''Create content for a sorting game for children aged ${subject.moduleId} years old based on the subject: ${subject.name} and chapter: ${chapter.name}.
              
              The sorting game asks children to sort items into different categories by dragging and dropping them.
              
              Format the response as a JSON object with the following structure:
              {
                "title": "Sorting Game: ${chapter.name}",
                "instructions": "Sort the items into the correct categories",
                "ageGroup": ${subject.moduleId},
                "categories": [
                  {
                    "name": "Fruits",
                    "emoji": "🍎",
                    "color": "red"
                  },
                  {
                    "name": "Animals",
                    "emoji": "🐶",
                    "color": "blue"
                  }
                ],
                "items": [
                  {
                    "name": "Apple",
                    "emoji": "🍎",
                    "category": "Fruits"
                  },
                  {
                    "name": "Banana",
                    "emoji": "🍌",
                    "category": "Fruits"
                  },
                  {
                    "name": "Orange",
                    "emoji": "🍊",
                    "category": "Fruits"
                  },
                  {
                    "name": "Dog",
                    "emoji": "🐶",
                    "category": "Animals"
                  },
                  {
                    "name": "Cat",
                    "emoji": "🐱",
                    "category": "Animals"
                  },
                  {
                    "name": "Elephant",
                    "emoji": "🐘",
                    "category": "Animals"
                  }
                ]
              }
              
              Notes:
              1. Make the categories and items related to the subject and chapter content.
              2. For language subjects, consider categories like "Starting with A" vs "Starting with B".
              3. For math subjects, consider categories like "Even Numbers" vs "Odd Numbers".
              4. For "Iqra" or Arabic/Islamic studies, use appropriate Arabic/Islamic categories.
              5. Choose 2-3 categories that are clearly distinct from each other.
              6. Provide at least 6 items to sort, with a balanced distribution across categories.
              7. Make sure the items are age-appropriate and relevant to the subject.
              8. Choose emojis that clearly represent the categories and items.
              '''
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON from the response
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = text.substring(jsonStart, jsonEnd);
          return jsonDecode(jsonStr) as Map<String, dynamic>;
        }
        return null;
      }
      return null;
    } catch (e) {
      print('Error generating sorting game content: $e');
      return null;
    }
  }
  
  // Generate matching game content
  Future<Map<String, dynamic>?> generateMatchingGameContent(Subject subject, Chapter chapter) async {
    try {
      final ageGroup = subject.moduleId;
      
      // Create a context-specific prompt based on subject and chapter
      String prompt;
      
      final bool isJawiContent = subject.name.toLowerCase().contains('jawi') || 
                               subject.name.toLowerCase().contains('arabic') || 
                               chapter.name.toLowerCase().contains('jawi') || 
                               chapter.name.toLowerCase().contains('arabic');
      
      if (isJawiContent) {
        // Special prompt for Jawi/Arabic content
        prompt = '''Create content for a Jawi letter matching game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The matching game should pair Jawi letters with their sounds, names, or example words that are specifically relevant to this chapter.
        
        Chapter notes: ${chapter.notes ?? 'Basic Jawi letters'}
        
        Format the response as a JSON object with the following structure:
        {
          "title": "Jawi Matching: ${chapter.name}",
          "instructions": "Match each Jawi letter with its correct sound or example word.",
          "pairs": [
            {"emoji": "ا", "word": "Alif", "description": "First letter of Jawi alphabet"},
            {"emoji": "ب", "word": "Ba", "description": "Second letter of Jawi alphabet"}
          ]
        }
        
        Important notes:
        1. Create pairs that are SPECIFICALLY related to the chapter "${chapter.name}" - don't use generic content.
        2. Use the actual Jawi letters that would be taught in this specific chapter.
        3. For age 4, include only 3-4 pairs of the simplest letters.
        4. For age 5-6, include 5-6 pairs of appropriate difficulty.
        ''';
      } else if (subjectContext == 'math') {
        // Special prompt for math content
        prompt = '''Create content for a math matching game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The matching game should pair numbers with quantities, math symbols with their meanings, or simple equations with their answers that are specifically relevant to this chapter.
        
        Chapter notes: ${chapter.notes ?? 'Basic math concepts'}
        
        Format the response as a JSON object with the following structure:
        {
          "title": "Math Matching: ${chapter.name}",
          "instructions": "Match each number with the correct quantity.",
          "pairs": [
            {"emoji": "1", "word": "One", "description": "The number 1"},
            {"emoji": "2", "word": "Two", "description": "The number 2"}
          ]
        }
        
        Important notes:
        1. Create pairs that are SPECIFICALLY related to the chapter "${chapter.name}" - don't use generic content.
        2. Use math concepts that would be taught in this specific chapter.
        3. Adjust difficulty based on age: simpler for age 4, more complex for ages 5-6.
        ''';
      } else {
        // General prompt for other subjects
        prompt = '''Create content for a matching game for children aged $ageGroup based on the subject: ${subject.name} and chapter: ${chapter.name}.
        
        The matching game should pair related items that are specifically relevant to this chapter.
        
        Chapter notes: ${chapter.notes ?? 'No additional notes'}
        
        Format the response as a JSON object with the following structure:
        {
          "title": "Matching Game: ${chapter.name}",
          "instructions": "Match each item with its pair.",
          "pairs": [
            {"emoji": "🍎", "word": "Apple", "description": "A red fruit"},
            {"emoji": "🍌", "word": "Banana", "description": "A yellow fruit"}
          ]
        }
        
        Important notes:
        1. Create pairs that are SPECIFICALLY related to the chapter "${chapter.name}" - don't use generic content.
        2. Make sure all content is age-appropriate for $ageGroup-year-old children.
        3. For age 4, use simple, familiar items with clear relationships.
        4. For age 5-6, you can use slightly more complex relationships.
        ''';
      }
      
      final response = await http.post(
        Uri.parse('${GeminiService.baseUrl}/${GeminiService.model}:generateContent?key=${GeminiService.apiKey}'),
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': prompt
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON from the response
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}') + 1;
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
          final jsonStr = text.substring(jsonStart, jsonEnd);
          return jsonDecode(jsonStr) as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error generating matching game content: $e');
      return null;
    }
  }
}
