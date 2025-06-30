import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'note_content_element.dart';

class FlashcardElement extends NoteContentElement {
  final String title;
  final String letter;
  final String imageAsset;
  final Map<int, String> descriptions;
  final Color cardColor;
  
  FlashcardElement({
    required String id,
    required int position,
    required Timestamp createdAt,
    required this.title,
    required this.letter,
    required this.imageAsset,
    required this.descriptions,
    this.cardColor = Colors.white,
    Map<String, dynamic>? metadata,
  }) : super(
        id: id,
        type: 'flashcard',
        position: position,
        createdAt: createdAt,
        metadata: metadata,
      );

  String getDescription(int age) {
    if (!descriptions.containsKey(age)) {
      final availableAges = descriptions.keys.toList()..sort();
      if (availableAges.isEmpty) return title;
      
      // Find the closest age available
      int closestAge = availableAges.first;
      for (final availableAge in availableAges) {
        if ((age - availableAge).abs() < (age - closestAge).abs()) {
          closestAge = availableAge;
        }
      }
      return descriptions[closestAge] ?? title;
    }
    return descriptions[age] ?? title;
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'title': title,
      'letter': letter,
      'imageAsset': imageAsset,
      'descriptions': descriptions.map((key, value) => MapEntry(key.toString(), value)),
      'cardColor': cardColor.value,
    };
  }

  factory FlashcardElement.fromJson(Map<String, dynamic> json) {
    final Map<int, String> descriptions = {};
    if (json['descriptions'] != null) {
      (json['descriptions'] as Map).forEach((key, value) {
        descriptions[int.parse(key.toString())] = value.toString();
      });
    }

    return FlashcardElement(
      id: json['id'],
      position: json['position'],
      createdAt: json['createdAt'],
      title: json['title'],
      letter: json['letter'],
      imageAsset: json['imageAsset'],
      descriptions: descriptions,
      cardColor: Color(json['cardColor'] ?? Colors.white.value),
      metadata: json['metadata'],
    );
  }
}
