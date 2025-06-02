import 'package:flutter/material.dart';
import '../../models/subject.dart';
import '../../services/content_service.dart';
import '../../models/note_content.dart';

class LearningSelectionScreen extends StatefulWidget {
  final Chapter chapter;
  final String subjectId;
  final String userId;
  final String userName;
  
  const LearningSelectionScreen({
    super.key, 
    required this.chapter,
    required this.subjectId,
    required this.userId,
    required this.userName,
  });

  @override
  State<LearningSelectionScreen> createState() => _LearningSelectionScreenState();
}

class _LearningSelectionScreenState extends State<LearningSelectionScreen> {
  final ContentService _contentService = ContentService();
  Note? _note;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadNote();
  }
  
  Future<void> _loadNote() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Extract arguments if they were passed as a map
      final args = ModalRoute.of(context)?.settings.arguments;
      late Chapter actualChapter = widget.chapter;
      late String actualSubjectId = widget.subjectId;
      
      if (args is Map<String, dynamic>) {
        actualChapter = args['chapter'] as Chapter;
        actualSubjectId = args['subjectId'] as String;
      }
      
      final note = await _contentService.getNoteForChapter(actualSubjectId, actualChapter.id);
      setState(() {
        _note = note;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading note: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Extract arguments if they were passed as a map
    final args = ModalRoute.of(context)?.settings.arguments;
    late Chapter actualChapter = widget.chapter;
    late String actualSubjectId = widget.subjectId;
    late String actualUserId = widget.userId;
    late String actualUserName = widget.userName;
    
    if (args is Map<String, dynamic>) {
      actualChapter = args['chapter'] as Chapter;
      actualSubjectId = args['subjectId'] as String;
      if (args.containsKey('userId')) {
        actualUserId = args['userId'] as String;
      }
      if (args.containsKey('userName')) {
        actualUserName = args['userName'] as String;
      }
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/rainbow.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "LEARNING SELECTION",
                    style: TextStyle(
                      fontFamily: 'ITEM',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                _isLoading
                ? const SizedBox(
                    height: 50,
                    width: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : ElevatedButton(
                  onPressed: _note != null
                      ? () {
                          Navigator.pushNamed(
                            context,
                            '/noteViewer',
                            arguments: {
                              'note': _note,
                              'chapterName': actualChapter.name,
                              'userId': actualUserId,
                              'userName': actualUserName,
                              'subjectId': actualSubjectId,
                              'chapterId': actualChapter.id,
                              'subjectName': actualChapter.name,
                            },
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: _note != null ? Colors.green : Colors.grey,
                  ),
                  child: const Text("Note"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: (actualChapter.videoUrl != null && actualChapter.videoUrl!.isNotEmpty) ||
                          (actualChapter.videoFilePath != null && actualChapter.videoFilePath!.isNotEmpty)
                      ? () {
                          Navigator.pushNamed(
                            context,
                            '/videoPlayer',
                            arguments: {
                              'videoUrl': actualChapter.videoUrl,
                              'videoFilePath': actualChapter.videoFilePath,
                              'chapterName': actualChapter.name,
                              'userId': actualUserId,
                              'userName': actualUserName,
                              'subjectId': actualSubjectId,
                              'chapterId': actualChapter.id,
                              'subjectName': actualChapter.name,
                            },
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: (actualChapter.videoUrl != null && actualChapter.videoUrl!.isNotEmpty) ||
                          (actualChapter.videoFilePath != null && actualChapter.videoFilePath!.isNotEmpty) 
                          ? Colors.red 
                          : Colors.grey,
                  ),
                  child: const Text("Watch Video"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
