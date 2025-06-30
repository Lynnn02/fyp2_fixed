import 'package:cloud_firestore/cloud_firestore.dart';

class Chapter {
  final String id;
  final String name;
  final String description;
  final int order;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final String subjectId;
  final String? noteId;
  final String? noteTitle;
  final Timestamp? noteLastUpdated;
  final String? gameId;
  final String? gameType;
  final String? videoUrl;

  Chapter({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.createdAt,
    this.updatedAt,
    required this.subjectId,
    this.noteId,
    this.noteTitle,
    this.noteLastUpdated,
    this.gameId,
    this.gameType,
    this.videoUrl,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: json['updatedAt'] as Timestamp?,
      subjectId: json['subjectId'] as String,
      noteId: json['noteId'] as String?,
      noteTitle: json['noteTitle'] as String?,
      noteLastUpdated: json['noteLastUpdated'] as Timestamp?,
      gameId: json['gameId'] as String?,
      gameType: json['gameType'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'order': order,
        'createdAt': createdAt,
        'updatedAt': updatedAt ?? Timestamp.now(),
        'subjectId': subjectId,
        if (noteId != null) 'noteId': noteId,
        if (noteTitle != null) 'noteTitle': noteTitle,
        if (noteLastUpdated != null) 'noteLastUpdated': noteLastUpdated,
        if (gameId != null) 'gameId': gameId,
        if (gameType != null) 'gameType': gameType,
        if (videoUrl != null) 'videoUrl': videoUrl,
      };
}
