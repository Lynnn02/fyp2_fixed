import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'widgets/game_completion_dialog.dart';

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
        _feedbackText = _isBahasaMalaysia() ? 'Betul! +10 mata' : 'Correct! +10 points';
        _feedbackColor = Colors.green;
        _correctPlayer.resume();
      } else {
        _showFeedback = true;
        _feedbackText = _isBahasaMalaysia() ? 'Cuba lagi!' : 'Try again!';
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
    _checkGameOver();
  }
  
  void _checkGameOver() {
    if (remainingItems.isEmpty) {
      setState(() {
        isGameOver = true;
      });
      
      _completionPlayer.resume();
      
      Future.delayed(const Duration(milliseconds: 500), () {
        _showCompletionDialog();
      });
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
      builder: (context) => GameCompletionDialog(
        points: score,
        stars: starCount,
        subject: widget.chapterName,
        minutes: 1,
        onTryAgain: () {
          Navigator.of(context).pop();
          setState(() {
            _initializeGame();
            isGameOver = false;
            score = 0;
            correctItems = 0;
          });
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
      _initializeGame();
    });
  }
  
  // Helper method to check if this is a Bahasa Malaysia subject
  bool _isBahasaMalaysia() {
    return widget.gameContent != null && 
        widget.gameContent!['title'] != null && 
        widget.gameContent!['title'].toString().contains('Bahasa Malaysia');
  }
  
  void _showGuideDialog(BuildContext context) {
    // Check if this is a Bahasa Malaysia subject
    final bool isMalay = _isBahasaMalaysia();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isMalay ? 'Cara Bermain' : 'How to Play', 
          style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMalay ? 'Matlamat:' : 'Goal:', 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            Text(
              isMalay 
                ? 'Susun semua item ke dalam kategori yang betul.'
                : 'Sort all items into their correct categories.'
            ),
            const SizedBox(height: 12),
            Text(
              isMalay ? 'Arahan:' : 'Instructions:', 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            Text(
              isMalay 
                ? '1. Seret setiap item ke kategori yang sepadan di bahagian atas.'
                : '1. Drag each item to its matching category at the top.'
            ),
            Text(
              isMalay 
                ? '2. Jika anda menyusun dengan betul, anda akan mendapat mata!'
                : '2. If you sort correctly, you will earn points!'
            ),
            Text(
              isMalay 
                ? '3. Cuba susun semua item dengan betul.'
                : '3. Try to sort all items correctly.'
            ),
            const SizedBox(height: 12),
            Text(
              isMalay ? 'Kategori:' : 'Categories:', 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            Text(
              isMalay 
                ? 'Setiap kategori ditunjukkan di bahagian atas skrin.'
                : 'Each category is shown at the top of the screen.'
            ),
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
            child: Text(isMalay ? 'Faham!' : 'Got it!'),
          ),
        ],
      ),
    );
  }
  
  // This duplicate method was removed to fix the compilation error

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
    
    // Get instructions text from game content or use default
    final String instructionsText = widget.gameContent?['instructions'] ?? 
        (_isBahasaMalaysia() ? 'Susun item ke dalam kategori yang betul.' : 'Sort items into the correct categories.');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameContent?['title'] ?? 'Sorting Game'),
        backgroundColor: Colors.purple,
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showGuideDialog(context),
            tooltip: _isBahasaMalaysia() ? 'Cara Bermain' : 'How to Play',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: _isBahasaMalaysia() ? 'Mulakan semula' : 'Reset',
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
                            _isBahasaMalaysia() ? 'Mata: $score' : 'Score: $score',
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
                            _isBahasaMalaysia() 
                              ? 'Item: ${totalItems - remainingItems.length}/$totalItems'
                              : 'Items: ${totalItems - remainingItems.length}/$totalItems',
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
                            Text(
                              _isBahasaMalaysia() ? 'Permainan Tamat!' : 'Game Over!',
                              style: const TextStyle(
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
                              child: Text(
                                _isBahasaMalaysia() ? 'Main Lagi' : 'Play Again',
                                style: const TextStyle(
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
