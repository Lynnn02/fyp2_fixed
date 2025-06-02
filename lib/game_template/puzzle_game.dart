import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class PuzzleGame extends StatefulWidget {
  final String chapterName;
  final Map<String, dynamic>? gameContent;
  
  const PuzzleGame({
    Key? key,
    required this.chapterName,
    this.gameContent,
  }) : super(key: key);

  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  late List<PuzzlePiece> puzzlePieces = [];
  late String puzzleImage = '🏠'; // Default emoji if no content provided
  late String puzzleWord = 'House'; // Default word if no content provided
  late bool isGameCompleted = false;
  late int moves = 0;
  late int gridSize = 3; // Default to 3x3 grid, will adjust based on age
  
  // Audio players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();
  
  // Timer
  late Timer _timer;
  late int _secondsElapsed = 0;
  
  @override
  void initState() {
    super.initState();
    _initAudio();
    _initializeGame();
    _startTimer();
  }
  
  void _initAudio() async {
    await _clickPlayer.setSource(AssetSource('sounds/click.mp3'));
    await _successPlayer.setSource(AssetSource('sounds/success.mp3'));
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }
  
  void _initializeGame() {
    // Initialize with content from Gemini if available
    if (widget.gameContent != null && 
        widget.gameContent!['puzzles'] != null && 
        widget.gameContent!['puzzles'].isNotEmpty) {
      final puzzles = widget.gameContent!['puzzles'] as List;
      final randomIndex = Random().nextInt(puzzles.length);
      final puzzle = puzzles[randomIndex];
      
      puzzleImage = puzzle['image'] ?? '🏠';
      puzzleWord = puzzle['word'] ?? 'House';
      
      // Set grid size based on age (from subject module ID)
      if (widget.gameContent != null && widget.gameContent!['gridSize'] != null) {
        gridSize = widget.gameContent!['gridSize'];
      } else {
        // Default grid sizes by age
        final ageGroup = widget.gameContent!['ageGroup'] ?? 4;
        gridSize = ageGroup <= 4 ? 3 : ageGroup <= 5 ? 3 : 4;
      }
      
      // Ensure grid size is at least 3 for enough puzzle pieces
      gridSize = gridSize < 3 ? 3 : gridSize;
    }
    
    // Create puzzle pieces
    _createPuzzlePieces();
    
    // Shuffle the puzzle (ensure it's solvable)
    _shufflePuzzle();
  }
  
  void _createPuzzlePieces() {
    puzzlePieces = [];
    final totalPieces = gridSize * gridSize;
    
    for (int i = 0; i < totalPieces - 1; i++) {
      puzzlePieces.add(PuzzlePiece(
        id: i,
        correctPosition: i,
        currentPosition: i,
      ));
    }
    
    // Add the empty space
    puzzlePieces.add(PuzzlePiece(
      id: totalPieces - 1,
      correctPosition: totalPieces - 1,
      currentPosition: totalPieces - 1,
      isEmpty: true,
    ));
  }
  
  void _shufflePuzzle() {
    // For very young children, we'll do a simple shuffle with few moves
    // to keep the puzzle solvable and not too difficult
    final emptyIndex = puzzlePieces.indexWhere((piece) => piece.isEmpty);
    final random = Random();
    
    // Make 10-20 random valid moves
    final shuffleMoves = random.nextInt(10) + 10;
    
    for (int i = 0; i < shuffleMoves; i++) {
      final validMoves = _getValidMoves(emptyIndex);
      if (validMoves.isNotEmpty) {
        final randomMove = validMoves[random.nextInt(validMoves.length)];
        _swapPieces(randomMove, emptyIndex);
      }
    }
    
    // Reset moves counter
    moves = 0;
  }
  
  List<int> _getValidMoves(int emptyIndex) {
    final validMoves = <int>[];
    final row = emptyIndex ~/ gridSize;
    final col = emptyIndex % gridSize;
    
    // Check up
    if (row > 0) {
      validMoves.add(emptyIndex - gridSize);
    }
    
    // Check down
    if (row < gridSize - 1) {
      validMoves.add(emptyIndex + gridSize);
    }
    
    // Check left
    if (col > 0) {
      validMoves.add(emptyIndex - 1);
    }
    
    // Check right
    if (col < gridSize - 1) {
      validMoves.add(emptyIndex + 1);
    }
    
    return validMoves;
  }
  
  void _swapPieces(int index1, int index2) {
    final temp = puzzlePieces[index1].currentPosition;
    puzzlePieces[index1].currentPosition = puzzlePieces[index2].currentPosition;
    puzzlePieces[index2].currentPosition = temp;
    
    // Swap the pieces in the list
    final tempPiece = puzzlePieces[index1];
    puzzlePieces[index1] = puzzlePieces[index2];
    puzzlePieces[index2] = tempPiece;
  }
  
  void _handleTap(int index) {
    if (isGameCompleted) return;
    
    final emptyIndex = puzzlePieces.indexWhere((piece) => piece.isEmpty);
    final validMoves = _getValidMoves(emptyIndex);
    
    if (validMoves.contains(index)) {
      // Play click sound
      _clickPlayer.resume();
      
      setState(() {
        _swapPieces(index, emptyIndex);
        moves++;
        
        // Check if puzzle is solved
        _checkCompletion();
      });
    }
  }
  
  void _checkCompletion() {
    bool completed = true;
    
    for (var piece in puzzlePieces) {
      if (piece.currentPosition != piece.correctPosition) {
        completed = false;
        break;
      }
    }
    
    if (completed) {
      isGameCompleted = true;
      _timer.cancel();
      _successPlayer.resume();
      
      // Show completion dialog after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _showCompletionDialog();
      });
    }
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Puzzle Completed!', 
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Word: $puzzleWord', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(puzzleImage, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text('Moves: $moves', style: const TextStyle(fontSize: 18)),
            Text('Time: ${_formatTime(_secondsElapsed)}', style: const TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  void _resetGame() {
    setState(() {
      isGameCompleted = false;
      moves = 0;
      _secondsElapsed = 0;
      _createPuzzlePieces();
      _shufflePuzzle();
      _startTimer();
    });
  }
  
  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play', 
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Goal:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Arrange the puzzle pieces to complete the picture.'),
            const SizedBox(height: 12),
            const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('1. Tap on a piece next to the empty space to move it.'),
            const Text('2. Continue moving pieces until the puzzle is solved.'),
            const Text('3. Try to solve it with as few moves as possible!'),
            const SizedBox(height: 12),
            Text('Current word: $puzzleWord', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Center(child: Text(puzzleImage, style: const TextStyle(fontSize: 60))),
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
    _timer.cancel();
    _clickPlayer.dispose();
    _successPlayer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Get custom title from gameContent if available
    String gameTitle = widget.gameContent != null && widget.gameContent!['title'] != null
        ? widget.gameContent!['title']
        : 'Puzzle Game: ${widget.chapterName}';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(gameTitle),
        backgroundColor: Colors.orange,
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
            colors: [Colors.orange.shade100, Colors.orange.shade200],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Game info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                          const Icon(Icons.timer, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(_secondsElapsed),
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
                          const Icon(Icons.swap_horiz, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Moves: $moves',
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
              
              // Word to complete
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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
                child: Column(
                  children: [
                    const Text(
                      'Complete the puzzle to reveal:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      puzzleWord,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Puzzle grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                            childAspectRatio: 1,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: puzzlePieces.length,
                          itemBuilder: (context, index) {
                            final piece = puzzlePieces[index];
                            
                            if (piece.isEmpty) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            }
                            
                            return GestureDetector(
                              onTap: () => _handleTap(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.orange.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: _buildPieceContent(piece),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Reset button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _resetGame,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Puzzle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
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
  
  Widget _buildPieceContent(PuzzlePiece piece) {
    // For all puzzles, show both the emoji and the number
    // This makes it more engaging and easier to understand
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          puzzleImage,
          style: TextStyle(fontSize: gridSize <= 3 ? 30 : 20),
        ),
        const SizedBox(height: 4),
        Text(
          '${piece.id + 1}',
          style: TextStyle(
            fontSize: gridSize <= 3 ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

class PuzzlePiece {
  final int id;
  final int correctPosition;
  int currentPosition;
  final bool isEmpty;
  
  PuzzlePiece({
    required this.id,
    required this.correctPosition,
    required this.currentPosition,
    this.isEmpty = false,
  });
}
