import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fyp2/models/note_content.dart';
import 'package:fyp2/models/container_element.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    } catch (e) {
      print('Error generating image: $e');
      // Return a placeholder image URL
      return 'https://picsum.photos/id/${(age % 10) + 237}/300/200';
    }
  }
  
  // Generate audio through the backend proxy
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
      
      final response = await http.post(
        Uri.parse('$_baseUrl/tts'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': cleanText,
          'language': language,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioUrl = data['audioUrl'];
        
        // Validate the URL format
        if (audioUrl != null && audioUrl.startsWith('http')) {
          return audioUrl;
        } else {
          throw Exception('Invalid audio URL format');
        }
      } else {
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