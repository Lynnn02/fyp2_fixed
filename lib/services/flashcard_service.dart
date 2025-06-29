import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fyp2/models/note_content.dart';
import 'package:fyp2/models/container_element.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FlashcardService {
  // Base URL for the backend API
  final String _baseUrl = 'http://localhost:3000'; // Change to your actual backend URL when deploying
  
  // Cache keys
  static const String _cachePrefix = 'flashcard_cache_';
  
  // Generate flashcards through the backend proxy
  Future<List<NoteContentElement>> generateFlashcards({
    required String subject,
    required String chapter,
    required int age,
    required String language,
    int count = 3,
  }) async {
    try {
      // Check cache first
      final cacheKey = '$_cachePrefix${subject}_${chapter}_${age}_$language';
      final cachedData = await _getCachedFlashcards(cacheKey);
      
      if (cachedData != null) {
        print('Using cached flashcards');
        return cachedData;
      }
      
      // Make API request to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/flashcards'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'subject': subject,
          'chapter': chapter,
          'age': age,
          'count': count,
          'language': language,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final flashcards = data['flashcards'] as List;
        
        // Convert to NoteContentElements
        final elements = <NoteContentElement>[];
        
        for (var i = 0; i < flashcards.length; i++) {
          final card = flashcards[i];
          
          // Generate container for each flashcard with proper title
          final containerElement = ContainerElement(
            id: 'container_$i',
            position: i,
            createdAt: Timestamp.now(),
            elements: [],
            title: '$subject: $chapter', // Use subject and chapter instead of card title
            containerType: 'card',
          );
          
          // Generate image for this flashcard
          final imageUrl = await generateImage(card['title'], age);
          
          // Add image element
          containerElement.elements.add(ImageElement(
            id: 'image_$i',
            position: 0,
            createdAt: Timestamp.now(),
            imageUrl: imageUrl,
            caption: '',
          ));
          
          // Add text element
          containerElement.elements.add(TextElement(
            id: 'text_$i',
            position: 1,
            createdAt: Timestamp.now(),
            content: card['content'],
            isBold: false,
            fontSize: age <= 4 ? 24.0 : (age <= 5 ? 22.0 : 20.0),
          ));
          
          // Generate audio for this flashcard
          final audioUrl = await generateAudio(card['content'], language);
          
          // Add audio element
          containerElement.elements.add(AudioElement(
            id: 'audio_$i',
            position: 2,
            createdAt: Timestamp.now(),
            audioUrl: audioUrl,
            title: card['title'],
            duration: 5, // Placeholder duration
            metadata: {'autoPlay': age <= 4, 'showPlayButton': age > 4},
          ));
          
          elements.add(containerElement);
        }
        
        // Cache the generated flashcards
        await _cacheFlashcards(cacheKey, elements);
        
        return elements;
      } else {
        throw Exception('Failed to generate flashcards: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating flashcards: $e');
      // Return sample flashcards as fallback
      return _getSampleFlashcards(age);
    }
  }
  
  // Generate image through the backend proxy
  Future<String> generateImage(String description, int age) async {
    try {
      // Clean up the description - remove any markdown formatting
      description = description.replaceAll('**', '').trim();
      
      // Generate emoji-based image instead of using API
      return generateEmojiImage(description);
      
      /* Original API-based implementation
      // Add age-appropriate context to the description
      String enhancedDescription = age <= 4 
          ? 'Simple, colorful, cartoon-style image of $description for preschool children'
          : 'Educational, clear image of $description for elementary school children';
      
      final response = await http.post(
        Uri.parse('$_baseUrl/image'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'description': enhancedDescription,
          'age': age,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['imageUrl'];
        
        // Validate the URL format
        if (imageUrl != null && imageUrl.startsWith('http')) {
          return imageUrl;
        } else {
          throw Exception('Invalid image URL format');
        }
      } else {
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
      */
    } catch (e) {
      print('Error generating image: $e');
      // Return a placeholder image URL using emoji
      return generateEmojiImage(description);
    }
  }
  
  // Generate an emoji-based image URL for flashcards
  String generateEmojiImage(String description) {
    // Normalize the description to lowercase for easier matching
    final String normalizedDesc = description.toLowerCase();
    
    // Map common concepts to emojis
    Map<String, String> emojiMap = {
      // Animals
      'dog': '🐕',
      'cat': '🐈',
      'lion': '🦁',
      'tiger': '🐅',
      'bear': '🐻',
      'wolf': '🐺',
      'fox': '🦊',
      'deer': '🦌',
      'cow': '🐄',
      'pig': '🐖',
      'horse': '🐎',
      'sheep': '🐑',
      'goat': '🐐',
      'monkey': '🐒',
      'elephant': '🐘',
      'giraffe': '🦒',
      'kangaroo': '🦘',
      'penguin': '🐧',
      'chicken': '🐔',
      'duck': '🦆',
      'eagle': '🦅',
      'owl': '🦉',
      'snake': '🐍',
      'turtle': '🐢',
      'fish': '🐠',
      'dolphin': '🐬',
      'whale': '🐋',
      'octopus': '🐙',
      'butterfly': '🦋',
      'bee': '🐝',
      'ant': '🐜',
      'spider': '🕷️',
      
      // Fruits and food
      'apple': '🍎',
      'banana': '🍌',
      'orange': '🍊',
      'grape': '🍇',
      'watermelon': '🍉',
      'strawberry': '🍓',
      'pineapple': '🍍',
      'mango': '🥭',
      'bread': '🍞',
      'cheese': '🧀',
      'pizza': '🍕',
      'hamburger': '🍔',
      'sandwich': '🥪',
      'taco': '🌮',
      'rice': '🍚',
      'noodle': '🍜',
      'ice cream': '🍦',
      'cake': '🍰',
      'cookie': '🍪',
      
      // Transportation
      'car': '🚗',
      'bus': '🚌',
      'train': '🚂',
      'airplane': '✈️',
      'ship': '🚢',
      'bicycle': '🚲',
      'motorcycle': '🏍️',
      'rocket': '🚀',
      
      // Weather and nature
      'sun': '☀️',
      'moon': '🌙',
      'star': '⭐',
      'cloud': '☁️',
      'rain': '🌧️',
      'snow': '❄️',
      'mountain': '🏔️',
      'tree': '🌳',
      'flower': '🌸',
      
      // Sports and activities
      'soccer': '⚽',
      'basketball': '🏀',
      'baseball': '⚾',
      'tennis': '🎾',
      'swimming': '🏊',
      'running': '🏃',
      'dancing': '💃',
      'music': '🎵',
      'book': '📚',
      'painting': '🎨',
      
      // Objects
      'house': '🏠',
      'school': '🏫',
      'hospital': '🏥',
      'clock': '🕒',
      'phone': '📱',
      'computer': '💻',
      'television': '📺',
      'camera': '📷',
      'light': '💡',
      'key': '🔑',
      'lock': '🔒',
      'scissors': '✂️',
      'pen': '🖊️',
      'pencil': '✏️',
      'book': '📕',
      
      // Alphabet and numbers
      'letter a': '🅰️',
      'letter b': '🅱️',
      'number': '🔢',
      
      // Emotions and people
      'happy': '😊',
      'sad': '😢',
      'angry': '😠',
      'surprised': '😲',
      'family': '👪',
      'baby': '👶',
      'boy': '👦',
      'girl': '👧',
      'man': '👨',
      'woman': '👩',
      
      // Colors
      'red': '🔴',
      'blue': '🔵',
      'green': '🟢',
      'yellow': '🟡',
      'orange': '🟠',
      'purple': '🟣',
      'black': '⚫',
      'white': '⚪',
      
      // Jawi/Arabic related
      'arabic': '🇸🇦',
      'jawi': '🇲🇾'
    };
    
    // Look for matches in the description
    String emoji = '📄'; // Default emoji
    
    // Try to find the best matching emoji
    for (var key in emojiMap.keys) {
      if (normalizedDesc.contains(key)) {
        emoji = emojiMap[key]!;
        break;
      }
    }
    
    // Return a data URL for the emoji
    // This creates a simple SVG with the emoji centered
    final String svgContent = '''<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" viewBox="0 0 300 300">
      <rect width="300" height="300" fill="#f8f9fa" />
      <text x="150" y="150" font-family="Arial" font-size="120" text-anchor="middle" dominant-baseline="central">${Uri.encodeComponent(emoji)}</text>
    </svg>''';
    
    // Return the SVG as a data URL
    return 'data:image/svg+xml;utf8,${Uri.encodeComponent(svgContent)}';
  }
  
  // Generate audio using Gemini 2.5 TTS capabilities
  Future<String> generateAudio(String text, String language) async {
    try {
      // Clean up the text - remove any markdown formatting and extract the main content
      String cleanText = text;
      if (text.contains('**')) {
        final regex = RegExp(r'\*\*(.*?)\*\*');
        final match = regex.firstMatch(text);
        if (match != null && match.group(1) != null) {
          // Use the highlighted word with some context
          cleanText = 'This is ${match.group(1)}.';
        } else {
          cleanText = text.replaceAll('**', '');
        }
      }
      
      // Use the API key directly for development purposes
      // In production, this should be stored securely
      final apiKey = 'AIzaSyAdbHuVOYKWtaMLqGf65vOjKpLN6jLIKuo';
      if (apiKey.isEmpty) {
        throw Exception('Gemini API key not found');
      }
      
      // Determine the appropriate voice based on language
      String voice = 'en-US-Neural2-F'; // Default English voice
      if (language.toLowerCase().contains('ar') || language.toLowerCase().contains('jawi')) {
        voice = 'ar-XA-Standard-B'; // Arabic voice
      } else if (language.toLowerCase().contains('ms') || language.toLowerCase().contains('malay')) {
        voice = 'ms-MY-Standard-A'; // Malay voice
      }
      
      // Use Gemini 2.5 Flash for audio generation via Google AI Studio API
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-audio:generateContent'),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': cleanText
            }]
          }],
          'generation_config': {
            'voice': voice,
            'speaking_rate': 1.0,
            'pitch': 0.0
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract audio URL or base64 content from the response
        final audioContent = data['candidates']?[0]?['content']?['parts']?[0]?['audio_data'];
        
        if (audioContent != null) {
          // Create a data URL for the audio
          return 'data:audio/mp3;base64,$audioContent';
        } else {
          throw Exception('No audio content in response');
        }
      } else {
        print('TTS API error: ${response.body}');
        throw Exception('Failed to generate audio: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating audio: $e');
      // Return a more appropriate placeholder audio URL (not an alarm sound)
      return 'https://actions.google.com/sounds/v1/cartoon/pop.ogg';
    }
  }
  
  // Cache flashcards locally
  Future<void> _cacheFlashcards(String key, List<NoteContentElement> elements) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = elements.map((e) => e.toJson()).toList();
      await prefs.setString(key, jsonEncode(jsonList));
    } catch (e) {
      print('Error caching flashcards: $e');
    }
  }
  
  // Get cached flashcards
  Future<List<NoteContentElement>?> _getCachedFlashcards(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        return jsonList.map((json) => NoteContentElement.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Error retrieving cached flashcards: $e');
      return null;
    }
  }
  
  // Clear cache for specific key or all flashcard cache
  Future<void> clearCache({String? specificKey}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (specificKey != null) {
        await prefs.remove(specificKey);
      } else {
        // Clear all flashcard cache
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith(_cachePrefix)) {
            await prefs.remove(key);
          }
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
  
  // Get sample flashcards as fallback
  List<NoteContentElement> _getSampleFlashcards(int age) {
    final timestamp = Timestamp.now();
    
    if (age <= 4) {
      // Simple flashcards for young children
      return [
        ContainerElement(
          id: 'sample_container_1',
          position: 0,
          createdAt: timestamp,
          elements: [
            ImageElement(
              id: 'sample_image_1',
              position: 0,
              createdAt: timestamp,
              imageUrl: 'https://picsum.photos/id/237/300/200',
              caption: '',
            ),
            TextElement(
              id: 'sample_text_1',
              position: 1,
              createdAt: timestamp,
              content: '• A is for Apple',
              isBold: true,
              fontSize: 24.0,
            ),
            AudioElement(
              id: 'sample_audio_1',
              position: 2,
              createdAt: timestamp,
              audioUrl: 'https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg',
              title: 'Apple',
              duration: 2,
              metadata: {'autoPlay': true},
            ),
          ],
          title: 'Letter A',
          containerType: 'card',
        ),
      ];
    } else if (age <= 5) {
      // More detailed flashcards for middle age group
      return [
        ContainerElement(
          id: 'sample_container_1',
          position: 0,
          createdAt: timestamp,
          elements: [
            ImageElement(
              id: 'sample_image_1',
              position: 0,
              createdAt: timestamp,
              imageUrl: 'https://picsum.photos/id/40/300/200',
              caption: '',
            ),
            TextElement(
              id: 'sample_text_1',
              position: 1,
              createdAt: timestamp,
              content: 'The letter C is for Cat, which says "meow".',
              isBold: false,
              fontSize: 22.0,
            ),
            AudioElement(
              id: 'sample_audio_1',
              position: 2,
              createdAt: timestamp,
              audioUrl: 'https://actions.google.com/sounds/v1/animals/cat_purr_close.ogg',
              title: 'Cat',
              duration: 4,
              metadata: {'showPlayButton': true},
            ),
          ],
          title: 'Letter C',
          containerType: 'card',
        ),
      ];
    } else {
      // More complex flashcards for older children
      return [
        ContainerElement(
          id: 'sample_container_1',
          position: 0,
          createdAt: timestamp,
          elements: [
            ImageElement(
              id: 'sample_image_1',
              position: 0,
              createdAt: timestamp,
              imageUrl: 'https://picsum.photos/id/1074/300/200',
              caption: '',
            ),
            TextElement(
              id: 'sample_text_1',
              position: 1,
              createdAt: timestamp,
              content: 'Bears are large mammals with fur, non-retractable claws, short tails, and excellent sense of smell. They eat both plants and animals and can be found in forests, mountains, and arctic regions.',
              isBold: false,
              fontSize: 20.0,
            ),
            AudioElement(
              id: 'sample_audio_1',
              position: 2,
              createdAt: timestamp,
              audioUrl: 'https://actions.google.com/sounds/v1/animals/bear_growl.ogg',
              title: 'About Bears',
              duration: 8,
              metadata: {'showPlayButton': true},
            ),
          ],
          title: 'Bears',
          containerType: 'card',
        ),
      ];
    }
  }
}