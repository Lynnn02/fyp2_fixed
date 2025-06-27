import 'package:cloud_firestore/cloud_firestore.dart';

class Chapter {
  final String id;
  final String name;
  final String description;
  final int order;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final String subjectId;

  Chapter({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.createdAt,
    this.updatedAt,
    required this.subjectId,
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
      };
}
