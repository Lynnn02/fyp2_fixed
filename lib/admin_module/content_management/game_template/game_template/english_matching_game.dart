import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class EnglishMatchingGame extends StatefulWidget {
  final String chapterName;
  
  const EnglishMatchingGame({
    Key? key,
    required this.chapterName,
  }) : super(key: key);

  @override
  _EnglishMatchingGameState createState() => _EnglishMatchingGameState();
}

class _EnglishMatchingGameState extends State<EnglishMatchingGame> {
  late List<MatchingItem> items;
  late List<MatchingItem> selectedItems = [];
  late int score = 0;
  late int attempts = 0;
  late bool isGameOver = false;
  late Timer _timer;
  late int _secondsRemaining = 60; // 1 minute game
  
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
    // Create pairs of words and images
    final List<MatchingPair> pairs = [
      MatchingPair(word: 'Apple', imageAsset: 'assets/game/apple.png', emoji: '🍎'),
      MatchingPair(word: 'Banana', imageAsset: 'assets/game/banana.png', emoji: '🍌'),
      MatchingPair(word: 'Cat', imageAsset: 'assets/game/cat.png', emoji: '🐱'),
      MatchingPair(word: 'Dog', imageAsset: 'assets/game/dog.png', emoji: '🐶'),
      MatchingPair(word: 'Elephant', imageAsset: 'assets/game/elephant.png', emoji: '🐘'),
      MatchingPair(word: 'Fish', imageAsset: 'assets/game/fish.png', emoji: '🐠'),
    ];
    
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
      initializeGame();
      startTimer();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matching Game: ${widget.chapterName}'),
        backgroundColor: Colors.orange,
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
                          backgroundColor: Colors.orange,
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
                            color: isSelected ? Colors.orange.shade200 : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected ? Colors.orange : Colors.grey.shade300,
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
