import 'package:cloud_firestore/cloud_firestore.dart';

/// Base class for all note content elements
abstract class NoteContentElement {
  final String id;
  final String type;
  final int position;
  final Timestamp createdAt;

  NoteContentElement({
    required this.id,
    required this.type,
    required this.position,
    required this.createdAt,
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
  }) : super(
          id: id,
          type: 'text',
          position: position,
          createdAt: createdAt,
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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'position': position,
        'createdAt': createdAt,
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
  }) : super(
          id: id,
          type: 'image',
          position: position,
          createdAt: createdAt,
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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'position': position,
        'createdAt': createdAt,
        'imageUrl': imageUrl,
        'caption': caption,
        'filePath': filePath,
        'width': width,
        'height': height,
      };
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
  }) : super(
          id: id,
          type: 'audio',
          position: position,
          createdAt: createdAt,
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
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'position': position,
        'createdAt': createdAt,
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
  final String title;
  final String? description;
  final List<NoteContentElement> elements;
  final bool isDraft;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  Note({
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

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'elements': elements.map((e) => e.toJson()).toList(),
        'isDraft': isDraft,
        'createdAt': createdAt,
        'updatedAt': updatedAt ?? Timestamp.now(),
      };
}
