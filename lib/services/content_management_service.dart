import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'gemini_service.dart';

class ContentManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GeminiService _geminiService = GeminiService();

  // Subject Management
  Future<String?> addSubject(String name) async {
    try {
      final cleanName = name.trim();
      final docRef = await _firestore.collection('subjects').add({
        'name': cleanName,
        'displayName': cleanName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding subject: $e');
      return null;
    }
  }

  Stream<QuerySnapshot> getSubjects() {
    return _firestore
        .collection('subjects')
        .orderBy('displayName')
        .snapshots();
  }

  // Module Management
  Stream<QuerySnapshot> getModules(String subjectId, {required int targetAge}) {
    try {
      return _firestore
          .collection('subjects')
          .doc(subjectId)
          .collection('modules')
          .where('targetAge', isEqualTo: targetAge)
          .snapshots();
    } catch (e) {
      print('Error getting modules: $e');
      rethrow;
    }
  }

  Future<String?> addModule(
    String subjectId,
    String name,
    int targetAge,
    String gameType, {
    File? videoFile,
    String? youtubeUrl,
  }) async {
    try {
      // Create the module document first
      final moduleRef = _firestore
          .collection('subjects')
          .doc(subjectId)
          .collection('modules')
          .doc();

      // If there's a video file, upload it
      String? videoUrl;
      if (videoFile != null) {
        final videoRef = _storage.ref().child('videos/$subjectId/${moduleRef.id}');
        await videoRef.putFile(videoFile);
        videoUrl = await videoRef.getDownloadURL();
      }

      // Add the module data
      await moduleRef.set({
        'name': name.trim(),
        'targetAge': targetAge,
        'gameType': gameType,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'videoUrl': videoUrl,
        'youtubeUrl': youtubeUrl,
        'hasGame': false,
        'hasQuiz': false,
      });

      return moduleRef.id;
    } catch (e) {
      print('Error adding module: $e');
      return null;
    }
  }

  Future<void> updateModule(String subjectId, String moduleId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('subjects')
          .doc(subjectId)
          .collection('modules')
          .doc(moduleId)
          .update({
        'name': data['name'],
        'gameType': data['gameType'],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating module: $e');
      throw e;
    }
  }

  Future<void> deleteModule(String subjectId, String moduleId) async {
    try {
      final moduleRef = _firestore
          .collection('subjects')
          .doc(subjectId)
          .collection('modules')
          .doc(moduleId);

      // Get module data to check for video URL
      final moduleData = await moduleRef.get();
      final videoUrl = moduleData.data()?['videoUrl'];

      // Delete video from storage if it exists
      if (videoUrl != null) {
        try {
          await _storage.refFromURL(videoUrl).delete();
        } catch (e) {
          print('Error deleting video: $e');
        }
      }

      // Delete the module document and all its subcollections
      await moduleRef.delete();
    } catch (e) {
      print('Error deleting module: $e');
      throw e;
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      // Delete all modules in the subject
      final modulesSnapshot = await _firestore
          .collection('subjects')
          .doc(subjectId)
          .collection('modules')
          .get();
      
      for (var module in modulesSnapshot.docs) {
        await module.reference.delete();
      }

      // Delete the subject
      await _firestore.collection('subjects').doc(subjectId).delete();
    } catch (e) {
      print('Error deleting subject: $e');
      throw e;
    }
  }

  // Game Management
  Future<bool> generateGame(String subjectId, String moduleId, String moduleName, int targetAge) async {
    try {
      // Generate game content using Gemini
      final gameContent = await _geminiService.createGame(
        moduleName,
        targetAge: targetAge,
      );

      if (gameContent != null) {
        await _firestore
            .collection('subjects')
            .doc(subjectId)
            .collection('modules')
            .doc(moduleId)
            .collection('games')
            .add({
          'content': gameContent,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update module to indicate it has a game
        await _firestore
            .collection('subjects')
            .doc(subjectId)
            .collection('modules')
            .doc(moduleId)
            .update({'hasGame': true});

        return true;
      }
      return false;
    } catch (e) {
      print('Error generating game: $e');
      return false;
    }
  }

  // Quiz Management
  Future<bool> generateQuiz(String subjectId, String moduleId, String moduleName, int targetAge) async {
    try {
      // Generate quiz content using Gemini
      final quizContent = await _geminiService.createQuiz(
        moduleName,
        targetAge: targetAge,
      );

      if (quizContent != null) {
        await _firestore
            .collection('subjects')
            .doc(subjectId)
            .collection('modules')
            .doc(moduleId)
            .collection('quizzes')
            .add({
          'content': quizContent,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update module to indicate it has a quiz
        await _firestore
            .collection('subjects')
            .doc(subjectId)
            .collection('modules')
            .doc(moduleId)
            .update({'hasQuiz': true});

        return true;
      }
      return false;
    } catch (e) {
      print('Error generating quiz: $e');
      return false;
    }
  }

  // Video Management
  Future<String?> _uploadVideo(File file, String subjectId) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.mp4';
      final ref = _storage.ref().child('videos/$subjectId/$fileName');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading video: $e');
      return null;
    }
  }

  // Preview Methods
  Future<Map<String, dynamic>?> getModulePreview(String subjectId, String moduleId) async {
    try {
      final moduleDoc = await _firestore
          .collection('subjects')
          .doc(subjectId)
          .collection('modules')
          .doc(moduleId)
          .get();

      if (!moduleDoc.exists) return null;

      final moduleData = moduleDoc.data()!;

      // Get latest game if exists
      String? gameContent;
      if (moduleData['hasGame'] == true) {
        final gameQuery = await moduleDoc.reference
            .collection('games')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();
        if (gameQuery.docs.isNotEmpty) {
          gameContent = gameQuery.docs.first.data()['content'];
        }
      }

      // Get latest quiz if exists
      String? quizContent;
      if (moduleData['hasQuiz'] == true) {
        final quizQuery = await moduleDoc.reference
            .collection('quizzes')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();
        if (quizQuery.docs.isNotEmpty) {
          quizContent = quizQuery.docs.first.data()['content'];
        }
      }

      return {
        ...moduleData,
        'gameContent': gameContent,
        'quizContent': quizContent,
      };
    } catch (e) {
      print('Error getting module preview: $e');
      return null;
    }
  }
}
