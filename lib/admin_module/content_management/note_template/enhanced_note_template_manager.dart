import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import '../../../models/note_content.dart';
import '../../../services/gemini_notes_service.dart';
import 'flashcard_template_generator_complete.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/flashcard_element.dart' as custom_flashcard;

class EnhancedNoteTemplateManager {
  final GeminiNotesService _geminiService = GeminiNotesService();
  
  // Map of chapter card rules for different subjects and chapters
  // Format: 'subject_chapter': {count: base card count, multiplier: age multiplier, bonus: additional cards}
  final Map<String, Map<String, dynamic>> chapterCardRules = {
    // Math rules
    'math_counting': {'count': 5, 'multiplier': 0.5, 'bonus': 0},
    'math_shapes': {'count': 4, 'multiplier': 0.5, 'bonus': 1},
    'math_numbers': {'count': 6, 'multiplier': 0.3, 'bonus': 0},
    'math_addition': {'count': 4, 'multiplier': 0.5, 'bonus': 1},
    'math_subtraction': {'count': 4, 'multiplier': 0.5, 'bonus': 1},
    
    // Science rules
    'science_animals': {'count': 5, 'multiplier': 0.4, 'bonus': 1},
    'science_plants': {'count': 4, 'multiplier': 0.5, 'bonus': 0},
    'science_weather': {'count': 3, 'multiplier': 0.7, 'bonus': 0},
    'science_body': {'count': 5, 'multiplier': 0.4, 'bonus': 1},
    
    // Language rules
    'language_alphabet': {'count': 6, 'multiplier': 0.3, 'bonus': 0},
    'language_words': {'count': 5, 'multiplier': 0.4, 'bonus': 1},
    'language_sentences': {'count': 4, 'multiplier': 0.5, 'bonus': 0},
    'language_stories': {'count': 3, 'multiplier': 0.7, 'bonus': 0},
    
    // Jawi rules
    'jawi_huruf': {'count': 6, 'multiplier': 0.3, 'bonus': 0},
    'jawi_harakat': {'count': 5, 'multiplier': 0.4, 'bonus': 0},
    'jawi_words': {'count': 4, 'multiplier': 0.5, 'bonus': 1},
    
    // Default rule
    'default': {'count': 4, 'multiplier': 0.5, 'bonus': 0},
  };
  
  // Calculate the number of cards based on subject, chapter, and age
  int calculateCardCount(String subject, String chapter, int age) {
    // Normalize subject and chapter names for lookup
    final normalizedSubject = subject.toLowerCase().trim();
    final normalizedChapter = chapter.toLowerCase().trim();

    // Special handling for alphabet/character sets - override to 26 or 37 cards regardless of age
    if (normalizedChapter.contains('alphabet') || 
        normalizedChapter.contains('abjad') || 
        normalizedChapter.contains('huruf')) {
      // Jawi alphabet has 37 letters, English has 26
      return normalizedSubject.contains('jawi') ? 37 : 26;
    }
    
    // Age-specific card counts as per requirements
    switch (age) {
      case 4:
        return 8;  // 8 cards for age 4
      case 5:
        return 12; // 12 cards for age 5
      case 6:
      default:
        return 16; // 16 cards for age 6
    }
  }
  
  // Determine cards per page based on screen width
  int getCardsPerPage(double screenWidth) {
    // Use 1 card per page on phones, 2 on tablets/larger screens
    return screenWidth < 600 ? 1 : 2;
  }
  
  // Generate flashcard content based on subject, chapter, age, language, and count
  List<Map<String, dynamic>> generateFlashcardContent({
    required String subject,
    required String chapter,
    required int age,
    required String language,
    required int count,
  }) {
    // Use the dedicated FlashcardTemplateGenerator class
    return FlashcardTemplateGenerator.generateFlashcards(
      subject: subject,
      chapter: chapter,
      age: age,
      language: language,
      count: count,
    );
  }
  
  // Convert flashcards to JSON string
  String flashcardsToJson(List<Map<String, dynamic>> flashcards) {
    return FlashcardTemplateGenerator.toJson(flashcards);
  }
  
  // Calculate total pages needed based on card count and screen size
  int calculateTotalPages(int cardCount, double screenWidth) {
    final int cardsPerPage = getCardsPerPage(screenWidth);
    return (cardCount / cardsPerPage).ceil();
  }
  
  // Helper method to get example word for each English letter
  String _getExampleWordForLetter(String letter) {
    final Map<String, String> exampleWords = {
      'A': 'Apple',
      'B': 'Ball',
      'C': 'Cat',
      'D': 'Dog',
      'E': 'Elephant',
      'F': 'Fish',
      'G': 'Goat',
      'H': 'House',
      'I': 'Ice cream',
      'J': 'Jelly',
      'K': 'Kite',
      'L': 'Lion',
      'M': 'Monkey',
      'N': 'Nest',
      'O': 'Orange',
      'P': 'Pencil',
      'Q': 'Queen',
      'R': 'Rabbit',
      'S': 'Sun',
      'T': 'Tree',
      'U': 'Umbrella',
      'V': 'Van',
      'W': 'Water',
      'X': 'X-ray',
      'Y': 'Yo-yo',
      'Z': 'Zebra',
    };
    
    return exampleWords[letter] ?? letter;
  }

  // Helper method to get ordinal suffix (1st, 2nd, 3rd, etc.)
  String _getOrdinalSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // Age-specific font sizes
  double getFontSizeForAge(int age, {bool isTitle = false}) {
    if (isTitle) {
      switch (age) {
        case 4: return 28.0;
        case 5: return 24.0;
        case 6: return 22.0;
        default: return 24.0;
      }
    } else {
      switch (age) {
        case 4: return 24.0;
        case 5: return 20.0;
        case 6: return 18.0;
        default: return 20.0;
      }
    }
  }

  // Age-specific image ratios (percentage of page)
  double getImageRatioForAge(int age) {
    switch (age) {
      case 4: return 0.7; // 70% images for age 4
      case 5: return 0.5; // 50% images for age 5
      case 6: return 0.4; // 40% images for age 6
      default: return 0.5;
    }
  }

  // Get page limit based on age
  int getPageLimitForAge(int age) {
    switch (age) {
      case 4: return 10;
      case 5: return 15;
      case 6: return 20;
      default: return 15;
    }
  }

  // Get vocabulary complexity based on age
  String getVocabularyLevelForAge(int age) {
    switch (age) {
      case 4: return "very simple with basic words of 1-2 syllables";
      case 5: return "simple with familiar words up to 2-3 syllables";
      case 6: return "moderately complex with some new vocabulary up to 3-4 syllables";
      default: return "simple";
    }
  }

  // Get sentence complexity based on age
  String getSentenceComplexityForAge(int age) {
    switch (age) {
      case 4: return "very short sentences with 3-5 words";
      case 5: return "short sentences with 5-7 words";
      case 6: return "medium-length sentences with 7-10 words";
      default: return "short sentences";
    }
  }

  // Get interactive elements based on age
  List<String> getInteractiveElementsForAge(int age) {
    final List<String> baseElements = ["colorful images", "audio narration"];
    
    switch (age) {
      case 4:
        return [...baseElements, "simple questions", "matching activities"];
      case 5:
        return [...baseElements, "fill-in-the-blank exercises", "counting activities", "simple quizzes"];
      case 6:
        return [...baseElements, "word puzzles", "sequencing activities", "comprehension questions"];
      default:
        return baseElements;
    }
  }

  // Get theme colors based on age
  List<Color> getThemeColorsForAge(int age) {
    switch (age) {
      case 4:
        return [
          Colors.red.shade300,
          Colors.yellow.shade300,
          Colors.blue.shade300,
          Colors.green.shade300,
          Colors.purple.shade300,
        ];
      case 5:
        return [
          Colors.teal.shade300,
          Colors.orange.shade300,
          Colors.indigo.shade300,
          Colors.pink.shade300,
          Colors.lightGreen.shade300,
        ];
      case 6:
        return [
          Colors.deepPurple.shade300,
          Colors.amber.shade300,
          Colors.cyan.shade300,
          Colors.lightBlue.shade300,
          Colors.deepOrange.shade300,
        ];
      default:
        return [
          Colors.blue.shade300,
          Colors.green.shade300,
          Colors.orange.shade300,
          Colors.purple.shade300,
          Colors.red.shade300,
        ];
    }
  }

  // Get a random theme color for the given age
  Color getRandomThemeColorForAge(int age) {
    final colors = getThemeColorsForAge(age);
    return colors[math.Random().nextInt(colors.length)];
  }

  // Generate interactive note content for different template types
  Future<Map<String, dynamic>> generateInteractiveNoteContent({
    required String templateId,
    required String subject,
    required String chapter,
    required int age,
    double screenWidth = 400, // Default to phone width if not provided
    String language = 'en', // Default language is English
  }) async {
    // Calculate card count and pages
    final int cardCount = calculateCardCount(subject, chapter, age);
    final int cardsPerPage = getCardsPerPage(screenWidth);
    final int totalPages = calculateTotalPages(cardCount, screenWidth);
    
    try {
      // For flashcard templates, use the dedicated FlashcardTemplateGenerator
      if (templateId.toLowerCase() == 'flashcard') {
        // Calculate the appropriate number of flashcards based on subject and chapter
        final int flashcardCount = calculateCardCount(subject, chapter, age);
        
        // Generate flashcards using the dedicated generator
        final flashcards = generateFlashcardContent(
          subject: subject,
          chapter: chapter,
          age: age,
          language: language,
          count: flashcardCount,
        );
        
        // Convert flashcards to a format compatible with the note preview system
        final Map<String, dynamic> processedContent = {
          'title': 'Flashcard: ${chapter}',
          'elements': flashcards.map((card) {
            return {
              'type': 'flashcard',
              'image_prompt': card['image_prompt'],
              'label': card['label'],
              'question_text': card['question_text'] ?? '',
              'audio_prompt': card['audio_prompt'] ?? '',
            };
          }).toList(),
          'cardCount': flashcards.length,
          'cardsPerPage': cardsPerPage,
          'totalPages': totalPages,
        };
        
        return processedContent;
      } else {
        // For non-flashcard templates, use the original Gemini-based approach
        // Prepare the prompt based on template type and age
        String prompt = _buildPromptForTemplate(
          templateId: templateId,
          subject: subject,
          chapter: chapter,
          age: age,
        );
        
        // Generate content using Gemini
        final response = await _geminiService.generateNoteContent(
          subject: subject,
          chapter: chapter,
          age: age,
          templateType: templateId,
        );
        
        // Process the response directly
        if (response == null) {
          throw Exception('Failed to generate note content');
        }
        
        // Process the response into structured note content
        Map<String, dynamic> processedContent = _processGeminiResponse(response, templateId, age);
        
        // Add paging information to the response
        processedContent['cardCount'] = cardCount;
        processedContent['cardsPerPage'] = cardsPerPage;
        processedContent['totalPages'] = totalPages;
        
        return processedContent;
      }
    } catch (e) {
      print('Error generating note content: $e');
      return {
        'title': 'Error: Could not generate content',
        'elements': [
          {
            'type': 'text',
            'content': 'There was an error generating the note content. Please try again later.',
            'isBold': false,
            'isItalic': true,
          }
        ],
        'cardCount': cardCount,
        'cardsPerPage': cardsPerPage,
        'totalPages': totalPages,
      };
    }
  }

  // Build a prompt for flashcard notes
  String _buildPromptForTemplate({
    required String templateId,
    required String subject,
    required String chapter,
    required int age,
  }) {
    final normalizedSubject = subject.toLowerCase().trim();
    final normalizedChapter = chapter.toLowerCase().trim();

    // Special prompt for Jawi Huruf and Language Alphabet
    if ((normalizedSubject == 'jawi' && normalizedChapter.contains('huruf')) ||
        (normalizedSubject == 'language' && normalizedChapter.contains('alphabet'))) {
      
      final isJawi = normalizedSubject == 'jawi';
      final letterCount = isJawi ? 37 : 26;
      final alphabetName = isJawi ? 'Jawi alphabet (huruf)' : 'English alphabet';
      final letterExample = isJawi ? "'letter': 'ا', 'name': 'Alif'" : "'letter': 'A', 'name': 'A'";
      final letterSet = isJawi ? "from Alif to Ya, including letters like Pa, Ga, Cha, Nga, Nya, Va, and Hamzah" : "from A to Z";

      return """
      Create a set of $letterCount flashcards for the $alphabetName.
      Each flashcard should represent a single letter.
      For each letter, provide the following in a structured format:
      - 'letter': The letter character (e.g., ${isJawi ? "'ا'" : "'A'"}).
      - 'name': The name of the letter (e.g., ${isJawi ? "'Alif'" : "'A'"}).

      Return the response as a JSON object with a single key "elements", which is a list of these flashcard objects.
      Each object in the list should have 'type': 'flashcard_letter'.
      Example for one element:
      {
        "type": "flashcard_letter",
        $letterExample
      }
      Generate all $letterCount letters $letterSet.
      Do not add any extra text, titles, or explanations outside of the JSON structure.
      The entire output must be a valid JSON.
      """;
    }

    final vocabularyLevel = getVocabularyLevelForAge(age);
    final sentenceComplexity = getSentenceComplexityForAge(age);
    final interactiveElements = getInteractiveElementsForAge(age).join(', ');
    final imageRatio = (getImageRatioForAge(age) * 100).toInt();
    final cardCount = calculateCardCount(subject, chapter, age);
    
    // Age-specific content format requirements
    String ageSpecificFormat;
    if (age == 4) {
      ageSpecificFormat = "very simple bullet-point captions with optional TTS audio snippets that auto-play";
    } else if (age == 5) {
      ageSpecificFormat = "short paragraphs with inline key-term highlights and a '🔊' play button";
    } else { // age 6
      ageSpecificFormat = "more detailed paragraphs enriched with embedded mini-quizzes";
    }
    
    return """
    Create flashcard educational content for children age $age about '$chapter' in the subject '$subject'.
    The content should be:
    - Appropriate for $age-year-old children
    - Using vocabulary that is $vocabularyLevel
    - Using $sentenceComplexity
    - Including $interactiveElements
    - Having approximately $imageRatio% visual content and ${100 - imageRatio}% text content
    - IMPORTANT: Generate EXACTLY $cardCount flashcards, no more and no less
    - IMPORTANT: Format the content as $ageSpecificFormat
    
    Structure each flashcard with:
    - An engaging title or question
    - Key concepts explained simply
    - Visual examples with images
    - Interactive questions or activities
    - Audio elements where appropriate
    
    Each flashcard should be self-contained and focus on a single concept or idea.
    """;
  }

  // Process Gemini response into structured note content
  Map<String, dynamic> _processGeminiResponse(Map<String, dynamic> response, String templateId, int age) {
    // Extract title from the response or use a default
    String title = response['title'] ?? 'Learning About Huruf';
    List<Map<String, dynamic>> elements = [];
    
    // Add age-specific metadata based on requirements
    Map<String, dynamic> ageMetadata = {
      'autoPlayAudio': age == 4, // Auto-play for age 4 only
      'showPlayButton': age >= 5, // Show play button for ages 5+
      'showDetailedText': age >= 6, // Show more detailed text for age 6+
      'cardsPerPage': 1, // Always use 1 card per page for better display
      'defaultCardCount': age == 4 ? 8 : (age == 5 ? 12 : 16), // Default card count based on age
    };

    // Check if this is a Jawi or alphabet subject
    final bool isAlphabetContent = templateId == 'flashcard' && 
        (response['subject']?.toString().toLowerCase().contains('jawi') == true ||
         response['chapter']?.toString().toLowerCase().contains('huruf') == true ||
         response['subject']?.toString().toLowerCase().contains('language') == true ||
         response['chapter']?.toString().toLowerCase().contains('alphabet') == true);

    // Special handling for alphabet content
    if (isAlphabetContent) {
      try {
        // Try to extract the content from various possible response formats
        var rawContent = response['content'] ?? response['text'] ?? response['response'] ?? '';
        
        // If we have a string response, try to parse it as JSON
        if (rawContent is String && rawContent.isNotEmpty) {
          try {
            // Try to extract JSON from the text
            final jsonStart = rawContent.indexOf('{');
            final jsonEnd = rawContent.lastIndexOf('}');
            
            if (jsonStart >= 0 && jsonEnd > jsonStart) {
              final jsonStr = rawContent.substring(jsonStart, jsonEnd + 1);
              final parsedJson = json.decode(jsonStr);
              
              if (parsedJson['elements'] is List) {
                for (var element in parsedJson['elements']) {
                  if (element is Map<String, dynamic> && 
                      element['letter'] != null && 
                      element['name'] != null) {
                    elements.add({
                      'type': 'text',
                      'content': element['letter'],
                      'isBold': true,
                      'fontSize': 80.0,
                      'metadata': {'name': element['name']}
                    });
                  }
                }
              }
            }
          } catch (e) {
            print('Error parsing JSON from response: $e');
            // Continue to fallback handling
          }
        }
        
        // If we still don't have elements, try to extract from the elements array directly
        if (elements.isEmpty && response['elements'] != null && response['elements'] is List) {
          for (var element in response['elements']) {
            if (element is Map<String, dynamic>) {
              // Handle the flashcard_letter type
              if (element['type'] == 'flashcard_letter') {
                elements.add({
                  'type': 'text',
                  'content': element['letter'] ?? '',
                  'isBold': true,
                  'fontSize': 80.0,
                  'metadata': {'name': element['name'] ?? ''}
                });
              } else if (element['letter'] != null && element['name'] != null) {
                // Handle direct letter/name pairs
                elements.add({
                  'type': 'text',
                  'content': element['letter'],
                  'isBold': true,
                  'fontSize': 80.0,
                  'metadata': {'name': element['name']}
                });
              } else {
                elements.add(Map<String, dynamic>.from(element));
              }
            }
          }
        }
        
        // If still no elements, create fallback alphabet content
        if (elements.isEmpty) {
          final bool isJawi = response['subject']?.toString().toLowerCase().contains('jawi') == true || 
                            response['chapter']?.toString().toLowerCase().contains('huruf') == true;
          
          if (isJawi) {
            // Create fallback Jawi alphabet content with age-specific formatting
            final List<Map<String, String>> jawiLetters = [
              {'letter': 'ا', 'name': 'Alif'},
              {'letter': 'ب', 'name': 'Ba'},
              {'letter': 'ت', 'name': 'Ta'},
              {'letter': 'ث', 'name': 'Tha'},
              {'letter': 'ج', 'name': 'Jim'},
              {'letter': 'ح', 'name': 'Ha'},
              {'letter': 'خ', 'name': 'Kha'},
              {'letter': 'د', 'name': 'Dal'},
              {'letter': 'ذ', 'name': 'Dzal'},
              {'letter': 'ر', 'name': 'Ra'},
              {'letter': 'ز', 'name': 'Zai'},
              {'letter': 'س', 'name': 'Sin'},
              {'letter': 'ش', 'name': 'Shin'},
              {'letter': 'ص', 'name': 'Sad'},
              {'letter': 'ض', 'name': 'Dad'},
              {'letter': 'ط', 'name': 'Ta'},
              {'letter': 'ظ', 'name': 'Za'},
              {'letter': 'ع', 'name': 'Ain'},
              {'letter': 'غ', 'name': 'Ghain'},
              {'letter': 'ف', 'name': 'Fa'},
              {'letter': 'ق', 'name': 'Qaf'},
              {'letter': 'ك', 'name': 'Kaf'},
              {'letter': 'ل', 'name': 'Lam'},
              {'letter': 'م', 'name': 'Mim'},
              {'letter': 'ن', 'name': 'Nun'},
              {'letter': 'ه', 'name': 'Ha'},
              {'letter': 'و', 'name': 'Waw'},
              {'letter': 'ي', 'name': 'Ya'},
              {'letter': 'ڤ', 'name': 'Pa'},
              {'letter': 'ݢ', 'name': 'Ga'},
              {'letter': 'چ', 'name': 'Cha'},
              {'letter': 'ڠ', 'name': 'Nga'},
              {'letter': 'ڽ', 'name': 'Nya'},
              {'letter': 'ۏ', 'name': 'Va'},
              {'letter': 'ء', 'name': 'Hamzah'},
            ];
            
            // Process each letter according to age-specific requirements
            for (var letter in jawiLetters) {
              // For age 4: Large letter with name and auto-playing audio
              if (age == 4) {
                // Create the main letter element with proper metadata
                Map<String, dynamic> letterElement = {
                  'type': 'text',
                  'content': letter['letter'] ?? '',
                  'isBold': true,
                  'fontSize': 80.0,
                  'metadata': {
                    'name': letter['name'] ?? '',
                    'autoPlayAudio': true,
                    'showPlayButton': false
                  }
                };
                
                // Add audio element with auto-play
                Map<String, dynamic> audioElement = {
                  'type': 'audio',
                  'content': 'Audio: ${letter['name']}',
                  'audioUrl': 'https://example.com/audio/${letter['letter']}.mp3', // Placeholder URL
                  'metadata': {
                    'autoPlay': true,
                    'showControls': false,
                    'letterName': letter['name'] ?? ''
                  }
                };
                
                // Add elements
                elements.add(letterElement);
                elements.add(audioElement);
              }
              // For age 5: Letter with name, simple description, and play button
              else if (age == 5) {
                // Create the main letter element
                Map<String, dynamic> letterElement = {
                  'type': 'text',
                  'content': letter['letter'] ?? '',
                  'isBold': true,
                  'fontSize': 70.0,
                  'metadata': {
                    'name': letter['name'] ?? '',
                    'autoPlayAudio': false,
                    'showPlayButton': true
                  }
                };
                
                // Add simple description
                Map<String, dynamic> descriptionElement = {
                  'type': 'text',
                  'content': '${letter['name']} is a letter in the Jawi alphabet.',
                  'isBold': false,
                  'fontSize': 18.0,
                  'metadata': {'isDescription': true}
                };
                
                // Add audio element with play button
                Map<String, dynamic> audioElement = {
                  'type': 'audio',
                  'content': 'Audio: ${letter['name']}',
                  'audioUrl': 'https://example.com/audio/${letter['letter']}.mp3', // Placeholder URL
                  'metadata': {
                    'autoPlay': false,
                    'showControls': true,
                    'letterName': letter['name'] ?? ''
                  }
                };
                
                // Add elements
                elements.add(letterElement);
                elements.add(descriptionElement);
                elements.add(audioElement);
              }
              // For age 6: Letter with name, detailed description, and full audio controls
              else {
                // Create the main letter element
                Map<String, dynamic> letterElement = {
                  'type': 'text',
                  'content': letter['letter'] ?? '',
                  'isBold': true,
                  'fontSize': 60.0,
                  'metadata': {
                    'name': letter['name'] ?? '',
                    'autoPlayAudio': false,
                    'showPlayButton': true
                  }
                };
                
                // Add detailed description
                Map<String, dynamic> descriptionElement = {
                  'type': 'text',
                  'content': '${letter['name']} is a letter in the Jawi alphabet. It is pronounced as "${letter['name']}".',
                  'isBold': false,
                  'fontSize': 20.0,
                  'metadata': {'isDescription': true}
                };
                
                // Add audio element with full controls
                Map<String, dynamic> audioElement = {
                  'type': 'audio',
                  'content': 'Audio: ${letter['name']}',
                  'audioUrl': 'https://example.com/audio/${letter['letter']}.mp3', // Placeholder URL
                  'metadata': {
                    'autoPlay': false,
                    'showControls': true,
                    'showFullControls': true,
                    'letterName': letter['name'] ?? ''
                  }
                };
                
                // Add elements
                elements.add(letterElement);
                elements.add(descriptionElement);
                elements.add(audioElement);
              }
            }
          } else {
            // Create fallback English alphabet content with age-specific formatting
            final List<String> englishAlphabet = [
              'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
              'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
            ];
            
            for (var letter in englishAlphabet) {
              // Get example word for this letter
              String exampleWord = _getExampleWordForLetter(letter);
              
              // For age 4: Large letter with name and auto-playing audio
              if (age == 4) {
                // Create the main letter element with proper metadata
                Map<String, dynamic> letterElement = {
                  'type': 'text',
                  'content': letter,
                  'isBold': true,
                  'fontSize': 80.0,
                  'metadata': {
                    'name': letter,
                    'exampleWord': exampleWord,
                    'autoPlayAudio': true,
                    'showPlayButton': false
                  }
                };
                
                // Add audio element with auto-play
                Map<String, dynamic> audioElement = {
                  'type': 'audio',
                  'content': 'Audio: Letter $letter',
                  'audioUrl': 'https://example.com/audio/$letter.mp3', // Placeholder URL
                  'metadata': {
                    'autoPlay': true,
                    'showControls': false,
                    'letterName': letter
                  }
                };
                
                // Add elements
                elements.add(letterElement);
                elements.add(audioElement);
              }
              // For age 5: Letter with name, simple description, and play button
              else if (age == 5) {
                // Create the main letter element
                Map<String, dynamic> letterElement = {
                  'type': 'text',
                  'content': letter,
                  'isBold': true,
                  'fontSize': 70.0,
                  'metadata': {
                    'name': letter,
                    'exampleWord': exampleWord,
                    'autoPlayAudio': false,
                    'showPlayButton': true
                  }
                };
                
                // Add simple description
                Map<String, dynamic> descriptionElement = {
                  'type': 'text',
                  'content': '$letter as in $exampleWord',
                  'isBold': false,
                  'fontSize': 18.0,
                  'metadata': {'isDescription': true}
                };
                
                // Add audio element with play button
                Map<String, dynamic> audioElement = {
                  'type': 'audio',
                  'content': 'Audio: Letter $letter',
                  'audioUrl': 'https://example.com/audio/$letter.mp3', // Placeholder URL
                  'metadata': {
                    'autoPlay': false,
                    'showControls': true,
                    'letterName': letter
                  }
                };
                
                // Add elements
                elements.add(letterElement);
                elements.add(descriptionElement);
                elements.add(audioElement);
              }
              // For age 6: Letter with name, detailed description, and full audio controls
              else {
                // Create the main letter element
                Map<String, dynamic> letterElement = {
                  'type': 'text',
                  'content': letter,
                  'isBold': true,
                  'fontSize': 60.0,
                  'metadata': {
                    'name': letter,
                    'exampleWord': exampleWord,
                    'autoPlayAudio': false,
                    'showPlayButton': true
                  }
                };
                
                // Add detailed description
                Map<String, dynamic> descriptionElement = {
                  'type': 'text',
                  'content': '$letter as in $exampleWord. The letter $letter is the ${englishAlphabet.indexOf(letter) + 1}${_getOrdinalSuffix(englishAlphabet.indexOf(letter) + 1)} letter of the English alphabet.',
                  'isBold': false,
                  'fontSize': 20.0,
                  'metadata': {'isDescription': true}
                };
                
                // Add audio element with full controls
                Map<String, dynamic> audioElement = {
                  'type': 'audio',
                  'content': 'Audio: Letter $letter',
                  'audioUrl': 'https://example.com/audio/$letter.mp3', // Placeholder URL
                  'metadata': {
                    'autoPlay': false,
                    'showControls': true,
                    'showFullControls': true,
                    'letterName': letter
                  }
                };
                
                // Add elements
                elements.add(letterElement);
                elements.add(descriptionElement);
                elements.add(audioElement);
              }
            }
          }
        }
      } catch (e) {
        print('Error processing alphabet content: $e');
        // Continue to standard element processing
      }
    } else {
      // Standard element processing for non-alphabet content
      if (response['elements'] != null && response['elements'] is List) {
        for (var element in response['elements']) {
          if (element is Map<String, dynamic>) {
            elements.add(Map<String, dynamic>.from(element));
          }
        }
      }
    }

    // If no elements were found or the list is empty, create a default text element
    if (elements.isEmpty) {
      elements.add({
        'type': 'text',
        'content': 'No content was generated. Please try again.',
        'isBold': false,
        'isItalic': true,
        'fontSize': getFontSizeForAge(age),
      });
    }
    
    // Add template-specific elements
    _addTemplateSpecificElements(elements, templateId, age);
    
    return {
      'title': title,
      'elements': elements,
      'templateId': templateId,
      'ageGroup': age,
    };
  }

  // Add template-specific elements based on template type and age
  void _addTemplateSpecificElements(List<Map<String, dynamic>> elements, String templateId, int age) {
    switch (templateId) {
      case 'flashcard':
        // Add age-specific elements for flashcards
        _addAgeSpecificFlashcardElements(elements, age);
        break;
        
      case 'interactive':
        // Ensure there are enough interactive elements
        int interactiveCount = elements.where((e) => e['type'] == 'interactive').length;
        if (interactiveCount < 3) {
          // Add some generic interactive elements
          elements.add({
            'type': 'interactive',
            'content': 'What did you learn from this note?',
            'activityType': 'question',
          });
          elements.add({
            'type': 'interactive',
            'content': 'Can you draw a picture about what you learned?',
            'activityType': 'activity',
          });
        }
        break;
        
      case 'visual':
        // Ensure there are enough image elements
        int imageCount = elements.where((e) => e['type'] == 'image').length;
        if (imageCount < 4) {
          // Add some generic image placeholders
          elements.add({
            'type': 'image',
            'imageUrl': '',
            'caption': 'Visual example',
          });
          elements.add({
            'type': 'image',
            'imageUrl': '',
            'caption': 'Illustration',
          });
        }
        break;
        
      case 'story':
        // Ensure there's a story structure
        bool hasIntro = false;
        bool hasEnding = false;
        
        for (var element in elements) {
          if (element['type'] == 'text') {
            String content = element['content'].toString().toLowerCase();
            if (content.contains('once upon a time') || 
                content.contains('once there was') ||
                content.contains('meet') ||
                content.contains('introduction')) {
              hasIntro = true;
            }
            if (content.contains('the end') || 
                content.contains('finally') ||
                content.contains('conclusion')) {
              hasEnding = true;
            }
          }
        }
        
        if (!hasIntro) {
          elements.insert(0, {
            'type': 'text',
            'content': 'Once upon a time...',
            'isBold': true,
            'isItalic': false,
          });
        }
        
        if (!hasEnding) {
          elements.add({
            'type': 'text',
            'content': 'The End! What did you learn from this story?',
            'isBold': true,
            'isItalic': false,
          });
        }
        break;
    }
  }
  
  // Add age-specific elements for flashcards
  void _addAgeSpecificFlashcardElements(List<Map<String, dynamic>> elements, int age) {
    // Ensure each element has the appropriate format based on age
    for (var i = 0; i < elements.length; i++) {
      var element = elements[i];
      
      // Skip if not a text element
      if (element['type'] != 'text') continue;
      
      // Age 4: Simple bullet points with auto-play audio
      if (age == 4) {
        // Convert paragraphs to bullet points if needed
        String content = element['content'] ?? '';
        if (!content.contains('•') && !content.contains('-')) {
          // Convert to bullet points
          List<String> sentences = content.split('. ')
              .where((s) => s.trim().isNotEmpty)
              .map((s) => s.endsWith('.') ? s : '$s.')
              .toList();
          
          content = sentences.map((s) => '• ${s.trim()}').join('\n');
          element['content'] = content;
        }
        
        // Add auto-play audio for age 4
        elements.add({
          'type': 'audio',
          'audioUrl': '',
          'title': 'Listen',
          'autoPlay': true,
          'position': (element['position'] ?? i) + 0.5, // Position after the text
        });
      }
      
      // Age 5: Short paragraphs with key-term highlights and play button
      else if (age == 5) {
        // Add play button icon to content if not already present
        String content = element['content'] ?? '';
        if (!content.contains('🔊')) {
          element['content'] = '🔊 $content';
        }
        
        // Add audio element without auto-play
        elements.add({
          'type': 'audio',
          'audioUrl': '',
          'title': 'Listen to explanation',
          'autoPlay': false,
          'position': (element['position'] ?? i) + 0.5, // Position after the text
        });
      }
      
      // Age 6: Detailed paragraphs with mini-quizzes
      else if (age == 6) {
        // Check if content already has quiz elements
        String content = element['content'] ?? '';
        if (!content.contains('?')) {
          // Add a simple quiz question at the end
          content += '\n\nQuick Quiz: What is the main idea of this flashcard?';
          element['content'] = content;
        }
      }
    }
    
    // Ensure each flashcard has an image
    bool hasImage = elements.any((e) => e['type'] == 'image');
    if (!hasImage) {
      elements.add({
        'type': 'image',
        'imageUrl': '',
        'caption': 'Illustration for this concept',
        'position': 1, // Position at the top
      });
    }
  }

  // Convert processed content to Note model
  Note convertToNoteModel(Map<String, dynamic> processedContent) {
    final List<NoteContentElement> noteElements = [];
    final List<dynamic> rawElements = processedContent['elements'] ?? [];

    int position = 0;
    for (var element in rawElements) {
      if (element['type'] == 'text') {
        noteElements.add(TextElement(
          id: const Uuid().v4(),
          position: position++,
          createdAt: Timestamp.now(),
          content: element['content'] ?? '',
          isBold: element['isBold'] ?? false,
          isItalic: element['isItalic'] ?? false,
        ));
      } else if (element['type'] == 'image') {
        noteElements.add(ImageElement(
          id: const Uuid().v4(),
          position: position++,
          createdAt: Timestamp.now(),
          imageUrl: element['imageUrl'] ?? '',
          caption: element['caption'] ?? '',
        ));
      } else if (element['type'] == 'audio') {
        noteElements.add(AudioElement(
          id: const Uuid().v4(),
          position: position++,
          createdAt: Timestamp.now(),
          audioUrl: element['audioUrl'] ?? '',
          title: element['title'] ?? '',
        ));
      } else if (element['type'] == 'interactive') {
        // Convert interactive elements to text elements for now
        // In a full implementation, you would create a specific InteractiveElement class
        noteElements.add(TextElement(
          id: const Uuid().v4(),
          position: position++,
          createdAt: Timestamp.now(),
          content: '🎮 Activity: ${element['content'] ?? ''}',
          isBold: true,
          isItalic: false,
        ));
      }
    }

    return Note(
      title: processedContent['title'] ?? 'New Note',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      elements: noteElements,
      isDraft: true,
    );
  }
}
