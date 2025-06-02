import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class SortingGame extends StatefulWidget {
  final String chapterName;
  final Map<String, dynamic>? gameContent;
  
  const SortingGame({
    Key? key,
    required this.chapterName,
    this.gameContent,
  }) : super(key: key);

  @override
  _SortingGameState createState() => _SortingGameState();
}

class _SortingGameState extends State<SortingGame> {
  late List<SortingCategory> categories = [];
  late List<SortingItem> items = [];
  late List<SortingItem> remainingItems = [];
  late int score = 0;
  late bool isGameOver = false;
  late int totalItems = 0;
  late int correctItems = 0;
  
  // Animation controllers
  bool _showFeedback = false;
  String _feedbackText = '';
  Color _feedbackColor = Colors.black;
  
  // Audio players
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _incorrectPlayer = AudioPlayer();
  final AudioPlayer _completionPlayer = AudioPlayer();
  
  @override
  void initState() {
    super.initState();
    _initAudio();
    _initializeGame();
  }
  
  void _initAudio() async {
    await _correctPlayer.setSource(AssetSource('sounds/success.mp3'));
    await _incorrectPlayer.setSource(AssetSource('sounds/error.mp3'));
    await _completionPlayer.setSource(AssetSource('sounds/completion.mp3'));
  }
  
  void _initializeGame() {
    categories = [];
    items = [];
    
    // Check if we have dynamic content from Gemini
    if (widget.gameContent != null && 
        widget.gameContent!['categories'] != null &&
        widget.gameContent!['items'] != null) {
      
      // Load categories
      final dynamicCategories = widget.gameContent!['categories'] as List;
      for (var category in dynamicCategories) {
        categories.add(SortingCategory(
          name: category['name'],
          emoji: category['emoji'],
          color: _getColorFromName(category['color'] ?? 'blue'),
        ));
      }
      
      // Load items
      final dynamicItems = widget.gameContent!['items'] as List;
      for (var item in dynamicItems) {
        items.add(SortingItem(
          name: item['name'],
          emoji: item['emoji'],
          categoryName: item['category'],
        ));
      }
    } else {
      // Default categories if no content provided
      categories = [
        SortingCategory(name: 'Fruits', emoji: '🍎', color: Colors.red),
        SortingCategory(name: 'Animals', emoji: '🐶', color: Colors.blue),
      ];
      
      // Default items
      items = [
        SortingItem(name: 'Apple', emoji: '🍎', categoryName: 'Fruits'),
        SortingItem(name: 'Banana', emoji: '🍌', categoryName: 'Fruits'),
        SortingItem(name: 'Orange', emoji: '🍊', categoryName: 'Fruits'),
        SortingItem(name: 'Grapes', emoji: '🍇', categoryName: 'Fruits'),
        SortingItem(name: 'Dog', emoji: '🐶', categoryName: 'Animals'),
        SortingItem(name: 'Cat', emoji: '🐱', categoryName: 'Animals'),
        SortingItem(name: 'Elephant', emoji: '🐘', categoryName: 'Animals'),
        SortingItem(name: 'Fish', emoji: '🐠', categoryName: 'Animals'),
      ];
    }
    
    // Shuffle the items
    items.shuffle(Random());
    
    // Limit the number of items based on age (from subject module ID)
    int itemLimit = 8; // Default
    if (widget.gameContent != null && widget.gameContent!['ageGroup'] != null) {
      final ageGroup = widget.gameContent!['ageGroup'];
      itemLimit = ageGroup <= 4 ? 6 : ageGroup <= 5 ? 8 : 10;
    }
    
    if (items.length > itemLimit) {
      items = items.sublist(0, itemLimit);
    }
    
    // Initialize game state
    remainingItems = List.from(items);
    totalItems = items.length;
    correctItems = 0;
    score = 0;
    isGameOver = false;
  }
  
  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'pink': return Colors.pink;
      default: return Colors.blue;
    }
  }
  
  void _handleItemSorted(SortingItem item, SortingCategory category) {
    final isCorrect = item.categoryName == category.name;
    
    setState(() {
      // Remove item from remaining items
      remainingItems.removeWhere((i) => i.emoji == item.emoji);
      
      // Update score and show feedback
      if (isCorrect) {
        score += 10;
        correctItems++;
        _showFeedback = true;
        _feedbackText = 'Correct! +10 points';
        _feedbackColor = Colors.green;
        _correctPlayer.resume();
      } else {
        _showFeedback = true;
        _feedbackText = 'Oops! That\'s not right';
        _feedbackColor = Colors.red;
        _incorrectPlayer.resume();
      }
    });
    
    // Hide feedback after a delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showFeedback = false;
        });
      }
    });
    
    // Check if game is over
    if (remainingItems.isEmpty) {
      _endGame();
    }
  }
  
  void _endGame() {
    setState(() {
      isGameOver = true;
    });
    
    _completionPlayer.resume();
    
    // Show completion dialog after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      _showCompletionDialog();
    });
  }
  
  void _showCompletionDialog() {
    final percentage = (correctItems / totalItems * 100).round();
    final starCount = percentage >= 80 ? 5 : percentage >= 60 ? 4 : percentage >= 40 ? 3 : 2;
  
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
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
                  color: index < starCount ? Colors.amber : Colors.grey.shade300,
                );
              }),
            ),
            const SizedBox(height: 20),
            
            // Completion message
            Text(
              'You sorted $correctItems out of $totalItems items correctly!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 15),
            
            // Score display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Category emojis
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var category in categories)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 25),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Retry button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetGame();
                  },
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
                    Navigator.of(context).pop();
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
    );
  }
  
  void _resetGame() {
    setState(() {
      _initializeGame();
    });
  }
  
  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play', 
          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Goal:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Sort all items into their correct categories.'),
            const SizedBox(height: 12),
            const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('1. Drag each item to its matching category at the top.'),
            const Text('2. If you sort correctly, you will earn points!'),
            const Text('3. Try to sort all items correctly.'),
            const SizedBox(height: 12),
            const Text('Categories:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var category in categories)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Text(category.emoji, style: const TextStyle(fontSize: 30)),
                        Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
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
  void dispose() {
    _correctPlayer.dispose();
    _incorrectPlayer.dispose();
    _completionPlayer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Get custom title from gameContent if available
    String gameTitle = widget.gameContent != null && widget.gameContent!['title'] != null
        ? widget.gameContent!['title']
        : 'Sorting Game: ${widget.chapterName}';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(gameTitle),
        backgroundColor: Colors.purple,
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
            colors: [Colors.purple.shade100, Colors.purple.shade200],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Score and progress
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            'Score: $score',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.checklist, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Items: ${totalItems - remainingItems.length}/$totalItems',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Feedback message
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showFeedback ? 50 : 0,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: _feedbackColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: _feedbackColor),
                ),
                child: Center(
                  child: Text(
                    _feedbackText,
                    style: TextStyle(
                      color: _feedbackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              
              // Categories
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: categories.map((category) {
                    return DragTarget<SortingItem>(
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: category.color,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                category.emoji,
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: category.color,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      onWillAccept: (data) => true,
                      onAccept: (item) {
                        _handleItemSorted(item, category);
                      },
                    );
                  }).toList(),
                ),
              ),
              
              // Items to sort
              Expanded(
                child: isGameOver
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Game Over!',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _resetGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Play Again',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: remainingItems.length,
                          itemBuilder: (context, index) {
                            final item = remainingItems[index];
                            return Draggable<SortingItem>(
                              data: item,
                              feedback: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.emoji,
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    item.emoji,
                                    style: TextStyle(
                                      fontSize: 40,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.emoji,
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
              
              // Reset button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Game'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SortingCategory {
  final String name;
  final String emoji;
  final Color color;
  
  SortingCategory({
    required this.name,
    required this.emoji,
    required this.color,
  });
}

class SortingItem {
  final String name;
  final String emoji;
  final String categoryName;
  
  SortingItem({
    required this.name,
    required this.emoji,
    required this.categoryName,
  });
}
