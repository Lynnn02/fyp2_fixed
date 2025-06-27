import 'dart:convert';

/// A class that generates flashcard content based on subject, chapter, age, and language
class FlashcardTemplateGenerator {
  /// Generate flashcard content based on subject, chapter, age, language, and count
  static List<Map<String, dynamic>> generateFlashcards({
    required String subject,
    required String chapter,
    required int age,
    required String language,
    required int count,
  }) {
    // Determine if we need RTL text direction based on language or subject
    final bool isRtl = _isRtlLanguage(language) || 
                       subject.toLowerCase().contains('jawi') || 
                       subject.toLowerCase().contains('arabic');
    // Normalize subject and chapter for easier comparison
    final normalizedSubject = subject.toLowerCase().trim();
    final normalizedChapter = chapter.toLowerCase().trim();
    
    // Special handling for alphabet chapters
    if ((normalizedSubject.contains('jawi') && normalizedChapter.contains('huruf')) ||
        (normalizedChapter.contains('alphabet'))) {
      return _generateAlphabetFlashcards(subject, chapter, age, language, count);
    }
    
    // Special handling for animals chapter
    if (normalizedChapter.contains('animal')) {
      return _generateAnimalFlashcards(subject, age, language, count);
    }
    
    // Special handling for shapes chapter
    if (normalizedChapter.contains('shape')) {
      return _generateShapeFlashcards(subject, age, language, count);
    }
    
    // Special handling for colors chapter
    if (normalizedChapter.contains('color')) {
      return _generateColorFlashcards(subject, age, language, count);
    }
    
    // Special handling for numbers/counting chapter
    if (normalizedChapter.contains('number') || normalizedChapter.contains('count')) {
      return _generateNumberFlashcards(subject, age, language, count);
    }
    
    // Default flashcards for other topics
    return _generateDefaultFlashcards(subject, chapter, age, language, count);
  }
  
  /// Generate flashcards for animals
  static List<Map<String, dynamic>> _generateAnimalFlashcards(
    String subject, 
    int age, 
    String language, 
    int count
  ) {
    final List<Map<String, dynamic>> flashcards = [];
    
    // Common animals with their labels and descriptions
    final List<Map<String, String>> animals = [
      {
        'label': 'CAT',
        'image_prompt': 'A friendly white cat with blue eyes on a rainbow background',
        'question_text': 'This is a cat. Cats say meow.',
      },
      {
        'label': 'DOG',
        'image_prompt': 'A cute brown dog with floppy ears on a rainbow background',
        'question_text': 'This is a dog. Dogs say woof.',
      },
      {
        'label': 'ELEPHANT',
        'image_prompt': 'A gray elephant with a long trunk on a rainbow background',
        'question_text': 'This is an elephant. Elephants have long trunks.',
      },
      {
        'label': 'LION',
        'image_prompt': 'A majestic lion with a golden mane on a rainbow background',
        'question_text': 'This is a lion. Lions say roar.',
      },
      {
        'label': 'MONKEY',
        'image_prompt': 'A playful brown monkey hanging from a branch on a rainbow background',
        'question_text': 'This is a monkey. Monkeys like to climb trees.',
      },
      {
        'label': 'GIRAFFE',
        'image_prompt': 'A tall giraffe with spots on a rainbow background',
        'question_text': 'This is a giraffe. Giraffes have long necks.',
      },
      {
        'label': 'ZEBRA',
        'image_prompt': 'A black and white striped zebra on a rainbow background',
        'question_text': 'This is a zebra. Zebras have stripes.',
      },
      {
        'label': 'TIGER',
        'image_prompt': 'An orange tiger with black stripes on a rainbow background',
        'question_text': 'This is a tiger. Tigers have stripes.',
      },
    ];
    
    // Limit to the requested count
    final int actualCount = count > animals.length ? animals.length : count;
    
    for (int i = 0; i < actualCount; i++) {
      Map<String, dynamic> flashcard = {
        'image_prompt': animals[i]['image_prompt'],
        'label': animals[i]['label'],
      };
      
      // Add question text for age 5 and 6
      if (age >= 5) {
        flashcard['question_text'] = animals[i]['question_text'];
      }
      
      // Add audio prompt for age 4 and 5
      if (age == 4 || age == 5) {
        flashcard['audio_prompt'] = age == 4 ? animals[i]['label'] : animals[i]['question_text'];
      }
      
      flashcards.add(flashcard);
    }
    
    return flashcards;
  }
  
  /// Generate flashcards for alphabet (Jawi or English)
  static List<Map<String, dynamic>> _generateAlphabetFlashcards(
    String subject, 
    String chapter, 
    int age, 
    String language, 
    int count
  ) {
    final List<Map<String, dynamic>> flashcards = [];
    
    // Check if it's Jawi or English alphabet
    final bool isJawi = subject.toLowerCase().contains('jawi') || chapter.toLowerCase().contains('huruf');
    
    // Set font family and text direction for RTL scripts
    final String fontFamily = isJawi ? 'Amiri' : 'Roboto';
    final String textDirection = isJawi ? 'rtl' : 'ltr';
    
    if (isJawi) {
      // Jawi alphabet
      final List<Map<String, String>> jawiLetters = [
        {'letter': 'ا', 'name': 'Alif', 'example': 'Api', 'description': 'The first letter of the Jawi alphabet'},
        {'letter': 'ب', 'name': 'Ba', 'example': 'Buku', 'description': 'The second letter of the Jawi alphabet'},
        {'letter': 'ت', 'name': 'Ta', 'example': 'Tali', 'description': 'The third letter of the Jawi alphabet'},
        {'letter': 'ث', 'name': 'Tha', 'example': 'Thalji', 'description': 'The fourth letter of the Jawi alphabet'},
        {'letter': 'ج', 'name': 'Jim', 'example': 'Jalan', 'description': 'The fifth letter of the Jawi alphabet'},
      ];
      
      // Limit to the requested count
      final int actualCount = count > jawiLetters.length ? jawiLetters.length : count;
      
      for (int i = 0; i < actualCount; i++) {
        Map<String, dynamic> flashcard = {
          'image_prompt': 'The Jawi letter ${jawiLetters[i]['letter']} (${jawiLetters[i]['name']}) on a rainbow background',
          'label': jawiLetters[i]['letter'],
          'fontFamily': fontFamily,
          'textDirection': textDirection,
        };
        
        // Add question text for age 5 and 6
        if (age >= 5) {
          flashcard['question_text'] = 'This is the letter ${jawiLetters[i]['name']}. It is used in words like ${jawiLetters[i]['example']}';
        }
        
        // Add audio prompt for age 4 and 5
        if (age == 4 || age == 5) {
          flashcard['audio_prompt'] = age == 4 ? jawiLetters[i]['name'] : 'This is the letter ${jawiLetters[i]['name']}';
        }
        
        flashcards.add(flashcard);
      }
    } else {
      // English alphabet
      final List<Map<String, String>> englishLetters = [
        {'letter': 'A', 'name': 'A', 'example': 'Apple', 'description': 'The first letter of the English alphabet'},
        {'letter': 'B', 'name': 'B', 'example': 'Ball', 'description': 'The second letter of the English alphabet'},
        {'letter': 'C', 'name': 'C', 'example': 'Cat', 'description': 'The third letter of the English alphabet'},
        {'letter': 'D', 'name': 'D', 'example': 'Dog', 'description': 'The fourth letter of the English alphabet'},
        {'letter': 'E', 'name': 'E', 'example': 'Elephant', 'description': 'The fifth letter of the English alphabet'},
      ];
      
      // Limit to the requested count
      final int actualCount = count > englishLetters.length ? englishLetters.length : count;
      
      for (int i = 0; i < actualCount; i++) {
        Map<String, dynamic> flashcard = {
          'image_prompt': 'The letter ${englishLetters[i]['letter']} with a ${englishLetters[i]['example']?.toLowerCase() ?? 'example'} on a rainbow background',
          'label': englishLetters[i]['letter'],
          'fontFamily': fontFamily,
          'textDirection': textDirection,
        };
        
        // Add question text for age 5 and 6
        if (age >= 5) {
          flashcard['question_text'] = '${englishLetters[i]['letter']} is for ${englishLetters[i]['example']}';
        }
        
        // Add audio prompt for age 4 and 5
        if (age == 4 || age == 5) {
          flashcard['audio_prompt'] = age == 4 ? englishLetters[i]['letter'] : '${englishLetters[i]['letter']} is for ${englishLetters[i]['example']}';
        }
        
        flashcards.add(flashcard);
      }
    }
    
    return flashcards;
  }
  
  /// Generate flashcards for shapes
  static List<Map<String, dynamic>> _generateShapeFlashcards(
    String subject, 
    int age, 
    String language, 
    int count
  ) {
    final List<Map<String, dynamic>> flashcards = [];
    
    // Common shapes with their labels and descriptions
    final List<Map<String, String>> shapes = [
      {
        'label': 'CIRCLE',
        'image_prompt': 'A red circle shape on a rainbow background',
        'question_text': 'This is a circle. A circle is round.',
      },
      {
        'label': 'SQUARE',
        'image_prompt': 'A blue square shape on a rainbow background',
        'question_text': 'This is a square. A square has four equal sides.',
      },
      {
        'label': 'TRIANGLE',
        'image_prompt': 'A yellow triangle shape on a rainbow background',
        'question_text': 'This is a triangle. A triangle has three sides.',
      },
      {
        'label': 'RECTANGLE',
        'image_prompt': 'A green rectangle shape on a rainbow background',
        'question_text': 'This is a rectangle. A rectangle has four sides.',
      },
      {
        'label': 'OVAL',
        'image_prompt': 'A purple oval shape on a rainbow background',
        'question_text': 'This is an oval. An oval is like a stretched circle.',
      },
    ];
    
    // Limit to the requested count
    final int actualCount = count > shapes.length ? shapes.length : count;
    
    for (int i = 0; i < actualCount; i++) {
      Map<String, dynamic> flashcard = {
        'image_prompt': shapes[i]['image_prompt'],
        'label': shapes[i]['label'],
      };
      
      // Add question text for age 5 and 6
      if (age >= 5) {
        flashcard['question_text'] = shapes[i]['question_text'];
      }
      
      // Add audio prompt for age 4 and 5
      if (age == 4 || age == 5) {
        flashcard['audio_prompt'] = age == 4 ? shapes[i]['label'] : shapes[i]['question_text'];
      }
      
      flashcards.add(flashcard);
    }
    
    return flashcards;
  }
  
  /// Generate flashcards for colors
  static List<Map<String, dynamic>> _generateColorFlashcards(
    String subject, 
    int age, 
    String language, 
    int count
  ) {
    final List<Map<String, dynamic>> flashcards = [];
    
    // Common colors with their labels and descriptions
    final List<Map<String, String>> colors = [
      {
        'label': 'RED',
        'image_prompt': 'A bright red color block on a rainbow background',
        'question_text': 'This is red. Apples can be red.',
      },
      {
        'label': 'BLUE',
        'image_prompt': 'A bright blue color block on a rainbow background',
        'question_text': 'This is blue. The sky is blue.',
      },
      {
        'label': 'YELLOW',
        'image_prompt': 'A bright yellow color block on a rainbow background',
        'question_text': 'This is yellow. Bananas are yellow.',
      },
      {
        'label': 'GREEN',
        'image_prompt': 'A bright green color block on a rainbow background',
        'question_text': 'This is green. Leaves are green.',
      },
      {
        'label': 'ORANGE',
        'image_prompt': 'A bright orange color block on a rainbow background',
        'question_text': 'This is orange. Oranges are orange.',
      },
    ];
    
    // Limit to the requested count
    final int actualCount = count > colors.length ? colors.length : count;
    
    for (int i = 0; i < actualCount; i++) {
      Map<String, dynamic> flashcard = {
        'image_prompt': colors[i]['image_prompt'],
        'label': colors[i]['label'],
      };
      
      // Add question text for age 5 and 6
      if (age >= 5) {
        flashcard['question_text'] = colors[i]['question_text'];
      }
      
      // Add audio prompt for age 4 and 5
      if (age == 4 || age == 5) {
        flashcard['audio_prompt'] = age == 4 ? colors[i]['label'] : colors[i]['question_text'];
      }
      
      flashcards.add(flashcard);
    }
    
    return flashcards;
  }
  
  /// Generate flashcards for numbers
  static List<Map<String, dynamic>> _generateNumberFlashcards(
    String subject, 
    int age, 
    String language, 
    int count
  ) {
    final List<Map<String, dynamic>> flashcards = [];
    
    // Numbers with their labels and descriptions
    final List<Map<String, String>> numbers = [];
    
    // Generate numbers from 1 to 20
    for (int i = 1; i <= 20; i++) {
      numbers.add({
        'label': i.toString(),
        'image_prompt': '$i objects (like apples or stars) arranged on a rainbow background',
        'question_text': 'This is the number $i. Count $i objects.',
      });
    }
    
    // Limit to the requested count
    final int actualCount = count > numbers.length ? numbers.length : count;
    
    for (int i = 0; i < actualCount; i++) {
      Map<String, dynamic> flashcard = {
        'image_prompt': numbers[i]['image_prompt'],
        'label': numbers[i]['label'],
      };
      
      // Add question text for age 5 and 6
      if (age >= 5) {
        flashcard['question_text'] = numbers[i]['question_text'];
      }
      
      // Add audio prompt for age 4 and 5
      if (age == 4 || age == 5) {
        flashcard['audio_prompt'] = age == 4 ? numbers[i]['label'] : numbers[i]['question_text'];
      }
      
      flashcards.add(flashcard);
    }
    
    return flashcards;
  }
  
  /// Generate default flashcards for any other topic
  static List<Map<String, dynamic>> _generateDefaultFlashcards(
    String subject, 
    String chapter, 
    int age, 
    String language, 
    int count
  ) {
    final List<Map<String, dynamic>> flashcards = [];
    
    // Generate generic flashcards based on the subject and chapter
    for (int i = 1; i <= count; i++) {
      final String label = 'ITEM $i';
      final String imagePrompt = 'An illustration related to $subject - $chapter, item $i on a rainbow background';
      final String questionText = 'This is item $i from the $chapter chapter of $subject.';
      
      Map<String, dynamic> flashcard = {
        'image_prompt': imagePrompt,
        'label': label,
      };
      
      // Add question text for age 5 and 6
      if (age >= 5) {
        flashcard['question_text'] = questionText;
      }
      
      // Add audio prompt for age 4 and 5
      if (age == 4 || age == 5) {
        flashcard['audio_prompt'] = age == 4 ? label : questionText;
      }
      
      flashcards.add(flashcard);
    }
    
    return flashcards;
  }
  
  /// Helper method to determine if a language is RTL
  static bool _isRtlLanguage(String languageCode) {
    // List of RTL language codes
    final List<String> rtlLanguages = [
      'ar', // Arabic
      'fa', // Persian/Farsi
      'he', // Hebrew
      'ur', // Urdu
      'ps', // Pashto
      'sd', // Sindhi
      'ku', // Kurdish
      'dv', // Dhivehi
      'ms-arab', // Malay in Arabic script
    ];
    
    return rtlLanguages.contains(languageCode.toLowerCase());
  }
  
  /// Convert a list of flashcards to a JSON string
  static String toJson(List<Map<String, dynamic>> flashcards) {
    return jsonEncode(flashcards);
  }
}