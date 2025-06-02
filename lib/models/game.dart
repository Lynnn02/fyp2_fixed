import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String id;
  final String title;
  final String description;
  final String type; // matching, memory, etc.
  final List<GameAsset> assets;
  final int ageGroup;

  Game({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.assets,
    required this.ageGroup,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'assets': assets.map((asset) => asset.toJson()).toList(),
        'ageGroup': ageGroup,
      };

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      assets: (json['assets'] as List)
          .map((asset) => GameAsset.fromJson(asset))
          .toList(),
      ageGroup: json['ageGroup'] as int,
    );
  }

  factory Game.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Game.fromJson({
      'id': doc.id,
      ...data,
    });
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
