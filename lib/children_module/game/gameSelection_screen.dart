import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:math';
import '../../models/subject.dart';
import '../../models/game.dart';
import '../../services/content_service.dart';
import '../../templates/subject_template_manager.dart';
import '../../services/game_template_manager.dart';
import '../../admin_module/content_management/game_template/game_template/matching_game.dart';
import '../../admin_module/content_management/game_template/game_template/tracing_game.dart';
import '../../admin_module/content_management/game_template/game_template/sorting_game.dart';
import '../../admin_module/content_management/game_template/game_template/shape_color_game.dart';
import 'english_matching_game.dart';

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
      print('Loading game with ID: ${widget.chapter.gameId} and type: ${widget.chapter.gameType}');
      
      final rawDoc = await FirebaseFirestore.instance.collection('games').doc(widget.chapter.gameId).get();
      if (rawDoc.exists) {
        final rawData = rawDoc.data();
        print('RAW FIRESTORE DATA - Game keys: ${rawData?.keys.toList() ?? "No data"}');
        
        if (rawData?.containsKey('content') ?? false) {
          final contentValue = rawData!['content'];
          print('CONTENT FIELD TYPE: ${contentValue.runtimeType}');
          print('CONTENT FIELD LENGTH: ${contentValue is String ? contentValue.length : "Not a string"}');
          print('CONTENT SAMPLE: ${contentValue is String ? contentValue.substring(0, min(50, contentValue.length)) : "Not a string"}');
          
          try {
            if (contentValue is String) {
              final decoded = jsonDecode(contentValue);
              print('SUCCESSFULLY DECODED CONTENT: ${decoded is Map ? decoded.keys.toList() : "Not a map"}');
            }
          } catch (decodeError) {
            print('ERROR DECODING CONTENT: $decodeError');
          }
        } else {
          print('NO CONTENT FIELD FOUND IN RAW FIRESTORE DATA');
        }
      } else {
        print('RAW FIRESTORE DATA - Game document does not exist');
      }
      
      // Now get the game through the service as before
      print('Loading game for subject: ${widget.subject.name}');
      var game = await _contentService.getGameById(widget.chapter.gameId!);
      print('Game loaded from ContentService: ${game?.title}, Type: ${game?.type}');
      
      if (game == null) {
        setState(() {
          _errorMessage = 'Game not found';
          _isLoading = false;
        });
        return;
      }
      
      // Check if game type needs to be updated
      if (widget.chapter.gameType != null && 
          game.type.toLowerCase() != widget.chapter.gameType!.toLowerCase()) {
        print('Warning: Game type mismatch. Chapter says ${widget.chapter.gameType}, but game says ${game.type}');
        print('Updating chapter to use the correct game type: ${game.type}');
        
        await _contentService.updateChapterGameType(
          widget.subject.id, 
          widget.chapter.id, 
          game.type
        );
      }
      
      // Check for template content for all subjects
      print('🔍 EXACT Subject Name: "${widget.subject.name}"');
      print('🔍 EXACT Chapter Name: "${widget.chapter.name}"');
      
      // Try to get predefined content from template system
      print('🔍 GameTemplateManager: Looking for predefined content');
      int ageGroup = widget.subject.moduleId ?? 4; // Default to age 4 if not set
      int rounds = 5; // Default number of rounds
      
      final templateContent = await _getTemplateContent(
        gameType: game.type.toLowerCase(),
        subjectName: widget.subject.name,
        chapterName: widget.chapter.name,
        ageGroup: ageGroup,
        rounds: rounds
      );
      
      // If template content is found, override the game content
      if (templateContent != null) {
        print('📌 Using PREDEFINED template content for ${widget.subject.name} - ${widget.chapter.name}');
        print('🔍 ContentManagementScreen: Game content received:');
        print('📦 Content keys: ${templateContent.keys.toList()}');
        
        if (templateContent.containsKey('pairs')) {
          print('✅ Found pairs: ${templateContent['pairs'].length} items');
        }
        
        // Update the game with template content
        if (game.gameContent == null) {
          game = game.copyWith(gameContent: templateContent);
        } else {
          // Create a new map with all existing content
          final updatedContent = Map<String, dynamic>.from(game.gameContent!);
          // Override with template content
          updatedContent.addAll(templateContent);
          // Update the game
          game = game.copyWith(gameContent: updatedContent);
        }
      }
      
      setState(() {
        _game = game;
        _isLoading = false;
      });
      
      print('Successfully loaded game: ${_game!.title}');
    } catch (e) {
      print('Error loading game: $e');
      setState(() {
        _errorMessage = 'Error loading game';
        _isLoading = false;
      });
    }
  }
  
  // Helper method to get template content
  Future<Map<String, dynamic>?> _getTemplateContent({
    required String gameType,
    required String subjectName,
    required String chapterName,
    required int ageGroup,
    required int rounds
  }) async {
    try {
      final content = SubjectTemplateManager.getTemplateContent(
        subjectName: subjectName,
        chapterName: chapterName,
        gameType: gameType,
        ageGroup: ageGroup,
        rounds: rounds
      );
      
      if (content != null) {
        return content;
      }
      
      // If specific template not found, use GameTemplateManager for generic content
      return GameTemplateManager().getPredefinedContent(
        templateType: gameType,
        subjectName: subjectName,
        chapterName: chapterName,
        ageGroup: ageGroup,
        rounds: rounds
      );
    } catch (e) {
      print('Error getting template content: $e');
      return null;
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
    print('Launching game type: $gameType with gameId: ${_game!.id}');
    
    // Log information about the game content
    if (_game!.gameContent != null) {
      print('Game has decoded content with keys: ${_game!.gameContent!.keys.toList()}');
      print('Subject: ${widget.subject.name}, Game type: $gameType');
      print('Game content sample: ${_game!.gameContent!.toString().substring(0, min(200, _game!.gameContent!.toString().length))}');
    } else {
      print('Warning: Game has no decoded content for ${widget.subject.name}');
    }
    
    // Create a proper game content map that includes both game metadata and decoded content
    Map<String, dynamic> fullGameContent = _game!.toJson();
    if (_game!.gameContent != null) {
      // If we have decoded content from the 'content' field, use that directly as gameContent
      fullGameContent = _game!.gameContent!;
      
      // Add any missing metadata fields that might be needed by the game widgets
      fullGameContent.putIfAbsent('id', () => _game!.id);
      fullGameContent.putIfAbsent('title', () => _game!.title);
      fullGameContent.putIfAbsent('type', () => _game!.type);
    }
    
    print('Full game content for widget: ${fullGameContent.keys.toList()}');
    Widget gameWidget;
    
    switch (gameType) {
      case 'matching':
        // Try to use the built-in English matching game first for backward compatibility
        if (widget.subject.name.toLowerCase().contains('english')) {
          print('Using English Matching Game with dynamic content');
          gameWidget = EnglishMatchingGame(
            chapterName: widget.chapter.name,
            gameContent: fullGameContent, // Pass the dynamic content
            subjectId: widget.subject.id,
            subjectName: widget.subject.name,
            chapterId: widget.chapter.id,
            userId: widget.userId,
            userName: widget.userName,
            ageGroup: widget.subject.moduleId,
          );
        } else {
          // Use the general matching game for other subjects
          gameWidget = MatchingGame(
            chapterName: widget.chapter.name, 
            gameContent: fullGameContent,
            subjectId: widget.subject.id,
            subjectName: widget.subject.name,
            chapterId: widget.chapter.id,
            userId: widget.userId,
            userName: widget.userName,
            ageGroup: widget.subject.moduleId,
          );
        }
        break;
      case 'shape_color':
        gameWidget = ShapeColorGame(
          chapterName: widget.chapter.name, 
          gameContent: fullGameContent,
          userId: widget.userId,
          userName: widget.userName,
          subjectId: widget.subject.id,
          subjectName: widget.subject.name,
          chapterId: widget.chapter.id,
          ageGroup: widget.subject.moduleId,
        );
        break;
      case 'tracing':
        gameWidget = TracingGame(
          chapterName: widget.chapter.name, 
          gameContent: fullGameContent,
        );
        break;
      case 'sorting':
        gameWidget = SortingGame(
          chapterName: widget.chapter.name, 
          gameContent: fullGameContent,
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Back',
          onPressed: () {
            Navigator.pop(context);
          },
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
