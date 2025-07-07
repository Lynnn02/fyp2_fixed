import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../../services/score_service.dart';
import '../../models/score.dart';

class EnglishMatchingGame extends StatefulWidget {
  final String chapterName;
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final String userId;
  final String userName;
  final int ageGroup;
  final Map<String, dynamic>? gameContent; // Add gameContent parameter
  
  const EnglishMatchingGame({
    Key? key,
    required this.chapterName,
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.userId,
    required this.userName,
    required this.ageGroup,
    this.gameContent, // Make it optional for backward compatibility
  }) : super(key: key);

  @override
  _EnglishMatchingGameState createState() => _EnglishMatchingGameState();
}

class _EnglishMatchingGameState extends State<EnglishMatchingGame> {
  final ScoreService _scoreService = ScoreService();
  late List<MatchingItem> items;
  late List<MatchingItem> selectedItems = [];
  late int score = 0;
  late int attempts = 0;
  late bool isGameOver = false;
  late Timer _timer;
  late int _secondsRemaining = 60; // 1 minute game
  bool _scoreSubmitted = false;
  
  @override
  void initState() {
    super.initState();
    initializeGame();
    startTimer();
  }
  
  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          isGameOver = true;
          _submitScore();
        }
      });
    });
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  void initializeGame() {
    print('Initializing English matching game');
    
    // Create pairs of words and images
    List<MatchingPair> pairs = [];
    
    // Check if we have dynamic content from Firestore
    if (widget.gameContent != null) {
      print('Using dynamic gameContent: ${widget.gameContent!.keys.toList()}');
      
      // Check if the content has pairs array
      if (widget.gameContent!.containsKey('pairs') && widget.gameContent!['pairs'] is List) {
        final dynamicPairs = widget.gameContent!['pairs'] as List;
        print('Found ${dynamicPairs.length} pairs in game content');
        
        for (var pair in dynamicPairs) {
          if (pair is Map) {
            // Get word from most likely field names
            final word = pair['malay_word'] ?? pair['word'] ?? pair['text'] ?? '';
            final emoji = pair['emoji'] ?? pair['image'] ?? '❓';
            final description = pair['description'] ?? '';
            
            print('Adding dynamic pair: $word - $emoji');
            pairs.add(MatchingPair(
              word: word.toString(),
              imageAsset: '',  // We don't use assets with dynamic content
              emoji: emoji.toString(),
              description: description.toString(),
            ));
          }
        }
      } else {
        print('No pairs found in game content, using fallback');
      }
    }
    
    // Use default content if no dynamic content was found or processed
    if (pairs.isEmpty) {
      print('Using default matching pairs');
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
    for (var pair in pairs) {
      items.add(MatchingItem(
        id: items.length,
        content: pair.word,
        matchId: items.length + 1,
        type: ItemType.word,
      ));
      items.add(MatchingItem(
        id: items.length + 1,
        content: pair.emoji,
        matchId: items.length,
        type: ItemType.image,
      ));
    }
    
    // Shuffle the items
    items.shuffle(Random());
  }
  
  void checkMatch() {
    if (selectedItems.length == 2) {
      attempts++;
      
      if (selectedItems[0].matchId == selectedItems[1].id && 
          selectedItems[1].matchId == selectedItems[0].id) {
        // It's a match!
        setState(() {
          items.removeWhere((item) => item.id == selectedItems[0].id || item.id == selectedItems[1].id);
          selectedItems.clear();
          score += 10;
          
          // Check if game is over
          if (items.isEmpty) {
            _timer.cancel();
            isGameOver = true;
            _submitScore();
          }
        });
      } else {
        // Not a match
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            selectedItems.clear();
          });
        });
      }
    }
  }
  
  void selectItem(MatchingItem item) {
    if (selectedItems.length < 2 && !selectedItems.contains(item)) {
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
      selectedItems.clear();
      score = 0;
      attempts = 0;
      isGameOver = false;
      _secondsRemaining = 60;
      _scoreSubmitted = false;
      initializeGame();
      startTimer();
    });
  }
  
  // Submit score to the database
  Future<void> _submitScore() async {
    if (_scoreSubmitted) return; // Prevent duplicate submissions
    
    try {
      await _scoreService.addScore(
        userId: widget.userId,
        userName: widget.userName,
        subjectId: widget.subjectId,
        subjectName: widget.subjectName,
        activityId: widget.chapterId,
        activityType: 'game',
        activityName: 'Matching Game: ${widget.chapterName}',
        points: score,
        ageGroup: widget.ageGroup,
      );
      
      setState(() {
        _scoreSubmitted = true;
      });
      
      // Show a congratulations message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Congratulations! You earned $score points!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error submitting score: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matching Game: ${widget.chapterName}'),
        backgroundColor: Colors.blue,
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
                            color: Colors.blue,
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
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                      const Text(
                        'Game Over!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your Score: $score',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: restartGame,
                        icon: const Icon(Icons.replay),
                        label: const Text('Play Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                            color: isSelected ? Colors.blue.shade200 : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey.shade300,
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
  final String description;
  
  MatchingPair({
    required this.word,
    required this.imageAsset,
    required this.emoji,
    this.description = '',
  });
}

class MatchingItem {
  final int id;
  final String content;
  final int matchId;
  final ItemType type;
  
  MatchingItem({
    required this.id,
    required this.content,
    required this.matchId,
    required this.type,
  });
}

enum ItemType {
  word,
  image,
}
