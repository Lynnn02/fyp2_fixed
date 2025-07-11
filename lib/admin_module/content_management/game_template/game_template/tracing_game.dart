import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/game_completion_dialog.dart';

class TracingGame extends StatefulWidget {
  final String chapterName;
  final Map<String, dynamic>? gameContent;
  
  const TracingGame({
    Key? key,
    required this.chapterName,
    this.gameContent,
  }) : super(key: key);

  @override
  _TracingGameState createState() => _TracingGameState();
}

class _TracingGameState extends State<TracingGame> {
  late List<TracingItem> tracingItems = [];
  late int currentItemIndex = 0;
  late bool isCompleted = false;
  
  // Drawing variables
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _isDrawing = false;
  
  // Progress tracking
  late int _totalPoints = 0;
  late int _pointsEarned = 0;
  late double _progressPercent = 0.0;
  late String _userId = '';
  late String _subject = '';
  late int _studyMinutes = 0;
  late DateTime _startTime;
  
  // Audio players
  final AudioPlayer _successPlayer = AudioPlayer();
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _completionPlayer = AudioPlayer();
  
  @override
  void initState() {
    super.initState();
    _initAudio();
    _initializeGame();
    _startTracking();
  }
  
  void _startTracking() {
    // Get current user ID
    final currentUser = FirebaseAuth.instance.currentUser;
    _userId = currentUser?.uid ?? 'anonymous';
    
    // Set subject based on chapter name
    _subject = widget.chapterName;
    
    // Record start time for study minutes calculation
    _startTime = DateTime.now();
  }
  
  void _initAudio() async {
    await _successPlayer.setSource(AssetSource('sounds/success.mp3'));
    await _clickPlayer.setSource(AssetSource('sounds/click.mp3'));
    await _completionPlayer.setSource(AssetSource('sounds/completion.mp3'));
  }
  
  void _initializeGame() {
    tracingItems = [];
    
    // Check if we have dynamic content from Gemini
    if (widget.gameContent != null && widget.gameContent!['items'] != null) {
      final items = widget.gameContent!['items'] as List;
      final bool isJawiOrArabic = _isJawiOrArabicContent(widget.gameContent!);
      
      for (var item in items) {
        if (isJawiOrArabic) {
          // Handle Jawi/Arabic content format
          tracingItems.add(TracingItem(
            character: item['character'] ?? 'ا',
            emoji: item['emoji'] ?? '🔤',
            word: item['example'] ?? item['name'] ?? 'Jawi',  // Use example or name as the word
            difficulty: item['difficulty'] ?? 1,
            name: item['name'],       // Arabic/Jawi letter name (e.g., "Alif")
            sound: item['sound'],     // Romanized sound (e.g., "A")
            example: item['example'], // Example word
          ));
        } else {
          // Handle standard content format
          // Check if this is Bahasa Malaysia content and use malay_word if available
          final bool isBahasaMalaysia = widget.gameContent != null && 
              widget.gameContent!['title'] != null && 
              widget.gameContent!['title'].toString().toLowerCase().contains('bahasa malaysia');
          
          tracingItems.add(TracingItem(
            character: item['character'] ?? 'A',
            emoji: item['emoji'] ?? '🍎',
            word: isBahasaMalaysia && item['malay_word'] != null 
                ? item['malay_word'] 
                : item['word'] ?? 'Apple',
            difficulty: item['difficulty'] ?? 1,
          ));
        }
      }
    } else {
      // Default tracing items if no content provided
      tracingItems = [
        TracingItem(character: 'A', emoji: '🍎', word: 'Apple', difficulty: 1),
        TracingItem(character: 'B', emoji: '🍌', word: 'Banana', difficulty: 1),
        TracingItem(character: 'C', emoji: '🐱', word: 'Cat', difficulty: 1),
        TracingItem(character: 'D', emoji: '🐶', word: 'Dog', difficulty: 1),
        TracingItem(character: 'E', emoji: '🐘', word: 'Elephant', difficulty: 2),
        TracingItem(character: 'F', emoji: '🐟', word: 'Fish', difficulty: 2),
      ];
    }
    
    // Shuffle the items for variety
    tracingItems.shuffle(Random());
    
    // Start with the first item
    currentItemIndex = 0;
    _totalPoints = tracingItems.length * 10; // 10 points per item
    _pointsEarned = 0;
    _updateProgress();
  }
  
  // Helper method to detect if content is Jawi/Arabic
  bool _isJawiOrArabicContent(Map<String, dynamic> content) {
    // Check if any of these flags are present
    if (content['arabicScript'] == true || 
        content['rightToLeft'] == true ||
        content['focusOnBasicLetters'] == true) {
      return true;
    }
    
    // Check title for Jawi/Arabic keywords
    final title = content['title'] as String? ?? '';
    if (title.toLowerCase().contains('jawi') || 
        title.toLowerCase().contains('arabic') || 
        title.toLowerCase().contains('iqra')) {
      return true;
    }
    
    // Check if items have name/sound fields which are typical for Jawi content
    if (content['items'] != null && content['items'] is List && (content['items'] as List).isNotEmpty) {
      final firstItem = (content['items'] as List).first;
      if (firstItem is Map && (firstItem['name'] != null || firstItem['sound'] != null)) {
        return true;
      }
    }
    
    return false;
  }
  
  // Helper method to check if a character is Arabic script
  bool _isArabicScript(String character) {
    if (character.isEmpty) return false;
    
    // Get the Unicode code point of the first character
    final codePoint = character.codeUnitAt(0);
    
    // Arabic Unicode range: 0x0600-0x06FF (Arabic)
    // or 0x0750-0x077F (Arabic Supplement)
    // or 0x08A0-0x08FF (Arabic Extended-A)
    // or 0xFB50-0xFDFF (Arabic Presentation Forms-A)
    // or 0xFE70-0xFEFF (Arabic Presentation Forms-B)
    return (codePoint >= 0x0600 && codePoint <= 0x06FF) ||
           (codePoint >= 0x0750 && codePoint <= 0x077F) ||
           (codePoint >= 0x08A0 && codePoint <= 0x08FF) ||
           (codePoint >= 0xFB50 && codePoint <= 0xFDFF) ||
           (codePoint >= 0xFE70 && codePoint <= 0xFEFF);
  }
  
  void _updateProgress() {
    setState(() {
      _progressPercent = _pointsEarned / _totalPoints;
    });
  }
  
  // This is now handled by the ActivityCompletionScreen
  
  void _handleDrawStart(Offset position) {
    setState(() {
      _isDrawing = true;
      _currentStroke = [position];
      _strokes.add(_currentStroke);
    });
  }
  
  void _handleDrawUpdate(Offset position) {
    if (!_isDrawing) return;
    
    setState(() {
      _currentStroke.add(position);
      // Update the last stroke in the list
      _strokes[_strokes.length - 1] = List.from(_currentStroke);
    });
  }
  
  void _handleDrawEnd() {
    setState(() {
      _isDrawing = false;
      
      // Check if enough of the character has been traced
      if (_strokes.isNotEmpty && _calculateCoverage() > 0.6) {
        _successPlayer.resume();
        _pointsEarned += 10;
        _updateProgress();
        
        // Progress is now saved by ActivityCompletionScreen
        
        // Move to next item with a short delay
        Future.delayed(const Duration(milliseconds: 800), () {
          _moveToNextItem();
        });
      }
    });
  }
  
  double _calculateCoverage() {
    // This is a simplified coverage calculation
    // In a real app, you would use more sophisticated algorithms
    // to check if the user has traced the character correctly
    
    // For simplicity, we'll just check the number of points drawn
    int totalPoints = 0;
    for (var stroke in _strokes) {
      totalPoints += stroke.length;
    }
    
    // Consider it covered if there are enough points
    // The threshold depends on the character complexity
    final currentItem = tracingItems[currentItemIndex];
    final requiredPoints = 50 * currentItem.difficulty;
    
    return totalPoints / requiredPoints;
  }
  
  void _moveToNextItem() {
    setState(() {
      // Clear strokes
      _strokes.clear();
      
      // Move to next item
      if (currentItemIndex < tracingItems.length - 1) {
        currentItemIndex++;
      } else {
        // Game completed
        isCompleted = true;
        _completionPlayer.resume();
        _showCompletionDialog();
      }
    });
  }
  
  void _showCompletionDialog() {
    _completionPlayer.resume();
    setState(() {
      isCompleted = true;
    });
    
    // Calculate study time in minutes
    final now = DateTime.now();
    final duration = now.difference(_startTime);
    _studyMinutes = (duration.inSeconds / 60).ceil(); // Round up to nearest minute
    
    // Calculate percentage for star rating
    final percentage = (_pointsEarned / _totalPoints * 100).round();
    final starCount = percentage >= 80 ? 5 : percentage >= 60 ? 4 : percentage >= 40 ? 3 : 2;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameCompletionDialog(
        points: _pointsEarned,
        stars: starCount,
        subject: widget.chapterName,
        minutes: _studyMinutes,
        onTryAgain: () {
          Navigator.of(context).pop();
          _resetGame();
        },
        onContinue: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop(); // Return to previous screen
        },
      ),
    );
  }
  
  void _resetGame() {
    setState(() {
      _strokes.clear();
      currentItemIndex = 0;
      isCompleted = false;
      _pointsEarned = 0;
      _progressPercent = 0.0;
      _initializeGame();
    });
  }
  
  void _showGuideDialog(BuildContext context) {
    // Get current tracing item
    final currentItem = tracingItems.isNotEmpty ? tracingItems[currentItemIndex] : null;
    
    // Check if this is a Bahasa Malaysia subject
    final bool isBahasaMalaysia = widget.gameContent != null && 
        widget.gameContent!['title'] != null && 
        widget.gameContent!['title'].toString().contains('Bahasa Malaysia');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isBahasaMalaysia ? 'Cara Bermain' : 'How to Play', 
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBahasaMalaysia ? 'Matlamat:' : 'Goal:', 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            Text(
              isBahasaMalaysia 
                ? 'Berlatih menulis huruf dengan menjejak di skrin.'
                : 'Practice writing letters by tracing them on the screen.'
            ),
            const SizedBox(height: 12),
            Text(
              isBahasaMalaysia ? 'Arahan:' : 'Instructions:', 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            Text(
              isBahasaMalaysia 
                ? '1. Gunakan jari anda untuk menjejak huruf kelabu.'
                : '1. Use your finger to trace over the gray letter.'
            ),
            Text(
              isBahasaMalaysia 
                ? '2. Cuba ikut bentuk huruf dengan teliti.'
                : '2. Try to follow the shape of the letter carefully.'
            ),
            Text(
              isBahasaMalaysia 
                ? '3. Apabila anda telah menjejak dengan cukup, anda akan beralih ke huruf seterusnya.'
                : '3. When you\'ve traced enough of the letter, you\'ll move to the next one.'
            ),
            const SizedBox(height: 12),
            if (currentItem != null) ...[  
              Text(
                isBahasaMalaysia ? 'Huruf Semasa: ${currentItem.character}' : 'Current Letter: ${currentItem.character}', 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(currentItem.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Text(currentItem.word, 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              isBahasaMalaysia ? 'Petua:' : 'Tips:', 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            Text(
              isBahasaMalaysia 
                ? '• Gunakan butang Padam untuk memulakan semula.'
                : '• Use the Clear button if you want to start over.'
            ),
            Text(
              isBahasaMalaysia 
                ? '• Gunakan butang Langkau untuk beralih ke huruf seterusnya.'
                : '• Use the Skip button to move to the next letter.'
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isBahasaMalaysia ? 'Faham!' : 'Got it!'),
          ),
        ],
      ),
    );
  }
  
  void _skipCurrentItem() {
    _clickPlayer.resume();
    _moveToNextItem();
  }
  
  @override
  void dispose() {
    _successPlayer.dispose();
    _clickPlayer.dispose();
    _completionPlayer.dispose();
    
    // Progress tracking is now handled by ActivityCompletionScreen
    // No need to save progress here anymore
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Get custom title from gameContent if available
    String gameTitle = widget.gameContent != null && widget.gameContent!["title"] != null
        ? widget.gameContent!["title"]
        : 'Tracing Game: ${widget.chapterName}';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(gameTitle),
        backgroundColor: Colors.green,
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showGuideDialog(context),
            tooltip: 'How to Play',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade100, Colors.green.shade200],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          // Use Malay text for Bahasa Malaysia subject
                          widget.gameContent != null && 
                              widget.gameContent!['title'] != null && 
                              widget.gameContent!['title'].toString().contains('Bahasa Malaysia')
                              ? 'Kemajuan: ${(_progressPercent * 100).toInt()}%'
                              : 'Progress: ${(_progressPercent * 100).toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.gameContent != null && 
                              widget.gameContent!['title'] != null && 
                              widget.gameContent!['title'].toString().contains('Bahasa Malaysia')
                              ? 'Mata: $_pointsEarned / $_totalPoints'
                              : 'Points: $_pointsEarned / $_totalPoints',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _progressPercent,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
              
              // Current item info
              if (!isCompleted && tracingItems.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Emoji
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Center(
                          child: Text(
                            tracingItems[currentItemIndex].emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Word and instruction
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tracingItems[currentItemIndex].word,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Show different instruction text based on item type
                            if (tracingItems[currentItemIndex].name != null)
                              // For Jawi/Arabic letters
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Trace the letter "${tracingItems[currentItemIndex].character}"',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  if (tracingItems[currentItemIndex].name != null)
                                    Text(
                                      'Letter name: ${tracingItems[currentItemIndex].name}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  if (tracingItems[currentItemIndex].sound != null)
                                    Text(
                                      'Sound: ${tracingItems[currentItemIndex].sound}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              )
                            else
                              // For regular letters
                              Text(
                                // Use Malay instructions for Bahasa Malaysia subject
                                widget.gameContent != null && 
                                    widget.gameContent!['title'] != null && 
                                    widget.gameContent!['title'].toString().contains('Bahasa Malaysia')
                                    ? 'Jejak huruf "${tracingItems[currentItemIndex].character}"'
                                    : 'Trace the letter "${tracingItems[currentItemIndex].character}"',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Drawing area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background letter to trace
                      if (!isCompleted && tracingItems.isNotEmpty)
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Main character to trace
                              Text(
                                tracingItems[currentItemIndex].character,
                                style: TextStyle(
                                  fontSize: _isArabicScript(tracingItems[currentItemIndex].character) ? 250 : 200,
                                  color: Colors.grey.shade300,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: _isArabicScript(tracingItems[currentItemIndex].character) ? 'Arial' : null,
                                ),
                              ),
                              // Removed emoji watermark from opacity tracing part
                            ],
                          ),
                        ),
                      
                      // Drawing canvas
                      GestureDetector(
                        onPanStart: (details) {
                          _handleDrawStart(details.localPosition);
                        },
                        onPanUpdate: (details) {
                          _handleDrawUpdate(details.localPosition);
                        },
                        onPanEnd: (details) {
                          _handleDrawEnd();
                        },
                        child: CustomPaint(
                          painter: TracingPainter(strokes: _strokes),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      
                      // Completion overlay
                      if (isCompleted)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                // Use Malay text for Bahasa Malaysia subject
                                widget.gameContent != null && 
                                    widget.gameContent!['title'] != null && 
                                    widget.gameContent!['title'].toString().contains('Bahasa Malaysia')
                                    ? 'Selesai!'
                                    : 'All Done!',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _resetGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  // Use Malay text for Bahasa Malaysia subject
                                  widget.gameContent != null && 
                                      widget.gameContent!['title'] != null && 
                                      widget.gameContent!['title'].toString().contains('Bahasa Malaysia')
                                      ? 'Main Lagi'
                                      : 'Play Again',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Controls
              if (!isCompleted)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _strokes.clear();
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: Text(
                          // Use Malay text for Bahasa Malaysia subject
                          widget.gameContent != null && 
                              widget.gameContent!['title'] != null && 
                              widget.gameContent!['title'].toString().contains('Bahasa Malaysia')
                              ? 'Padam'
                              : 'Clear'
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _skipCurrentItem,
                        icon: const Icon(Icons.skip_next),
                        label: Text(
                          // Use Malay text for Bahasa Malaysia subject
                          widget.gameContent != null && 
                              widget.gameContent!['title'] != null && 
                              widget.gameContent!['title'].toString().contains('Bahasa Malaysia')
                              ? 'Langkau'
                              : 'Skip'
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TracingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  
  TracingPainter({required this.strokes});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    
    for (var stroke in strokes) {
      if (stroke.length < 2) continue;
      
      final path = Path();
      path.moveTo(stroke[0].dx, stroke[0].dy);
      
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(TracingPainter oldDelegate) => true;
}

class TracingItem {
  final String character;
  final String emoji;
  final String word;
  final int difficulty;
  final String? name;     // For Jawi/Arabic letters (e.g., "Alif")
  final String? sound;    // For Jawi/Arabic letters (e.g., "A")
  final String? example;  // For Jawi/Arabic letters (e.g., "Api")
  
  TracingItem({
    required this.character,
    required this.emoji,
    required this.word,
    required this.difficulty,
    this.name,
    this.sound,
    this.example,
  });
}
