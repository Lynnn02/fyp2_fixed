import 'package:flutter/material.dart';
import '../../models/subject.dart';
import '../../services/content_service.dart';
import '../../services/content_filter_service.dart';
import 'gameChapterSelection_screen.dart';

class GameSubjectSelectionScreen extends StatefulWidget {
  final int moduleId;
  final String userId;
  final String userName;

  const GameSubjectSelectionScreen({
    super.key, 
    this.moduleId = 4,
    required this.userId,
    required this.userName,
  });
  
  @override
  State<GameSubjectSelectionScreen> createState() => _GameSubjectSelectionScreenState();
}

class _GameSubjectSelectionScreenState extends State<GameSubjectSelectionScreen> {
  final ContentService _contentService = ContentService();
  final ContentFilterService _filterService = ContentFilterService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              // Subject Selection Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'GAME SELECTION',
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
              // Subject List
              Expanded(
                child: StreamBuilder<List<Subject>>(
                  stream: _contentService.getSubjectsByAge(widget.moduleId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final subjects = snapshot.data!;
                    
                    if (subjects.isEmpty) {
                      return const Center(
                        child: Text(
                          'No games available for this module yet',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
                    
                    // Check content filters for each subject
                    return FutureBuilder<List<Subject>>(
                      future: _filterSubjects(subjects),
                      builder: (context, filteredSnapshot) {
                        if (filteredSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (filteredSnapshot.hasError) {
                          return Center(child: Text('Error: ${filteredSnapshot.error}'));
                        }
                        
                        final filteredSubjects = filteredSnapshot.data!;
                        
                        if (filteredSubjects.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.block, size: 64, color: Colors.red.shade300),
                                const SizedBox(height: 16),
                                const Text(
                                  'No games available',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Ask your parent to enable subjects in Content Filters',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = filteredSubjects[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  // Circle number
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Subject Button
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Use direct navigation instead of named routes to avoid type casting issues
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => GameChapterSelectionScreen(
                                              subject: subject,
                                              userId: widget.userId,
                                              userName: widget.userName,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 15,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: Text(
                                        subject.name,
                                        style: const TextStyle(
                                          fontFamily: 'ITEM',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
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
  
  // Filter subjects based on content filter settings
  Future<List<Subject>> _filterSubjects(List<Subject> subjects) async {
    List<Subject> filteredSubjects = [];
    
    for (var subject in subjects) {
      // Check if subject is allowed by content filters
      bool isAllowed = await _filterService.isSubjectAllowed(subject.id);
      
      if (isAllowed) {
        filteredSubjects.add(subject);
      }
    }
    
    return filteredSubjects;
  }
}
