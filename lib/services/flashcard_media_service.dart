import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FlashcardMediaService {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String imageModel = 'gemini-1.5-pro-vision';
  static const String textModel = 'gemini-1.5-pro';
  static const String ttsModel = 'cloud-tts'; // For Google Cloud TTS

  // Generate image for flashcard based on prompt
  static Future<String> generateImageUrl(String imagePrompt) async {
    try {
      // For now, we'll use a placeholder image until the actual Gemini image generation is set up
      // In a real implementation, you would call the Gemini image generation API
      final String placeholderUrl = _getPlaceholderImageUrl(imagePrompt);
      
      // Log the image generation request
      debugPrint('Image generation requested for prompt: $imagePrompt');
      debugPrint('Using placeholder image: $placeholderUrl');
      
      return placeholderUrl;
    } catch (e) {
      debugPrint('Error generating image: $e');
      return 'https://via.placeholder.com/400x300?text=${Uri.encodeComponent(imagePrompt)}';
    }
  }

  // Generate audio for flashcard based on prompt using Gemini 2.5 Flash TTS API
  static Future<String> generateAudioUrl(String audioPrompt, String language) async {
    try {
      // Clean the text to ensure it's suitable for TTS
      final String cleanText = audioPrompt.trim();
      if (cleanText.isEmpty) {
        throw Exception('Empty text for audio generation');
      }
      
      // Select appropriate voice based on language
      String voice;
      switch (language.toLowerCase()) {
        case 'ar-sa':
        case 'ar':
          voice = 'ar-XA-Standard-A'; // Arabic voice
          break;
        case 'ms':
        case 'ms-my':
          voice = 'ms-MY-Standard-A'; // Malay voice
          break;
        case 'zh':
        case 'zh-cn':
          voice = 'cmn-CN-Standard-A'; // Chinese voice
          break;
        default:
          voice = 'en-US-Standard-A'; // Default to English
      }
      
      debugPrint('Generating audio for: $cleanText in language: $language with voice: $voice');
      
      // Call Gemini 2.5 Flash TTS API
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-audio:generateContent'),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode({
          'contents': [{'parts': [{'text': cleanText}]}],
          'generation_config': {'voice': voice, 'speaking_rate': 1.0, 'pitch': 0.0}
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioContent = data['candidates']?[0]?['content']?['parts']?[0]?['audio_data'];
        if (audioContent != null) {
          debugPrint('Successfully generated audio data');
          return 'data:audio/mp3;base64,$audioContent';
        } else {
          throw Exception('No audio content in response');
        }
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to generate audio: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating audio: $e');
      // Fall back to placeholder audio
      return _getPlaceholderAudioUrl(audioPrompt, language);
    }
  }

  // Process all flashcards to add media URLs
  static Future<List<Map<String, dynamic>>> processFlashcardsMedia(
    List<Map<String, dynamic>> flashcards,
    String language,
  ) async {
    List<Map<String, dynamic>> processedFlashcards = [];
    
    for (var flashcard in flashcards) {
      // Create a copy of the flashcard to modify
      final Map<String, dynamic> processedCard = Map<String, dynamic>.from(flashcard);
      
      // Generate image URL if there's an image prompt
      if (flashcard.containsKey('image_prompt') && flashcard['image_prompt'] != null) {
        final String imageUrl = await generateImageUrl(flashcard['image_prompt']);
        processedCard['imageUrl'] = imageUrl;
      }
      
      // Generate audio URL if there's an audio prompt
      if (flashcard.containsKey('audio_prompt') && flashcard['audio_prompt'] != null) {
        final String audioUrl = await generateAudioUrl(
          flashcard['audio_prompt'], 
          flashcard['textDirection'] == 'rtl' ? 'ar-SA' : 'en-US'
        );
        processedCard['audioUrl'] = audioUrl;
      }
      
      processedFlashcards.add(processedCard);
    }
    
    return processedFlashcards;
  }

  // Helper method to get placeholder image URL based on prompt
  static String _getPlaceholderImageUrl(String prompt) {
    // Normalize the prompt to lowercase for easier matching
    final String normalizedPrompt = prompt.toLowerCase();
    
    // Check for specific categories and return appropriate placeholder images
    if (normalizedPrompt.contains('apple') || normalizedPrompt.contains('fruit')) {
      return 'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/flashcards%2Fapple.png?alt=media';
    } else if (normalizedPrompt.contains('cat') || normalizedPrompt.contains('kitten')) {
      return 'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/flashcards%2Fcat.png?alt=media';
    } else if (normalizedPrompt.contains('dog') || normalizedPrompt.contains('puppy')) {
      return 'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/flashcards%2Fdog.png?alt=media';
    } else if (normalizedPrompt.contains('alphabet') || normalizedPrompt.contains('letter')) {
      // For alphabet flashcards, extract the letter if possible
      final RegExp letterRegex = RegExp(r'letter\s+([a-zA-Z])');
      final match = letterRegex.firstMatch(normalizedPrompt);
      final String letter = match?.group(1)?.toUpperCase() ?? 'A';
      
      return 'https://via.placeholder.com/400x300/FFFF00/000000?text=$letter';
    } else if (normalizedPrompt.contains('jawi') || normalizedPrompt.contains('arabic')) {
      // For Jawi/Arabic letters, use a special placeholder
      // Extract the letter if possible
      final RegExp letterRegex = RegExp(r'letter\s+(\S)');
      final match = letterRegex.firstMatch(normalizedPrompt);
      final String letter = match?.group(1) ?? 'ا';
      
      return 'https://via.placeholder.com/400x300/00FFFF/000000?text=$letter';
    }
    
    // Default rainbow background with the first word from the prompt
    final String firstWord = prompt.split(' ').first;
    return 'https://via.placeholder.com/400x300/FF9E80/000000?text=$firstWord';
  }

  // Helper method to get placeholder audio URL based on prompt
  static String _getPlaceholderAudioUrl(String prompt, String language) {
    // In a real implementation, you would call a TTS API
    // For now, return a placeholder audio URL
    return 'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_audio%2Fdefault1.mp3?alt=media';
  }
}
