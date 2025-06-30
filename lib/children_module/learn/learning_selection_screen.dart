import 'package:flutter/material.dart';
import '../../models/subject.dart';
import '../../services/content_service.dart';
import '../../models/note_content.dart';
import 'note_viewer_screen.dart';

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
      
      print('Loading note for chapter: ${actualChapter.id} in subject: $actualSubjectId');
      print('Initial chapter data: noteId=${actualChapter.noteId}, noteTitle=${actualChapter.noteTitle}');
      
      // Refresh the subject data to get the latest chapter information
      try {
        final refreshedSubject = await _contentService.getSubjectById(actualSubjectId);
        if (refreshedSubject != null) {
          // Find the updated chapter
          final refreshedChapter = refreshedSubject.chapters.firstWhere(
            (c) => c.id == actualChapter.id,
            orElse: () => actualChapter,
          );
          
          // Update our chapter reference with the latest data
          actualChapter = refreshedChapter;
          print('Refreshed chapter data: noteId=${actualChapter.noteId}, noteTitle=${actualChapter.noteTitle}');
        }
      } catch (refreshError) {
        print('Error refreshing subject data: $refreshError');
        // Continue with the original chapter data
      }
      
      final note = await _contentService.getNoteForChapter(actualSubjectId, actualChapter.id);
      print('Note loaded: ${note != null ? 'Yes' : 'No'}');
      if (note != null) {
        print('Note title: ${note.title}, elements: ${note.elements.length}');
      }
      
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
    
    print('BUILD: Note loaded: ${_note != null ? 'Yes' : 'No'}');
    if (_note != null) {
      print('BUILD: Note ID: ${_note!.id}, title: ${_note!.title}, elements: ${_note!.elements.length}');
    }
    print('BUILD: Chapter noteId: ${actualChapter.noteId}');
    print('BUILD: isLoading: $_isLoading');
    
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
                        print('Navigating to note viewer with note: ${_note!.id}, title: ${_note!.title}');
                        // Try using push with MaterialPageRoute instead of pushNamed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteViewerScreen(
                              note: _note!,
                              chapterName: actualChapter.name,
                              userId: actualUserId,
                              userName: actualUserName,
                              subjectId: actualSubjectId,
                              chapterId: actualChapter.id,
                              subjectName: actualChapter.name,
                              ageGroup: 5, // Set a default age group for children
                            ),
                          ),
                        );
                        // Fallback to pushNamed if the above doesn't work
                        // Navigator.pushNamed(
                        //   context,
                        //   '/noteViewer',
                        //   arguments: {
                        //     'note': _note,
                        //     'chapterName': actualChapter.name,
                        //     'userId': actualUserId,
                        //     'userName': actualUserName,
                        //     'subjectId': actualSubjectId,
                        //     'chapterId': actualChapter.id,
                        //     'subjectName': actualChapter.name,
                        //     'ageGroup': 5, // Set a default age group for children
                        //   },
                        // );
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
