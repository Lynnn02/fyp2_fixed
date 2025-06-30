import 'package:cloud_firestore/cloud_firestore.dart';
import 'note_content.dart';

class Subject {
  final String id;
  final String name;
  final List<Chapter> chapters;
  final Timestamp createdAt;
  final int moduleId; // 4, 5, or 6 to indicate which module this subject belongs to

  Subject({
    required this.id,
    required this.name,
    required this.chapters,
    required this.createdAt,
    required this.moduleId,
  });

  factory Subject.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var chaptersData = data['chapters'] as List<dynamic>? ?? [];
    
    // Extract the subject field if available, otherwise use name
    String subjectName = data['subject'] as String? ?? data['name'] as String;
    
    return Subject(
      id: doc.id,
      name: subjectName, // Use the extracted subject name
      chapters: chaptersData.map((e) => Chapter.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      moduleId: data['moduleId'] as int? ?? 4, // Default to module 4 if not specified
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'chapters': chapters.map((e) => e.toJson()).toList(),
    'createdAt': createdAt,
    'moduleId': moduleId,
  };
}

class Chapter {
  final String id;
  final String name;
  final String? notes; // Legacy field for backward compatibility
  final String? videoUrl;
  final String? videoFilePath;
  final Timestamp createdAt;
  final Note? richNote; // New field for rich multimedia notes
  final String? gameId; // ID of the published game for this chapter
  final String? gameType; // Type of the published game
  final String? noteId; // ID of the published note for this chapter
  final String? noteTitle; // Title of the published note
  final Timestamp? noteLastUpdated; // When the note was last updated

  Chapter({
    required this.id,
    required this.name,
    this.notes,
    this.videoUrl,
    this.videoFilePath,
    required this.createdAt,
    this.richNote,
    this.gameId,
    this.gameType,
    this.noteId,
    this.noteTitle,
    this.noteLastUpdated,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      name: json['name'] as String,
      notes: json['notes'] as String?,
      videoUrl: json['videoUrl'] as String?,
      videoFilePath: json['videoFilePath'] as String?,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      richNote: json['richNote'] != null ? Note.fromJson(json['richNote'] as Map<String, dynamic>) : null,
      gameId: json['gameId'] as String?,
      gameType: json['gameType'] as String?,
      noteId: json['noteId'] as String?,
      noteTitle: json['noteTitle'] as String?,
      noteLastUpdated: json['noteLastUpdated'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
      'videoUrl': videoUrl,
      'videoFilePath': videoFilePath,
      'createdAt': createdAt,
      'richNote': richNote?.toJson(),
      'gameId': gameId,
      'gameType': gameType,
      'noteId': noteId,
      'noteTitle': noteTitle,
      'noteLastUpdated': noteLastUpdated,
    };
  }
}
