import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../../../../services/score_service.dart';
import '../../../../services/gemini_service.dart'; // For dynamic content generation

class ShapeColorGame extends StatefulWidget {
  final String chapterName;
  final Map<String, dynamic>? gameContent;
  final String userId;
  final String userName;
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final int ageGroup;
  
  const ShapeColorGame({
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
  _ShapeColorGameState createState() => _ShapeColorGameState();
}

class _ShapeColorGameState extends State<ShapeColorGame> with TickerProviderStateMixin {
  // Gemini service for dynamic content
  final GeminiService _geminiService = GeminiService();
  // Game state
  late List<ShapeItem> _shapes;
  late ShapeItem _targetShape;
  int _score = 0;
  int _round = 0;
  late int _totalRounds; // Will be set based on age
  bool _isGameOver = false;
  bool _scoreSubmitted = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  
  // Animation controllers
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  // Audio players
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _incorrectPlayer = AudioPlayer();
  final AudioPlayer _completionPlayer = AudioPlayer();
  final AudioPlayer _shapePlayer = AudioPlayer();
  
  // Score service
  final ScoreService _scoreService = ScoreService();
  
  // Content variables based on age, subject and chapter
  late List<String> _gameShapes;
  late List<Color> _gameColors;
  late int _gameDifficulty;
  late int _gameRounds;
  late double _feedbackDuration;
  late double _fontSize;
  late double _itemSize;
  
  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initAudio();
    _initAnimations();
  }
  
  void _initAnimations() {
    // Bounce animation
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _bounceAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticInOut,
      ),
    );
    
    _bounceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _bounceController.reverse();
      }
    });
    
    // Rotate animation
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOut,
      ),
    );
    
    _scaleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scaleController.reverse();
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
    _bounceController.dispose();
    _rotateController.dispose();
    _scaleController.dispose();
    _correctPlayer.dispose();
    _incorrectPlayer.dispose();
    _completionPlayer.dispose();
    _shapePlayer.dispose();
    super.dispose();
  }
  
  void _initializeGame() async {
    // Configure game based on age
    _configureGameForAge(widget.ageGroup);
    
    // Create game shapes
    _shapes = [];
    
    // Check if we have dynamic content
    if (widget.gameContent != null && widget.gameContent!['shapes'] != null) {
      // Use provided dynamic content
      final dynamicShapes = widget.gameContent!['shapes'] as List;
      
      for (var shape in dynamicShapes) {
        _shapes.add(ShapeItem(
          name: shape['name'],
          color: _getColorFromString(shape['color']),
          shapeName: shape['shape'],
          soundUrl: shape['soundUrl'] ?? '',
        ));
      }
    } else {
      // Generate content based on subject and chapter
      await _generateDynamicContent();
    }
    
    // Shuffle shapes
    _shapes.shuffle();
    
    // Set first target
    _nextShape();
  }
  
  void _configureGameForAge(int age) {
    // Set game parameters based on age
    switch (age) {
      case 4:
        _gameShapes = ['circle', 'square', 'triangle', 'star', 'heart'];
        _gameColors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple];
        _gameDifficulty = 1; // Easiest
        _totalRounds = 5; // Fewer rounds for younger children
        _feedbackDuration = 2000; // Longer feedback time
        _fontSize = 24.0; // Larger font
        _itemSize = 120.0; // Larger items
        break;
      case 5:
        _gameShapes = ['circle', 'square', 'triangle', 'star', 'heart', 'rectangle', 'oval'];
        _gameColors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange, Colors.pink];
        _gameDifficulty = 2; // Medium
        _totalRounds = 7; // Medium number of rounds
        _feedbackDuration = 1500; // Medium feedback time
        _fontSize = 20.0; // Medium font
        _itemSize = 100.0; // Medium items
        break;
      case 6:
      default:
        _gameShapes = ['circle', 'square', 'triangle', 'star', 'heart', 'rectangle', 'oval', 'pentagon', 'hexagon', 'diamond'];
        _gameColors = [
          Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, 
          Colors.orange, Colors.pink, Colors.teal, Colors.brown, Colors.indigo
        ];
        _gameDifficulty = 3; // Harder
        _totalRounds = 10; // More rounds for older children
        _feedbackDuration = 1000; // Shorter feedback time
        _fontSize = 18.0; // Smaller font
        _itemSize = 80.0; // Smaller items
        break;
    }
  }
  
  Future<void> _generateDynamicContent() async {
    try {
      // Generate content based on subject and chapter
      final prompt = '''
      Create educational content for a shape and color game for ${widget.ageGroup}-year-old children 
      studying ${widget.subjectName}, chapter: ${widget.chapterName}.
      
      Generate ${_gameDifficulty == 1 ? 5 : (_gameDifficulty == 2 ? 8 : 12)} items that relate to this subject.
      For each item, provide:
      1. A shape name (choose from: ${_gameShapes.join(', ')})
      2. A color name (choose from: red, blue, green, yellow, purple, orange, pink, teal, brown, indigo)
      3. A descriptive name that relates to the subject
      4. A sound description
      
      Format as JSON array.
      ''';
      
      final response = await _geminiService.generateContent(prompt);
      
      // Parse the response and create shape items
      // This is a simplified parsing - in a real app, you'd want more robust JSON parsing
      if (response.contains('[') && response.contains(']')) {
        final jsonStr = response.substring(
          response.indexOf('['),
          response.lastIndexOf(']') + 1
        );
        
        try {
          final List<dynamic> items = jsonDecode(jsonStr);
          
          for (var item in items) {
            if (item is Map && item.containsKey('shape') && item.containsKey('color') && item.containsKey('name')) {
              final shapeName = item['shape'] as String;
              final colorName = item['color'] as String;
              final name = item['name'] as String;
              
              if (_gameShapes.contains(shapeName)) {
                _shapes.add(ShapeItem(
                  name: name,
                  color: _getColorFromString(colorName),
                  shapeName: shapeName,
                  soundUrl: 'sounds/${shapeName}_${colorName}.mp3',
                ));
              }
            }
          }
        } catch (e) {
          print('Error parsing dynamic content: $e');
          _createFallbackContent();
        }
      } else {
        _createFallbackContent();
      }
    } catch (e) {
      print('Error generating dynamic content: $e');
      _createFallbackContent();
    }
    
    // If we couldn't generate content or not enough items, use fallback
    if (_shapes.isEmpty) {
      _createFallbackContent();
    }
  }
  
  void _createFallbackContent() {
    // Use default content as fallback - adjust based on subject if possible
    String subjectPrefix = '';
    
    // Try to make fallback content somewhat relevant to the subject
    if (widget.subjectName.toLowerCase().contains('math')) {
      subjectPrefix = 'Math ';
    } else if (widget.subjectName.toLowerCase().contains('science')) {
      subjectPrefix = 'Science ';
    } else if (widget.subjectName.toLowerCase().contains('english')) {
      subjectPrefix = 'English ';
    }
    
    for (var shape in _gameShapes) {
      for (var color in _gameColors) {
        if (_shapes.length < 10) { // Limit to 10 combinations
          _shapes.add(ShapeItem(
            name: '$subjectPrefix${_getColorName(color)} $shape',
            color: color,
            shapeName: shape,
            soundUrl: 'sounds/${shape}_${_getColorName(color)}.mp3',
          ));
        }
      }
    }
  }
  
  String _getColorName(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.yellow) return 'yellow';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.pink) return 'pink';
    return 'color';
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
      default: return Colors.blue;
    }
  }
  
  void _nextShape() {
    if (_round >= _totalRounds || _shapes.isEmpty) {
      _endGame();
      return;
    }
    
    setState(() {
      _targetShape = _shapes[_round % _shapes.length];
      _showFeedback = false;
    });
    
    // Play shape sound if available
    if (_targetShape.soundUrl.isNotEmpty) {
      _shapePlayer.setSource(AssetSource(_targetShape.soundUrl));
      _shapePlayer.resume();
    }
    
    // Start animations
    _bounceController.forward();
    
    _round++;
  }
  
  void _checkAnswer(ShapeItem selectedShape) {
    bool isCorrect = selectedShape.name == _targetShape.name;
    
    setState(() {
      _isCorrect = isCorrect;
      _showFeedback = true;
      
      if (isCorrect) {
        _score += 10;
        _correctPlayer.resume();
        _scaleController.forward();
        _rotateController.forward();
      } else {
        _incorrectPlayer.resume();
      }
    });
    
    // Wait before moving to next shape - duration based on age
    Timer(Duration(milliseconds: _feedbackDuration.toInt()), () {
      if (_round < _totalRounds) {
        _nextShape();
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
      activityName: '${widget.chapterName} Shape & Color Game',
      points: finalScore,
      ageGroup: widget.ageGroup,
    );
    
    setState(() {
      _scoreSubmitted = true;
    });
    
    // Show a snackbar to inform the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wonderful! You earned $finalScore points!'),
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
    
    _shapes.shuffle();
    _nextShape();
  }
  
  void _playShapeSound() {
    if (_targetShape.soundUrl.isNotEmpty) {
      _shapePlayer.setSource(AssetSource(_targetShape.soundUrl));
      _shapePlayer.resume();
    }
  }
  
  Widget _buildShapeWidget(ShapeItem shape, {bool isTarget = false, bool isSelectable = false}) {
    Widget shapeWidget;
    
    switch (shape.shapeName) {
      case 'circle':
        shapeWidget = Container(
          width: isTarget ? _itemSize * 1.5 : _itemSize,
          height: isTarget ? _itemSize * 1.5 : _itemSize,
          decoration: BoxDecoration(
            color: shape.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        );
        break;
        
      case 'square':
        shapeWidget = Container(
          width: isTarget ? _itemSize * 1.5 : _itemSize,
          height: isTarget ? _itemSize * 1.5 : _itemSize,
          decoration: BoxDecoration(
            color: shape.color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        );
        break;
        
      case 'triangle':
        shapeWidget = ClipPath(
          clipper: TriangleClipper(),
          child: Container(
            width: isTarget ? 120 : 80,
            height: isTarget ? 120 : 80,
            color: shape.color,
          ),
        );
        break;
        
      case 'star':
        shapeWidget = Icon(
          Icons.star,
          size: isTarget ? _itemSize * 1.5 : _itemSize,
          color: shape.color,
        );
        break;
        
      case 'heart':
        shapeWidget = Icon(
          Icons.favorite,
          size: isTarget ? _itemSize * 1.5 : _itemSize,
          color: shape.color,
        );
        break;
        
      default:
        shapeWidget = Container(
          width: isTarget ? _itemSize * 1.5 : _itemSize,
          height: isTarget ? _itemSize * 1.5 : _itemSize,
          decoration: BoxDecoration(
            color: shape.color,
            shape: BoxShape.circle,
          ),
        );
    }
    
    if (isSelectable) {
      return GestureDetector(
        onTap: _showFeedback ? null : () => _checkAnswer(shape),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: shapeWidget,
          ),
        ),
      );
    }
    
    if (isTarget) {
      return AnimatedBuilder(
        animation: Listenable.merge([_bounceAnimation, _rotateAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_bounceAnimation.value),
            child: Transform.rotate(
              angle: _showFeedback && _isCorrect ? _rotateAnimation.value : 0,
              child: Transform.scale(
                scale: _showFeedback && _isCorrect ? _scaleAnimation.value : 1.0,
                child: child,
              ),
            ),
          );
        },
        child: shapeWidget,
      );
    }
    
    return shapeWidget;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName}: ${widget.chapterName}'),
        backgroundColor: Colors.teal,
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
            colors: [Colors.teal.shade300, Colors.teal.shade100],
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
          child: Row(
            children: [
              Text(
                'Round: $_round/$_totalRounds',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LinearProgressIndicator(
                  value: _round / _totalRounds,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
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
                        'Find this shape:',
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Target shape
                      GestureDetector(
                        onTap: _playShapeSound,
                        child: Column(
                          children: [
                            _buildShapeWidget(_targetShape, isTarget: true),
                            const SizedBox(height: 10),
                            Text(
                              _targetShape.name,
                              style: const TextStyle(
                                fontSize: _fontSize - 2,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Sound button
                      ElevatedButton.icon(
                        onPressed: _playShapeSound,
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
                            _isCorrect ? 'Great job! 🎉' : 'Try again! 💪',
                            style: TextStyle(
                              fontSize: _fontSize,
                              fontWeight: FontWeight.bold,
                              color: _isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Options
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 4, // Show 4 options
                      itemBuilder: (context, index) {
                        // Create a list with the target and 3 random different shapes
                        List<ShapeItem> options = [_targetShape];
                        
                        // Add random shapes until we have 4 options
                        while (options.length < 4) {
                          final randomShape = _shapes[Random().nextInt(_shapes.length)];
                          if (!options.any((s) => s.name == randomShape.name)) {
                            options.add(randomShape);
                          }
                        }
                        
                        // Shuffle options
                        options.shuffle();
                        
                        return _buildShapeWidget(options[index], isSelectable: true);
                      },
                    ),
                  ),
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
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score: $_score',
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'You did amazing! Great job with ${widget.subjectName}!',
              style: TextStyle(
                fontSize: _fontSize - 4,
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
                    backgroundColor: Colors.teal,
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

class ShapeItem {
  final String name;
  final Color color;
  final String shapeName;
  final String soundUrl;
  
  ShapeItem({
    required this.name,
    required this.color,
    required this.shapeName,
    required this.soundUrl,
  });
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
