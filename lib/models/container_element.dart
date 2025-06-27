import 'package:cloud_firestore/cloud_firestore.dart';
import 'note_content.dart';

/// Container element that can hold multiple child elements
class ContainerElement extends NoteContentElement {
  final List<NoteContentElement> elements;
  final String? title;
  final String? containerType; // card, section, etc.

  ContainerElement({
    required String id,
    required int position,
    required Timestamp createdAt,
    required this.elements,
    this.title,
    this.containerType = 'card',
    Map<String, dynamic>? metadata,
  }) : super(
          id: id,
          type: 'container',
          position: position,
          createdAt: createdAt,
          metadata: metadata,
        );

  factory ContainerElement.fromJson(Map<String, dynamic> json) {
    var elementsData = json['elements'] as List<dynamic>? ?? [];
    
    return ContainerElement(
      id: json['id'] as String,
      position: json['position'] as int,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      elements: elementsData
          .map((e) => NoteContentElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String?,
      containerType: json['containerType'] as String? ?? 'card',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'position': position,
        'createdAt': createdAt,
        'metadata': metadata,
        'elements': elements.map((e) => e.toJson()).toList(),
        'title': title,
        'containerType': containerType,
      };
}
