import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/game_template_manager.dart';
import '../../../game_template/matching_game.dart';
import '../../../game_template/sorting_game.dart';
import '../../../game_template/tracing_game.dart';
import '../../../game_template/shape_color_game.dart';
import '../../../services/database_service.dart';
import '../../../services/score_service.dart';

class GameTemplatePreviewScreen extends StatefulWidget {
  final GameTemplateInfo templateInfo;
  final Map<String, dynamic> gameContent;
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final String chapterName;
  final int ageGroup;
  
  const GameTemplatePreviewScreen({
    Key? key,
    required this.templateInfo,
    required this.gameContent,
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.chapterName,
    required this.ageGroup,
  }) : super(key: key);

  @override
  _GameTemplatePreviewScreenState createState() => _GameTemplatePreviewScreenState();
}

class _GameTemplatePreviewScreenState extends State<GameTemplatePreviewScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ScoreService _scoreService = ScoreService();
  bool _isPublishing = false;
  bool _isEditing = false;
  String _gameName = '';
  String _gameDescription = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _startTime = DateTime.now(); // Track when the preview started
  
  @override
  void initState() {
    super.initState();
    _gameName = 'Game: ${widget.chapterName}';
    _gameDescription = 'Interactive ${widget.templateInfo.name} for ${widget.ageGroup}-year-olds about ${widget.chapterName}';
    
    _nameController.text = _gameName;
    _descriptionController.text = _gameDescription;
    
    // Initialize start time for study minutes tracking
    _startTime = DateTime.now();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Save changes when exiting edit mode
        _gameName = _nameController.text;
        _gameDescription = _descriptionController.text;
      }
    });
  }
  
  Future<void> _publishGame() async {
    setState(() {
      _isPublishing = true;
    });
    
    try {
      // Calculate study minutes from start time
      final now = DateTime.now();
      final duration = now.difference(_startTime);
      final studyMinutes = (duration.inSeconds / 60).ceil(); // Round up to nearest minute
      
      // For games, we can calculate a score based on template type
      // This is a placeholder - in a real app, you'd get this from game completion
      int score = 85; // Default score for games
      int stars = 4;  // Default stars for games
      
      // Create game document in database
      final gameData = {
        'name': _gameName,
        'description': _gameDescription,
        'templateType': widget.templateInfo.id,
        'subjectId': widget.subjectId,
        'subjectName': widget.subjectName,
        'chapterId': widget.chapterId,
        'chapterName': widget.chapterName,
        'ageGroup': widget.ageGroup,
        'content': jsonEncode(widget.gameContent),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'score': score, // Add score field for consistency with notes
        'stars': stars, // Add stars field for consistency with notes
        'type': 'game', // Specify that this is a game for the child module
        'completionStatus': 'completed', // Mark as completed
        'studyMinutes': studyMinutes, // Add study time tracking
      };
      
      // Save to database
      final gameId = await _databaseService.addGame(gameData);
      
      // Record the score in the scores collection for leaderboard functionality
      try {
        // Get current user ID
        String userId = FirebaseAuth.instance.currentUser?.uid ?? 'default_user';
        String userName = FirebaseAuth.instance.currentUser?.displayName ?? 'Default User';
        
        // Add score entry
        await _scoreService.addScore(
          userId: userId,
          userName: userName,
          subjectId: widget.subjectId,
          subjectName: widget.subjectName,
          activityId: gameId,
          activityType: 'game',
          activityName: _gameName,
          points: score,
          ageGroup: widget.ageGroup,
        );
        
        print('Score recorded successfully for game: $_gameName');
      } catch (scoreError) {
        print('Error recording score: $scoreError');
        // Continue with the publishing process even if score recording fails
      }
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game published successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to previous screen
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error publishing game: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }
  
  Widget _buildGamePreview() {
    // Create a temporary user ID and name for preview
    const String previewUserId = 'preview_user';
    const String previewUserName = 'Preview User';
    
    switch (widget.templateInfo.id) {
      case 'matching':
        return MatchingGame(
          chapterName: widget.chapterName,
          gameContent: widget.gameContent,
          userId: previewUserId,
          userName: previewUserName,
          subjectId: widget.subjectId,
          subjectName: widget.subjectName,
          chapterId: widget.chapterId,
          ageGroup: widget.ageGroup,
        );
        
      case 'sorting':
        return SortingGame(
          chapterName: widget.chapterName,
          gameContent: widget.gameContent,
          userId: previewUserId,
          userName: previewUserName,
          subjectId: widget.subjectId,
          subjectName: widget.subjectName,
          chapterId: widget.chapterId,
          ageGroup: widget.ageGroup,
        );
        
      case 'shape_color':
        return ShapeColorGame(
          chapterName: widget.chapterName,
          gameContent: widget.gameContent,
          userId: previewUserId,
          userName: previewUserName,
          subjectId: widget.subjectId,
          subjectName: widget.subjectName,
          chapterId: widget.chapterId,
          ageGroup: widget.ageGroup,
        );
        
      case 'tracing':
        return TracingGame(
          chapterName: widget.chapterName,
          gameContent: widget.gameContent,
          userId: previewUserId,
          userName: previewUserName,
          subjectId: widget.subjectId,
          subjectName: widget.subjectName,
          chapterId: widget.chapterId,
          ageGroup: widget.ageGroup,
        );
        
      default:
        return Center(
          child: Text(
            'Preview not available for ${widget.templateInfo.name}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.red,
            ),
          ),
        );
    }
  }
  
  Widget _buildContentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Content Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.templateInfo.color,
            ),
          ),
          const Divider(),
          _buildContentDetails(),
        ],
      ),
    );
  }
  
  Widget _buildContentDetails() {
    // Extract and display relevant content based on template type
    switch (widget.templateInfo.id) {
      case 'matching':
        final pairs = widget.gameContent['pairs'] as List?;
        if (pairs == null || pairs.isEmpty) {
          return const Text('No matching pairs available');
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${pairs.length} matching pairs'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                min(5, pairs.length),
                (index) => Chip(
                  label: Text('${pairs[index]['word']} ${pairs[index]['emoji']}'),
                  backgroundColor: widget.templateInfo.color.withOpacity(0.1),
                ),
              ),
            ),
            if (pairs.length > 5)
              Text('... and ${pairs.length - 5} more pairs'),
          ],
        );
        
      case 'picture_recognition':
        final items = widget.gameContent['items'] as List?;
        if (items == null || items.isEmpty) {
          return const Text('No items available');
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${items.length} recognition items'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                min(5, items.length),
                (index) => Chip(
                  label: Text('${items[index]['name']} ${items[index]['emoji']}'),
                  backgroundColor: widget.templateInfo.color.withOpacity(0.1),
                ),
              ),
            ),
            if (items.length > 5)
              Text('... and ${items.length - 5} more items'),
          ],
        );
        
      case 'shape_color':
        final shapes = widget.gameContent['shapes'] as List?;
        if (shapes == null || shapes.isEmpty) {
          return const Text('No shapes available');
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${shapes.length} shape items'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                min(5, shapes.length),
                (index) => Chip(
                  label: Text('${shapes[index]['name']}'),
                  backgroundColor: _getColorFromString(shapes[index]['color']).withOpacity(0.3),
                ),
              ),
            ),
            if (shapes.length > 5)
              Text('... and ${shapes.length - 5} more shapes'),
          ],
        );
        
      case 'animal_sounds':
        final animals = widget.gameContent['animals'] as List?;
        if (animals == null || animals.isEmpty) {
          return const Text('No animals available');
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${animals.length} animal sounds'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                min(5, animals.length),
                (index) => Chip(
                  label: Text('${animals[index]['name']} ${animals[index]['emoji']}'),
                  backgroundColor: widget.templateInfo.color.withOpacity(0.1),
                ),
              ),
            ),
            if (animals.length > 5)
              Text('... and ${animals.length - 5} more animals'),
          ],
        );
        
      default:
        return const Text('Content summary not available');
    }
  }
  
  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'pink': return Colors.pink;
      case 'teal': return Colors.teal;
      case 'brown': return Colors.brown;
      case 'indigo': return Colors.indigo;
      default: return Colors.grey;
    }
  }
  
  int min(int a, int b) => a < b ? a : b;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview ${widget.templateInfo.name}'),
        backgroundColor: widget.templateInfo.color,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditing ? 'Save changes' : 'Edit game details',
          ),
        ],
      ),
      body: Column(
        children: [
          // Game details section
          Container(
            padding: const EdgeInsets.all(16),
            color: widget.templateInfo.color.withOpacity(0.1),
            child: _isEditing
                ? _buildEditForm()
                : _buildGameDetails(),
          ),
          
          // Content summary
          if (!_isEditing)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildContentSummary(),
            ),
          
          // Game preview
          Expanded(
            child: _isEditing
                ? Center(
                    child: Text(
                      'Finish editing to see the game preview',
                      style: TextStyle(
                        fontSize: 18,
                        color: widget.templateInfo.color,
                      ),
                    ),
                  )
                : _buildGamePreview(),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isPublishing || _isEditing ? null : _publishGame,
                  icon: _isPublishing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.publish),
                  label: Text(_isPublishing ? 'Publishing...' : 'Publish Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.templateInfo.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              widget.templateInfo.icon,
              size: 32,
              color: widget.templateInfo.color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _gameName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _gameDescription,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.school,
              size: 18,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Subject: ${widget.subjectName}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.book,
              size: 18,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Chapter: ${widget.chapterName}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.child_care,
              size: 18,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Age Group: ${widget.ageGroup} years',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Game Name:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Enter game name',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Game Description:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Enter game description',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Note: Game content is automatically generated based on subject, chapter, and age group.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
