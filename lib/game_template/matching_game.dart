import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../services/score_service.dart';
import '../widgets/activity_completion_screen.dart';

class MatchingGame extends StatefulWidget {
  final String chapterName;
  final Map<String, dynamic>? gameContent; // Add gameContent parameter
  final String userId;
  final String userName;
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final int ageGroup;
  
  const MatchingGame({
    Key? key,
    required this.chapterName,
    this.gameContent, // Optional parameter for dynamic content
    required this.userId,
    required this.userName,
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.ageGroup,
  }) : super(key: key);

  @override
  _MatchingGameState createState() => _MatchingGameState();
}

class _MatchingGameState extends State<MatchingGame> {
  late List<MatchingItem> items;
  late List<MatchingItem> selectedItems = [];
  late int score = 0;
  late int attempts = 0;
  late bool isGameOver = false;
  late Timer _timer;
  late int _secondsRemaining = 60; // 1 minute game
  late String _feedbackMessage = '';
  late Color _feedbackColor = Colors.black;
  
  // Score service
  final ScoreService _scoreService = ScoreService();
  bool _scoreSubmitted = false;
  
  // Audio players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();
  final AudioPlayer _completionPlayer = AudioPlayer();
  
  // Animation controllers
  bool _showStars = false;
  
  @override
  void initState() {
    super.initState();
    initializeGame();
    startTimer();
    _initAudio();
  }
  
  void _initAudio() async {
    await _clickPlayer.setSource(AssetSource('sounds/click.mp3'));
    await _successPlayer.setSource(AssetSource('sounds/success.mp3'));
    await _errorPlayer.setSource(AssetSource('sounds/error.mp3'));
    await _completionPlayer.setSource(AssetSource('sounds/completion.mp3'));
  }
  
  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          isGameOver = true;
        }
      });
    });
  }
  
  @override
  void dispose() {
    _timer.cancel();
    _clickPlayer.dispose();
    _successPlayer.dispose();
    _errorPlayer.dispose();
    _completionPlayer.dispose();
    super.dispose();
  }
  
  void initializeGame() {
    // Create pairs of words and images
    List<MatchingPair> pairs = [];
    
    // Check if we have dynamic content from Gemini
    if (widget.gameContent != null && widget.gameContent!['pairs'] != null) {
      // Use dynamic content from Gemini
      final dynamicPairs = widget.gameContent!['pairs'] as List;
      
      for (var pair in dynamicPairs) {
        pairs.add(MatchingPair(
          word: pair['word'],
          imageAsset: '', // We don't use image assets with dynamic content
          emoji: pair['emoji'],
        ));
      }
    } else {
      // Use default content as fallback
      pairs = [
        MatchingPair(word: 'Apple', imageAsset: 'assets/game/apple.png', emoji: '🍎'),
        MatchingPair(word: 'Banana', imageAsset: 'assets/game/banana.png', emoji: '🍌'),
        MatchingPair(word: 'Cat', imageAsset: 'assets/game/cat.png', emoji: '🐱'),
        MatchingPair(word: 'Dog', imageAsset: 'assets/game/dog.png', emoji: '🐶'),
        MatchingPair(word: 'Elephant', imageAsset: 'assets/game/elephant.png', emoji: '🐘'),
        MatchingPair(word: 'Fish', imageAsset: 'assets/game/fish.png', emoji: '🐠'),
      ];
    }
    
    // Create matching items
    items = [];
    int id = 0;
    for (var pair in pairs) {
      final wordId = id++;
      final imageId = id++;
      
      items.add(MatchingItem(
        id: wordId,
        content: pair.word,
        matchId: imageId,
        pairName: pair.word.toLowerCase(), // Use this for matching logic
        type: ItemType.word,
      ));
      
      items.add(MatchingItem(
        id: imageId,
        content: pair.emoji,
        matchId: wordId,
        pairName: pair.word.toLowerCase(), // Same pair name for matching
        type: ItemType.image,
      ));
    }
    
    // Shuffle the items
    items.shuffle(Random());
  }
  
  void checkMatch() {
    if (selectedItems.length == 2) {
      attempts++;
      
      // Check if the two selected items have the same pairName and are different types
      if (selectedItems[0].pairName == selectedItems[1].pairName && 
          selectedItems[0].type != selectedItems[1].type) {
        // It's a match!
        // Play success sound
        _successPlayer.resume();
        
        setState(() {
          _feedbackMessage = 'Correct Match! +10 points';
          _feedbackColor = Colors.green;
          items.removeWhere((item) => item.id == selectedItems[0].id || item.id == selectedItems[1].id);
          selectedItems.clear();
          score += 10;
          
          // Check if all pairs are matched
          if (items.every((item) => item.isMatched)) {
            _timer.cancel();
            isGameOver = true;
            _showStars = true;
            _completionPlayer.play(AssetSource('sounds/completion.mp3'));
            _feedbackMessage = 'Congratulations! You matched all pairs!';
            _feedbackColor = Colors.green;
            
            // Submit score if not already submitted
            if (!_scoreSubmitted) {
              _submitScore();
              _scoreSubmitted = true;
            }
          }
        });
        
        // Clear feedback message after 1.5 seconds
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _feedbackMessage = '';
            });
          }
        });
      } else {
        // Not a match
        // Play error sound
        _errorPlayer.resume();
        
        setState(() {
          _feedbackMessage = 'Wrong Match! Try again';
          _feedbackColor = Colors.red;
        });
        
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              selectedItems.clear();
              _feedbackMessage = '';
            });
          }
        });
      }
    }
  }
  
  void selectItem(MatchingItem item) {
    if (selectedItems.length < 2 && !selectedItems.contains(item)) {
      // Play click sound
      _clickPlayer.resume();
      
      setState(() {
        selectedItems.add(item);
      });
      
      if (selectedItems.length == 2) {
        checkMatch();
      }
    }
  }
  
  void restartGame() {
    setState(() {
      selectedItems = [];
      score = 0;
      attempts = 0;
      isGameOver = false;
      _secondsRemaining = 60;
      _feedbackMessage = '';
      _showStars = false;
      _scoreSubmitted = false;
      initializeGame();
    });
    startTimer();
  }
  
  // Submit score to the score service
  void _submitScore() {
    // Calculate final score based on time remaining and attempts
    final int timeBonus = _secondsRemaining * 2; // 2 points per second remaining
    final int attemptPenalty = attempts > items.length / 2 ? (attempts - items.length ~/ 2) * 5 : 0;
    final int finalScore = score + timeBonus - attemptPenalty;
    
    // Submit score to the score service
    _scoreService.addScore(
      userId: widget.userId,
      userName: widget.userName,
      subjectId: widget.subjectId,
      subjectName: widget.subjectName,
      activityId: widget.chapterId,
      activityType: 'game',
      activityName: '${widget.chapterName} Matching Game',
      points: finalScore,
      ageGroup: widget.ageGroup,
    );
    
    // Calculate study time (game duration)
    final int studyMinutes = (60 - _secondsRemaining) ~/ 60 + 1; // At least 1 minute
    
    // Show completion screen with animation and sound
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => ActivityCompletionScreen(
          activityType: 'game',
          activityName: '${widget.chapterName} Matching Game',
          subject: widget.subjectName,
          points: finalScore,
          studyMinutes: studyMinutes,
          userId: widget.userId,
          onContinue: () {
            Navigator.of(context).pop();
          },
          onRestart: () {
            Navigator.of(context).pop();
            restartGame();
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
  
  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play', 
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Goal:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Match all the words with their correct pictures.'),
            const SizedBox(height: 12),
            const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('1. Tap on a card to select it.'),
            const Text('2. Tap on another card to try to match it.'),
            const Text('3. If they match, you earn a point!'),
            const Text('4. Try to match all pairs before time runs out.'),
            const SizedBox(height: 12),
            const Text('Examples:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (items.isNotEmpty) ...[  
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < min(2, items.length ~/ 2); i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Text(
                            items[i * 2].type == ItemType.word 
                              ? items[i * 2].content 
                              : items[i * 2 + 1].content,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text('matches'),
                          Text(
                            items[i * 2].type == ItemType.image 
                              ? items[i * 2].content 
                              : items[i * 2 + 1].content,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Get custom title from gameContent if available
    String gameTitle = widget.gameContent != null && widget.gameContent!['title'] != null
        ? widget.gameContent!['title']
        : 'Matching Game: ${widget.chapterName}';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(gameTitle),
        backgroundColor: Colors.blue,
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showGuideDialog(context),
            tooltip: 'How to Play',
          ),
        ],
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/rainbow.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Feedback message
              if (_feedbackMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: _feedbackColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _feedbackColor),
                  ),
                  child: Text(
                    _feedbackMessage,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _feedbackColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Game stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          score.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _secondsRemaining.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _secondsRemaining < 10 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Attempts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          attempts.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Game over message
              if (isGameOver)
                Stack(
                  children: [
                    // Celebration stars
                    if (_showStars)
                      ...List.generate(20, (index) {
                        final random = Random();
                        final size = random.nextDouble() * 30 + 10;
                        final left = random.nextDouble() * MediaQuery.of(context).size.width;
                        final top = random.nextDouble() * 400;
                        final delay = random.nextInt(2000);
                        
                        return Positioned(
                          left: left,
                          top: top,
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(milliseconds: 1000 + delay),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Opacity(
                                  opacity: value,
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: size,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    
                    // Game over card
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Congratulations text with celebration icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.celebration, color: Colors.amber, size: 30),
                              const SizedBox(width: 10),
                              const Text(
                                'Congratulations!',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.celebration, color: Colors.amber, size: 30),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Star rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                size: 40,
                                color: Colors.amber,
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                          
                          // Score display
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              'Your Score: $score',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          // Attempts
                          Text(
                            'Attempts: $attempts',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 25),
                          
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Retry button
                              ElevatedButton.icon(
                                onPressed: restartGame,
                                icon: const Icon(Icons.replay),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              
                              // Finish button
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Return to previous screen
                                },
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Finish'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                // Game grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = selectedItems.contains(item);
                      
                      return GestureDetector(
                        onTap: () => selectItem(item),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.shade100 : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: Center(
                            child: isSelected || true
                                ? Text(
                                    item.content,
                                    style: TextStyle(
                                      fontSize: item.type == ItemType.image ? 40 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : const Icon(
                                    Icons.question_mark,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchingPair {
  final String word;
  final String imageAsset;
  final String emoji;
  
  MatchingPair({
    required this.word,
    required this.imageAsset,
    required this.emoji,
  });
}

class MatchingItem {
  final int id;
  final String content;
  final int matchId;
  final String pairName; // Added for reliable matching
  final ItemType type;
  bool isMatched = false;
  
  MatchingItem({
    required this.id,
    required this.content,
    required this.matchId,
    required this.pairName,
    required this.type,
  });
}

enum ItemType {
  word,
  image,
}
