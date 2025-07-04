import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String id;
  final String title;
  final String description;
  final String type; // matching, memory, etc.
  final List<GameAsset> assets;
  final int ageGroup;
  final Map<String, dynamic>? gameContent; // Decoded game content from JSON

  Game({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.assets,
    required this.ageGroup,
    this.gameContent,
  });
  
  // Create a copy of the game with optional new values
  Game copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    List<GameAsset>? assets,
    int? ageGroup,
    Map<String, dynamic>? gameContent,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      assets: assets ?? this.assets,
      ageGroup: ageGroup ?? this.ageGroup,
      gameContent: gameContent ?? this.gameContent,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'assets': assets.map((asset) => asset.toJson()).toList(),
      'ageGroup': ageGroup,
    };
    
    // Include decoded game content if available
    if (gameContent != null) {
      json['gameContent'] = gameContent;
      json['decodedContent'] = gameContent;
    }
    
    return json;
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    print('Game.fromJson: Processing game with keys: ${json.keys.toList()}');
    Map<String, dynamic>? gameContent;
    
    // Try multiple ways to get the game content
    if (json.containsKey('decodedContent')) {
      print('Using decodedContent field');
      gameContent = json['decodedContent'] as Map<String, dynamic>;
    } else if (json.containsKey('gameContent') && json['gameContent'] is Map<String, dynamic>) {
      print('Using gameContent field');
      gameContent = json['gameContent'] as Map<String, dynamic>;
    } else if (json.containsKey('rawContent') && json['rawContent'] is String) {
      print('Attempting to decode rawContent field');
      try {
        gameContent = jsonDecode(json['rawContent']);
        print('Successfully decoded rawContent');
      } catch (e) {
        print('Failed to decode rawContent: $e');
      }
    } else if (json.containsKey('content')) {
      print('Found content field with type: ${json['content'].runtimeType}');
      if (json['content'] is String) {
        try {
          gameContent = jsonDecode(json['content']);
          print('Successfully decoded content string');
        } catch (e) {
          print('Failed to decode content string: $e');
        }
      } else if (json['content'] is Map<String, dynamic>) {
        print('Content field is already a Map');
        gameContent = json['content'] as Map<String, dynamic>;
      }
    }
    
    // Check if we have individual content_ fields
    if (gameContent == null) {
      print('Checking for individual content_ fields');
      Map<String, dynamic> reconstructedContent = {};
      bool foundContentFields = false;
      
      json.forEach((key, value) {
        if (key.startsWith('content_')) {
          String contentKey = key.substring('content_'.length);
          print('Found content field: $contentKey');
          foundContentFields = true;
          
          // If the value is a string that looks like JSON, try to decode it
          if (value is String && value.startsWith('{') && value.endsWith('}')) {
            try {
              reconstructedContent[contentKey] = jsonDecode(value);
            } catch (e) {
              reconstructedContent[contentKey] = value;
            }
          } else {
            reconstructedContent[contentKey] = value;
          }
        }
      });
      
      if (foundContentFields) {
        print('Reconstructed content from individual fields with keys: ${reconstructedContent.keys.toList()}');
        gameContent = reconstructedContent;
      }
    }
    
    if (gameContent != null) {
      print('Final game content has keys: ${gameContent.keys.toList()}');
    } else {
      print('WARNING: Could not extract game content from any field');
    }
    
    // Handle potential missing or incorrect type field
    String gameType = 'unknown';
    if (json.containsKey('type') && json['type'] is String) {
      gameType = json['type'] as String;
    } else if (json.containsKey('templateType') && json['templateType'] is String) {
      // Fallback to templateType if type is missing
      gameType = json['templateType'] as String;
    }
    
    return Game(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: gameType,
      assets: (json['assets'] as List)
          .map((asset) => GameAsset.fromJson(asset))
          .toList(),
      ageGroup: json['ageGroup'] as int,
      gameContent: gameContent,
    );
  }

  factory Game.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Extract content field with fallbacks for backward compatibility
    String content = '';
    if (data.containsKey('content') && data['content'] != null) {
      content = data['content'];
    } else if (data.containsKey('gameContent') && data['gameContent'] != null) {
      content = data['gameContent'];
    }
    
    // Extract assets for game templates
    List<dynamic> assets = [];
    if (data.containsKey('assets') && data['assets'] != null) {
      assets = data['assets'];
    }
    
    // For published games, ensure we get the content from assets if the content field is empty
    // This fixes the sync issue between admin publishing and children app
    if (content.isEmpty && assets.isNotEmpty && data['type'] == 'published') {
      try {
        // Extract content from the first asset that contains game content
        for (var asset in assets) {
          if (asset is Map<String, dynamic> && 
              asset.containsKey('content') && 
              asset['content'] != null && 
              asset['content'].toString().isNotEmpty) {
            content = asset['content'];
            break;
          }
        }
        print('Extracted game content from assets for game: ${doc.id}');
      } catch (e) {
        print('Error extracting content from assets: $e');
      }
    }
    
    // Extract game content with multiple fallback approaches
    Map<String, dynamic>? gameContent;
    
    // Try multiple ways to get the game content
    if (data.containsKey('gameContent') && data['gameContent'] is Map<String, dynamic>) {
      print('Using gameContent field directly from Firestore');
      gameContent = data['gameContent'] as Map<String, dynamic>;
    } else if (data.containsKey('rawContent') && data['rawContent'] is String) {
      print('Attempting to decode rawContent field from Firestore');
      try {
        final contentString = data['rawContent'] as String;
        final decoded = jsonDecode(contentString);
        print('Successfully decoded rawContent: ${decoded.runtimeType}');
        if (decoded is Map<String, dynamic>) {
          gameContent = decoded;
        }
      } catch (e) {
        print('Error decoding rawContent: $e');
      }
    } else if (data.containsKey('content')) {
      print('Found content field with type: ${data['content'].runtimeType}');
      if (data['content'] is String) {
        try {
          final contentString = data['content'] as String;
          print('Content string length: ${contentString.length}');
          if (contentString.isNotEmpty) {
            print('Content string sample: ${contentString.substring(0, contentString.length > 50 ? 50 : contentString.length)}...');
            final decoded = jsonDecode(contentString);
            print('Successfully decoded content: ${decoded.runtimeType}');
            if (decoded is Map<String, dynamic>) {
              gameContent = decoded;
              print('Decoded content keys: ${gameContent.keys.toList()}');
            }
          } else {
            print('Content string is empty');
          }
        } catch (e) {
          print('Error decoding content string: $e');
        }
      } else if (data['content'] is Map<String, dynamic>) {
        print('Content field is already a Map in Firestore');
        gameContent = data['content'] as Map<String, dynamic>;
      }
    }
    
    // Check if we have individual content_ fields as fallback
    if (gameContent == null) {
      print('Checking for individual content_ fields in Firestore');
      Map<String, dynamic> reconstructedContent = {};
      bool foundContentFields = false;
      
      data.forEach((key, value) {
        if (key.startsWith('content_')) {
          String contentKey = key.substring('content_'.length);
          print('Found individual content field: $contentKey');
          foundContentFields = true;
          
          // If the value is a string that looks like JSON, try to decode it
          if (value is String && value.startsWith('{') && value.endsWith('}')) {
            try {
              reconstructedContent[contentKey] = jsonDecode(value);
            } catch (e) {
              reconstructedContent[contentKey] = value;
            }
          } else {
            reconstructedContent[contentKey] = value;
          }
        }
      });
      
      if (foundContentFields) {
        print('Reconstructed content from individual fields: ${reconstructedContent.keys.toList()}');
        gameContent = reconstructedContent;
      }
    }
    
    // Try to use assets field as fallback if no game content was found
    if (gameContent == null && data.containsKey('assets')) {
      print('Attempting to create game content from assets field');
      final assets = data['assets'];
      
      // Try to create pairs from assets
      if (assets is List) {
        List<Map<String, dynamic>> pairs = [];
        
        for (var asset in assets) {
          if (asset is Map<String, dynamic>) {
            // Create a matching pair from each asset
            final word = asset['question'] ?? asset['answer'] ?? 'Item';
            final emoji = asset['imageUrl'] ?? '❓';
            
            pairs.add({
              'word': word,
              'emoji': emoji,
              'description': ''
            });
            
            print('Created pair from asset: $word - $emoji');
          }
        }
        
        if (pairs.isNotEmpty) {
          // Create a matching game content structure
          gameContent = {
            'title': data['title'] ?? 'Matching Game',
            'pairs': pairs,
            'instructions': 'Match the items',
            'type': 'matching'
          };
          print('Created game content with ${pairs.length} pairs from assets');
        }
      }
    }
    
    // If still no content, create minimal default content
    if (gameContent == null) {
      print('Creating minimal default game content');
      gameContent = {
        'title': data['title'] ?? 'Game', 
        'type': data['type'] ?? 'matching',
        'pairs': [
          {'word': 'Apple', 'emoji': '🍎'},
          {'word': 'Banana', 'emoji': '🍌'},
          {'word': 'Cat', 'emoji': '🐱'},
          {'word': 'Dog', 'emoji': '🐶'}
        ],
        'instructions': 'Match the items'
      };
      print('Created default game content with 4 pairs');
    }
    
    // Add the extracted content to the data map
    print('Setting game content with keys: ${gameContent.keys.toList()}');
    data['gameContent'] = gameContent;
    data['decodedContent'] = gameContent;
    
    // Ensure all required fields are present
    Map<String, dynamic> gameData = {
      'id': doc.id,
      'title': data['title'] ?? data['name'] ?? 'Untitled Game',
      'description': data['description'] ?? 'No description available',
      'type': data['type'] ?? data['templateType'] ?? 'unknown',
      'ageGroup': data['ageGroup'] ?? 4, // Default to age 4 if missing
      ...data,
    };
    
    // Handle assets properly
    if (!gameData.containsKey('assets') || gameData['assets'] == null) {
      print('Warning: Game ${doc.id} has no assets, creating empty list');
      gameData['assets'] = [];
    }
    
    return Game.fromJson(gameData);
  }
}

class GameAsset {
  final String imageUrl;
  final String? answer;
  final String? question;

  GameAsset({
    required this.imageUrl,
    this.answer,
    this.question,
  });

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'answer': answer,
        'question': question,
      };

  factory GameAsset.fromJson(Map<String, dynamic> json) {
    return GameAsset(
      imageUrl: json['imageUrl'] as String,
      answer: json['answer'] as String?,
      question: json['question'] as String?,
    );
  }
}
