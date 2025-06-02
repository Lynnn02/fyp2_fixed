import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../models/note_content.dart';
import '../../../services/gemini_service.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnhancedNoteTemplateManager {
  final GeminiService _geminiService = GeminiService();

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
  }) async {
    // Prepare the prompt based on template type and age
    String prompt = _buildPromptForTemplate(
      templateId: templateId,
      subject: subject,
      chapter: chapter,
      age: age,
    );

    try {
      // Generate content using Gemini
      final response = await _geminiService.generateNoteContent(prompt);
      
      // Process the response into structured note content
      return _processGeminiResponse(response, templateId, age);
    } catch (e) {
      print('Error generating note content: $e');
      return {
        'title': 'Error generating content',
        'elements': [],
      };
    }
  }

  // Build prompt for different template types
  String _buildPromptForTemplate({
    required String templateId,
    required String subject,
    required String chapter,
    required int age,
  }) {
    final pageLimit = getPageLimitForAge(age);
    final vocabularyLevel = getVocabularyLevelForAge(age);
    final sentenceComplexity = getSentenceComplexityForAge(age);
    final interactiveElements = getInteractiveElementsForAge(age).join(", ");
    final imageRatio = (getImageRatioForAge(age) * 100).toInt();

    String basePrompt = """
    Create educational content for children age $age about '$chapter' in the subject '$subject'.
    The content should be:
    - Appropriate for $age-year-old children
    - Using vocabulary that is $vocabularyLevel
    - Using $sentenceComplexity
    - Including $interactiveElements
    - Having approximately $imageRatio% visual content and ${100 - imageRatio}% text content
    - Limited to $pageLimit pages maximum
    """;

    switch (templateId) {
      case 'balanced':
        return basePrompt + """
        Create a balanced educational note with a mix of text, images, and interactive elements.
        Structure the content with:
        - An engaging title
        - A brief introduction
        - Key concepts explained simply
        - Visual examples
        - Interactive questions or activities
        - A simple summary
        """;
      
      case 'story':
        return basePrompt + """
        Create a narrative story that teaches about the topic.
        Structure the story with:
        - An engaging title
        - Characters that children can relate to
        - A clear beginning, middle, and end
        - Educational content woven into the story
        - Visual scenes to illustrate key moments
        - Questions or activities related to the story
        """;
      
      case 'factual':
        return basePrompt + """
        Create a fact-based educational note that presents information clearly.
        Structure the content with:
        - An informative title
        - Simple, clear facts about the topic
        - Visual examples or diagrams
        - "Did you know?" sections with interesting facts
        - Simple explanations of concepts
        - Review questions
        """;
      
      case 'interactive':
        return basePrompt + """
        Create a highly interactive educational note with many activities.
        Structure the content with:
        - An engaging title
        - Brief explanations of concepts
        - Multiple interactive elements like:
          * Questions to answer
          * Matching activities
          * Fill-in-the-blank exercises
          * Counting or sequencing activities
          * Simple puzzles
        - Visual aids for each activity
        - Encouraging feedback phrases
        """;
      
      case 'visual':
        return basePrompt + """
        Create a visually-focused educational note with minimal text.
        Structure the content with:
        - An engaging title
        - Primarily visual content (images, diagrams)
        - Very brief text explanations
        - Visual sequences showing processes or concepts
        - Simple labels and captions
        - Visual questions or activities
        """;
      
      default:
        return basePrompt;
    }
  }

  // Process Gemini response into structured note content
  Map<String, dynamic> _processGeminiResponse(String response, String templateId, int age) {
    // Extract title and content sections
    final lines = response.split('\n');
    String title = 'New Note';
    List<Map<String, dynamic>> elements = [];
    
    // Try to extract title from first line
    if (lines.isNotEmpty && lines[0].trim().isNotEmpty) {
      title = lines[0].trim();
      // Remove any markdown characters like # from the title
      title = title.replaceAll(RegExp(r'^#+\s*'), '');
    }
    
    // Process the rest of the content
    bool isInTextBlock = false;
    String currentTextBlock = '';
    
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      
      // Skip empty lines
      if (line.isEmpty) {
        if (isInTextBlock && currentTextBlock.isNotEmpty) {
          // End of text block
          elements.add({
            'type': 'text',
            'content': currentTextBlock.trim(),
            'isBold': false,
            'isItalic': false,
          });
          currentTextBlock = '';
          isInTextBlock = false;
        }
        continue;
      }
      
      // Check for image descriptions (in brackets or with image keywords)
      if (line.contains('[image') || line.contains('(image') || 
          line.startsWith('image:') || line.startsWith('Image:') ||
          line.contains('picture of') || line.contains('diagram of')) {
        
        // If we were in a text block, end it
        if (isInTextBlock && currentTextBlock.isNotEmpty) {
          elements.add({
            'type': 'text',
            'content': currentTextBlock.trim(),
            'isBold': false,
            'isItalic': false,
          });
          currentTextBlock = '';
          isInTextBlock = false;
        }
        
        // Add image element
        String caption = line
            .replaceAll(RegExp(r'\[image.*?\]'), '')
            .replaceAll(RegExp(r'\(image.*?\)'), '')
            .replaceAll('image:', '')
            .replaceAll('Image:', '')
            .trim();
            
        elements.add({
          'type': 'image',
          'imageUrl': '', // Will be filled by Gemini later
          'caption': caption.isEmpty ? 'Image' : caption,
        });
      }
      // Check for audio descriptions
      else if (line.contains('[audio') || line.contains('(audio') || 
               line.startsWith('audio:') || line.startsWith('Audio:') ||
               line.contains('listen to')) {
        
        // If we were in a text block, end it
        if (isInTextBlock && currentTextBlock.isNotEmpty) {
          elements.add({
            'type': 'text',
            'content': currentTextBlock.trim(),
            'isBold': false,
            'isItalic': false,
          });
          currentTextBlock = '';
          isInTextBlock = false;
        }
        
        // Add audio element
        String description = line
            .replaceAll(RegExp(r'\[audio.*?\]'), '')
            .replaceAll(RegExp(r'\(audio.*?\)'), '')
            .replaceAll('audio:', '')
            .replaceAll('Audio:', '')
            .trim();
            
        elements.add({
          'type': 'audio',
          'audioUrl': '', // Will be filled later
          'title': description.isEmpty ? 'Audio' : description,
        });
      }
      // Check for interactive elements
      else if (line.contains('activity:') || line.contains('Activity:') ||
               line.contains('question:') || line.contains('Question:') ||
               line.contains('exercise:') || line.contains('Exercise:')) {
        
        // If we were in a text block, end it
        if (isInTextBlock && currentTextBlock.isNotEmpty) {
          elements.add({
            'type': 'text',
            'content': currentTextBlock.trim(),
            'isBold': false,
            'isItalic': false,
          });
          currentTextBlock = '';
          isInTextBlock = false;
        }
        
        // Add interactive element
        String activityText = line
            .replaceAll('activity:', '')
            .replaceAll('Activity:', '')
            .replaceAll('question:', '')
            .replaceAll('Question:', '')
            .replaceAll('exercise:', '')
            .replaceAll('Exercise:', '')
            .trim();
            
        elements.add({
          'type': 'interactive',
          'content': activityText,
          'activityType': line.toLowerCase().contains('question') ? 'question' :
                         line.toLowerCase().contains('match') ? 'matching' :
                         'activity',
        });
      }
      // Regular text
      else {
        if (!isInTextBlock) {
          isInTextBlock = true;
          currentTextBlock = line;
        } else {
          currentTextBlock += '\n' + line;
        }
      }
    }
    
    // Add any remaining text block
    if (isInTextBlock && currentTextBlock.isNotEmpty) {
      elements.add({
        'type': 'text',
        'content': currentTextBlock.trim(),
        'isBold': false,
        'isItalic': false,
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

  // Add template-specific elements based on template type
  void _addTemplateSpecificElements(List<Map<String, dynamic>> elements, String templateId, int age) {
    switch (templateId) {
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
      id: const Uuid().v4(),
      title: processedContent['title'] ?? 'New Note',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      elements: noteElements,
    );
  }
}
