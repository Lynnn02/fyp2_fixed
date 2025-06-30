import 'package:flutter/material.dart';
import '../../models/subject.dart';
import '../../models/note_content.dart';
import '../../services/content_service.dart';
import 'learning_selection_screen.dart';
import 'video_player_screen.dart';
import 'note_viewer_screen.dart';

class ChapterSelectionScreen extends StatefulWidget {
  final Subject subject;
  final String userId;
  final String userName;

  const ChapterSelectionScreen({
    super.key,
    required this.subject,
    required this.userId,
    required this.userName,
  });
  
  @override
  State<ChapterSelectionScreen> createState() => _ChapterSelectionScreenState();
}

class _ChapterSelectionScreenState extends State<ChapterSelectionScreen> {
  final ContentService _contentService = ContentService();

  @override
  Widget build(BuildContext context) {
    // Extract arguments if they were passed as a map
    final args = ModalRoute.of(context)?.settings.arguments;
    late Subject actualSubject = widget.subject;
    late String actualUserId = widget.userId;
    late String actualUserName = widget.userName;
    
    if (args is Map<String, dynamic>) {
      actualSubject = args['subject'] as Subject;
      actualUserId = args['userId'] as String;
      actualUserName = args['userName'] as String;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          actualSubject.name,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'ITEM',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/rainbow.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 100),
              // Chapter Selection Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'CHAPTER SELECTION',
                  style: TextStyle(
                    fontFamily: 'ITEM',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Chapter List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: actualSubject.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = actualSubject.chapters[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/learningSelection',
                          arguments: {
                            'chapter': chapter,
                            'subjectId': actualSubject.id,
                            'userId': actualUserId,
                            'userName': actualUserName,
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                          color: Colors.white.withOpacity(0.9),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  chapter.name,
                                  style: const TextStyle(
                                    fontFamily: 'ITEM',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Check if the chapter has a note before showing the Notes button
                                    FutureBuilder<Note?>(
                                      future: _contentService.getNoteForChapter(actualSubject.id, chapter.id),
                                      builder: (context, snapshot) {
                                        // Show placeholder while loading
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                                          );
                                        }
                                        
                                        // If note exists, show the Notes button
                                        if (snapshot.hasData && snapshot.data != null) {
                                          return _buildFeatureButton(
                                            icon: Icons.book,
                                            label: 'Notes',
                                            color: Colors.green,
                                            onPressed: () {
                                              _loadAndViewNote(
                                                context,
                                                chapter,
                                                actualSubject.id,
                                                actualUserId,
                                                actualUserName,
                                              );
                                            },
                                          );
                                        }
                                        
                                        // If no note exists, show a disabled message
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(0.2),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.grey, width: 2),
                                              ),
                                              child: const Icon(Icons.book, color: Colors.grey),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Coming Soon',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'ITEM',
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    if ((chapter.videoUrl != null && chapter.videoUrl!.isNotEmpty) ||
                                        (chapter.videoFilePath != null && chapter.videoFilePath!.isNotEmpty))
                                      _buildFeatureButton(
                                        icon: Icons.play_circle_fill,
                                        label: 'Video',
                                        color: Colors.red.shade600,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => VideoPlayerScreen(
                                                chapter: chapter,
                                                subject: actualSubject,
                                                userId: actualUserId,
                                                userName: actualUserName,
                                                ageGroup: widget.subject.moduleId,
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to load and view note directly
  Future<void> _loadAndViewNote(BuildContext context, Chapter chapter, String subjectId, String userId, String userName) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Load the note
      final note = await _contentService.getNoteForChapter(subjectId, chapter.id);
      
      // Close loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      if (note != null && context.mounted) {
        // Navigate directly to note viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteViewerScreen(
              note: note,
              chapterName: chapter.name,
              userId: userId,
              userName: userName,
              subjectId: subjectId,
              subjectName: widget.subject.name, // Use the actual subject name instead of chapter name
              chapterId: chapter.id,
              ageGroup: widget.subject.moduleId,
            ),
          ),
        );
      } else if (context.mounted) {
        // Show error if note not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No note available for this chapter yet.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // Handle error
      if (context.mounted) {
        Navigator.pop(context); // Close loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: 'ITEM',
          ),
        ),
      ],
    );
  }
}
