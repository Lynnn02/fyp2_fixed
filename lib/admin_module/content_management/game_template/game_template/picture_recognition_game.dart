import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../../../../services/score_service.dart';

class PictureRecognitionGame extends StatefulWidget {
  final String chapterName;
  final Map<String, dynamic>? gameContent;
  final String userId;
  final String userName;
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final int ageGroup;
  
  const PictureRecognitionGame({
    Key? key,
    required this.chapterName,
    this.gameContent,
    required this.userId,
    required this.userName,
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.ageGroup,
  }) : super(key: key);

  @override
  _PictureRecognitionGameState createState() => _PictureRecognitionGameState();
}

class _PictureRecognitionGameState extends State<PictureRecognitionGame> with SingleTickerProviderStateMixin {
  // Game state
  late List<GameItem> _items;
  late GameItem _currentItem;
  int _score = 0;
  int _round = 0;
  int _totalRounds = 5; // Shorter game for young children
  bool _isGameOver = false;
  bool _scoreSubmitted = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  // Audio players
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _incorrectPlayer = AudioPlayer();
  final AudioPlayer _completionPlayer = AudioPlayer();
  final AudioPlayer _itemSoundPlayer = AudioPlayer();
  
  // Score service
  final ScoreService _scoreService = ScoreService();
  
  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initAudio();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }
  
  void _initAudio() async {
    await _correctPlayer.setSource(AssetSource('sounds/success.mp3'));
    await _incorrectPlayer.setSource(AssetSource('sounds/error.mp3'));
    await _completionPlayer.setSource(AssetSource('sounds/completion.mp3'));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _correctPlayer.dispose();
    _incorrectPlayer.dispose();
    _completionPlayer.dispose();
    _itemSoundPlayer.dispose();
    super.dispose();
  }
  
  void _initializeGame() {
    // Create game items
    _items = [];
    
    // Check if we have dynamic content
    if (widget.gameContent != null && widget.gameContent!['items'] != null) {
      // Use dynamic content
      final dynamicItems = widget.gameContent!['items'] as List;
      
      for (var item in dynamicItems) {
        _items.add(GameItem(
          name: item['name'],
          emoji: item['emoji'],
          soundUrl: item['soundUrl'] ?? '',
          options: (item['options'] as List).cast<String>(),
        ));
      }
    } else {
      // Use default content as fallback - simple items for 4-year-olds
      _items = [
        GameItem(
          name: 'Dog',
          emoji: '🐶',
          soundUrl: 'sounds/dog.mp3',
          options: ['Dog', 'Cat', 'Bird'],
        ),
        GameItem(
          name: 'Cat',
          emoji: '🐱',
          soundUrl: 'sounds/cat.mp3',
          options: ['Cat', 'Dog', 'Fish'],
        ),
        GameItem(
          name: 'Apple',
          emoji: '🍎',
          soundUrl: 'sounds/apple.mp3',
          options: ['Apple', 'Banana', 'Orange'],
        ),
        GameItem(
          name: 'Banana',
          emoji: '🍌',
          soundUrl: 'sounds/banana.mp3',
          options: ['Banana', 'Apple', 'Grapes'],
        ),
        GameItem(
          name: 'Star',
          emoji: '⭐',
          soundUrl: 'sounds/star.mp3',
          options: ['Star', 'Moon', 'Sun'],
        ),
      ];
    }
    
    // Shuffle items
    _items.shuffle();
    
    // Set first item
    _nextItem();
  }
  
  void _nextItem() {
    if (_round >= _totalRounds || _items.isEmpty) {
      _endGame();
      return;
    }
    
    setState(() {
      _currentItem = _items[_round % _items.length];
      _showFeedback = false;
    });
    
    // Play sound if available
    if (_currentItem.soundUrl.isNotEmpty) {
      _itemSoundPlayer.setSource(AssetSource(_currentItem.soundUrl));
      _itemSoundPlayer.resume();
    }
    
    _round++;
  }
  
  void _checkAnswer(String answer) {
    bool isCorrect = answer == _currentItem.name;
    
    setState(() {
      _isCorrect = isCorrect;
      _showFeedback = true;
      
      if (isCorrect) {
        _score += 10;
        _correctPlayer.resume();
        _animationController.forward();
      } else {
        _incorrectPlayer.resume();
      }
    });
    
    // Wait before moving to next item
    Timer(const Duration(milliseconds: 1500), () {
      if (_round < _totalRounds) {
        _nextItem();
      } else {
        _endGame();
      }
    });
  }
  
  void _endGame() {
    setState(() {
      _isGameOver = true;
    });
    
    _completionPlayer.resume();
    
    if (!_scoreSubmitted) {
      _submitScore();
    }
  }
  
  void _submitScore() {
    // Calculate final score
    final int finalScore = _score;
    
    // Submit score to the score service
    _scoreService.addScore(
      userId: widget.userId,
      userName: widget.userName,
      subjectId: widget.subjectId,
      subjectName: widget.subjectName,
      activityId: widget.chapterId,
      activityType: 'game',
      activityName: '${widget.chapterName} Picture Recognition Game',
      points: finalScore,
      ageGroup: widget.ageGroup,
    );
    
    setState(() {
      _scoreSubmitted = true;
    });
    
    // Show a snackbar to inform the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great job! You earned $finalScore points!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _restartGame() {
    setState(() {
      _score = 0;
      _round = 0;
      _isGameOver = false;
      _scoreSubmitted = false;
      _showFeedback = false;
    });
    
    _items.shuffle();
    _nextItem();
  }
  
  void _playItemSound() {
    if (_currentItem.soundUrl.isNotEmpty) {
      _itemSoundPlayer.setSource(AssetSource(_currentItem.soundUrl));
      _itemSoundPlayer.resume();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Picture Game: ${widget.chapterName}'),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Score: $_score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade300, Colors.purple.shade100],
          ),
        ),
        child: SafeArea(
          child: _isGameOver ? _buildGameOverScreen() : _buildGameScreen(),
        ),
      ),
    );
  }
  
  Widget _buildGameScreen() {
    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: LinearProgressIndicator(
            value: _round / _totalRounds,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        
        // Game content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Question
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'What is this?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Emoji/Image
                      GestureDetector(
                        onTap: _playItemSound,
                        child: AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _showFeedback && _isCorrect ? _scaleAnimation.value : 1.0,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                              border: Border.all(
                                color: _showFeedback
                                    ? (_isCorrect ? Colors.green : Colors.red)
                                    : Colors.purple,
                                width: 4,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _currentItem.emoji,
                                style: const TextStyle(
                                  fontSize: 80,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Sound button
                      ElevatedButton.icon(
                        onPressed: _playItemSound,
                        icon: const Icon(Icons.volume_up),
                        label: const Text('Listen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      
                      // Feedback
                      if (_showFeedback)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _isCorrect ? 'Correct! 🎉' : 'Try again! 💪',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Answer options
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: _currentItem.options.map((option) {
                    return ElevatedButton(
                      onPressed: _showFeedback ? null : () => _checkAnswer(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(option),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGameOverScreen() {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 Game Over! 🎉',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score: $_score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Great job! You\'re amazing!',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _restartGame,
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GameItem {
  final String name;
  final String emoji;
  final String soundUrl;
  final List<String> options;
  
  GameItem({
    required this.name,
    required this.emoji,
    required this.soundUrl,
    required this.options,
  });
}
