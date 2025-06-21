import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subject.dart';
import '../models/note_content.dart';
import '../widgets/flashcard_widget.dart';
import 'gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Extension for GeminiService to add note generation functionality
extension GeminiServiceNoteExtension on GeminiService {
  // Generate flashcard note content using Gemini API with function calling
  Future<List<NoteContentElement>> generateNoteContent({
    required Subject subject,
    required Chapter chapter,
    required int age,
    required String language,
  }) async {
    try {
      // Check cache first
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'flashcard_note_${subject.id}_${chapter.id}_${age}_${language}';
      final cachedResult = prefs.getString(cacheKey);
      
      if (cachedResult != null) {
        final List<dynamic> jsonList = jsonDecode(cachedResult);
        return jsonList.map((json) => NoteContentElement.fromJson(json)).toList();
      }
      
      // Prepare the function calling schema for structured note content
      final functionCallingSchema = {
        "name": "generate_flashcard_note",
        "description": "Generate structured flashcard note content for educational purposes",
        "parameters": {
          "type": "object",
          "properties": {
            "title": {
              "type": "string",
              "description": "The title of the note"
            },
            "elements": {
              "type": "array",
              "description": "Array of note content elements",
              "items": {
                "type": "object",
                "properties": {
                  "type": {
                    "type": "string",
                    "enum": ["text", "image", "audio"],
                    "description": "Type of content element"
                  },
                  "content": {
                    "type": "string",
                    "description": "For text elements: the text content; For image/audio: description or URL"
                  },
                  "position": {
                    "type": "integer",
                    "description": "Position order of the element"
                  },
                  "isBold": {
                    "type": "boolean",
                    "description": "For text: whether it should be bold"
                  },
                  "isItalic": {
                    "type": "boolean",
                    "description": "For text: whether it should be italic"
                  },
                  "isList": {
                    "type": "boolean",
                    "description": "For text: whether it should be a list item"
                  },
                  "fontSize": {
                    "type": "number",
                    "description": "For text: font size"
                  },
                  "caption": {
                    "type": "string",
                    "description": "For image: caption text"
                  },
                  "title": {
                    "type": "string",
                    "description": "For audio: title of audio clip"
                  }
                },
                "required": ["type", "content", "position"]
              }
            }
          },
          "required": ["title", "elements"]
        }
      };
      
      // Prepare age-specific instructions
      final String ageSpecificInstructions = _getAgeSpecificInstructions(age);
      
      // Determine if the language is RTL
      final bool isRightToLeft = _isRightToLeftLanguage(language);
      final String directionInstruction = isRightToLeft ? "The content should be formatted for right-to-left reading." : "";
      
      final prompt = '''
      Generate educational flashcard note content about "${subject.name}: ${chapter.name}" for age $age students in $language language.
      $directionInstruction
      
      $ageSpecificInstructions
      
      Include appropriate text elements, suggest image descriptions (I'll replace with actual images later), 
      and suggest audio elements where appropriate.
      
      For images, provide detailed image descriptions that I can use to create or find appropriate images.
      For audio elements, describe what the audio should contain (e.g., "Audio explaining how photosynthesis works").
      
      The content should be culturally appropriate and engaging for the target age group.
      ''';
      
      // Call the Gemini API with function calling
      final response = await callGeminiAPIWithFunctionCalling(
        prompt,
        functionCallingSchema,
      );
      
      // Parse the function calling response
      final Map<String, dynamic> functionResponse = jsonDecode(response);
      final List<dynamic> elements = functionResponse['elements'];
      
      // Convert to NoteContentElement objects
      final List<NoteContentElement> noteElements = [];
      int position = 0;
      
      for (var element in elements) {
        position++;
        final String type = element['type'];
        final timestamp = Timestamp.now();
        final String id = DateTime.now().millisecondsSinceEpoch.toString() + position.toString();
        
        switch (type) {
          case 'text':
            noteElements.add(TextElement(
              id: id,
              position: position,
              createdAt: timestamp,
              content: element['content'],
              isBold: element['isBold'] ?? false,
              isItalic: element['isItalic'] ?? false,
              isList: element['isList'] ?? false,
              fontSize: element['fontSize'] ?? _getDefaultFontSizeForAge(age),
            ));
            break;
            
          case 'image':
            noteElements.add(ImageElement(
              id: id,
              position: position,
              createdAt: timestamp,
              imageUrl: _getPlaceholderImageUrl(element['content']),
              caption: element['caption'] ?? element['content'],
            ));
            break;
            
          case 'audio':
            noteElements.add(AudioElement(
              id: id,
              position: position,
              createdAt: timestamp,
              audioUrl: _getPlaceholderAudioUrl(),
              title: element['title'] ?? element['content'],
            ));
            break;
        }
      }
      
      // Cache the result
      final jsonList = noteElements.map((e) => e.toJson()).toList();
      await prefs.setString(cacheKey, jsonEncode(jsonList));
      
      return noteElements;
    } catch (e) {
      // Return fallback content on error
      return _generateFallbackNoteContent(subject, chapter, age, language);
    }
  }
  
  // Check if a language is right-to-left
  bool _isRightToLeftLanguage(String language) {
    final rtlLanguages = ['ar', 'he', 'fa', 'ur', 'ps', 'sd', 'ms-Arab'];
    return rtlLanguages.contains(language.split('-').first) || language.contains('Arab');
  }
  
  // Get age-specific instructions
  String _getAgeSpecificInstructions(int age) {
    switch (age) {
      case 4:
        return 'For age 4: Use very simple bullet points, short sentences, and include audio snippets for each key point. Use large, colorful images. Limit text to 1-2 sentences per point.';
      case 5:
        return 'For age 5: Use short paragraphs with key terms highlighted. Include "🔊" play buttons for important concepts. Balance text and images equally.';
      case 6:
        return 'For age 6: Use more detailed paragraphs with embedded mini-quizzes. Include more complex vocabulary with explanations. Use a mix of images and text with more emphasis on text.';
      default:
        return 'Use age-appropriate content with a mix of text, images, and interactive elements.';
    }
  }
  
  // Get default font size based on age
  double _getDefaultFontSizeForAge(int age) {
    switch (age) {
      case 4: return 24.0;
      case 5: return 20.0;
      case 6: return 18.0;
      default: return 16.0;
    }
  }
  
  // Get placeholder image URL based on description
  String _getPlaceholderImageUrl(String description) {
    // In a real implementation, you might use an image generation API
    // For now, return a placeholder
    return 'https://via.placeholder.com/400x300?text=${Uri.encodeComponent(description)}';
  }
  
  // Get placeholder audio URL
  String _getPlaceholderAudioUrl() {
    // In a real implementation, you might use a text-to-speech API
    // For now, return a placeholder
    return 'https://example.com/placeholder-audio.mp3';
  }
  
  // Generate fallback content in case of API failure
  List<NoteContentElement> _generateFallbackNoteContent(
    Subject subject,
    Chapter chapter,
    int age,
    String language,
  ) {
    final List<NoteContentElement> elements = [];
    final timestamp = Timestamp.now();
    final bool isRtl = _isRightToLeftLanguage(language);
    
    // Add title
    elements.add(TextElement(
      id: 'title_1',
      position: 1,
      createdAt: timestamp,
      content: '${subject.name}: ${chapter.name}',
      isBold: true,
      fontSize: 28.0,
    ));
    
    // Add content based on age group
    switch (age) {
      case 4:
        // For age 4: simple bullet points + optional TTS audio snippets
        elements.add(TextElement(
          id: 'intro_2',
          position: 2,
          createdAt: timestamp,
          content: 'Let\'s learn about ${chapter.name}!',
          fontSize: 24.0,
          isBold: true,
        ));
        
        // Add a simple image
        elements.add(ImageElement(
          id: 'image_3',
          position: 3,
          createdAt: timestamp,
          imageUrl: 'https://via.placeholder.com/400x300?text=${Uri.encodeComponent('${chapter.name}')}',
          caption: 'Picture of ${chapter.name}',
        ));
        
        // Add simple bullet points
        for (int i = 0; i < 3; i++) {
          elements.add(TextElement(
            id: 'bullet_${i+4}',
            position: i + 4,
            createdAt: timestamp,
            content: 'Simple fact ${i+1} about ${chapter.name}.',
            isList: true,
            fontSize: 24.0,
          ));
          
          // Add audio snippet for each bullet point
          elements.add(AudioElement(
            id: 'audio_${i+7}',
            position: i + 7,
            createdAt: timestamp,
            audioUrl: 'https://example.com/placeholder-audio-${i+1}.mp3',
            title: 'Listen to fact ${i+1}',
          ));
        }
        break;
        
      case 5:
        // For age 5: short paragraphs + highlighted key terms + "🔊" play buttons
        elements.add(TextElement(
          id: 'intro_2',
          position: 2,
          createdAt: timestamp,
          content: 'Welcome to our lesson about ${chapter.name}.',
          fontSize: 20.0,
        ));
        
        // Add an image with caption
        elements.add(ImageElement(
          id: 'image_3',
          position: 3,
          createdAt: timestamp,
          imageUrl: 'https://via.placeholder.com/450x350?text=${Uri.encodeComponent('${chapter.name}')}',
          caption: 'This is ${chapter.name}',
        ));
        
        // Add short paragraphs with highlighted terms
        elements.add(TextElement(
          id: 'para_4',
          position: 4,
          createdAt: timestamp,
          content: '${chapter.name} is very interesting. It has many **important features** that we can learn about.',
          fontSize: 20.0,
        ));
        
        // Add audio button
        elements.add(AudioElement(
          id: 'audio_5',
          position: 5,
          createdAt: timestamp,
          audioUrl: 'https://example.com/placeholder-audio.mp3',
          title: '🔊 Listen to learn about ${chapter.name}',
        ));
        
        // Add another paragraph with highlighted term
        elements.add(TextElement(
          id: 'para_6',
          position: 6,
          createdAt: timestamp,
          content: 'When we study ${chapter.name}, we discover **new concepts** that help us understand ${subject.name} better.',
          fontSize: 20.0,
        ));
        break;
        
      case 6:
      default:
        // For age 6: detailed paragraphs + embedded mini-quizzes
        elements.add(TextElement(
          id: 'intro_2',
          position: 2,
          createdAt: timestamp,
          content: 'In this lesson, we will explore ${chapter.name} in detail and learn about its importance in ${subject.name}.',
          fontSize: 18.0,
        ));
        
        // Add an image
        elements.add(ImageElement(
          id: 'image_3',
          position: 3,
          createdAt: timestamp,
          imageUrl: 'https://via.placeholder.com/500x400?text=${Uri.encodeComponent('${chapter.name} Diagram')}',
          caption: 'Detailed diagram of ${chapter.name}',
        ));
        
        // Add detailed paragraph
        elements.add(TextElement(
          id: 'para_4',
          position: 4,
          createdAt: timestamp,
          content: '${chapter.name} is a fascinating topic in ${subject.name}. It involves several key concepts that we need to understand. These concepts help us build a foundation for more advanced learning.',
          fontSize: 18.0,
        ));
        
        // Add mini-quiz
        elements.add(TextElement(
          id: 'quiz_5',
          position: 5,
          createdAt: timestamp,
          content: 'Mini-Quiz: What is the main purpose of ${chapter.name}? Think about it before moving on!',
          isBold: true,
          fontSize: 18.0,
        ));
        
        // Add another detailed paragraph
        elements.add(TextElement(
          id: 'para_6',
          position: 6,
          createdAt: timestamp,
          content: 'When we examine ${chapter.name} more closely, we discover that it consists of multiple components. Each component serves a specific function and contributes to the overall system.',
          fontSize: 18.0,
        ));
        break;
    }
    
    // Add conclusion appropriate for the age
    elements.add(TextElement(
      id: 'conclusion',
      position: elements.length + 1,
      createdAt: timestamp,
      content: age <= 4 ? 'Great job learning!' : 
               age == 5 ? 'You\'ve learned a lot about ${chapter.name}. Well done!' :
               'Congratulations on completing this lesson about ${chapter.name}. You now understand the key concepts!',
      isItalic: true,
      fontSize: _getDefaultFontSizeForAge(age),
    ));
    
    return elements;
  }
}

// Extension for GeminiService to add flashcard generation functionality
extension GeminiServiceFlashcardExtension on GeminiService {
  // Generate flashcards using Gemini API
  Future<List<FlashcardItem>> generateFlashcards(
    Subject subject,
    Chapter chapter,
    int age,
    String language,
  ) async {
    try {
      // Determine the language script and direction
      final String languageScript = _determineLanguageScript(language);
      final bool isRightToLeft = _isRightToLeftLanguage(language);
      
      // Build the prompt for Gemini API
      final Map<String, dynamic> requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text": """
                Generate educational flashcards for children aged $age learning about ${chapter.name} in ${subject.name}.
                The content should be in $language language using $languageScript script.
                
                Please generate a JSON array of 10 flashcards with the following structure:
                [
                  {
                    "image_url": "URL to a relevant educational image",
                    "audio_url": "URL to audio pronunciation or explanation",
                    "question_text": "Text for the question side of the flashcard",
                    "answer_text": "Text for the answer side of the flashcard"
                  }
                ]
                
                Guidelines:
                - For age 4: Keep text extremely simple, focus on single words or very short phrases
                - For age 5: Use simple sentences with basic vocabulary
                - For age 6: Use complete sentences with slightly more advanced vocabulary
                - Make sure all text is in $language language using $languageScript script
                - For image_url and audio_url, provide URLs that would work in a real application
                - Make the content educational and appropriate for children
                - Ensure the content is directly related to ${chapter.name} in ${subject.name}
                
                Return ONLY the JSON array with no additional text or explanation.
                """
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.2,
          "topK": 32,
          "topP": 0.95,
          "maxOutputTokens": 8192,
          "responseMimeType": "application/json"
        },
        "tools": [
          {
            "functionDeclarations": [
              {
                "name": "generateFlashcards",
                "description": "Generate educational flashcards for children",
                "parameters": {
                  "type": "object",
                  "properties": {
                    "flashcards": {
                      "type": "array",
                      "description": "Array of flashcard objects",
                      "items": {
                        "type": "object",
                        "properties": {
                          "image_url": {
                            "type": "string",
                            "description": "URL to a relevant educational image"
                          },
                          "audio_url": {
                            "type": "string",
                            "description": "URL to audio pronunciation or explanation"
                          },
                          "question_text": {
                            "type": "string",
                            "description": "Text for the question side of the flashcard"
                          },
                          "answer_text": {
                            "type": "string",
                            "description": "Text for the answer side of the flashcard"
                          }
                        },
                        "required": ["image_url", "audio_url", "question_text", "answer_text"]
                      }
                    }
                  },
                  "required": ["flashcards"]
                }
              }
            ]
          }
        ]
      };

      // Make the API call
      final response = await http.post(
        Uri.parse('$baseUrl/$model:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Extract the function call result
        final functionCall = jsonResponse['candidates'][0]['content']['parts'][0]['functionCall'];
        
        if (functionCall != null && functionCall['name'] == 'generateFlashcards') {
          final arguments = jsonDecode(functionCall['args']['flashcards']);
          
          // Process the flashcards
          final List<dynamic> flashcardsJson = arguments;
          final List<FlashcardItem> flashcards = flashcardsJson.map((json) {
            // Ensure we have valid URLs for images and audio
            String imageUrl = json['image_url'] ?? '';
            String audioUrl = json['audio_url'] ?? '';
            
            // Use placeholder URLs if the API returns invalid or empty URLs
            if (!_isValidUrl(imageUrl)) {
              imageUrl = _getPlaceholderImageUrl(subject.name, chapter.name);
            }
            
            if (!_isValidUrl(audioUrl)) {
              audioUrl = _getPlaceholderAudioUrl(subject.name, chapter.name);
            }
            
            return FlashcardItem(
              imageUrl: imageUrl,
              audioUrl: audioUrl,
              questionText: json['question_text'] ?? '',
              answerText: json['answer_text'] ?? '',
            );
          }).toList();
          
          return flashcards;
        }
      }
      
      // If we couldn't get valid flashcards from the API, generate placeholder flashcards
      return _generatePlaceholderFlashcards(subject, chapter, age, language);
    } catch (e) {
      print('Error generating flashcards: $e');
      // Return placeholder flashcards in case of error
      return _generatePlaceholderFlashcards(subject, chapter, age, language);
    }
  }
  
  // Generate placeholder flashcards when API fails
  List<FlashcardItem> _generatePlaceholderFlashcards(
    Subject subject,
    Chapter chapter,
    int age,
    String language,
  ) {
    final List<FlashcardItem> placeholders = [];
    final String subjectContext = _getSubjectContext(subject.name);
    
    // Generate 5 placeholder flashcards
    for (int i = 0; i < 5; i++) {
      placeholders.add(
        FlashcardItem(
          imageUrl: _getPlaceholderImageUrl(subject.name, chapter.name),
          audioUrl: _getPlaceholderAudioUrl(subject.name, chapter.name),
          questionText: 'Flashcard ${i + 1} for ${chapter.name}',
          answerText: 'Answer for flashcard ${i + 1}',
        ),
      );
    }
    
    return placeholders;
  }
  
  // Get placeholder image URL based on subject context
  String _getPlaceholderImageUrl(String subjectName, String chapterName) {
    final String context = _getSubjectContext(subjectName);
    
    // Use the existing image URLs from the GeminiService class
    final imageUrls = _imageUrls[context] ?? _imageUrls['default']!;
    return imageUrls[0]; // Just use the first one as a placeholder
  }
  
  // Get placeholder audio URL based on subject context
  String _getPlaceholderAudioUrl(String subjectName, String chapterName) {
    final String context = _getSubjectContext(subjectName);
    
    // Use the existing audio URLs from the GeminiService class
    final audioUrls = _audioUrls[context] ?? _audioUrls['default']!;
    return audioUrls[0]; // Just use the first one as a placeholder
  }
  
  // Check if a URL is valid
  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (e) {
      return false;
    }
  }
  
  // Determine language script based on language name
  String _determineLanguageScript(String language) {
    switch (language.toLowerCase()) {
      case 'arabic':
        return 'Arabic';
      case 'jawi':
        return 'Jawi';
      case 'chinese':
      case 'mandarin':
        return 'Chinese';
      case 'tamil':
        return 'Tamil';
      case 'hindi':
        return 'Devanagari';
      case 'malay':
      case 'bahasa malaysia':
        return 'Latin';
      default:
        return 'Latin';
    }
  }
  
  // Check if language is right-to-left
  bool _isRightToLeftLanguage(String language) {
    final rtlLanguages = ['arabic', 'jawi', 'urdu', 'hebrew', 'persian'];
    return rtlLanguages.contains(language.toLowerCase());
  }
}
