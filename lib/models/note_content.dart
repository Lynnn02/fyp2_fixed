import 'package:cloud_firestore/cloud_firestore.dart';
import 'container_element.dart';
import 'package:flutter/material.dart';

/// Base class for all note content elements
abstract class NoteContentElement {
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

  Map<String, dynamic> toJson();

  factory NoteContentElement.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    switch (type) {
      case 'text':
        return TextElement.fromJson(json);
      case 'image':
        return ImageElement.fromJson(json);
      case 'audio':
        return AudioElement.fromJson(json);
      case 'document':
        return DocumentElement.fromJson(json);
      case 'container':
        return ContainerElement.fromJson(json);
      case 'flashcard':
        return FlashcardElement.fromJson(json);
      default:
        throw Exception('Unknown note content element type: $type');
    }
  }
}

class TextElement extends NoteContentElement {
  final String content;
  final bool isBold;
  final bool isItalic;
  final bool isList;
  final String? textColor;
  final double? fontSize;

  TextElement({
    required String id,
    required int position,
    required Timestamp createdAt,
    required this.content,
    this.isBold = false,
    this.isItalic = false,
    this.isList = false,
    this.textColor,
    this.fontSize,
    Map<String, dynamic>? metadata,
  }) : super(
          id: id,
          type: 'text',
          position: position,
          createdAt: createdAt,
          metadata: metadata,
        );

  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      id: json['id'] as String,
      position: json['position'] as int,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      content: json['content'] as String,
      isBold: json['isBold'] as bool? ?? false,
      isItalic: json['isItalic'] as bool? ?? false,
      isList: json['isList'] as bool? ?? false,
      textColor: json['textColor'] as String?,
      fontSize: json['fontSize'] as double?,
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
        'content': content,
        'isBold': isBold,
        'isItalic': isItalic,
        'isList': isList,
        'textColor': textColor,
        'fontSize': fontSize,
      };
}

class ImageElement extends NoteContentElement {
  final String imageUrl;
  final String? caption;
  final String? filePath;
  final double? width;
  final double? height;

  ImageElement({
    required String id,
    required int position,
    required Timestamp createdAt,
    required this.imageUrl,
    this.caption,
    this.filePath,
    this.width,
    this.height,
    Map<String, dynamic>? metadata,
  }) : super(
          id: id,
          type: 'image',
          position: position,
          createdAt: createdAt,
          metadata: metadata,
        );

  factory ImageElement.fromJson(Map<String, dynamic> json) {
    return ImageElement(
      id: json['id'] as String,
      position: json['position'] as int,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      imageUrl: json['imageUrl'] as String,
      caption: json['caption'] as String?,
      filePath: json['filePath'] as String?,
      width: json['width'] as double?,
      height: json['height'] as double?,
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
        'imageUrl': imageUrl,
        'caption': caption,
        'filePath': filePath,
        'width': width,
        'height': height,
      };
}

/// Specialized element for flashcards with age-appropriate content
class FlashcardElement extends NoteContentElement {
  final String title;       // The main word/concept (e.g., "Monkey")
  final String letter;      // The letter representation (e.g., "Mm")
  final String imageAsset;  // Path to the image asset
  final Map<int, String> descriptions; // Age-appropriate descriptions keyed by age
  final Color cardColor;    // Background color of the flashcard
  
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

  /// Get the appropriate description based on age
  String getDescription(int age) {
    // Default to the lowest age if the specific age isn't available
    if (!descriptions.containsKey(age)) {
      final availableAges = descriptions.keys.toList()..sort();
      if (availableAges.isEmpty) return title;
      return descriptions[availableAges.first] ?? title;
    }
    return descriptions[age] ?? title;
  }

  factory FlashcardElement.fromJson(Map<String, dynamic> json) {
    // Convert the descriptions map from JSON
    final Map<int, String> descriptions = {};
    if (json['descriptions'] != null) {
      final Map<String, dynamic> descMap = json['descriptions'] as Map<String, dynamic>;
      descMap.forEach((key, value) {
        descriptions[int.parse(key)] = value as String;
      });
    }
    
    // Parse color if available
    Color cardColor = Colors.white;
    if (json['cardColor'] != null) {
      final colorValue = int.tryParse(json['cardColor'] as String);
      if (colorValue != null) {
        cardColor = Color(colorValue);
      }
    }
    
    return FlashcardElement(
      id: json['id'] as String,
      position: json['position'] as int,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      title: json['title'] as String,
      letter: json['letter'] as String,
      imageAsset: json['imageAsset'] as String,
      descriptions: descriptions,
      cardColor: cardColor,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // Convert the descriptions map to JSON-compatible format
    final Map<String, dynamic> descriptionsJson = {};
    descriptions.forEach((key, value) {
      descriptionsJson[key.toString()] = value;
    });
    
    return {
      'id': id,
      'type': type,
      'position': position,
      'createdAt': createdAt,
      'metadata': metadata,
      'title': title,
      'letter': letter,
      'imageAsset': imageAsset,
      'descriptions': descriptionsJson,
      'cardColor': cardColor.value.toString(),
    };
  }
}

class AudioElement extends NoteContentElement {
  final String audioUrl;
  final String? title;
  final String? filePath;
  final double? duration;

  AudioElement({
    required String id,
    required int position,
    required Timestamp createdAt,
    required this.audioUrl,
    this.title,
    this.filePath,
    this.duration,
    Map<String, dynamic>? metadata,
  }) : super(
          id: id,
          type: 'audio',
          position: position,
          createdAt: createdAt,
          metadata: metadata,
        );

  factory AudioElement.fromJson(Map<String, dynamic> json) {
    return AudioElement(
      id: json['id'] as String,
      position: json['position'] as int,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      audioUrl: json['audioUrl'] as String,
      title: json['title'] as String?,
      filePath: json['filePath'] as String?,
      duration: json['duration'] as double?,
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
        'audioUrl': audioUrl,
        'title': title,
        'filePath': filePath,
        'duration': duration,
      };
}

class DocumentElement extends NoteContentElement {
  final String documentUrl;
  final String fileName;
  final String fileType; // pdf, doc, docx, etc.
  final String? filePath;
  final int? fileSize; // in bytes

  DocumentElement({
    required String id,
    required int position,
    required Timestamp createdAt,
    required this.documentUrl,
    required this.fileName,
    required this.fileType,
    this.filePath,
    this.fileSize,
  }) : super(
          id: id,
          type: 'document',
          position: position,
          createdAt: createdAt,
        );

  factory DocumentElement.fromJson(Map<String, dynamic> json) {
    return DocumentElement(
      id: json['id'] as String,
      position: json['position'] as int,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      documentUrl: json['documentUrl'] as String,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      filePath: json['filePath'] as String?,
      fileSize: json['fileSize'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'position': position,
        'createdAt': createdAt,
        'documentUrl': documentUrl,
        'fileName': fileName,
        'fileType': fileType,
        'filePath': filePath,
        'fileSize': fileSize,
      };
}

class Note {
  final String id;
  final String title;
  final String? description;
  final List<NoteContentElement> elements;
  final bool isDraft;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  Note({
    this.id = '',
    required this.title,
    this.description,
    required this.elements,
    this.isDraft = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    var elementsData = json['elements'] as List<dynamic>? ?? [];
    
    return Note(
      id: json['id'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String?,
      elements: elementsData
          .map((e) => NoteContentElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      isDraft: json['isDraft'] as bool? ?? true,
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: json['updatedAt'] as Timestamp?,
    );
  }
  
  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    print('Note data from Firestore: ${data.keys.toList()}');
    
    // Check if elements exist and are properly formatted
    if (data.containsKey('elements')) {
      print('Elements found in note data: ${data['elements'].runtimeType}');
      if (data['elements'] is List) {
        print('Elements count: ${(data['elements'] as List).length}');
      }
    } else {
      print('WARNING: No elements field found in note data');
      // Create empty elements list if missing
      data['elements'] = [];
    }
    
    return Note.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'elements': elements.map((e) => e.toJson()).toList(),
        'isDraft': isDraft,
        'createdAt': createdAt,
        'updatedAt': updatedAt ?? Timestamp.now(),
      };
}
