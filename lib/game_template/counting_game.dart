import 'package:flutter/material.dart';
import 'dart:math';

class CountingGame extends StatefulWidget {
  final String chapterName;
  final Map<String, dynamic>? gameContent; // Add gameContent parameter
  
  const CountingGame({
    Key? key,
    required this.chapterName,
    this.gameContent, // Optional parameter for dynamic content
  }) : super(key: key);

  @override
  _CountingGameState createState() => _CountingGameState();
}

class _CountingGameState extends State<CountingGame> {
  late List<CountingChallenge> challenges;
  late CountingChallenge currentChallenge;
  late int score = 0;
  late int currentChallengeIndex = 0;
  late bool isGameOver = false;
  late List<int> answerOptions = [];
  
  @override
  void initState() {
    super.initState();
    initializeGame();
  }
  
  void initializeGame() {
    // Create counting challenges
    if (widget.gameContent != null && widget.gameContent!['challenges'] != null) {
      // Use dynamic content from Gemini
      final dynamicChallenges = widget.gameContent!['challenges'] as List;
      challenges = [];
      
      for (var challenge in dynamicChallenges) {
        challenges.add(CountingChallenge(
          emoji: challenge['emoji'],
          count: challenge['count'],
          question: challenge['question'],
        ));
      }
    } else {
      // Use default content as fallback
      challenges = [
        CountingChallenge(
          emoji: '🍎',
          count: 3,
          question: 'How many apples do you see?',
        ),
        CountingChallenge(
          emoji: '🐶',
          count: 5,
          question: 'Count the dogs!',
        ),
        CountingChallenge(
          emoji: '🌟',
          count: 4,
          question: 'How many stars are there?',
        ),
        CountingChallenge(
          emoji: '🐠',
          count: 6,
          question: 'Count the fish!',
        ),
        CountingChallenge(
          emoji: '🦋',
          count: 2,
          question: 'How many butterflies can you see?',
        ),
        CountingChallenge(
          emoji: '🍦',
          count: 7,
          question: 'Count the ice creams!',
        ),
      ];
    }
    
    // Shuffle the challenges
    challenges.shuffle(Random());
    
    // Set the first challenge
    loadNextChallenge();
  }
  
  void loadNextChallenge() {
    if (currentChallengeIndex >= challenges.length) {
      setState(() {
        isGameOver = true;
      });
      return;
    }
    
    currentChallenge = challenges[currentChallengeIndex];
    
    // Generate answer options
    generateAnswerOptions();
  }
  
  void generateAnswerOptions() {
    final random = Random();
    final correctAnswer = currentChallenge.count;
    
    // Create a set to avoid duplicate options
    final optionsSet = <int>{correctAnswer};
    
    // Add some wrong answers
    while (optionsSet.length < 4) {
      int wrongAnswer = random.nextInt(10) + 1; // Numbers between 1 and 10
      if (wrongAnswer != correctAnswer) {
        optionsSet.add(wrongAnswer);
      }
    }
    
    // Convert to list and shuffle
    answerOptions = optionsSet.toList()..shuffle();
  }
  
  void checkAnswer(int selectedAnswer) {
    if (selectedAnswer == currentChallenge.count) {
      // Correct answer
      setState(() {
        score += 10;
        currentChallengeIndex++;
        
        // Show success animation and load next challenge
        Future.delayed(const Duration(milliseconds: 800), () {
          loadNextChallenge();
        });
      });
    } else {
      // Incorrect answer
      setState(() {
        // Move to next challenge after a short delay
        Future.delayed(const Duration(milliseconds: 800), () {
          currentChallengeIndex++;
          loadNextChallenge();
        });
      });
    }
  }
  
  void restartGame() {
    setState(() {
      score = 0;
      currentChallengeIndex = 0;
      isGameOver = false;
      initializeGame();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Get custom title from gameContent if available
    String gameTitle = widget.gameContent != null && widget.gameContent!['title'] != null
        ? widget.gameContent!['title']
        : 'Counting Game: ${widget.chapterName}';
        
    return Scaffold(
      appBar: AppBar(
        title: Text(gameTitle),
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
          child: isGameOver 
            ? _buildGameOverScreen() 
            : _buildGameScreen(),
        ),
      ),
    );
  }
  
  Widget _buildGameScreen() {
    return Column(
      children: [
        // Score display
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Challenge ${currentChallengeIndex + 1}/${challenges.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Challenge question
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            currentChallenge.question,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        // Emoji display
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: List.generate(
                  currentChallenge.count,
                  (index) => Text(
                    currentChallenge.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Answer options
        Container(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: answerOptions.map((option) {
              return ElevatedButton(
                onPressed: () => checkAnswer(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.blue.shade300, width: 2),
                  ),
                ),
                child: Text('$option'),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGameOverScreen() {
    return Center(
      child: Container(
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
              'Game Completed!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
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
      ),
    );
  }
}

class CountingChallenge {
  final String emoji;
  final int count;
  final String question;
  
  CountingChallenge({
    required this.emoji,
    required this.count,
    required this.question,
  });
}
