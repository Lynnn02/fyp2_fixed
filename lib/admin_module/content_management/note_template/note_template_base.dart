import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/note_content.dart';
import '../../../models/subject.dart';

/// Base class for all note templates
abstract class NoteTemplate {
  final Subject subject;
  final Chapter chapter;
  final int ageGroup;
  
  NoteTemplate({
    required this.subject,
    required this.chapter,
    required this.ageGroup,
  });
  
  /// Generate the note content
  Future<Note> generateNote();
  
  /// Get the template name
  String get templateName;
  
  /// Get the template description
  String get templateDescription;
  
  /// Get the template icon
  String get templateIcon;
  
  /// Helper method to create a text element
  TextElement createTextElement({
    required String content,
    required int position,
    bool isBold = false,
    bool isItalic = false,
    bool isList = false,
    double? fontSize,
  }) {
    return TextElement(
      id: DateTime.now().millisecondsSinceEpoch.toString() + position.toString(),
      position: position,
      createdAt: Timestamp.now(),
      content: content,
      isBold: isBold,
      isItalic: isItalic,
      isList: isList,
      fontSize: fontSize ?? _getFontSizeForAge(),
    );
  }
  
  /// Helper method to create an image element
  ImageElement createImageElement({
    required String imageUrl,
    required int position,
    String? caption,
  }) {
    return ImageElement(
      id: DateTime.now().millisecondsSinceEpoch.toString() + position.toString(),
      position: position,
      createdAt: Timestamp.now(),
      imageUrl: imageUrl,
      caption: caption,
    );
  }
  
  /// Helper method to create an audio element
  AudioElement createAudioElement({
    required String audioUrl,
    required int position,
    String? title,
  }) {
    return AudioElement(
      id: DateTime.now().millisecondsSinceEpoch.toString() + position.toString(),
      position: position,
      createdAt: Timestamp.now(),
      audioUrl: audioUrl,
      title: title,
    );
  }
  
  /// Get appropriate font size based on age
  double _getFontSizeForAge() {
    switch (ageGroup) {
      case 4:
        return 24.0; // Larger font for younger children
      case 5:
        return 20.0; // Medium font
      case 6:
        return 18.0; // Smaller font for older children
      default:
        return 20.0; // Default size
    }
  }
  
  /// Get the number of pages based on age
  int getPageCountForAge() {
    switch (ageGroup) {
      case 4:
        return 10; // Fewer pages for younger children
      case 5:
        return 15; // Medium number of pages
      case 6:
        return 20; // More pages for older children
      default:
        return 15;
    }
  }
  
  /// Get a list of sample audio URLs for educational content
  List<String> getSampleAudioUrls() {
    return [
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_audio%2Fwelcome.mp3?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_audio%2Fexplanation.mp3?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_audio%2Fquestion.mp3?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_audio%2Fcelebration.mp3?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_audio%2Fhint.mp3?alt=media',
    ];
  }
  
  /// Get a list of sample image URLs for educational content
  List<String> getSampleImageUrls() {
    return [
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_images%2Flearning1.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_images%2Flearning2.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_images%2Flearning3.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_images%2Flearning4.jpg?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/note_images%2Flearning5.jpg?alt=media',
    ];
  }
}
