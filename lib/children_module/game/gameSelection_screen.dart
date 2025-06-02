import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/subject.dart';
import '../../models/game.dart';
import '../../services/content_service.dart';
import '../../game_template/matching_game.dart';
import '../../game_template/counting_game.dart';
import '../../game_template/puzzle_game.dart';
import '../../game_template/tracing_game.dart';
import '../../game_template/sorting_game.dart';

class GameSelectionScreen extends StatefulWidget {
  final Chapter chapter;
  final Subject subject;
  final String userId;
  final String userName;

  const GameSelectionScreen({
    super.key,
    required this.chapter,
    required this.subject,
    required this.userId,
    required this.userName,
  });
  
  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> {
  final ContentService _contentService = ContentService();
  Game? _game;
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadGameData();
  }
  
  Future<void> _loadGameData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Check if the chapter has a game associated with it
      if (widget.chapter.gameId != null && widget.chapter.gameType != null) {
        // Load the game data from Firestore
        final game = await _contentService.getGameById(widget.chapter.gameId!);
        setState(() {
          _game = game;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No game available for this chapter';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading game: $e';
        _isLoading = false;
      });
    }
  }
  
  // Get the appropriate icon for the game type
  IconData _getGameIcon(String gameType) {
    switch (gameType.toLowerCase()) {
      case 'matching':
        return Icons.grid_view;
      case 'counting':
        return Icons.format_list_numbered;
      case 'puzzle':
        return Icons.extension;
      case 'tracing':
        return Icons.gesture;
      case 'sorting':
        return Icons.sort;
      default:
        return Icons.sports_esports;
    }
  }
  
  // Get the appropriate color for the game type
  Color _getGameColor(String gameType) {
    switch (gameType.toLowerCase()) {
      case 'matching':
        return Colors.blue;
      case 'counting':
        return Colors.amber;
      case 'puzzle':
        return Colors.orange;
      case 'tracing':
        return Colors.green;
      case 'sorting':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }
  
  // Launch the appropriate game based on the game type
  void _launchGame() {
    if (_game == null || widget.chapter.gameType == null) return;
    
    final gameType = widget.chapter.gameType!.toLowerCase();
    Widget gameWidget;
    
    switch (gameType) {
      case 'matching':
        gameWidget = MatchingGame(
          chapterName: widget.chapter.name, 
          gameContent: _game!.toJson(),
          subjectId: widget.subject.id,
          subjectName: widget.subject.name,
          chapterId: widget.chapter.id,
          userId: widget.userId,
          userName: widget.userName,
          ageGroup: widget.subject.moduleId,
        );
        break;
      case 'counting':
        gameWidget = CountingGame(
          chapterName: widget.chapter.name, 
          gameContent: _game!.toJson(),
        );
        break;
      case 'puzzle':
        gameWidget = PuzzleGame(
          chapterName: widget.chapter.name, 
          gameContent: _game!.toJson(),
        );
        break;
      case 'tracing':
        gameWidget = TracingGame(
          chapterName: widget.chapter.name, 
          gameContent: _game!.toJson(),
        );
        break;
      case 'sorting':
        gameWidget = SortingGame(
          chapterName: widget.chapter.name, 
          gameContent: _game!.toJson(),
        );
        break;
      default:
        gameWidget = const Center(child: Text('Game not available'));
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameWidget),
    );
  }
  
  void _handleNavigation(int index) {
    if (index == 0) {
      // Navigate to home
      Navigator.pushReplacementNamed(
        context,
        '/childrenHome',
        arguments: {
          'userId': widget.userId,
          'userName': widget.userName,
        },
      );
    } else if (index == 2) {
      // Navigate to learn
      Navigator.pushReplacementNamed(
        context,
        '/childrenLearning',
        arguments: {
          'userId': widget.userId,
          'userName': widget.userName,
        },
      );
    } else if (index == 3) {
      // Navigate to awards
      Navigator.pushReplacementNamed(
        context,
        '/awards',
        arguments: {
          'userId': widget.userId,
          'userName': widget.userName,
        },
      );
    }
  }
  
  // Show sign out confirmation dialog
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 10),
            const Text('Sign Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('SIGN OUT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context); // Close the dialog
              
              // Navigate to login screen and clear navigation history
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', 
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => _showSignOutDialog(context),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/rainbow.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 100),
              // Game Selection Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'LITTLE EXPLORERS',
                  style: TextStyle(
                    fontFamily: 'ITEM',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              
              // Game content
              Expanded(
                child: Center(
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.orange)
                    : _errorMessage.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                            const SizedBox(height: 20),
                            Text(
                              _errorMessage,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Game icon
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: widget.chapter.gameType != null
                                  ? _getGameColor(widget.chapter.gameType!).withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.chapter.gameType != null
                                    ? _getGameColor(widget.chapter.gameType!)
                                    : Colors.orange,
                                  width: 3
                                ),
                              ),
                              child: Icon(
                                widget.chapter.gameType != null
                                  ? _getGameIcon(widget.chapter.gameType!)
                                  : Icons.sports_esports,
                                size: 60,
                                color: widget.chapter.gameType != null
                                  ? _getGameColor(widget.chapter.gameType!)
                                  : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 30),
                            
                            // Game title
                            Text(
                              _game?.title ?? 'Game: ${widget.chapter.name}',
                              style: const TextStyle(
                                fontFamily: 'ITEM',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            
                            // Game description
                            if (_game?.description != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  _game!.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 40),
                            
                            // Main buttons container for consistent width
                            Container(
                              width: 280, // Fixed width for all buttons
                              child: Column(
                                children: [
                                  // Play button
                                  ElevatedButton.icon(
                                    onPressed: _game != null ? _launchGame : null,
                                    icon: const Icon(Icons.play_arrow, size: 30),
                                    label: const Text(
                                      'PLAY',
                                      style: TextStyle(
                                        fontFamily: 'ITEM',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 5,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Leaderboard button
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
                                    icon: const Icon(Icons.leaderboard, size: 30),
                                    label: const Text(
                                      'LEADERBOARD',
                                      style: TextStyle(
                                        fontFamily: 'ITEM',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 5,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Settings button
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                                    icon: const Icon(Icons.settings, size: 30),
                                    label: const Text(
                                      'SETTING',
                                      style: TextStyle(
                                        fontFamily: 'ITEM',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
