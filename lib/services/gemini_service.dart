import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject.dart';
import '../models/note_content.dart';
import 'json_helper_fixed.dart';

class GeminiService {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String model = 'gemini-1.5-pro';
  
  // Image URLs for different categories that can be used in notes
  static const Map<String, List<String>> _imageUrls = {
    'animals': [
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_images%2Fanimal1.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_images%2Fanimal2.jpg?alt=media',
    ],
    'default': [
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_images%2Fdefault1.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_images%2Fdefault2.jpg?alt=media',
    ],
  };
  
  // Audio URLs for different categories that can be used in notes
  static const Map<String, List<String>> _audioUrls = {
    'animals': [
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_audio%2Fanimal1.mp3?alt=media',
    ],
    'default': [
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_audio%2Fdefault1.mp3?alt=media',
    ],
  };

  // Helper method to determine if a subject is Jawi/Arabic related
  bool _isJawiOrArabicSubject(String subjectName) {
    final name = subjectName.toLowerCase();
    return name.contains('jawi') || 
           name.contains('arabic') || 
           name.contains('iqra') ||
           name.contains('quran') ||
           name.contains('islamic');
  }
  
  // Helper method to determine if a chapter is Jawi/Arabic letter related
  bool _isJawiOrArabicChapter(String chapterName) {
    final name = chapterName.toLowerCase();
    return name.contains('huruf') || 
           name.contains('letter') || 
           name.contains('abjad') ||
           name.contains('hijaiyah');
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
    } else if (name.contains('animal') || name.contains('haiwan')) {
      return 'animals';
    } else if (name.contains('food') || name.contains('makanan')) {
      return 'food';
    }
    
    return 'general';
  }

  // Get suitable game types based on age, subject, and chapter
  Future<List<String>> getSuitableGameTypes(Subject subject, Chapter chapter) async {
    final List<String> allGameTypes = [
      'tracing', 
      'matching', 
      'sorting', 
      'counting', 
      'puzzle'
    ];
    
    final int age = subject.moduleId;
    final String subjectContext = _getSubjectContext(subject.name);
    final bool chapterContext = _isJawiOrArabicChapter(chapter.name);
    
    List<String> recommendedGames = [];
    
    // Age-appropriate game recommendations
    if (age == 4) {
      // For youngest age group, focus on simple games
      if (subjectContext == 'jawi' || chapterContext) {
        recommendedGames = ['tracing', 'matching'];
      } else if (subjectContext == 'math') {
        recommendedGames = ['counting', 'matching'];
      } else if (subjectContext == 'animals') {
        recommendedGames = ['matching', 'sorting'];
      } else {
        // Default for age 4
        recommendedGames = ['matching', 'tracing', 'sorting'];
      }
    } else if (age == 5) {
      // For middle age group, balance between simplicity and challenge
      if (subjectContext == 'jawi' || chapterContext) {
        recommendedGames = ['tracing', 'matching', 'puzzle'];
      } else if (subjectContext == 'math') {
        recommendedGames = ['counting', 'matching', 'sorting'];
      } else {
        // Default for age 5
        recommendedGames = ['matching', 'sorting', 'puzzle'];
      }
    } else {
      // For oldest age group, more challenging games
      if (subjectContext == 'jawi' || chapterContext) {
        recommendedGames = ['tracing', 'matching', 'puzzle'];
      } else if (subjectContext == 'math') {
        recommendedGames = ['counting', 'sorting', 'puzzle'];
      } else {
        // Default for age 6
        recommendedGames = ['matching', 'puzzle', 'sorting'];
      }
    }
    
    // Add a random game if we don't have enough recommendations
    if (recommendedGames.length < 3) {
      final random = Random();
      while (recommendedGames.length < 3) {
        final gameType = allGameTypes[random.nextInt(allGameTypes.length)];
        if (!recommendedGames.contains(gameType)) {
          recommendedGames.add(gameType);
          break;
        }
      }
    }
    
    // Limit to 3 recommendations
    return recommendedGames.take(3).toList();
  }

  // Generate game content based on game type, subject, and chapter
  Future<Map<String, dynamic>?> generateGameContent(String gameType, Subject subject, Chapter chapter) async {
    // Prepare context information to make content more relevant
    final String subjectContext = _getSubjectContext(subject.name);
    final bool isJawiContent = _isJawiOrArabicSubject(subject.name) || _isJawiOrArabicChapter(chapter.name);
    final bool isMathContent = subjectContext == 'math';
    
    switch (gameType) {
      case 'tracing':
        return generateTracingGameContent(subject, chapter);
      case 'matching':
        return generateMatchingGameContent(subject, chapter);
      case 'sorting':
        return generateSortingGameContent(subject, chapter);
      case 'counting':
        return generateCountingGameContent(subject, chapter);
      case 'puzzle':
        return generatePuzzleGameContent(subject, chapter);
      default:
        return null;
    }
  }

  // Generate tracing game content
  Future<Map<String, dynamic>?> generateTracingGameContent(Subject subject, Chapter chapter) async {
    // Create fallback content
    return createFallbackTracingGameContent(subject, chapter);
  }

  // Generate matching game content
  Future<Map<String, dynamic>?> generateMatchingGameContent(Subject subject, Chapter chapter) async {
    // Create fallback content
    return createFallbackMatchingGameContent(subject, chapter);
  }

  // Generate sorting game content
  Future<Map<String, dynamic>?> generateSortingGameContent(Subject subject, Chapter chapter) async {
    // Create fallback content
    return createFallbackSortingGameContent(subject, chapter);
  }

  // Generate counting game content
  Future<Map<String, dynamic>?> generateCountingGameContent(Subject subject, Chapter chapter) async {
    // Create fallback content
    return createFallbackCountingGameContent(subject, chapter);
  }

  // Generate puzzle game content
  Future<Map<String, dynamic>?> generatePuzzleGameContent(Subject subject, Chapter chapter) async {
    // Create fallback content
    return createFallbackPuzzleGameContent(subject, chapter);
  }

  // Generate note content based on template type, subject, and chapter
  Future<Map<String, dynamic>?> generateNoteContent({
    required String subject,
    required String chapter,
    required int age,
    required String templateType,
    int? pageCount,
  }) async {
    // Create fallback content
    return createFallbackNoteContent(
      Subject(id: 'temp', name: subject, moduleId: age, chapters: [], createdAt: Timestamp.now()),
      Chapter(id: 'temp', name: chapter, createdAt: Timestamp.now()),
      age,
      _imageUrls,
      _audioUrls,
      _getSubjectContext(subject)
    );
  }
  
  // Generate flashcard content based on subject, chapter, age and style
  Future<List<NoteContentElement>> generateFlashcardContent(Map<String, dynamic> params) async {
    try {
      final String subject = params['subject'];
      final String chapter = params['chapter'];
      final int age = params['age'];
      final String style = params['style'];
      
      // Create a Subject and Chapter object from the parameters
      final Subject subjectObj = Subject(id: 'temp', name: subject, moduleId: age, chapters: [], createdAt: Timestamp.now());
      final Chapter chapterObj = Chapter(id: 'temp', name: chapter, createdAt: Timestamp.now());
      
      // Generate content using the existing method
      final Map<String, dynamic>? contentResult = await createFallbackNoteContent(
        subjectObj,
        chapterObj,
        age,
        _imageUrls,
        _audioUrls,
        _getSubjectContext(subject)
      );
      
      if (contentResult == null) {
        throw Exception('Failed to generate flashcard content');
      }
      
      // Parse the content result into NoteContentElement objects
      final List<dynamic> elementsJson = contentResult['elements'] ?? [];
      final List<NoteContentElement> elements = [];
      
      // Convert each element to the appropriate NoteContentElement type
      int position = 0;
      for (final element in elementsJson) {
        final String type = element['type'];
        final String id = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();
        final Timestamp createdAt = Timestamp.now();
        
        if (type == 'text') {
          elements.add(TextElement(
            id: id,
            position: position++,
            createdAt: createdAt,
            content: element['content'] ?? '',
            isBold: element['isBold'] ?? false,
            isItalic: element['isItalic'] ?? false,
            isList: element['isList'] ?? false,
            fontSize: element['fontSize']?.toDouble() ?? 16.0,
            textColor: element['textColor'] ?? '#000000',
          ));
        } else if (type == 'image') {
          elements.add(ImageElement(
            id: id,
            position: position++,
            createdAt: createdAt,
            imageUrl: element['imageUrl'] ?? '',
            caption: element['caption'] ?? '',
            width: element['width']?.toDouble() ?? 300.0,
            height: element['height']?.toDouble() ?? 200.0,
          ));
        } else if (type == 'audio') {
          elements.add(AudioElement(
            id: id,
            position: position++,
            createdAt: createdAt,
            audioUrl: element['audioUrl'] ?? '',
            title: element['title'] ?? 'Audio',
          ));
        }
      }
      
      return elements;
    } catch (e) {
      print('Error generating flashcard content: $e');
      // Return a basic set of elements if there's an error
      final Timestamp now = Timestamp.now();
      return [
        TextElement(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          position: 0,
          createdAt: now,
          content: 'Flashcard for ${params['subject']}: ${params['chapter']}',
          isBold: true,
          isItalic: false,
          fontSize: 20.0,
          textColor: '#000000',
        ),
        TextElement(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          position: 1,
          createdAt: now,
          content: 'This is a sample flashcard content. Please try again or edit this content.',
          isBold: false,
          isItalic: false,
          fontSize: 16.0,
          textColor: '#000000',
        )
      ];
    }
  }

  // Create fallback tracing game content
  Map<String, dynamic> createFallbackTracingGameContent(Subject subject, Chapter chapter) {
    // Check if this is a Jawi/Arabic subject
    bool isJawiOrArabic = _isJawiOrArabicSubject(subject.name) || _isJawiOrArabicChapter(chapter.name);
    
    List<Map<String, dynamic>> items;
    String title;
    String instructions;
    
    if (isJawiOrArabic) {
      // Jawi alphabet characters with their names, sounds, and examples
      items = [
        {"character": "ا", "name": "Alif", "sound": "A", "example": "Ayah", "emoji": "👨"},
        {"character": "ب", "name": "Ba", "sound": "B", "example": "Buku", "emoji": "📚"},
        {"character": "ت", "name": "Ta", "sound": "T", "example": "Taman", "emoji": "🌳"},
        {"character": "ث", "name": "Tha", "sound": "Th", "example": "Thalatha", "emoji": "3️⃣"},
        {"character": "ج", "name": "Jim", "sound": "J", "example": "Jalan", "emoji": "🛣️"},
        {"character": "ح", "name": "Ha", "sound": "H", "example": "Hari", "emoji": "📅"},
        {"character": "خ", "name": "Kha", "sound": "Kh", "example": "Khabar", "emoji": "📰"},
        {"character": "د", "name": "Dal", "sound": "D", "example": "Daun", "emoji": "🍃"},
      ];
      
      title = "Jawi Tracing: ${chapter.name}";
      instructions = "Trace the Jawi letters with your finger";
    } else {
      // Default English alphabet for non-Jawi subjects
      items = [
        {"character": "A", "name": "A", "sound": "Ah", "example": "Apple", "emoji": "🍎"},
        {"character": "B", "name": "B", "sound": "Buh", "example": "Ball", "emoji": "⚽"},
        {"character": "C", "name": "C", "sound": "Kuh", "example": "Cat", "emoji": "🐱"},
        {"character": "D", "name": "D", "sound": "Duh", "example": "Dog", "emoji": "🐶"},
        {"character": "E", "name": "E", "sound": "Eh", "example": "Elephant", "emoji": "🐘"},
        {"character": "F", "name": "F", "sound": "Fuh", "example": "Fish", "emoji": "🐟"},
      ];
      
      title = "Tracing: ${chapter.name}";
      instructions = "Trace the letters with your finger";
    }
    
    return {
      "title": title,
      "instructions": instructions,
      "items": items,
      "rightToLeft": isJawiOrArabic, // Set right-to-left flag for Jawi/Arabic content
      "arabicScript": isJawiOrArabic, // Set Arabic script flag for Jawi content
    };
  }

  // Create fallback matching game content
  Map<String, dynamic> createFallbackMatchingGameContent(Subject subject, Chapter chapter) {
    final pairs = [
      {"left": "A", "right": "Apple", "emoji": "🍎"},
      {"left": "B", "right": "Ball", "emoji": "⚽"},
      {"left": "C", "right": "Cat", "emoji": "🐱"},
    ];
    
    return {
      "title": "Matching: ${chapter.name}",
      "instructions": "Match each item with its pair",
      "pairs": pairs,
    };
  }

  // Create fallback sorting game content
  Map<String, dynamic> createFallbackSortingGameContent(Subject subject, Chapter chapter) {
    final categories = [
      {
        "name": "Fruits",
        "items": [
          {"name": "Apple", "emoji": "🍎"},
          {"name": "Banana", "emoji": "🍌"},
        ]
      },
      {
        "name": "Animals",
        "items": [
          {"name": "Cat", "emoji": "🐱"},
          {"name": "Dog", "emoji": "🐶"},
        ]
      }
    ];
    
    return {
      "title": "Sorting: ${chapter.name}",
      "instructions": "Sort the items into their correct categories",
      "categories": categories,
    };
  }

  // Create fallback counting game content
  Map<String, dynamic> createFallbackCountingGameContent(Subject subject, Chapter chapter) {
    final items = [
      {"number": 1, "items": [{"name": "Apple", "emoji": "🍎"}]},
      {"number": 2, "items": [{"name": "Ball", "emoji": "⚽"}, {"name": "Ball", "emoji": "⚽"}]},
      {"number": 3, "items": [{"name": "Cat", "emoji": "🐱"}, {"name": "Cat", "emoji": "🐱"}, {"name": "Cat", "emoji": "🐱"}]},
    ];
    
    return {
      "title": "Counting: ${chapter.name}",
      "instructions": "Count the items in each group",
      "items": items,
    };
  }

  // Create fallback puzzle game content
  Map<String, dynamic> createFallbackPuzzleGameContent(Subject subject, Chapter chapter) {
    final puzzles = [
      {
        "image": "https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_images%2Fdefault1.jpg?alt=media",
        "title": "Puzzle 1",
        "difficulty": "easy"
      },
      {
        "image": "https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_images%2Fdefault2.jpg?alt=media",
        "title": "Puzzle 2",
        "difficulty": "medium"
      }
    ];
    
    return {
      "title": "Puzzle: ${chapter.name}",
      "instructions": "Complete the puzzles by arranging the pieces",
      "puzzles": puzzles,
    };
  }

  // Create fallback note content when API calls fail
  Map<String, dynamic> createFallbackNoteContent(
    Subject subject,
    Chapter chapter,
    int ageGroup,
    Map<String, List<String>> imageUrls,
    Map<String, List<String>> audioUrls,
    String subjectContext
  ) {
    final random = Random();
    final List<Map<String, dynamic>> elements = [];
    
    // Determine number of pages based on age
    int pageCount = 5; // Reduced for better focus
    if (ageGroup == 5) pageCount = 6;
    if (ageGroup == 6) pageCount = 8;
    
    // Create a title with proper capitalization
    final title = 'Learning About ${chapter.name}';
    
    // Create a description
    final description = 'Educational content to help children learn about ${chapter.name}';
    
    // Get appropriate images and audio for this subject
    final List<String> images = imageUrls[subjectContext] ?? imageUrls['default']!;
    final List<String> audios = audioUrls[subjectContext] ?? audioUrls['default']!;
    
    // Check if this is a Jawi/Arabic subject
    bool isJawiOrArabic = _isJawiOrArabicSubject(subject.name) || _isJawiOrArabicChapter(chapter.name);
    
    // Add a cover page with title and introduction
    elements.add({
      'type': 'text',
      'content': title,
      'isBold': true,
      'isItalic': false,
      'fontSize': 24.0,
      'textColor': '#3F51B5', // Indigo color for title
    });
    
    // Add a cover image
    if (images.isNotEmpty) {
      elements.add({
        'type': 'image',
        'imageUrl': images[random.nextInt(images.length)],
        'caption': 'Cover image for ${chapter.name}',
        'width': 300.0,
        'height': 200.0,
      });
    }
    
    // Add introduction text
    elements.add({
      'type': 'text',
      'content': 'Welcome to this lesson about ${chapter.name}. ' +
                'In this note, you will learn important concepts and facts about this topic.',
      'isBold': false,
      'isItalic': false,
    });
    
    // Generate content for each page based on subject context
    if (subjectContext == 'math') {
      _generateMathContent(elements, chapter.name, ageGroup, images, audios);
    } else if (subjectContext == 'science') {
      _generateScienceContent(elements, chapter.name, ageGroup, images, audios);
    } else if (isJawiOrArabic) {
      _generateJawiContent(elements, chapter.name, ageGroup, images, audios);
    } else if (subjectContext == 'language') {
      _generateLanguageContent(elements, chapter.name, ageGroup, images, audios);
    } else {
      // Default content generation for other subjects
      for (int i = 0; i < pageCount; i++) {
        // Add section heading
        elements.add({
          'type': 'text',
          'content': 'Section ${i+1}: ${_getTopicForSection(chapter.name, i)}',
          'isBold': true,
          'isItalic': false,
          'fontSize': 20.0,
          'textColor': '#2196F3', // Blue color for headings
        });
        
        // Add detailed content
        elements.add({
          'type': 'text',
          'content': _getDetailedContent(chapter.name, i, ageGroup),
          'isBold': false,
          'isItalic': false,
        });
        
        // Add images for visual learning
        if (images.isNotEmpty) {
          elements.add({
            'type': 'image',
            'imageUrl': images[random.nextInt(images.length)],
            'caption': 'Figure ${i+1}: Visual representation for ${_getTopicForSection(chapter.name, i)}',
            'width': 250.0,
            'height': 180.0,
          });
        }
        
        // Add audio explanation for some sections
        if (i % 2 == 0 && audios.isNotEmpty) {
          elements.add({
            'type': 'audio',
            'audioUrl': audios[random.nextInt(audios.length)],
            'title': 'Audio explanation for ${_getTopicForSection(chapter.name, i)}',
          });
        }
        
        // Add activity or exercise for engagement
        elements.add({
          'type': 'text',
          'content': 'Activity: ' + _getActivityForTopic(chapter.name, i, ageGroup),
          'isBold': true,
          'isItalic': false,
          'textColor': '#4CAF50', // Green color for activities
        });
      }
    }
    
    // Add a summary page at the end
    elements.add({
      'type': 'text',
      'content': 'Summary',
      'isBold': true,
      'isItalic': false,
      'fontSize': 20.0,
      'textColor': '#3F51B5',
    });
    
    elements.add({
      'type': 'text',
      'content': 'In this lesson, we learned about ${chapter.name}. ' +
                'We covered important concepts and did activities to help us understand better. ' +
                'Remember to practice what you learned!',
      'isBold': false,
      'isItalic': false,
    });
    
    return {
      'title': title,
      'description': description,
      'elements': elements,
      'isComplete': true, // Mark as complete for teacher review
    };
  }
  
  // Helper methods for generating content based on subject
  
  // Generate math content
  void _generateMathContent(List<Map<String, dynamic>> elements, String chapterName, int ageGroup, List<String> images, List<String> audios) {
    final random = Random();
    
    // Math topics based on chapter name
    List<String> topics = ['Numbers', 'Counting', 'Shapes', 'Addition', 'Subtraction'];
    if (chapterName.toLowerCase().contains('add')) {
      topics = ['Addition', 'Counting Forward', 'Number Bonds', 'Mental Math', 'Word Problems'];
    } else if (chapterName.toLowerCase().contains('subtract')) {
      topics = ['Subtraction', 'Counting Backward', 'Number Bonds', 'Mental Math', 'Word Problems'];
    } else if (chapterName.toLowerCase().contains('shape')) {
      topics = ['2D Shapes', '3D Shapes', 'Patterns', 'Symmetry', 'Geometry'];
    }
    
    // Generate content for each topic
    for (int i = 0; i < topics.length; i++) {
      // Add section heading
      elements.add({
        'type': 'text',
        'content': 'Section ${i+1}: ${topics[i]}',
        'isBold': true,
        'isItalic': false,
        'fontSize': 20.0,
        'textColor': '#2196F3',
      });
      
      // Add explanation
      String content = '';
      if (topics[i] == 'Addition') {
        content = 'Addition means putting numbers together to find the total. ' +
                 'For example, 2 + 3 = 5. This means 2 apples plus 3 apples gives us 5 apples in total.';
      } else if (topics[i] == 'Subtraction') {
        content = 'Subtraction means taking away one number from another. ' +
                 'For example, 5 - 2 = 3. This means if you have 5 apples and eat 2, you will have 3 apples left.';
      } else {
        content = 'Let\'s learn about ${topics[i]} in mathematics. This is an important concept that helps us understand numbers and patterns.';
      }
      
      elements.add({
        'type': 'text',
        'content': content,
        'isBold': false,
        'isItalic': false,
      });
      
      // Add an image
      if (images.isNotEmpty) {
        elements.add({
          'type': 'image',
          'imageUrl': images[random.nextInt(images.length)],
          'caption': 'Visual example of ${topics[i]}',
          'width': 250.0,
          'height': 180.0,
        });
      }
      
      // Add an activity
      String activity = '';
      if (ageGroup <= 5) {
        activity = 'Count the objects in the picture and write the number.';
      } else {
        activity = 'Solve these problems: 1) 3 + 4 = ? 2) 8 - 5 = ? 3) If you have 6 candies and get 2 more, how many do you have now?';
      }
      
      elements.add({
        'type': 'text',
        'content': 'Activity: ' + activity,
        'isBold': true,
        'isItalic': false,
        'textColor': '#4CAF50',
      });
    }
  }
  
  // Generate science content
  void _generateScienceContent(List<Map<String, dynamic>> elements, String chapterName, int ageGroup, List<String> images, List<String> audios) {
    final random = Random();
    
    // Science topics based on chapter name
    List<String> topics = ['Plants', 'Animals', 'Weather', 'Earth', 'Human Body'];
    if (chapterName.toLowerCase().contains('plant')) {
      topics = ['Parts of a Plant', 'How Plants Grow', 'Types of Plants', 'Plants We Eat', 'Taking Care of Plants'];
    } else if (chapterName.toLowerCase().contains('animal')) {
      topics = ['Types of Animals', 'Animal Homes', 'What Animals Eat', 'Baby Animals', 'Animal Movements'];
    }
    
    // Generate content for each topic
    for (int i = 0; i < topics.length; i++) {
      // Add section heading
      elements.add({
        'type': 'text',
        'content': 'Section ${i+1}: ${topics[i]}',
        'isBold': true,
        'isItalic': false,
        'fontSize': 20.0,
        'textColor': '#2196F3',
      });
      
      // Add explanation
      elements.add({
        'type': 'text',
        'content': 'In this section, we will learn about ${topics[i]}. Science helps us understand the world around us.',
        'isBold': false,
        'isItalic': false,
      });
      
      // Add an image
      if (images.isNotEmpty) {
        elements.add({
          'type': 'image',
          'imageUrl': images[random.nextInt(images.length)],
          'caption': 'Example of ${topics[i]}',
          'width': 250.0,
          'height': 180.0,
        });
      }
      
      // Add an audio if available
      if (i % 2 == 0 && audios.isNotEmpty) {
        elements.add({
          'type': 'audio',
          'audioUrl': audios[random.nextInt(audios.length)],
          'title': 'Listen about ${topics[i]}',
        });
      }
      
      // Add an activity
      elements.add({
        'type': 'text',
        'content': 'Activity: Draw and label the parts of a ${topics[i].toLowerCase().contains('plant') ? 'plant' : 'animal'}.',
        'isBold': true,
        'isItalic': false,
        'textColor': '#4CAF50',
      });
    }
  }
  
  // Generate Jawi content
  void _generateJawiContent(List<Map<String, dynamic>> elements, String chapterName, int ageGroup, List<String> images, List<String> audios) {
    final random = Random();
    
    // Jawi letters with their names and examples
    final jawiLetters = [
      {'letter': 'ا', 'name': 'Alif', 'example': 'Ayah', 'emoji': '👨'},
      {'letter': 'ب', 'name': 'Ba', 'example': 'Buku', 'emoji': '📚'},
      {'letter': 'ت', 'name': 'Ta', 'example': 'Taman', 'emoji': '🌳'},
      {'letter': 'ث', 'name': 'Tha', 'example': 'Thalatha', 'emoji': '3️⃣'},
      {'letter': 'ج', 'name': 'Jim', 'example': 'Jalan', 'emoji': '🛣️'},
      {'letter': 'ح', 'name': 'Ha', 'example': 'Hari', 'emoji': '📅'},
      {'letter': 'خ', 'name': 'Kha', 'example': 'Khabar', 'emoji': '📰'},
      {'letter': 'د', 'name': 'Dal', 'example': 'Daun', 'emoji': '🍃'},
    ];
    
    // Introduction to Jawi
    elements.add({
      'type': 'text',
      'content': 'Jawi is a writing system used for the Malay language based on Arabic script. Let\'s learn some Jawi letters!',
      'isBold': false,
      'isItalic': false,
    });
    
    // Generate content for each letter (limit based on age)
    int letterCount = ageGroup <= 5 ? 4 : jawiLetters.length;
    for (int i = 0; i < letterCount; i++) {
      // Add letter heading
      elements.add({
        'type': 'text',
        'content': 'Letter ${i+1}: ${jawiLetters[i]['letter']} (${jawiLetters[i]['name']})',
        'isBold': true,
        'isItalic': false,
        'fontSize': 24.0,
        'textColor': '#2196F3',
      });
      
      // Add explanation
      elements.add({
        'type': 'text',
        'content': 'This is the letter ${jawiLetters[i]['name'] ?? ''}. It makes the sound "${(jawiLetters[i]['name'] ?? '').isNotEmpty ? jawiLetters[i]['name']![0] : ''}". ' +
                   'An example word is "${jawiLetters[i]['example'] ?? ''}".',
        'isBold': false,
        'isItalic': false,
      });
      
      // Add an image
      if (images.isNotEmpty) {
        elements.add({
          'type': 'image',
          'imageUrl': images[random.nextInt(images.length)],
          'caption': 'Example for ${jawiLetters[i]['name']}: ${jawiLetters[i]['example']}',
          'width': 250.0,
          'height': 180.0,
        });
      }
      
      // Add an audio if available
      if (audios.isNotEmpty) {
        elements.add({
          'type': 'audio',
          'audioUrl': audios[random.nextInt(audios.length)],
          'title': 'Listen to ${jawiLetters[i]['name']} pronunciation',
        });
      }
      
      // Add a tracing activity
      elements.add({
        'type': 'text',
        'content': 'Activity: Practice writing the letter ${jawiLetters[i]['letter']} in the space below.',
        'isBold': true,
        'isItalic': false,
        'textColor': '#4CAF50',
      });
    }
  }
  
  // Generate language content
  void _generateLanguageContent(List<Map<String, dynamic>> elements, String chapterName, int ageGroup, List<String> images, List<String> audios) {
    final random = Random();
    
    // Language topics
    List<String> topics = ['Alphabet', 'Vocabulary', 'Reading', 'Writing', 'Speaking'];
    
    // Generate content for each topic
    for (int i = 0; i < topics.length; i++) {
      // Add section heading
      elements.add({
        'type': 'text',
        'content': 'Section ${i+1}: ${topics[i]}',
        'isBold': true,
        'isItalic': false,
        'fontSize': 20.0,
        'textColor': '#2196F3',
      });
      
      // Add explanation
      elements.add({
        'type': 'text',
        'content': 'In this section, we will learn about ${topics[i]}. Language helps us communicate with others.',
        'isBold': false,
        'isItalic': false,
      });
      
      // Add an image
      if (images.isNotEmpty) {
        elements.add({
          'type': 'image',
          'imageUrl': images[random.nextInt(images.length)],
          'caption': 'Example for ${topics[i]}',
          'width': 250.0,
          'height': 180.0,
        });
      }
      
      // Add an activity
      String activity = '';
      if (topics[i] == 'Alphabet') {
        activity = 'Write the missing letters: A, B, _, D, _, F';
      } else if (topics[i] == 'Vocabulary') {
        activity = 'Match the words with the pictures.';
      } else {
        activity = 'Read the sentence and draw a picture about it.';
      }
      
      elements.add({
        'type': 'text',
        'content': 'Activity: ' + activity,
        'isBold': true,
        'isItalic': false,
        'textColor': '#4CAF50',
      });
    }
  }
  
  // Helper method to get a topic for a section based on chapter name
  String _getTopicForSection(String chapterName, int sectionIndex) {
    // Default topics
    final defaultTopics = [
      'Introduction', 
      'Key Concepts', 
      'Examples', 
      'Activities', 
      'Review'
    ];
    
    return defaultTopics[sectionIndex % defaultTopics.length];
  }
  
  // Helper method to get detailed content for a topic
  String _getDetailedContent(String chapterName, int sectionIndex, int ageGroup) {
    // Simplified content for younger children
    if (ageGroup <= 5) {
      return 'This is all about $chapterName. ' +
             'We learn new things every day. ' +
             'Learning is fun and helps us grow smarter!';
    }
    
    // More detailed content for older children
    return 'In this section about $chapterName, we will explore important concepts and ideas. ' +
           'Understanding these concepts will help you build a strong foundation. ' +
           'Make sure to complete all the activities to practice what you\'ve learned.';
  }
  
  // Helper method to get an activity for a topic
  String _getActivityForTopic(String chapterName, int sectionIndex, int ageGroup) {
    if (ageGroup <= 5) {
      return 'Draw a picture about $chapterName and show it to your teacher.';
    } else {
      return 'Write three things you learned about $chapterName and one question you still have.';
    }
  }
}
