import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/subject.dart';
import '../../models/note_content.dart';
import '../../services/content_service.dart';
import '../../services/gemini_games_service.dart';
import '../../services/gemini_notes_service.dart';
import '../../services/game_template_manager.dart';
import '../../widgets/admin_app_bar.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/admin_ui_style.dart';
import 'game_template/game_template/matching_game.dart';
import 'game_template/game_template/sorting_game.dart';
import 'game_template/game_template/tracing_game.dart';
import 'game_template/game_template/shape_color_game.dart';
import '../../models/game.dart';

import 'note_template/note_template_selection_screen.dart';
import 'note_template/enhanced_note_preview_screen.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({Key? key}) : super(key: key);

  @override
  _ContentManagementScreenState createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  final ContentService _contentService = ContentService();
  final GeminiGamesService _geminiService = GeminiGamesService();
  final GeminiNotesService _geminiNotesService = GeminiNotesService();
  int _selectedAge = 4; // Default selected age
  bool _isGeneratingContent = false;
  int _selectedIndex = 2;
  
  // Build a navigation item for the custom navigation bar
  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final bool isSelected = index == 2; // Content tab is always selected in preview
    final Color itemColor = isSelected ? Theme.of(context).primaryColor : Colors.grey;
    
    return Expanded(
      child: InkWell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: itemColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: itemColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Content Management',
      selectedIndex: 2, // Content tab is selected
      onNavigate: (index) {
        // Handle navigation based on index
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/adminHome');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/userManagement');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/analytics');
        } else if (index == 4) {
          Navigator.pushReplacementNamed(context, '/settings');
        }
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectDialog(context),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        tooltip: 'Add New Subject',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Age selector in a consistent container style
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Content',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Select Age Group:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: _selectedAge,
                      onChanged: (value) {
                        setState(() {
                          _selectedAge = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 4, child: Text('Age 4')),
                        DropdownMenuItem(value: 5, child: Text('Age 5')),
                        DropdownMenuItem(value: 6, child: Text('Age 6')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Subjects list
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: StreamBuilder<List<Subject>>(
                stream: _contentService.getSubjectsByAge(_selectedAge),
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
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.library_books_outlined, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No subjects found for this age group.',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Click the + button to add a subject.',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return _buildSubjectCard(subject);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSubjectCard(Subject subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          subject.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text('${subject.chapters.length} chapters'),
        leading: CircleAvatar(
          backgroundColor: _getAgeColor(_selectedAge),
          child: Text(
            '$_selectedAge',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () => _showAddChapterDialog(context, subject),
              tooltip: 'Add Chapter',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteSubjectDialog(context, subject),
              tooltip: 'Delete Subject',
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          if (subject.chapters.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No chapters yet. Add a chapter to get started.'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subject.chapters.length,
              itemBuilder: (context, index) {
                final chapter = subject.chapters[index];
                return _buildChapterTile(subject, chapter, index);
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildChapterTile(Subject subject, Chapter chapter, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          ListTile(
            title: Text(
              chapter.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Text('${index + 1}'),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: chapter.noteId != null 
                      ? const Icon(Icons.edit_note, color: Colors.green)
                      : const Icon(Icons.note_add, color: Colors.green),
                  onPressed: () {
                    _showAddNoteDialog(context, subject, chapter);
                  },
                  tooltip: chapter.noteId != null ? 'Edit Note' : 'Create Note',
                ),
                IconButton(
                  icon: chapter.videoUrl != null
                      ? const Icon(Icons.video_library, color: Colors.red)
                      : const Icon(Icons.video_library, color: Colors.purple),
                  onPressed: () {
                    _showAddVideoDialog(context, subject, chapter);
                  },
                  tooltip: 'Add Video URL',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteChapterDialog(context, subject, chapter),
                  tooltip: 'Delete Chapter',
                ),
              ],
            ),
            onTap: () {
              // Navigate to children module
              Navigator.pushNamed(
                context, 
                '/childrenLearning',
                arguments: {
                  'moduleId': subject.moduleId,
                  'subjectId': subject.id,
                  'chapterId': chapter.id,
                },
              );
            },
          ),
          
          // Published note info (if exists)
          if (chapter.noteId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _getAgeColor(subject.moduleId).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: _getAgeColor(subject.moduleId), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_stories, color: _getAgeColor(subject.moduleId)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Published Note: ${chapter.noteTitle ?? "Flashcard Note"}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (chapter.noteLastUpdated != null)
                            Text(
                              'Updated ${_formatTimestamp(chapter.noteLastUpdated!)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.green),
                      tooltip: 'Edit Note',
                      onPressed: () => _editPublishedNote(subject, chapter),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Note',
                      onPressed: () => _showDeleteNoteDialog(context, subject, chapter),
                    ),
                  ],
                ),
              ),
            ),
          
          // Published game info (if exists)
          if (chapter.gameId != null && chapter.gameType != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _getGameColor(chapter.gameType!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: _getGameColor(chapter.gameType!), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(_getGameIcon(chapter.gameType!), color: _getGameColor(chapter.gameType!)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Published Game: ${_getGameName(chapter.gameType!)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          FutureBuilder<Game?>(
                            future: _contentService.getGameById(chapter.gameId!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('Loading game details...');
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              final game = snapshot.data;
                              return Text(game?.title ?? 'Game details not available');
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Edit Game',
                      onPressed: () => _editPublishedGame(subject, chapter),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Game',
                      onPressed: () => _showDeleteGameDialog(context, subject, chapter),
                    ),
                  ],
                ),
              ),
            ),
          
          // Preview/publish buttons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Note button
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton.icon(
                    icon: Icon(chapter.noteId != null ? Icons.edit_note : Icons.note_add),
                    label: Text(chapter.noteId != null ? 'Edit Note' : 'Create Note'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showAddNoteDialog(context, subject, chapter),
                  ),
                ),
                // Game button
                ElevatedButton.icon(
                  icon: const Icon(Icons.gamepad),
                  label: Text(chapter.gameId != null ? 'Edit Game' : 'Create Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _previewGame(subject, chapter),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getAgeColor(int age) {
    switch (age) {
      case 4:
        return Colors.pink.shade300;
      case 5:
        return Colors.purple.shade300;
      case 6:
        return Colors.indigo.shade300;
      default:
        return Colors.blue.shade300;
    }
  }
  
  int _getPageLimit(int age) {
    switch (age) {
      case 4:
        return 10;
      case 5:
        return 15;
      case 6:
        return 20;
      default:
        return 10;
    }
  }

  IconData _getGameIcon(String gameType) {
    switch (gameType) {
      case 'tracing':
        return Icons.gesture;
      case 'matching':
        return Icons.compare_arrows;
      case 'sorting':
        return Icons.sort;
      case 'counting':
        return Icons.looks_one;
      case 'puzzle':
        return Icons.extension;
      default:
        return Icons.games;
    }
  }
  
  Color _getGameColor(String gameType) {
    switch (gameType) {
      case 'tracing':
        return Colors.blue;
      case 'matching':
        return Colors.green;
      case 'sorting':
        return Colors.orange;
      case 'counting':
        return Colors.red;
      case 'puzzle':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
  
  String _getGameName(String gameType) {
    switch (gameType) {
      case 'tracing':
        return 'Tracing Game';
      case 'matching':
        return 'Matching Game';
      case 'sorting':
        return 'Sorting Game';
      case 'counting':
        return 'Counting Game';
      case 'puzzle':
        return 'Puzzle Game';
      default:
        return 'Game';
    }
  }
  
  String _getGameDescription(String gameType) {
    switch (gameType) {
      case 'tracing':
        return 'Practice writing letters, numbers, or shapes';
      case 'matching':
        return 'Match pairs of related items';
      case 'sorting':
        return 'Sort items into categories';
      case 'counting':
        return 'Count objects and select the correct number';
      case 'puzzle':
        return 'Solve simple puzzles';
      default:
        return 'Interactive educational game';
    }
  }
  
  String _getAgeAppropriateNote(String gameType, int age) {
    switch (gameType) {
      case 'tracing':
        return age <= 4 
          ? 'Simple shapes and uppercase letters with guides'
          : age <= 5 
            ? 'Letters and numbers with moderate guidance'
            : 'Words and sentences with minimal guidance';
      case 'matching':
        return age <= 4 
          ? 'Simple word-picture pairs with large visuals'
          : age <= 5 
            ? 'Moderate difficulty with familiar words'
            : 'More challenging vocabulary with related concepts';
      case 'sorting':
        return age <= 4 
          ? 'Basic categories with distinct differences'
          : age <= 5 
            ? 'More nuanced categories with similar items'
            : 'Multiple categories with subtle differences';
      case 'counting':
        return age <= 4 
          ? 'Numbers 1-5 with large, countable objects'
          : age <= 5 
            ? 'Numbers 1-10 with grouped objects'
            : 'Numbers 1-20 with addition concepts';
      case 'puzzle':
        return age <= 4 
          ? '3x3 grid with simple images and visual guides'
          : age <= 5 
            ? '3x3 grid with more detailed images'
            : '4x4 grid with challenging images';
      default:
        return 'Difficulty adjusted for age $age';
    }
  }

  void _showAddSubjectDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                hintText: 'Enter subject name',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedAge,
              decoration: const InputDecoration(labelText: 'Age Group'),
              items: const [
                DropdownMenuItem(value: 4, child: Text('Age 4')),
                DropdownMenuItem(value: 5, child: Text('Age 5')),
                DropdownMenuItem(value: 6, child: Text('Age 6')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAge = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _contentService.addSubject(nameController.text, _selectedAge);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Subject "${nameController.text}" added successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a subject name')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddChapterDialog(BuildContext context, Subject subject) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Chapter to ${subject.name}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Chapter Name',
            hintText: 'Enter chapter name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _contentService.addChapter(subject.id, nameController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chapter "${nameController.text}" added successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a chapter name')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  void _showAddNoteDialog(BuildContext context, Subject subject, Chapter chapter) {
    // Directly open the template selection screen for AI-generated content
    _openTemplateSelection(context, subject, chapter);
  }
  
  void _showSimpleNoteDialog(BuildContext context, Subject subject, Chapter chapter) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Simple Note to ${chapter.name}'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Note Content',
            hintText: 'Enter note content',
          ),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                _contentService.updateChapterNote(
                  subject.id, 
                  chapter.id, 
                  noteController.text
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note added successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter note content')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  // Rich note editor has been removed in favor of AI-generated content
  Future<void> _openTemplateSelection(BuildContext context, Subject subject, Chapter chapter) async {
    // Navigate to template selection and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteTemplateSelectionScreen(
          subject: subject,
          chapter: chapter,
          age: _selectedAge,
        ),
      ),
    );
    
    // If we got a true result (note was published) or any result (to be safe), refresh the UI
    if (result != null) {
      // Refresh the UI to show the updated note status
      setState(() {
        // This will trigger a rebuild of the UI
      });
    }
  }
  
  void _showAddVideoDialog(BuildContext context, Subject subject, Chapter chapter) {
    final TextEditingController urlController = TextEditingController();
    PlatformFile? selectedVideoFile;
    bool isUploading = false;
    bool isUrlMode = true; // Track which mode is active
    
    // Check if running on web platform
    final bool isWebPlatform = kIsWeb;
    
    // If chapter already has a video URL, pre-fill the controller
    if (chapter.videoUrl != null) {
      urlController.text = chapter.videoUrl!;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isUrlMode ? Icons.link : Icons.upload_file,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add Video to ${chapter.name}',
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // YouTube URL header
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.link,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'YouTube URL',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // YouTube URL input section
                    Column(children: [                      
                      // YouTube URL input
                      TextField(
                        controller: urlController,
                        decoration: InputDecoration(
                          labelText: 'Video URL',
                          hintText: 'Enter YouTube or other video URL',
                          prefixIcon: const Icon(Icons.video_library),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Supported formats: YouTube, Vimeo, or direct video URLs',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ]),
                    
                    // Note about Firebase Storage
                    const SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.info_outline, color: Colors.amber),
                              SizedBox(width: 8),
                              Text(
                                'Note about video uploads',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Direct file uploads require Firebase Storage with a billing plan. For now, please use YouTube URLs to add videos to your chapters.',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You can upload your videos to YouTube and then paste the URL here.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.link),
                  label: Text(isUploading ? 'Uploading...' : 'Add YouTube URL'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.blue.shade200,
                  ),
                  onPressed: isUploading
                      ? null // Disable when uploading
                      : () async {
                          {
                            // Handle YouTube URL
                            if (urlController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a video URL')),
                              );
                              return;
                            }
                            
                            // Update with URL
                            await _contentService.updateChapterVideo(
                              subject.id,
                              chapter.id,
                              urlController.text,
                            );
                            
                            if (context.mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Video URL added successfully')),
                              );
                            }
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteSubjectDialog(BuildContext context, Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "${subject.name}"? This will also delete all chapters and content within this subject.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _contentService.deleteSubject(subject.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Subject "${subject.name}" deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteChapterDialog(BuildContext context, Subject subject, Chapter chapter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chapter'),
        content: Text('Are you sure you want to delete "${chapter.name}"? This will also delete all content within this chapter.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _contentService.deleteChapter(subject.id, chapter.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chapter "${chapter.name}" deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _previewGame(Subject subject, Chapter chapter) async {
    setState(() {
      _isGeneratingContent = true;
    });
    
    try {
      // Use the available game types instead of AI recommendation
      final List<String> suitableGameTypes = ['matching', 'sorting', 'tracing', 'shape_color'];
      
      if (context.mounted) {
        setState(() {
          _isGeneratingContent = false;
        });
        
        // Show game selection dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Select Game for ${chapter.name}'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getAgeColor(subject.moduleId),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Age ${subject.moduleId}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${subject.name}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Top 3 AI-Recommended Games:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Specially tailored for ${subject.name}, ${chapter.name}, and age ${subject.moduleId}.',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  for (int i = 0; i < suitableGameTypes.length; i++) 
                    Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getGameColor(suitableGameTypes[i]).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getGameIcon(suitableGameTypes[i]),
                              color: _getGameColor(suitableGameTypes[i]),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(_getGameName(suitableGameTypes[i])),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: i == 0 ? Colors.green : (i == 1 ? Colors.blue : Colors.orange),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  i == 0 ? 'Best Match' : (i == 1 ? 'Great Option' : 'Good Choice'),
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getGameDescription(suitableGameTypes[i])),
                              const SizedBox(height: 4),
                              Text(
                                _getAgeAppropriateNote(suitableGameTypes[i], subject.moduleId),
                                style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.pop(context);
                            _launchGamePreview(subject, chapter, suitableGameTypes[i]);
                          },
                        ),
                        if (i < suitableGameTypes.length - 1)
                          const Divider(height: 1),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _isGeneratingContent = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating game preview: $e')),
        );
      }
    }
  }

  void _launchGamePreview(Subject subject, Chapter chapter, String gameType) async {
    // Show loading dialog while generating content
    setState(() {
      _isGeneratingContent = true;
    });
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating game content...'),
          ],
        ),
      ),
    );
    
    // Generate game content using our template system instead of Gemini AI
    Map<String, dynamic>? gameContent;
    try {
      // Print exact subject and chapter names
      print('🔍 EXACT Subject Name: "${subject.name}"');
      print('🔍 EXACT Chapter Name: "${chapter.name}"');
      
      // Use our GameTemplateManager to get content from templates
      final templateManager = GameTemplateManager();
      gameContent = await templateManager.getContentForSubjectAndChapter(
        templateType: gameType,
        subjectName: subject.name,
        chapterName: chapter.name,
        ageGroup: subject.moduleId,
      );
      
      print('🔍 ContentManagementScreen: Game content received:');
      if (gameContent != null) {
        print('📦 Content keys: ${gameContent.keys.toList()}');
        if (gameContent.containsKey('pairs')) {
          print('✅ Found pairs: ${(gameContent['pairs'] as List).length} items');
        } else {
          print('❌ No pairs found in content');
        }
      } else {
        print('❌ Game content is null');
      }
    } catch (e) {
      print('Error generating game content: $e');
    }
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
    }
    
    setState(() {
      _isGeneratingContent = false;
    });
    
    if (!context.mounted) return;
    
    // Determine which game widget to show based on the game type
    Widget gameWidget;
    Color appBarColor;
    
    switch (gameType) {
      case 'matching':
        appBarColor = Colors.blue;
        gameWidget = MatchingGame(
          chapterName: chapter.name, 
          gameContent: gameContent,
          userId: 'admin',
          userName: 'Administrator',
          subjectId: subject.id,
          subjectName: subject.name,
          chapterId: chapter.id,
          ageGroup: subject.moduleId,
        );
        break;

      // Removed counting and puzzle cases as these templates are no longer supported
      case 'tracing':
        appBarColor = Colors.green;
        gameWidget = TracingGame(chapterName: chapter.name, gameContent: gameContent);
        break;
      case 'sorting':
        appBarColor = Colors.purple;
        gameWidget = SortingGame(chapterName: chapter.name, gameContent: gameContent);
        break;
      case 'shape_color':
        appBarColor = Colors.orange;
        gameWidget = ShapeColorGame(
          chapterName: chapter.name, 
          gameContent: gameContent,
          userId: 'admin',
          userName: 'Administrator',
          subjectId: subject.id,
          subjectName: subject.name,
          chapterId: chapter.id,
          ageGroup: subject.moduleId,
        );
        break;
      default:
        appBarColor = Colors.purple;
        gameWidget = const Center(child: Text('Game not available'));
    }
    
    // Show game preview with a simple scaffold (no admin navigation)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Preview: ${chapter.name}'),
            backgroundColor: appBarColor,
            automaticallyImplyLeading: false,
            actions: [
              // Enhanced Publish button
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.publish, color: Colors.white),
                  label: const Text('PUBLISH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    // Show publish confirmation dialog
                    _showPublishConfirmationDialog(subject, chapter, gameType, gameContent);
                  },
                ),
              ),
            ],
          ),
          body: gameWidget,
        ),
      ),
    );
  }
  
  // Method to publish a game to Firestore
  Future<void> _publishGame(Subject subject, Chapter chapter, String gameType, Map<String, dynamic>? gameContent) async {
    // Create game assets based on the game type and content
    List<GameAsset> assets = [];
    
    // Process different game types to create appropriate assets
    if (gameType == 'matching' && gameContent != null && gameContent['pairs'] != null) {
      final pairs = gameContent['pairs'] as List;
      for (var pair in pairs) {
        // Create an asset for each pair
        assets.add(GameAsset(
          imageUrl: pair['emoji'], // Using emoji as the image URL for now
          answer: pair['word'],
          question: 'Match with the correct word',
        ));
      }
    } else if (gameType == 'counting' && gameContent != null && gameContent['challenges'] != null) {
      final challenges = gameContent['challenges'] as List;
      for (var challenge in challenges) {
        assets.add(GameAsset(
          imageUrl: challenge['emoji'],
          answer: challenge['count'].toString(),
          question: challenge['question'],
        ));
      }
    }
    
    // Check if chapter already has a game
    String gameId;
    if (chapter.gameId != null) {
      // Update existing game
      gameId = chapter.gameId!;
    } else {
      // Create new game ID
      gameId = FirebaseFirestore.instance.collection('games').doc().id;
    }
    
    // Create a new game object
    final game = Game(
      id: gameId,
      title: gameContent?['title'] ?? '$gameType Game: ${chapter.name}',
      description: gameContent?['instructions'] ?? 'A fun educational game for children',
      type: gameType,
      assets: assets,
      ageGroup: subject.moduleId, // Using the subject's module ID as the age group
    );
    
    // Save the game to Firestore
    await _contentService.saveGame(game);
    
    // Associate the game with the chapter
    await _contentService.associateGameWithChapter(subject.id, chapter.id, game.id, gameType);
    
    // No SnackBar here - we'll handle success messages in the calling method
    // This allows the progress dialog to be closed properly before showing success messages
  }
  
  // Method to edit a published game
  void _editPublishedGame(Subject subject, Chapter chapter) {
    if (chapter.gameId != null && chapter.gameType != null) {
      // Launch the game preview with the existing game type
      _launchGamePreview(subject, chapter, chapter.gameType!);
    }
  }
  
  // Method to show delete game confirmation dialog
  void _showDeleteGameDialog(BuildContext context, Subject subject, Chapter chapter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game'),
        content: Text('Are you sure you want to delete the ${_getGameName(chapter.gameType!)} game for ${chapter.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePublishedGame(subject, chapter);
            },
            child: const Text('DELETE'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
  
  // Method to delete a published game
  Future<void> _deletePublishedGame(Subject subject, Chapter chapter) async {
    try {
      if (chapter.gameId != null) {
        await _contentService.removeGameFromChapter(subject.id, chapter.id);
        
        // Refresh the UI
        setState(() {});
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Game deleted successfully')),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting game: $e')),
      );
    }
  }
  
  // Method to show an enhanced publish confirmation dialog
  void _showPublishConfirmationDialog(Subject subject, Chapter chapter, String gameType, Map<String, dynamic>? gameContent) {
    final bool isUpdate = chapter.gameId != null;
    final String gameTitle = gameContent?['title'] ?? '$gameType Game: ${chapter.name}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.publish, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            Text(isUpdate ? 'Update Game' : 'Publish Game'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getGameIcon(gameType), color: _getGameColor(gameType)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          gameTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${_getGameName(gameType)}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  Text(
                    'Subject: ${subject.name}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  Text(
                    'Chapter: ${chapter.name}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  Text(
                    'Age Group: ${subject.moduleId}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Publishing info
            Text(
              isUpdate 
                ? 'You are about to update the existing game for this chapter. This will replace the current game content.'
                : 'You are about to publish this game to the child module. Once published, children will be able to play this game.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Games are automatically tailored to the child\'s age and learning level.',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
          ),
          
          // Publish button
          ElevatedButton.icon(
            icon: Icon(isUpdate ? Icons.update : Icons.publish),
            label: Text(isUpdate ? 'UPDATE' : 'PUBLISH'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUpdate ? Colors.blue : Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context); // Close the confirmation dialog
            
              try {
                // Show a simple snackbar to indicate publishing is in progress
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Publishing game...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                // Publish the game
                await _publishGame(subject, chapter, gameType, gameContent);
                
                if (context.mounted) {
                  // Close all screens and return to content management
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  
                  // Refresh the UI to show updated list
                  setState(() {});
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${_getGameName(gameType)} game published successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error publishing game: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
  
  // Method to show publishing progress dialog with linear progress bar
  void _showPublishingProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Publishing Game',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Linear progress bar
            Container(
              width: 250,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const LinearProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 10,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Please wait while we publish your game...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  // Method to show publish success dialog
  void _showPublishSuccessDialog(Subject subject, Chapter chapter, String gameType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            const Text('Game Published!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The ${_getGameName(gameType)} game for ${chapter.name} has been successfully published to the child module.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: const Text(
                      'Children can now access this game from the learning module.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('OK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  // Format timestamp for display
  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  // Preview published note method removed as requested
  
  // Edit published note
  void _editPublishedNote(Subject subject, Chapter chapter) async {
    try {
      // Get the published note
      final publishedNote = await _contentService.getNoteForChapter(subject.id, chapter.id);
      
      if (publishedNote == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No published note found')),
        );
        return;
      }
      
      // Navigate to note template selection screen to create a new note
      // The existing note will be replaced when the new one is published
      _showAddNoteDialog(context, subject, chapter);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error editing note: $e')),
      );
    }
  }
  
  // Show delete note confirmation dialog
  void _showDeleteNoteDialog(BuildContext context, Subject subject, Chapter chapter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: Text(
          'Are you sure you want to delete the note for ${chapter.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePublishedNote(subject, chapter);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  // Delete published note
  Future<void> _deletePublishedNote(Subject subject, Chapter chapter) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Deleting note...'),
            ],
          ),
        ),
      );
      
      // Delete the note
      await _contentService.deleteNoteFromChapter(subject.id, chapter.id);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh the UI
        setState(() {});
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting note: $e')),
        );
      }
    }
  }
}
