import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../../../../services/score_service.dart';
import '../../../../services/gemini_service.dart'; // For dynamic content generation
import '../../../../services/gemini_service_extension.dart'; // For flashcard functionality
import '../../../../widgets/flashcard_widget.dart'; // Import the flashcard widget
import '../../../../models/subject.dart';
import '../../../../models/note_content.dart';

class AnimalSoundsGame extends StatefulWidget {
  final String chapterName;
  final Map<String, dynamic>? gameContent;
  final String userId;
  final String userName;
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final int ageGroup;
  
  const AnimalSoundsGame({
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
  _AnimalSoundsGameState createState() => _AnimalSoundsGameState();
}

// Game modes enum to switch between different game types
enum GameMode {
  animalSounds,
  flashcards
}

class _AnimalSoundsGameState extends State<AnimalSoundsGame> with TickerProviderStateMixin {
  // Gemini service for dynamic content
  final GeminiService _geminiService = GeminiService();
  // Game state
  late List<AnimalItem> _animals;
  late AnimalItem _currentAnimal;
  int _score = 0;
  int _round = 0;
  late int _totalRounds; // Will be set based on age
  bool _isGameOver = false;
  bool _scoreSubmitted = false;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _isPlayingSound = false;
  
  // Game mode state
  GameMode _currentMode = GameMode.animalSounds; // Default to animal sounds game
  
  // Animation controllers
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _wiggleController;
  late Animation<double> _wiggleAnimation;
  
  // Audio players
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _incorrectPlayer = AudioPlayer();
  final AudioPlayer _completionPlayer = AudioPlayer();
  final AudioPlayer _animalSoundPlayer = AudioPlayer();
  
  // Score service
  final ScoreService _scoreService = ScoreService();
  
  // Game configuration variables based on age
  late double _fontSize;
  late double _imageSize;
  late double _feedbackDuration;
  late int _optionsCount;
  
  // Subject-specific content lists
  final Map<String, List<AnimalItem>> _subjectAnimals = {
    'math': [
      AnimalItem(
        name: 'Counting Elephant',
        emoji: '🐘',
        soundUrl: 'sounds/elephant.mp3',
        soundName: 'One, two, three!',
        options: ['One, two, three!', 'Quack quack', 'Roar!'],
      ),
      AnimalItem(
        name: 'Addition Monkey',
        emoji: '🐵',
        soundUrl: 'sounds/monkey.mp3',
        soundName: 'Plus plus!',
        options: ['Plus plus!', 'Minus minus', 'Equals!'],
      ),
      AnimalItem(
        name: 'Subtraction Snake',
        emoji: '🐍',
        soundUrl: 'sounds/snake.mp3',
        soundName: 'Minus minus',
        options: ['Minus minus', 'Times times', 'Plus plus!'],
      ),
    ],
    'science': [
      AnimalItem(
        name: 'Weather Frog',
        emoji: '🐸',
        soundUrl: 'sounds/frog.mp3',
        soundName: 'Ribbit ribbit',
        options: ['Ribbit ribbit', 'Chirp chirp', 'Hoot hoot'],
      ),
      AnimalItem(
        name: 'Plant Growing Turtle',
        emoji: '🐢',
        soundUrl: 'sounds/turtle.mp3',
        soundName: 'Slow and steady',
        options: ['Slow and steady', 'Fast and quick', 'Jump jump'],
      ),
      AnimalItem(
        name: 'Solar System Eagle',
        emoji: '🦅',
        soundUrl: 'sounds/eagle.mp3',
        soundName: 'Soar high',
        options: ['Soar high', 'Swim deep', 'Crawl low'],
      ),
    ],
    'english': [
      AnimalItem(
        name: 'Alphabet Owl',
        emoji: '🦉',
        soundUrl: 'sounds/owl.mp3',
        soundName: 'Hoot hoot',
        options: ['Hoot hoot', 'Meow meow', 'Woof woof'],
      ),
      AnimalItem(
        name: 'Reading Rabbit',
        emoji: '🐰',
        soundUrl: 'sounds/rabbit.mp3',
        soundName: 'Hop hop',
        options: ['Hop hop', 'Slither slither', 'Roar roar'],
      ),
      AnimalItem(
        name: 'Storytelling Lion',
        emoji: '🦁',
        soundUrl: 'sounds/lion.mp3',
        soundName: 'Roar!',
        options: ['Roar!', 'Squeak!', 'Chirp!'],
      ),
    ]
  };
  
  // Default animals as fallback
  final List<AnimalItem> _defaultAnimals = [
    AnimalItem(
      name: 'Dog',
      emoji: '🐶',
      soundUrl: 'sounds/dog.mp3',
      soundName: 'Woof woof',
      options: ['Woof woof', 'Meow', 'Moo'],
    ),
    AnimalItem(
      name: 'Cat',
      emoji: '🐱',
      soundUrl: 'sounds/cat.mp3',
      soundName: 'Meow',
      options: ['Meow', 'Woof woof', 'Quack'],
    ),
    AnimalItem(
      name: 'Cow',
      emoji: '🐄',
      soundUrl: 'sounds/cow.mp3',
      soundName: 'Moo',
      options: ['Moo', 'Oink', 'Meow'],
    ),
    AnimalItem(
      name: 'Duck',
      emoji: '🦆',
      soundUrl: 'sounds/duck.mp3',
      soundName: 'Quack',
      options: ['Quack', 'Woof woof', 'Moo'],
    ),
    AnimalItem(
      name: 'Pig',
      emoji: '🐷',
      soundUrl: 'sounds/pig.mp3',
      soundName: 'Oink',
      options: ['Oink', 'Quack', 'Meow'],
    ),
    AnimalItem(
      name: 'Horse',
      emoji: '🐴',
      soundUrl: 'sounds/horse.mp3',
      soundName: 'Neigh',
      options: ['Neigh', 'Moo', 'Oink'],
    ),
  ];
  
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
      } else if (status == AnimationStatus.dismissed) {
        _bounceController.forward();
      }
    });
    
    // Wiggle animation for sound playing
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _wiggleAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _wiggleController,
        curve: Curves.easeInOut,
      ),
    );
    
    _wiggleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _wiggleController.reverse();
      } else if (status == AnimationStatus.dismissed && _isPlayingSound) {
        _wiggleController.forward();
      }
    });
    
    // Start bounce animation
    _bounceController.forward();
  }
  
  void _initAudio() async {
    await _correctPlayer.setSource(AssetSource('sounds/success.mp3'));
    await _incorrectPlayer.setSource(AssetSource('sounds/error.mp3'));
    await _completionPlayer.setSource(AssetSource('sounds/completion.mp3'));
    
    // Set up animal sound player completion listener
    _animalSoundPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlayingSound = false;
      });
      _wiggleController.reset();
    });
  }
  
  @override
  void dispose() {
    _bounceController.dispose();
    _wiggleController.dispose();
    _correctPlayer.dispose();
    _incorrectPlayer.dispose();
    _completionPlayer.dispose();
    _animalSoundPlayer.dispose();
    super.dispose();
  }
  
  void _initializeGame() async {
    // Configure game based on age
    _configureGameForAge(widget.ageGroup);
    
    // Initialize animals list
    _animals = [];
    
    if (widget.gameContent != null && widget.gameContent!['animals'] != null) {
      // Use provided dynamic content
      final dynamicAnimals = widget.gameContent!['animals'] as List;
      _animals = dynamicAnimals.map((animal) {
        return AnimalItem(
          name: animal['name'],
          emoji: animal['emoji'],
          soundUrl: animal['soundUrl'] ?? '',
          soundName: animal['soundName'],
          options: (animal['options'] as List).cast<String>(),
        );
      }).toList();
    } else {
      // Generate content based on subject and chapter
      await _generateDynamicContent();
    }
    
    // If we couldn't generate content or not enough items, use fallback
    if (_animals.isEmpty) {
      _createFallbackContent();
    }
    
    // Shuffle animals
    _animals.shuffle();
    
    // Set first animal
    _nextAnimal();
  }
  
  void _configureGameForAge(int age) {
    // Set game parameters based on age
    switch (age) {
      case 4:
        _totalRounds = 5; // Fewer rounds for younger children
        _fontSize = 24.0; // Larger font
        _imageSize = 150.0; // Larger images
        _feedbackDuration = 2000; // Longer feedback time
        _optionsCount = 2; // Fewer options for simplicity
        break;
      case 5:
        _totalRounds = 7; // Medium number of rounds
        _fontSize = 20.0; // Medium font
        _imageSize = 130.0; // Medium images
        _feedbackDuration = 1500; // Medium feedback time
        _optionsCount = 3; // Standard number of options
        break;
      case 6:
      default:
        _totalRounds = 10; // More rounds for older children
        _fontSize = 18.0; // Smaller font
        _imageSize = 110.0; // Smaller images
        _feedbackDuration = 1000; // Shorter feedback time
        _optionsCount = 4; // More options for challenge
        break;
    }
  }
  
  Future<void> _generateDynamicContent() async {
    try {
      // First check if we have subject-specific content
      String subjectKey = '';
      if (widget.subjectName.toLowerCase().contains('math')) {
        subjectKey = 'math';
      } else if (widget.subjectName.toLowerCase().contains('science')) {
        subjectKey = 'science';
      } else if (widget.subjectName.toLowerCase().contains('english')) {
        subjectKey = 'english';
      }
      
      // If we have predefined content for this subject, use it first
      if (_subjectAnimals.containsKey(subjectKey)) {
        _animals.addAll(_subjectAnimals[subjectKey]!);
      }
      
      // If we need more content, generate it
      if (_animals.length < _totalRounds) {
        // Generate content based on subject and chapter
        final prompt = '''
        Create educational content for an animal sounds game for ${widget.ageGroup}-year-old children 
        studying ${widget.subjectName}, chapter: ${widget.chapterName}.
        
        Generate ${_totalRounds - _animals.length} items that relate to this subject.
        For each item, provide:
        1. A descriptive animal name that relates to the subject (e.g., "Counting Elephant" for math)
        2. An emoji representing the animal
        3. A sound the animal makes (written as text)
        4. 3 options for what sound the animal makes (including the correct one)
        
        Format as JSON array.
        ''';
        
        final response = await _geminiService.generateContent(prompt);
        
        // Parse the response and create animal items
        if (response.contains('[') && response.contains(']')) {
          final jsonStr = response.substring(
            response.indexOf('['),
            response.lastIndexOf(']') + 1
          );
          
          try {
            final List<dynamic> items = jsonDecode(jsonStr);
            
            for (var item in items) {
              if (item is Map && 
                  item.containsKey('name') && 
                  item.containsKey('emoji') && 
                  item.containsKey('sound') && 
                  item.containsKey('options')) {
                
                final name = item['name'] as String;
                final emoji = item['emoji'] as String;
                final sound = item['sound'] as String;
                List<String> options = [];
                
                if (item['options'] is List) {
                  options = (item['options'] as List).map((e) => e.toString()).toList();
                } else if (item['options'] is String) {
                  // Handle case where options might be a comma-separated string
                  options = (item['options'] as String).split(',').map((e) => e.trim()).toList();
                }
                
                // Ensure the correct answer is in the options
                if (!options.contains(sound)) {
                  options.add(sound);
                }
                
                // Limit options based on age
                while (options.length > _optionsCount) {
                  // Remove random options (but not the correct one)
                  final nonCorrectOptions = options.where((o) => o != sound).toList();
                  if (nonCorrectOptions.isNotEmpty) {
                    options.remove(nonCorrectOptions[Random().nextInt(nonCorrectOptions.length)]);
                  } else {
                    break;
                  }
                }
                
                // Add to animals list
                _animals.add(AnimalItem(
                  name: name,
                  emoji: emoji,
                  soundUrl: '', // No actual sound URL, would need to be generated
                  soundName: sound,
                  options: options,
                ));
              }
            }
          } catch (e) {
            print('Error parsing dynamic content: $e');
          }
        }
      }
    } catch (e) {
      print('Error generating dynamic content: $e');
    }
  }
  
  void _createFallbackContent() {
    // Use default content as fallback
    _animals = List.from(_defaultAnimals);
    
    // Try to adapt default content to the subject if possible
    String subjectPrefix = '';
    if (widget.subjectName.toLowerCase().contains('math')) {
      subjectPrefix = 'Math ';
    } else if (widget.subjectName.toLowerCase().contains('science')) {
      subjectPrefix = 'Science ';
    } else if (widget.subjectName.toLowerCase().contains('english')) {
      subjectPrefix = 'English ';
    }
    
    // Add subject prefix to animal names if applicable
    if (subjectPrefix.isNotEmpty) {
      for (var i = 0; i < _animals.length; i++) {
        final animal = _animals[i];
        if (!animal.name.contains(subjectPrefix)) {
          _animals[i] = AnimalItem(
            name: '$subjectPrefix${animal.name}',
            emoji: animal.emoji,
            soundUrl: animal.soundUrl,
            soundName: animal.soundName,
            options: animal.options,
          );
        }
      }
    }
  }
  
  void _nextAnimal() {
    if (_round >= _totalRounds || _animals.isEmpty) {
      _endGame();
      return;
    }
    
    setState(() {
      _currentAnimal = _animals[_round % _animals.length];
      _showFeedback = false;
    });
    
    // Play animal sound automatically
    _playAnimalSound();
    
    _round++;
  }
  
  void _playAnimalSound() {
    if (_currentAnimal.soundUrl.isNotEmpty) {
      setState(() {
        _isPlayingSound = true;
      });
      _animalSoundPlayer.setSource(AssetSource(_currentAnimal.soundUrl));
      _animalSoundPlayer.resume();
      _wiggleController.forward();
    }
  }
  
  void _checkAnswer(String answer) {
    bool isCorrect = answer == _currentAnimal.soundName;
    
    setState(() {
      _isCorrect = isCorrect;
      _showFeedback = true;
      
      if (isCorrect) {
        _score += 10;
        _correctPlayer.resume();
      } else {
        _incorrectPlayer.resume();
      }
    });
    
    // Wait before moving to next animal - duration based on age
    Timer(Duration(milliseconds: _feedbackDuration.toInt()), () {
      if (_round < _totalRounds) {
        _nextAnimal();
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
      activityName: '${widget.chapterName} Animal Sounds Game',
      points: finalScore,
      ageGroup: widget.ageGroup,
    );
    
    setState(() {
      _scoreSubmitted = true;
    });
    
    // Show a snackbar to inform the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Amazing! You earned $finalScore points!'),
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
      _setupRound();
    });
  }
  
  // Build the flashcard game mode
  Widget _buildFlashcardMode() {
    // Create a Chapter object from the widget's chapterId and chapterName
    final chapter = Chapter(
      id: widget.chapterId,
      name: widget.chapterName,
      content: [],
      gameId: '',
    );
    
    // Create a Subject object from the widget's subjectId and subjectName
    final subject = Subject(
      id: widget.subjectId,
      name: widget.subjectName,
      moduleId: widget.ageGroup,
      chapters: [],
    );
    
    // Determine language based on subject name
    String language = _determineLanguage(widget.subjectName);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcards: ${widget.chapterName}'),
        actions: [
          // Toggle between game modes
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch to Animal Sounds Game',
            onPressed: () {
              setState(() {
                _currentMode = GameMode.animalSounds;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FlashcardWidget(
            subject: subject,
            chapter: chapter,
            age: widget.ageGroup,
            language: language,
            userId: widget.userId,
            userName: widget.userName,
          ),
        ),
      ),
    );
  }
  
  // Determine language based on subject name
  String _determineLanguage(String subjectName) {
    final name = subjectName.toLowerCase();
    
    if (name.contains('arabic') || name.contains('iqra') || name.contains('quran')) {
      return 'Arabic';
    } else if (name.contains('jawi')) {
      return 'Jawi';
    } else if (name.contains('chinese') || name.contains('mandarin')) {
      return 'Chinese';
    } else if (name.contains('tamil')) {
      return 'Tamil';
    } else if (name.contains('hindi')) {
      return 'Hindi';
    } else if (name.contains('malay') || name.contains('bahasa')) {
      return 'Malay';
    }
    
    return 'English'; // Default language
  }
  
  @override
  Widget build(BuildContext context) {
    // Determine which game mode to display
    if (_currentMode == GameMode.flashcards) {
      return _buildFlashcardMode();
    }
    
    // Default to animal sounds game
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName}: ${widget.chapterName}'),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          // Toggle between game modes
          IconButton(
            icon: const Icon(Icons.style),
            tooltip: 'Switch to Flashcards',
            onPressed: () {
              setState(() {
                _currentMode = GameMode.flashcards;
              });
            },
          ),
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
            colors: [Colors.orange.shade300, Colors.orange.shade100],
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
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
                // Animal display
                Container(
                  padding: const EdgeInsets.all(24.0),
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
                        'What sound does this animal make?',
                        style: TextStyle(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      
                      // Animal emoji with animations
                      GestureDetector(
                        onTap: _playAnimalSound,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_bounceAnimation, _wiggleAnimation]),
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                _isPlayingSound ? _wiggleAnimation.value * 20 : 0,
                                -_bounceAnimation.value,
                              ),
                              child: child,
                            );
                          },
                          child: Container(
                            width: _imageSize,
                            height: _imageSize,
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
                                    : Colors.orange,
                                width: 4,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _currentAnimal.emoji,
                                style: const TextStyle(
                                  fontSize: 80,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Animal name
                      Text(
                        _currentAnimal.name,
                        style: const TextStyle(
                          fontSize: _fontSize + 4,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Sound button
                      ElevatedButton.icon(
                        onPressed: _playAnimalSound,
                        icon: Icon(_isPlayingSound ? Icons.volume_up : Icons.volume_up_outlined),
                        label: Text(_isPlayingSound ? 'Listening...' : 'Listen Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                
                // Answer options
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: _currentAnimal.options.map((sound) {
                    return ElevatedButton(
                      onPressed: _showFeedback ? null : () => _checkAnswer(sound),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(sound),
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
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Score: $_score',
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'You\'re amazing at ${widget.subjectName}!',
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
                    backgroundColor: Colors.orange,
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

class AnimalItem {
  final String name;
  final String emoji;
  final String soundUrl;
  final String soundName;
  final List<String> options;
  
  AnimalItem({
    required this.name,
    required this.emoji,
    required this.soundUrl,
    required this.soundName,
    required this.options,
  });
}
