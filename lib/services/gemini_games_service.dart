import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/chapter.dart';
import 'game_template_manager.dart';

/// Service for generating game content using Gemini API
class GeminiGamesService {
  final String _apiKey;
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String model = 'gemini-1.5-pro';
  final GameTemplateManager _templateManager = GameTemplateManager();
  
  GeminiGamesService({String? apiKey}) 
      : _apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '';
  
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
  Future<List<String>> recommendGameTypes(int ageGroup, String subject, String chapter) async {
    // Get available templates from the template manager
    final templates = _templateManager.getAvailableTemplates(ageGroup);
    final List<String> availableGameTypes = templates.map((t) => t.id).toList();
    
    // Get subject context
    final String subjectContext = _getSubjectContext(subject);
    final bool isJawiContent = _isJawiOrArabicSubject(subject) || _isJawiOrArabicChapter(chapter);
    
    List<String> recommendedGames = [];
    
    // Age-appropriate game recommendations
    if (ageGroup == 4) {
      // For youngest age group, focus on simple games
      if (isJawiContent) {
        recommendedGames = ['tracing', 'matching'];
      } else if (subjectContext == 'math') {
        recommendedGames = ['shape_color', 'matching'];
      } else {
        recommendedGames = ['matching', 'sorting'];
      }
    } else if (ageGroup == 5) {
      // For middle age group, balance between simplicity and challenge
      if (isJawiContent) {
        recommendedGames = ['tracing', 'matching', 'shape_color'];
      } else if (subjectContext == 'math') {
        recommendedGames = ['shape_color', 'matching', 'sorting'];
      } else {
        recommendedGames = ['matching', 'sorting', 'shape_color'];
      }
    } else {
      // For oldest age group, more challenging games
      if (isJawiContent) {
        recommendedGames = ['tracing', 'matching', 'sorting'];
      } else if (subjectContext == 'math') {
        recommendedGames = ['shape_color', 'sorting', 'matching'];
      } else {
        recommendedGames = ['matching', 'sorting', 'shape_color'];
      }
    }
    
    // Filter recommendations to only include available templates
    recommendedGames = recommendedGames
        .where((game) => availableGameTypes.contains(game))
        .toList();
    
    // Add a random game if we don't have enough recommendations
    if (recommendedGames.length < 3) {
      final random = Random();
      while (recommendedGames.length < 3 && recommendedGames.length < availableGameTypes.length) {
        final gameType = availableGameTypes[random.nextInt(availableGameTypes.length)];
        if (!recommendedGames.contains(gameType)) {
          recommendedGames.add(gameType);
        }
      }
    }
    
    // Limit to 3 recommendations or fewer if not enough available
    return recommendedGames.take(min(3, availableGameTypes.length)).toList();
  }
  
  // Generate game content using Gemini API
  Future<Map<String, dynamic>> generateGameContent({
    required String subject,
    required String chapter,
    required int age,
    required String gameType,
  }) async {
    try {
      // Get the prompt for the specified game type
      final prompt = _templateManager.getPrompt(
        templateType: gameType,
        subjectName: subject,
        chapterName: chapter,
        ageGroup: age,
      );
      
      // Call Gemini API
      final url = '$baseUrl/$model:generateContent?key=$_apiKey';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
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
            'maxOutputTokens': 2048,
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final generatedText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON content from the response
        final jsonContent = _extractJsonFromText(generatedText);
        
        if (jsonContent != null) {
          // Add metadata to the content
          jsonContent['metadata'] = {
            'templateType': gameType,
            'subjectName': subject,
            'chapterName': chapter,
            'ageGroup': age,
            'isFallback': false,
            'generatedAt': DateTime.now().toIso8601String(),
          };
          
          print('Successfully generated ${gameType} content for ${subject} - ${chapter}');
          return jsonContent;
        }
      }
      
      print('Falling back to template content for ${gameType} (${subject} - ${chapter})');
      
      // If API call fails or JSON parsing fails, use fallback content
      return _templateManager.getFallbackContent(gameType, subject, age);
    } catch (e) {
      print('Error generating game content: $e');
      
      // Return fallback content in case of any error
      return _templateManager.getFallbackContent(gameType, subject, age);
    }
  }
  
  // Helper method to extract JSON from generated text
  Map<String, dynamic>? _extractJsonFromText(String text) {
    try {
      // Clean up the text - remove markdown code blocks if present
      String cleanText = text;
      if (text.contains('```json')) {
        final startIndex = text.indexOf('```json') + 7;
        final endIndex = text.lastIndexOf('```');
        if (endIndex > startIndex) {
          cleanText = text.substring(startIndex, endIndex).trim();
        }
      } else if (text.contains('```')) {
        final startIndex = text.indexOf('```') + 3;
        final endIndex = text.lastIndexOf('```');
        if (endIndex > startIndex) {
          cleanText = text.substring(startIndex, endIndex).trim();
        }
      }
      
      // Find JSON content between curly braces
      final jsonRegExp = RegExp(r'\{[\s\S]*\}');
      final match = jsonRegExp.firstMatch(cleanText);
      
      if (match != null) {
        final jsonString = match.group(0);
        if (jsonString != null) {
          final parsedJson = jsonDecode(jsonString);
          
          // Validate that the JSON has the expected structure based on game template
          if (parsedJson.containsKey('items') || 
              parsedJson.containsKey('shapes') || 
              parsedJson.containsKey('tracingItems') || 
              parsedJson.containsKey('pairs') ||
              parsedJson.containsKey('categories')) {
            return parsedJson;
          } else {
            print('JSON missing expected keys for game template');
          }
        }
      }
      
      // Try to find JSON array if object not found
      final arrayRegExp = RegExp(r'\[[\s\S]*\]');
      final arrayMatch = arrayRegExp.firstMatch(cleanText);
      
      if (arrayMatch != null) {
        final arrayString = arrayMatch.group(0);
        if (arrayString != null) {
          final parsedArray = jsonDecode(arrayString);
          // Wrap array in an object
          return {'items': parsedArray};
        }
      }
      
      return null;
    } catch (e) {
      print('Error extracting JSON: $e');
      return null;
    }
  }
}