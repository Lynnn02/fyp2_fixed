import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject.dart';
import '../models/note_content.dart';
import '../models/container_element.dart';
import 'json_helper_fixed.dart';

class GeminiNotesService {
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
    } else if (name.contains('language') || name.contains('bahasa') || name.contains('english')) {
      return 'language';
    }
    
    return 'general';
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
        } else if (type == 'container') {
          // Handle container elements for flashcards
          final List<dynamic> containerElements = element['elements'] ?? [];
          final List<NoteContentElement> childElements = [];
          
          // Process child elements
          for (final childElement in containerElements) {
            final String childType = childElement['type'];
            final String childId = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();
            
            if (childType == 'text') {
              childElements.add(TextElement(
                id: childId,
                position: childElements.length,
                createdAt: createdAt,
                content: childElement['content'] ?? '',
                isBold: childElement['isBold'] ?? false,
                isItalic: childElement['isItalic'] ?? false,
                isList: childElement['isList'] ?? false,
                fontSize: childElement['fontSize']?.toDouble() ?? 16.0,
                textColor: childElement['textColor'] ?? '#000000',
              ));
            } else if (childType == 'image') {
              childElements.add(ImageElement(
                id: childId,
                position: childElements.length,
                createdAt: createdAt,
                imageUrl: childElement['imageUrl'] ?? '',
                caption: childElement['caption'] ?? '',
                width: childElement['width']?.toDouble() ?? 300.0,
                height: childElement['height']?.toDouble() ?? 200.0,
              ));
            } else if (childType == 'audio') {
              childElements.add(AudioElement(
                id: childId,
                position: childElements.length,
                createdAt: createdAt,
                audioUrl: childElement['audioUrl'] ?? '',
                title: childElement['title'] ?? 'Audio',
              ));
            }
          }
          
          // Add the container element with its children
          elements.add(ContainerElement(
            id: id,
            position: position++,
            createdAt: createdAt,
            elements: childElements,
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
          fontSize: 24.0,
          textColor: '#3F51B5',
        ),
      ];
    }
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
    
    // Get images and audios for the subject
    final List<String> images = imageUrls[subject.name.toLowerCase()] ?? [];
    final List<String> audios = audioUrls[subject.name.toLowerCase()] ?? [];
    
    // Determine which content generation method to use based on subject and chapter
    final String subjectName = subject.name.toLowerCase();
    final String chapterName = chapter.name.toLowerCase();
    
    // Generate content based on subject type
    if (_isJawiOrArabicSubject(subjectName) || _isJawiOrArabicChapter(chapterName)) {
      // Generate Jawi or Arabic content
      _generateJawiContent(elements, chapter.name, ageGroup, images, audios);
    } else if (subjectName.contains('english') || 
        subjectName.contains('bahasa') || 
        subjectName.contains('language')) {
      // Generate language content
      _generateLanguageContent(elements, chapter.name, ageGroup, images, audios);
    } else if (subjectName.contains('math') || 
        subjectName.contains('matematik')) {
      // Generate math content
      _generateMathContent(elements, chapter.name, ageGroup, images, audios);
    } else if (subjectName.contains('science') || 
        subjectName.contains('sains')) {
      // Generate science content
      _generateScienceContent(elements, chapter.name, ageGroup, images, audios);
    } else if (subjectName.contains('social') || 
        subjectName.contains('emotion') || 
        subjectName.contains('emotional')) {
      // Generate social and emotional learning content
      _generateSocialEmotionalContent(elements, chapter.name, ageGroup, images, audios);
    } else if (subjectName.contains('art') || 
        subjectName.contains('craft')) {
      // Generate art and craft content
      _generateArtCraftContent(elements, chapter.name, ageGroup, images, audios);
    } else if (subjectName.contains('physical') || 
        subjectName.contains('motor')) {
      // Generate physical development content
      _generatePhysicalDevelopmentContent(elements, chapter.name, ageGroup, images, audios);
    } else {
      // If no specific content generator is available, use language content as default
      _generateLanguageContent(elements, chapter.name, ageGroup, images, audios);
    }
    
    // Create a title with proper capitalization
    final title = 'Learning About ${chapter.name}';
    
    // Create a description
    final description = 'Educational content to help children learn about ${chapter.name}';
    
    // Use the images and audios we already have
    
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
      final int defaultPageCount = 5; // Define a default page count
      for (int i = 0; i < defaultPageCount; i++) {
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
      }
    }
    
    return {
      'title': title,
      'description': description,
      'elements': elements,
    };
  }
  
  // Helper method to get a topic for a section based on chapter name
  String _getTopicForSection(String chapterName, int sectionIndex) {
    // Default topics
    final defaultTopics = [
      'Introduction', 
      'Key Concepts', 
      'Examples', 
      'Activities',
      'Review',
      'Fun Facts',
      'Quiz',
      'Summary'
    ];
    
    // If we have specific topics for this chapter, use those
    // Otherwise, use the default topics
    return defaultTopics[sectionIndex % defaultTopics.length];
  }
  
  // Helper method to get detailed content for a section
  String _getDetailedContent(String chapterName, int sectionIndex, int ageGroup) {
    final topic = _getTopicForSection(chapterName, sectionIndex);
    
    // Adjust content complexity based on age
    String contentPrefix = '';
    if (ageGroup <= 4) {
      contentPrefix = 'This is a simple explanation about ';
    } else if (ageGroup == 5) {
      contentPrefix = 'Let\'s learn more about ';
    } else {
      contentPrefix = 'Here\'s what you need to know about ';
    }
    
    // Generate content based on topic
    switch (topic) {
      case 'Introduction':
        return '$contentPrefix$chapterName. This is the beginning of our learning journey!';
      case 'Key Concepts':
        return '$contentPrefix the important ideas in $chapterName. Remember these key points!';
      case 'Examples':
        return 'Here are some examples of $chapterName that you can see in everyday life.';
      case 'Activities':
        return 'Let\'s do some fun activities to learn more about $chapterName!';
      case 'Review':
        return 'Let\'s review what we\'ve learned about $chapterName so far.';
      case 'Fun Facts':
        return 'Did you know? Here are some interesting facts about $chapterName!';
      case 'Quiz':
        return 'Test your knowledge about $chapterName with these questions.';
      case 'Summary':
        return 'To sum up what we\'ve learned about $chapterName...';
      default:
        return 'Let\'s learn about $chapterName together!';
    }
  }
}

  // Generate math content as flashcards
void _generateMathContent(List<Map<String, dynamic>> elements, String chapterName, int ageGroup, List<String> images, List<String> audios) {
  final random = Random();
  elements.clear();
  
  // Determine content based on chapter name
  if (chapterName.toLowerCase().contains('count')) {
    // Counting 1-10 chapter
    for (int i = 1; i <= 10; i++) {
      // Create a flashcard container with text, image, and audio elements
      final Map<String, dynamic> flashcard = {
        'type': 'container',
        'elements': [
          // Number as main text
          {
            'type': 'text',
            'content': '$i',
            'isBold': true,
            'isItalic': false,
            'fontSize': 72.0, // Large font for the number
            'textColor': _getColorForIndex(i % 8),
          },
          // Image showing the number of objects
          {
            'type': 'image',
            'imageUrl': 'https://via.placeholder.com/300x300/FFFFFF/000000?text=$i ${i == 1 ? "object" : "objects"}',
            'caption': '$i ${i == 1 ? "object" : "objects"}',
            'width': 200.0,
            'height': 200.0,
          },
          // Word representation
          {
            'type': 'text',
            'content': _getNumberWord(i),
            'isBold': true,
            'isItalic': false,
            'fontSize': 24.0,
            'textColor': '#000000',
          },
          // Audio for pronunciation
          {
            'type': 'audio',
            'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
            'title': 'Listen to number $i',
          }
        ]
      };
      
      elements.add(flashcard);
    }
  } else if (chapterName.toLowerCase().contains('shape') || chapterName.toLowerCase().contains('pattern')) {
    // Shapes & Patterns chapter
    final shapes = [
      {'name': 'Circle', 'emoji': '⭕'},
      {'name': 'Square', 'emoji': '🔲'},
      {'name': 'Triangle', 'emoji': '🔺'},
      {'name': 'Rectangle', 'emoji': '▬'},
      {'name': 'Star', 'emoji': '⭐'},
      {'name': 'Heart', 'emoji': '❤️'},
    ];
    
    for (int i = 0; i < shapes.length; i++) {
      // Create a flashcard container with text, image, and audio elements
      final Map<String, dynamic> flashcard = {
        'type': 'container',
        'elements': [
          // Shape name as main text
          {
            'type': 'text',
            'content': shapes[i]['name'],
            'isBold': true,
            'isItalic': false,
            'fontSize': 48.0, // Large font for the shape name
            'textColor': _getColorForIndex(i),
          },
          // Shape image
          {
            'type': 'image',
            'imageUrl': 'https://via.placeholder.com/300x300/FFFFFF/000000?text=${shapes[i]['emoji']}',
            'caption': shapes[i]['name'],
            'width': 200.0,
            'height': 200.0,
          },
          // Description
          {
            'type': 'text',
            'content': 'This is a ${shapes[i]['name']}',
            'isBold': true,
            'isItalic': false,
            'fontSize': 24.0,
            'textColor': '#000000',
          },
          // Audio for pronunciation
          {
            'type': 'audio',
            'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
            'title': 'Listen to ${shapes[i]['name']}',
          }
        ]
      };
      
      elements.add(flashcard);
    }
  }
}

// Helper method to convert number to word
String _getNumberWord(int number) {
  final words = ['One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten'];
  if (number >= 1 && number <= 10) {
    return words[number - 1];
  }
  return number.toString();
  }
  
  // Generate science content as flashcards
  void _generateScienceContent(List<Map<String, dynamic>> elements, String chapterName, int ageGroup, List<String> images, List<String> audios) {
  final random = Random();
  elements.clear();
  
  if (chapterName.toLowerCase().contains('sense')) {
    // Five Senses chapter
    final senses = [
      {'sense': 'Sight', 'organ': 'Eyes', 'emoji': '👁️'},
      {'sense': 'Hearing', 'organ': 'Ears', 'emoji': '👂'},
      {'sense': 'Smell', 'organ': 'Nose', 'emoji': '👃'},
      {'sense': 'Taste', 'organ': 'Tongue', 'emoji': '👅'},
      {'sense': 'Touch', 'organ': 'Skin', 'emoji': '🤚️'},
    ];
    
    for (int i = 0; i < senses.length; i++) {
      // Create a flashcard container with text, image, and audio elements
      final Map<String, dynamic> flashcard = {
        'type': 'container',
        'elements': [
          // Sense name as main text
          {
            'type': 'text',
            'content': senses[i]['sense'],
            'isBold': true,
            'isItalic': false,
            'fontSize': 48.0, // Large font for the sense name
            'textColor': _getColorForIndex(i),
          },
          // Sense organ image
          {
            'type': 'image',
            'imageUrl': 'https://via.placeholder.com/300x300/FFFFFF/000000?text=${senses[i]['emoji']}',
            'caption': senses[i]['organ'],
            'width': 200.0,
            'height': 200.0,
          },
          // Description
          {
            'type': 'text',
            'content': 'We use our ${senses[i]['organ']} for ${senses[i]['sense']}',
            'isBold': true,
            'isItalic': false,
            'fontSize': 24.0,
            'textColor': '#000000',
          },
          // Audio for explanation
          {
            'type': 'audio',
            'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
            'title': 'Learn about ${senses[i]['sense']}',
          }
        ]
      };
      
      elements.add(flashcard);
    }
  } else if (chapterName.toLowerCase().contains('living')) {
    // Living vs Non-living Things chapter
    final things = [
      {'name': 'Tree', 'type': 'Living', 'emoji': '🌳', 'description': 'Trees are living things. They grow and need water and sunlight.'},
      {'name': 'Dog', 'type': 'Living', 'emoji': '🐶', 'description': 'Dogs are living things. They move, eat food, and breathe.'},
      {'name': 'Rock', 'type': 'Non-living', 'emoji': '🪨', 'description': 'Rocks are non-living things. They don\'t grow or need food.'},
      {'name': 'Car', 'type': 'Non-living', 'emoji': '🚗', 'description': 'Cars are non-living things. They need people to move them.'},
      {'name': 'Flower', 'type': 'Living', 'emoji': '🌸', 'description': 'Flowers are living things. They grow and make seeds.'},
      {'name': 'Chair', 'type': 'Non-living', 'emoji': '🪑', 'description': 'Chairs are non-living things. They don\'t grow or change.'},
    ];
    
    for (int i = 0; i < things.length; i++) {
      // Create a flashcard container with text, image, and audio elements
      final Map<String, dynamic> flashcard = {
        'type': 'container',
        'elements': [
          // Thing name as main text
          {
            'type': 'text',
            'content': things[i]['name'],
            'isBold': true,
            'isItalic': false,
            'fontSize': 48.0, // Large font for the thing name
            'textColor': things[i]['type'] == 'Living' ? '#4CAF50' : '#2196F3', // Green for living, blue for non-living
          },
          // Thing image
          {
            'type': 'image',
            'imageUrl': 'https://via.placeholder.com/300x300/FFFFFF/000000?text=${things[i]['emoji']}',
            'caption': '${things[i]['type']} Thing',
            'width': 200.0,
            'height': 200.0,
          },
          // Description
          {
            'type': 'text',
            'content': things[i]['description'],
            'isBold': true,
            'isItalic': false,
            'fontSize': 24.0,
            'textColor': '#000000',
          },
          // Audio for explanation
          {
            'type': 'audio',
            'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
            'title': 'Learn about ${things[i]['name']}',
          }
        ]
      };
      
      elements.add(flashcard);
    }
  }
  }

  // Generate Social & Emotional Learning content as flashcards
  void _generateSocialEmotionalContent(List<Map<String, dynamic>> elements, String chapterName, int ageGroup, List<String> images, List<String> audios) {
    final random = Random();
    elements.clear();
    
    if (chapterName.toLowerCase().contains('emotion')) {
      // Emotions & Expressions chapter
      final emotions = [
        {'name': 'Happy', 'emoji': '😊', 'description': 'I feel happy when I play with my friends.'},
        {'name': 'Sad', 'emoji': '😢', 'description': 'I feel sad when I lose my toy.'},
        {'name': 'Angry', 'emoji': '😠', 'description': 'I feel angry when someone breaks my toys.'},
        {'name': 'Scared', 'emoji': '😨', 'description': 'I feel scared during thunderstorms.'},
        {'name': 'Excited', 'emoji': '🤩', 'description': 'I feel excited on my birthday.'},
        {'name': 'Surprised', 'emoji': '😲', 'description': 'I feel surprised when I get a gift.'},
      ];
      
      for (int i = 0; i < emotions.length; i++) {
        // Create a flashcard container with text, image, and audio elements
        final Map<String, dynamic> flashcard = {
          'type': 'container',
          'elements': [
            // Emotion name as main text
            {
              'type': 'text',
              'content': emotions[i]['name'],
              'isBold': true,
              'isItalic': false,
              'fontSize': 48.0, // Large font for the emotion name
              'textColor': _getColorForIndex(i),
            },
            // Emotion image
            {
              'type': 'image',
              'imageUrl': 'https://via.placeholder.com/300x300/FFFFFF/000000?text=${emotions[i]['emoji']}',
              'caption': emotions[i]['name'],
              'width': 200.0,
              'height': 200.0,
            },
            // Description
            {
              'type': 'text',
              'content': emotions[i]['description'],
              'isBold': true,
              'isItalic': false,
              'fontSize': 24.0,
              'textColor': '#000000',
            },
            // Audio for explanation
            {
              'type': 'audio',
              'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
              'title': 'Learn about feeling ${emotions[i]['name']}',
            }
          ]
        };
        
        elements.add(flashcard);
      }
    } else if (chapterName.toLowerCase().contains('sharing') || chapterName.toLowerCase().contains('cooperation')) {
      // Sharing & Cooperation chapter
      final concepts = [
        {'name': 'Sharing', 'emoji': '🤝', 'description': 'I share my toys with my friends.'},
        {'name': 'Taking Turns', 'emoji': '🔄', 'description': 'I wait for my turn on the slide.'},
        {'name': 'Helping', 'emoji': '🤲', 'description': 'I help my friend clean up.'},
        {'name': 'Listening', 'emoji': '👂', 'description': 'I listen when my teacher talks.'},
        {'name': 'Being Kind', 'emoji': '❤️', 'description': 'I say nice words to my friends.'},
        {'name': 'Teamwork', 'emoji': '👨‍👩‍👧‍👦', 'description': 'We build a tower together.'},
      ];
      
      for (int i = 0; i < concepts.length; i++) {
        // Create a flashcard container with text, image, and audio elements
        final Map<String, dynamic> flashcard = {
          'type': 'container',
          'elements': [
            // Concept name as main text
            {
              'type': 'text',
              'content': concepts[i]['name'],
              'isBold': true,
              'isItalic': false,
              'fontSize': 48.0, // Large font for the concept name
              'textColor': _getColorForIndex(i),
            },
            // Concept image
            {
              'type': 'image',
              'imageUrl': 'https://via.placeholder.com/300x300/FFFFFF/000000?text=${concepts[i]['emoji']}',
              'caption': concepts[i]['name'],
              'width': 200.0,
              'height': 200.0,
            },
            // Description
            {
              'type': 'text',
              'content': concepts[i]['description'],
              'isBold': true,
              'isItalic': false,
              'fontSize': 24.0,
              'textColor': '#000000',
            },
            // Audio for explanation
            {
              'type': 'audio',
              'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
              'title': 'Learn about ${concepts[i]['name']}',
            }
          ]
        };
        
        elements.add(flashcard);
      }
    }
  }

  // Generate Art & Craft content as flashcards
  void _generateArtCraftContent(List<Map<String, dynamic>> elements, String chapterName, int ageGroup, List<String> images, List<String> audios) {
    final random = Random();
    elements.clear();
    
    if (chapterName.toLowerCase().contains('color')) {
      // Color Exploration & Mixing chapter
      final colors = [
        {'name': 'Red', 'hex': '#FF0000', 'emoji': '🔴', 'description': 'Red like an apple'},
        {'name': 'Blue', 'hex': '#0000FF', 'emoji': '🔵', 'description': 'Blue like the sky'},
        {'name': 'Yellow', 'hex': '#FFFF00', 'emoji': '🟡', 'description': 'Yellow like the sun'},
        {'name': 'Green', 'hex': '#00FF00', 'emoji': '🟢', 'description': 'Green like grass'},
        {'name': 'Purple', 'hex': '#800080', 'emoji': '🟣', 'description': 'Purple like grapes'},
        {'name': 'Orange', 'hex': '#FFA500', 'emoji': '🟠', 'description': 'Orange like an orange'},
      ];
      
      for (int i = 0; i < colors.length; i++) {
        // Create a flashcard container with text, image, and audio elements
        final Map<String, dynamic> flashcard = {
          'type': 'container',
          'elements': [
            // Color name as main text
            {
              'type': 'text',
              'content': colors[i]['name'],
              'isBold': true,
              'isItalic': false,
              'fontSize': 48.0, // Large font for the color name
              'textColor': colors[i]['hex'],
            },
            // Color image
            {
              'type': 'image',
              'imageUrl': 'https://via.placeholder.com/300x300/FFFFFF/000000?text=${colors[i]['emoji']}',
              'caption': colors[i]['name'],
              'width': 200.0,
              'height': 200.0,
            },
            // Description
            {
              'type': 'text',
              'content': colors[i]['description'],
              'isBold': true,
              'isItalic': false,
              'fontSize': 24.0,
              'textColor': '#000000',
            },
            // Audio for explanation
            {
              'type': 'audio',
              'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
              'title': 'Learn about the color ${colors[i]['name']}',
            }
          ]
        };
        
        elements.add(flashcard);
      }
    } else if (chapterName.toLowerCase().contains('line') || chapterName.toLowerCase().contains('pattern')) {
      // Simple Lines & Patterns chapter
      final patterns = [
        {'name': 'Straight Line', 'symbol': '—', 'description': 'A straight line goes from one point to another.'},
        {'name': 'Curved Line', 'symbol': '~', 'description': 'A curved line bends and flows.'},
        {'name': 'Zigzag', 'symbol': '⚡', 'description': 'A zigzag line goes up and down with sharp turns.'},
        {'name': 'Spiral', 'symbol': '🌀', 'description': 'A spiral curves around a center point.'},
        {'name': 'Dots', 'symbol': '⋯', 'description': 'Dots are small round marks.'},
        {'name': 'Wavy Line', 'symbol': '〰️', 'description': 'A wavy line moves up and down smoothly.'},
      ];
      
      for (int i = 0; i < patterns.length; i++) {
        // Create a flashcard container with text, image, and audio elements
        final Map<String, dynamic> flashcard = {
          'type': 'container',
          'elements': [
            // Pattern name as main text
            {
              'type': 'text',
              'content': patterns[i]['name'],
              'isBold': true,
              'isItalic': false,
              'fontSize': 48.0, // Large font for the pattern name
              'textColor': _getColorForIndex(i),
            },
            // Pattern image
            {
              'type': 'image',
              'imageUrl': 'https://via.placeholder.com/300x300/FFFFFF/000000?text=${patterns[i]['symbol']}',
              'caption': patterns[i]['name'],
              'width': 200.0,
              'height': 200.0,
            },
            // Description
            {
              'type': 'text',
              'content': patterns[i]['description'],
              'isBold': true,
              'isItalic': false,
              'fontSize': 24.0,
              'textColor': '#000000',
            },
            // Audio for explanation
            {
              'type': 'audio',
              'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
              'title': 'Learn about ${patterns[i]['name']}',
            }
          ]
        };
        
        elements.add(flashcard);
      }
    }
  }

  // Generate Physical Development content as flashcards
  void _generatePhysicalDevelopmentContent(List<Map<String, dynamic>> elements, String chapterName, int ageGroup, List<String> images, List<String> audios) {
    final random = Random();
    elements.clear();
    
    if (chapterName.toLowerCase().contains('gross')) {
      // Gross Motor Skills chapter
      final skills = [
        {'name': 'Running', 'emoji': '🏃', 'description': 'Moving quickly on your feet'},
        {'name': 'Jumping', 'emoji': '🦘', 'description': 'Pushing off the ground with both feet'},
        {'name': 'Throwing', 'emoji': '🤾', 'description': 'Using your arm to send an object through the air'},
        {'name': 'Catching', 'emoji': '🧤', 'description': 'Using your hands to stop a moving object'},
        {'name': 'Kicking', 'emoji': '⚽', 'description': 'Using your foot to hit an object'},
        {'name': 'Climbing', 'emoji': '🧗', 'description': 'Moving up using your hands and feet'},
      ];
      
      for (int i = 0; i < skills.length; i++) {
        // Create a flashcard container with text, image, and audio elements
        final Map<String, dynamic> flashcard = {
          'type': 'container',
          'elements': [
            // Skill name as main text
            {
              'type': 'text',
              'content': skills[i]['name'],
              'isBold': true,
              'isItalic': false,
              'fontSize': 48.0, // Large font for the skill name
              'textColor': _getColorForIndex(i),
            },
            // Skill image
            {
              'type': 'image',
              'imageUrl': 'https://via.placeholder.com/300x300/FFFFFF/000000?text=${skills[i]['emoji']}',
              'caption': skills[i]['name'],
              'width': 200.0,
              'height': 200.0,
            },
            // Description
            {
              'type': 'text',
              'content': skills[i]['description'],
              'isBold': true,
              'isItalic': false,
              'fontSize': 24.0,
              'textColor': '#000000',
            },
            // Audio for explanation
            {
              'type': 'audio',
              'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
              'title': 'Learn about ${skills[i]['name']}',
            }
          ]
        };
        
        elements.add(flashcard);
      }
    } else if (chapterName.toLowerCase().contains('fine')) {
      // Fine Motor Skills chapter
      final skills = [
        {'name': 'Drawing', 'emoji': '✏️', 'description': 'Using a pencil to make marks on paper'},
        {'name': 'Cutting', 'emoji': '✂️', 'description': 'Using scissors to cut paper'},
        {'name': 'Buttoning', 'emoji': '👕', 'description': 'Putting buttons through buttonholes'},
        {'name': 'Zipping', 'emoji': '🧥', 'description': 'Pulling a zipper up and down'},
        {'name': 'Beading', 'emoji': '📿', 'description': 'Putting beads on a string'},
        {'name': 'Folding', 'emoji': '📄', 'description': 'Folding paper neatly'},
      ];
      
      for (int i = 0; i < skills.length; i++) {
        // Create a flashcard container with text, image, and audio elements
        final Map<String, dynamic> flashcard = {
          'type': 'container',
          'elements': [
            // Skill name as main text
            {
              'type': 'text',
              'content': skills[i]['name'],
              'isBold': true,
              'isItalic': false,
              'fontSize': 48.0, // Large font for the skill name
              'textColor': _getColorForIndex(i),
            },
            // Skill image
            {
              'type': 'image',
              'imageUrl': 'https://via.placeholder.com/300x300/FFFFFF/000000?text=${skills[i]['emoji']}',
              'caption': skills[i]['name'],
              'width': 200.0,
              'height': 200.0,
            },
            // Description
            {
              'type': 'text',
              'content': skills[i]['description'],
              'isBold': true,
              'isItalic': false,
              'fontSize': 24.0,
              'textColor': '#000000',
            },
            // Audio for explanation
            {
              'type': 'audio',
              'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
              'title': 'Learn about ${skills[i]['name']}',
            }
          ]
        };
        
        elements.add(flashcard);
      }
    }
  }

  // Helper method to get a color based on index
  String _getColorForIndex(int index) {
    final colors = [
      '#F44336', // Red
      '#2196F3', // Blue
      '#4CAF50', // Green
      '#FF9800', // Orange
      '#9C27B0', // Purple
      '#00BCD4', // Cyan
      '#FFEB3B', // Yellow
      '#795548', // Brown
    ];
    
    return colors[index % colors.length];
  }
  
  // Generate Jawi content as flashcards
  void _generateJawiContent(List<Map<String, dynamic>> elements, String chapterName, int ageGroup, List<String> images, List<String> audios) {
    final random = Random();
    
    // Clear existing elements to replace with flashcard format
    elements.clear();
    
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
    
    // Introduction flashcard
    elements.add({
      'type': 'container',
      'elements': [
        {
          'type': 'text',
          'content': 'Jawi Letters',
          'isBold': true,
          'isItalic': false,
          'fontSize': 28.0,
          'textColor': '#3F51B5',
        },
        {
          'type': 'image',
          'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/flashcards%2Fjawi_intro.png?alt=media',
          'caption': 'Jawi Alphabet',
          'width': 300.0,
          'height': 200.0,
        },
        {
          'type': 'audio',
          'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
          'title': 'Introduction to Jawi',
        }
      ]
    });
    
    // Generate flashcard for each letter (limit based on age)
    int letterCount = ageGroup <= 5 ? 4 : jawiLetters.length;
    for (int i = 0; i < letterCount; i++) {
      // Create a flashcard container with text, image, and audio elements
      final Map<String, dynamic> flashcard = {
        'type': 'container',
        'elements': [
          // Letter as main text
          {
            'type': 'text',
            'content': jawiLetters[i]['letter'],
            'isBold': true,
            'isItalic': false,
            'fontSize': 72.0, // Large font for the letter
            'textColor': _getColorForIndex(i),
          },
          // Emoji or image
          {
            'type': 'image',
            'imageUrl': 'https://via.placeholder.com/300x300/FFFFFF/000000?text=${jawiLetters[i]['emoji']}',
            'caption': jawiLetters[i]['example'],
            'width': 200.0,
            'height': 200.0,
          },
          // Word example
          {
            'type': 'text',
            'content': '${jawiLetters[i]['name']} - ${jawiLetters[i]['example']}',
            'isBold': true,
            'isItalic': false,
            'fontSize': 24.0,
            'textColor': '#000000',
          },
          // Audio for pronunciation
          {
            'type': 'audio',
            'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
            'title': 'Listen to ${jawiLetters[i]['name']} pronunciation',
          }
        ]
      };
      
      elements.add(flashcard);
    }
  }
  
  // Generate language content as flashcards
  List<Map<String, dynamic>> _generateLanguageContent(List<Map<String, dynamic>> elements, String chapterName, int ageGroup, List<String> images, List<String> audios) {
    final random = Random();
    
    // Clear existing elements to replace with flashcard format
    elements.clear();
    
    // English alphabet with examples and emojis
    final List<Map<String, dynamic>> alphabetCards = [
      {'letter': 'A', 'word': 'Apple', 'emoji': '🍎'},
      {'letter': 'B', 'word': 'Ball', 'emoji': '⚽'},
      {'letter': 'C', 'word': 'Cat', 'emoji': '🐱'},
      {'letter': 'D', 'word': 'Dog', 'emoji': '🐶'},
      {'letter': 'E', 'word': 'Elephant', 'emoji': '🐘'},
      {'letter': 'F', 'word': 'Fish', 'emoji': '🐠'},
      {'letter': 'G', 'word': 'Giraffe', 'emoji': '🦒'},
      {'letter': 'H', 'word': 'House', 'emoji': '🏠'},
    ];
    
    // Introduction flashcard
    elements.add({
      'type': 'container',
      'elements': [
        {
          'type': 'text',
          'content': 'English Alphabet',
          'isBold': true,
          'isItalic': false,
          'fontSize': 28.0,
          'textColor': '#3F51B5',
        },
        {
          'type': 'image',
          'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/flashcards%2Falphabet_intro.png?alt=media',
          'caption': 'English Alphabet',
          'width': 300.0,
          'height': 200.0,
        },
        {
          'type': 'audio',
          'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
          'title': 'Introduction to the Alphabet',
        }
      ]
    });
    
    // Generate flashcard for each letter (limit based on age)
    int letterCount = ageGroup <= 5 ? 5 : alphabetCards.length;
    for (int i = 0; i < letterCount; i++) {
      // Create a flashcard container with text, image, and audio elements
      final Map<String, dynamic> flashcard = {
        'type': 'container',
        'elements': [
          // Letter as main text
          {
            'type': 'text',
            'content': alphabetCards[i]['letter'],
            'isBold': true,
            'isItalic': false,
            'fontSize': 72.0, // Large font for the letter
            'textColor': _getColorForIndex(i),
          },
          // Emoji or image
          {
            'type': 'image',
            'imageUrl': 'https://via.placeholder.com/300x300/FFFFFF/000000?text=${alphabetCards[i]['emoji']}',
            'caption': alphabetCards[i]['word'],
            'width': 200.0,
            'height': 200.0,
          },
          // Word example
          {
            'type': 'text',
            'content': '${alphabetCards[i]['letter']} is for ${alphabetCards[i]['word']}',
            'isBold': true,
            'isItalic': false,
            'fontSize': 24.0,
            'textColor': '#000000',
          },
          // Audio for pronunciation
          {
            'type': 'audio',
            'audioUrl': audios.isNotEmpty ? audios[random.nextInt(audios.length)] : '',
            'title': 'Listen to ${alphabetCards[i]['letter']} pronunciation',
          }
        ]
      };
      
      elements.add(flashcard);
    }
    return elements;
}
