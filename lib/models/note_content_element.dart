import 'package:cloud_firestore/cloud_firestore.dart';

/// Base class for all note content elements
class NoteContentElement {
  final String id;
  final String type;
  final int position;
  final Timestamp createdAt;
  final Map<String, dynamic>? metadata;

  NoteContentElement({
    required this.id,
    required this.type,
    required this.position,
    required this.createdAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'position': position,
      'createdAt': createdAt,
      'metadata': metadata ?? {},
    };
  }

  factory NoteContentElement.fromJson(Map<String, dynamic> json) {
    return NoteContentElement(
      id: json['id'],
      type: json['type'],
      position: json['position'],
      createdAt: json['createdAt'],
      metadata: json['metadata'],
    );
  }
}
