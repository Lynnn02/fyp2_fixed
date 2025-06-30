import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/game.dart';
// Quiz model removed
import '../models/video_content.dart';
import '../models/subject.dart';
import '../models/note_content.dart';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Game methods
  Stream<List<Game>> getGames() {
    return _firestore.collection('games').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
    });
  }
  
  // Get a specific game by ID
  Future<Game?> getGameById(String gameId) async {
    final doc = await _firestore.collection('games').doc(gameId).get();
    if (doc.exists) {
      return Game.fromFirestore(doc);
    }
    return null;
  }

  Future<void> saveGame(Game game) async {
    await _firestore.collection('games').doc(game.id).set(game.toJson());
  }
  
  // Associate a game with a chapter
  Future<void> associateGameWithChapter(String subjectId, String chapterId, String gameId, String gameType) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    final index = chapters.indexWhere((c) => c['id'] == chapterId);
    
    if (index != -1) {
      chapters[index]['gameId'] = gameId;
      chapters[index]['gameType'] = gameType;
      
      await _firestore.collection('subjects').doc(subjectId).update({
        'chapters': chapters,
      });
    }
  }
  
  // Remove game association from a chapter
  Future<void> removeGameFromChapter(String subjectId, String chapterId) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    final index = chapters.indexWhere((c) => c['id'] == chapterId);
    
    if (index != -1) {
      // Store the gameId to delete the game later if needed
      final gameId = chapters[index]['gameId'];
      
      // Remove the game association
      chapters[index].remove('gameId');
      chapters[index].remove('gameType');
      
      await _firestore.collection('subjects').doc(subjectId).update({
        'chapters': chapters,
      });
      
      // Optionally delete the game from the games collection
      if (gameId != null) {
        await deleteGame(gameId);
      }
    }
  }

  Future<void> deleteGame(String gameId) async {
    await _firestore.collection('games').doc(gameId).delete();
  }

  // Quiz methods
  Stream<List<Map<String, dynamic>>> getQuizzes() {
    return _firestore.collection('quizzes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  Future<void> saveQuiz(Map<String, dynamic> quiz) async {
    await _firestore.collection('quizzes').doc(quiz['id'] as String).set(quiz);
  }

  Future<void> deleteQuiz(String quizId) async {
    await _firestore.collection('quizzes').doc(quizId).delete();
  }

  // Video methods
  Stream<List<VideoContent>> getVideos() {
    return _firestore.collection('videos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => VideoContent.fromFirestore(doc)).toList();
    });
  }

  Future<void> saveVideo(VideoContent video) async {
    await _firestore.collection('videos').doc(video.id).set(video.toJson());
  }

  Future<void> deleteVideo(String videoId) async {
    await _firestore.collection('videos').doc(videoId).delete();
  }

  // Upload a file to Firebase Storage
  Future<Map<String, String>> uploadFile(File file, String folder) async {
    try {
      // Clean the file name to avoid path issues
      String originalFileName = file.path.split('/').last.split('\\').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${originalFileName}';
      final ref = _storage.ref().child('$folder/$fileName');
      
      // Set metadata for the file
      final metadata = SettableMetadata(
        contentType: getContentType(file.path),
        customMetadata: {'uploaded_by': 'admin_app'},
      );
      
      // Start upload with metadata
      final uploadTask = ref.putFile(file, metadata);
      
      // Monitor progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      }, onError: (e) {
        print('Upload error: $e');
      });
      
      // Wait for completion
      final snapshot = await uploadTask.whenComplete(() => print('Upload complete'));
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return {
        'url': downloadUrl,
        'path': ref.fullPath,
      };
    } catch (e) {
      print('Error uploading file: $e');
      rethrow; // Rethrow to handle in the UI
    }
  }
  
  // Upload file bytes to Firebase Storage (for web platform)
  Future<Map<String, String>> uploadFileBytes(Uint8List bytes, String fileName, String folder) async {
    try {
      // Clean the file name and add timestamp to avoid conflicts
      final safeFileName = '${DateTime.now().millisecondsSinceEpoch}_${fileName.replaceAll(RegExp(r'[^\w\s\.\-]'), '_')}';
      final ref = _storage.ref().child('$folder/$safeFileName');
      
      // Set metadata for the file
      final metadata = SettableMetadata(
        contentType: getContentType(fileName),
        customMetadata: {'uploaded_by': 'admin_app'},
      );
      
      // Start upload with metadata
      final uploadTask = ref.putData(bytes, metadata);
      
      // Monitor progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      }, onError: (e) {
        print('Upload error: $e');
      });
      
      // Wait for completion
      final snapshot = await uploadTask.whenComplete(() => print('Upload complete'));
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return {
        'url': downloadUrl,
        'path': ref.fullPath,
      };
    } catch (e) {
      print('Error uploading file bytes: $e');
      rethrow; // Rethrow to handle in the UI
    }
  }
  
  // Public method to determine content type
  String getContentType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp3':
        return 'audio/mpeg';
      case 'mp4':
        return 'video/mp4';
      case 'wav':
        return 'audio/wav';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }
  
  // Upload multiple files at once
  Future<List<Map<String, String>>> uploadMultipleFiles(List<File> files, String folder) async {
    List<Map<String, String>> results = [];
    
    for (var file in files) {
      try {
        final result = await uploadFile(file, folder);
        results.add(result);
      } catch (e) {
        print('Error uploading file: $e');
        // Continue with the next file
      }
    }
    
    return results;
  }
  
  // Upload an image file and return its URL
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      // Create a reference to the location where the file will be uploaded
      final ref = _storage.ref().child(path);
      
      // Upload the file
      final uploadTask = ref.putFile(imageFile);
      
      // Wait for the upload to complete
      final snapshot = await uploadTask.whenComplete(() {});
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
  
  // Check if a file exists in storage
  Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Subject methods
  Stream<List<Subject>> getSubjects() {
    return _firestore
        .collection('subjects')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();
    });
  }
  
  // Get subjects filtered by age/moduleId
  Stream<List<Subject>> getSubjectsByAge(int moduleId) {
    return _firestore
        .collection('subjects')
        .where('moduleId', isEqualTo: moduleId)
        .snapshots()
        .map((snapshot) {
      final subjects = snapshot.docs.map((doc) => Subject.fromFirestore(doc)).toList();
      // Sort locally instead of using orderBy to avoid composite index requirement
      subjects.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return subjects;
    });
  }

  Future<void> addSubject(String name, int moduleId) async {
    await _firestore.collection('subjects').add({
      'name': name,
      'chapters': [],
      'createdAt': Timestamp.now(),
      'moduleId': moduleId,
    });
  }

  Future<void> deleteSubject(String subjectId) async {
    // First, delete all associated files
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (subject.exists) {
      final data = subject.data() as Map<String, dynamic>;
      final chapters = data['chapters'] as List<dynamic>? ?? [];
      
      for (var chapter in chapters) {
        if (chapter['videoFilePath'] != null) {
          await deleteFile(chapter['videoFilePath']);
        }
      }
    }
    
    // Then delete the subject document
    await _firestore.collection('subjects').doc(subjectId).delete();
  }

  Future<void> addChapter(String subjectId, String chapterName) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    chapters.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': chapterName,
      'notes': null,
      'videoUrl': null,
      'videoFilePath': null,
      'createdAt': Timestamp.now(),
    });

    await _firestore.collection('subjects').doc(subjectId).update({
      'chapters': chapters,
    });
  }

  Future<void> updateChapter(String subjectId, Chapter chapter) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    final index = chapters.indexWhere((c) => c['id'] == chapter.id);
    
    if (index != -1) {
      chapters[index] = chapter.toJson();
      await _firestore.collection('subjects').doc(subjectId).update({
        'chapters': chapters,
      });
    }
  }

  Future<void> deleteChapter(String subjectId, String chapterId) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    final chapter = chapters.firstWhere(
      (c) => c['id'] == chapterId,
      orElse: () => null,
    );

    if (chapter != null && chapter['videoFilePath'] != null) {
      await deleteFile(chapter['videoFilePath']);
    }

    chapters.removeWhere((c) => c['id'] == chapterId);
    await _firestore.collection('subjects').doc(subjectId).update({
      'chapters': chapters,
    });
  }
  
  // Update chapter note content (legacy method)
  Future<void> updateChapterNote(String subjectId, String chapterId, String noteContent) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    final index = chapters.indexWhere((c) => c['id'] == chapterId);
    
    if (index != -1) {
      chapters[index]['notes'] = noteContent;
      await _firestore.collection('subjects').doc(subjectId).update({
        'chapters': chapters,
      });
    }
  }
  
  // Create or update rich note for a chapter
  Future<void> updateRichNote(String subjectId, String chapterId, Note note) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    final index = chapters.indexWhere((c) => c['id'] == chapterId);
    
    if (index != -1) {
      chapters[index]['richNote'] = note.toJson();
      await _firestore.collection('subjects').doc(subjectId).update({
        'chapters': chapters,
      });
    }
  }
  
  // Add a content element to a rich note
  Future<void> addNoteElement(String subjectId, String chapterId, NoteContentElement element) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    final index = chapters.indexWhere((c) => c['id'] == chapterId);
    
    if (index != -1) {
      var richNoteData = chapters[index]['richNote'] as Map<String, dynamic>?;
      
      if (richNoteData == null) {
        // Create a new rich note if it doesn't exist
        richNoteData = Note(
          title: 'Note for ${chapters[index]['name']}',
          elements: [element],
          createdAt: Timestamp.now(),
        ).toJson();
      } else {
        // Add the element to the existing note
        var elements = (richNoteData['elements'] as List<dynamic>? ?? []).toList();
        elements.add(element.toJson());
        richNoteData['elements'] = elements;
        richNoteData['updatedAt'] = Timestamp.now();
      }
      
      chapters[index]['richNote'] = richNoteData;
      await _firestore.collection('subjects').doc(subjectId).update({
        'chapters': chapters,
      });
    }
  }
  
  // Remove a content element from a rich note
  Future<void> removeNoteElement(String subjectId, String chapterId, String elementId) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    final index = chapters.indexWhere((c) => c['id'] == chapterId);
    
    if (index != -1) {
      var richNoteData = chapters[index]['richNote'] as Map<String, dynamic>?;
      
      if (richNoteData != null) {
        var elements = (richNoteData['elements'] as List<dynamic>? ?? []).toList();
        elements.removeWhere((e) => e['id'] == elementId);
        richNoteData['elements'] = elements;
        richNoteData['updatedAt'] = Timestamp.now();
        
        chapters[index]['richNote'] = richNoteData;
        await _firestore.collection('subjects').doc(subjectId).update({
          'chapters': chapters,
        });
      }
    }
  }
  
  // Update the positions of note elements (for drag and drop reordering)
  Future<void> updateNoteElementPositions(String subjectId, String chapterId, List<Map<String, dynamic>> positionUpdates) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    final index = chapters.indexWhere((c) => c['id'] == chapterId);
    
    if (index != -1) {
      var richNoteData = chapters[index]['richNote'] as Map<String, dynamic>?;
      
      if (richNoteData != null) {
        var elements = (richNoteData['elements'] as List<dynamic>? ?? []).toList();
        
        for (var update in positionUpdates) {
          final elementIndex = elements.indexWhere((e) => e['id'] == update['id']);
          if (elementIndex != -1) {
            elements[elementIndex]['position'] = update['position'];
          }
        }
        
        richNoteData['elements'] = elements;
        richNoteData['updatedAt'] = Timestamp.now();
        
        chapters[index]['richNote'] = richNoteData;
        await _firestore.collection('subjects').doc(subjectId).update({
          'chapters': chapters,
        });
      }
    }
  }
  
  // Publish a note (change from draft to published)
  Future<void> publishNote(String subjectId, String chapterId) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    final index = chapters.indexWhere((c) => c['id'] == chapterId);
    
    if (index != -1) {
      var richNoteData = chapters[index]['richNote'] as Map<String, dynamic>?;
      
      if (richNoteData != null) {
        richNoteData['isDraft'] = false;
        richNoteData['updatedAt'] = Timestamp.now();
        
        chapters[index]['richNote'] = richNoteData;
        await _firestore.collection('subjects').doc(subjectId).update({
          'chapters': chapters,
        });
      }
    }
  }
  
  // Update chapter video URL
  Future<void> updateChapterVideo(String subjectId, String chapterId, String videoUrl) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    final index = chapters.indexWhere((c) => c['id'] == chapterId);
    
    if (index != -1) {
      chapters[index]['videoUrl'] = videoUrl;
      await _firestore.collection('subjects').doc(subjectId).update({
        'chapters': chapters,
      });
    }
  }
  
  // Save note to chapter
  Future<void> saveNoteToChapter(String subjectId, String chapterId, Note note) async {
    try {
      final subject = await _firestore.collection('subjects').doc(subjectId).get();
      if (!subject.exists) throw Exception('Subject not found');

      final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
      final index = chapters.indexWhere((c) => c['id'] == chapterId);
      
      if (index == -1) throw Exception('Chapter not found');
      
      // Convert note to JSON
      final noteData = note.toJson();
      
      // Add note to chapter
      chapters[index]['note'] = noteData;
      
      // Update subject document
      await _firestore.collection('subjects').doc(subjectId).update({
        'chapters': chapters,
      });
    } catch (e) {
      print('Error saving note to chapter: $e');
      throw e;
    }
  }
  
  // Get notes for a chapter
  Future<Note?> getNoteForChapter(String subjectId, String chapterId) async {
    try {
      final subject = await _firestore.collection('subjects').doc(subjectId).get();
      if (!subject.exists) return null;

      final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []);
      final chapter = chapters.firstWhere(
        (c) => c['id'] == chapterId,
        orElse: () => null,
      );
      
      if (chapter == null || !chapter.containsKey('note')) return null;
      
      // Convert JSON to Note object
      return Note.fromJson(chapter['note']);
    } catch (e) {
      print('Error getting note for chapter: $e');
      return null;
    }
  }
  
  // Delete note from chapter
  Future<void> deleteNoteFromChapter(String subjectId, String chapterId) async {
    try {
      final subject = await _firestore.collection('subjects').doc(subjectId).get();
      if (!subject.exists) return;

      final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
      final index = chapters.indexWhere((c) => c['id'] == chapterId);
      
      if (index == -1) return;
      
      // Remove note from chapter
      if (chapters[index].containsKey('note')) {
        chapters[index].remove('note');
        
        // Update subject document
        await _firestore.collection('subjects').doc(subjectId).update({
          'chapters': chapters,
        });
      }
    } catch (e) {
      print('Error deleting note from chapter: $e');
      throw e;
    }
  }
  
  // Update chapter video file path (for uploaded MP4 files)
  Future<void> updateChapterVideoFilePath(String subjectId, String chapterId, String filePath) async {
    final subject = await _firestore.collection('subjects').doc(subjectId).get();
    if (!subject.exists) return;

    final chapters = (subject.data()?['chapters'] as List<dynamic>? ?? []).toList();
    final index = chapters.indexWhere((c) => c['id'] == chapterId);
    
    if (index != -1) {
      chapters[index]['videoFilePath'] = filePath;
      await _firestore.collection('subjects').doc(subjectId).update({
        'chapters': chapters,
      });
    }
  }
  

}
