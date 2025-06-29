import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math' as math;

import '../../models/note_content.dart';
import '../../services/content_service.dart';
import '../../services/score_service.dart';
import '../../widgets/child_ui_style.dart';
import 'fixed_text_element.dart' as fix;
import '../../widgets/activity_completion_screen.dart';

// Define ContainerElement since it's not in the original models
class ContainerElement extends NoteContentElement {
  final List<NoteContentElement> elements;
  
  ContainerElement({
    required this.elements, 
    String? id, 
    String type = 'container', 
    int position = 0
  }) : super(
    id: id ?? DateTime.now().millisecondsSinceEpoch.toString(), 
    type: type, 
    position: position,
    createdAt: Timestamp.now()
  );
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'position': position,
      'created_at': createdAt,
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }
}

class NoteViewerScreen extends StatefulWidget {
  final Note note;
  final String chapterName;
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final String userId;
  final String userName;
  final int ageGroup;

  const NoteViewerScreen({
    Key? key,
    required this.note,
    required this.chapterName,
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.userId,
    required this.userName,
    required this.ageGroup,
  }) : super(key: key);

  @override
  State<NoteViewerScreen> createState() => _NoteViewerScreenState();
}

class _NoteViewerScreenState extends State<NoteViewerScreen> {
  final ContentService _contentService = ContentService();
  final ScoreService _scoreService = ScoreService();
  late PageController _pageController;
  int _currentPage = 0;
  List<List<NoteContentElement>> _pages = [];
  int _childAge = 5; // Default age
  bool _scoreSubmitted = false;
  bool _completedReading = false;
  bool _showCompletionScreen = false;
  int _earnedPoints = 0;
  DateTime _startTime = DateTime.now();
  
  // Audio players for note content
  final Map<String, AudioPlayer> _audioPlayers = <String, AudioPlayer>{};
  
  // Audio players for flashcards
  final AudioPlayer _flashcardAudioPlayer = AudioPlayer();
  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  String? _currentlyPlayingAudioId;
  bool _isBgMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _childAge = widget.ageGroup; // Use the provided age group
    _groupElementsIntoPages();
    
    // Listen for page changes to track progress
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);
    
    // Set up background music player
    _setupBackgroundMusicPlayer();
  }
  
  // Set up background music player with looping
  void _setupBackgroundMusicPlayer() async {
    try {
      // Use a cheerful, child-friendly background music
      const bgMusicUrl = 'https://example.com/childrens_background_music.mp3';
      // You should replace this with an actual music URL or asset
      // For now we'll just set it up without playing
      await _bgMusicPlayer.setLoopMode(LoopMode.all);
      await _bgMusicPlayer.setUrl(bgMusicUrl);
    } catch (e) {
      debugPrint('Error setting up background music: $e');
    }
  }

  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (_currentPage != page) {
      setState(() {
        _currentPage = page;
      });
      
      // Check if the new page has a flashcard with audio and play it
      if (_pages.isNotEmpty && page < _pages.length) {
        final elements = _pages[page];
        if (elements.isNotEmpty) {
          // Check if it's our custom container element
          if (elements.first is ContainerElement) {
            final containerElement = elements.first as ContainerElement;
            AudioElement? audioElement;
            
            for (var child in containerElement.elements) {
              if (child is AudioElement) {
                audioElement = child;
                break;
              }
            }
            
            if (audioElement != null && audioElement.audioUrl != null) {
              _playAudio(audioElement.audioUrl!);
            }
          } else if (elements.first is AudioElement) {
            // Direct audio element
            final audioElement = elements.first as AudioElement;
            if (audioElement.audioUrl != null) {
              _playAudio(audioElement.audioUrl!);
            }
          }
        }
        _submitScore();
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    
    // Dispose all audio players
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    _flashcardAudioPlayer.dispose();
    _bgMusicPlayer.dispose();
    
    super.dispose();
  }
  
  // Submit score to the database
  Future<void> _submitScore() async {
    if (_scoreSubmitted) return; // Prevent duplicate submissions
    
    try {
      // Calculate points based on note length and age group
      int basePoints = 5; // Base points for completing a note
      int lengthBonus = widget.note.elements.length ~/ 3; // Bonus for longer notes
      int totalPoints = basePoints + lengthBonus;
      
      // Cap points between 5-15 based on age group and content length
      totalPoints = math.min(math.max(totalPoints, 5), 15);
      
      // Calculate study time in minutes
      final now = DateTime.now();
      final duration = now.difference(_startTime);
      final studyMinutes = (duration.inSeconds / 60).ceil(); // Round up to nearest minute
      
      await _scoreService.addScore(
        userId: widget.userId,
        userName: widget.userName,
        subjectId: widget.subjectId,
        subjectName: widget.subjectName,
        activityId: widget.chapterId,
        activityType: 'note',
        activityName: 'Note: ${widget.note.title}',
        points: totalPoints,
        ageGroup: widget.ageGroup,
      );
      
      setState(() {
        _scoreSubmitted = true;
        _earnedPoints = totalPoints;
      });
      
      // Show completion screen with animation and sound
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) => ActivityCompletionScreen(
            activityType: 'note',
            activityName: widget.note.title,
            subject: widget.subjectName,
            points: totalPoints,
            studyMinutes: studyMinutes,
            userId: widget.userId,
            onContinue: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to chapter selection
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      print('Error submitting score: $e');
    }
  }



  void _groupElementsIntoPages() {
    final elements = widget.note.elements;
    List<List<NoteContentElement>> pages = [];
    List<NoteContentElement> currentPage = [];

    // Determine max elements per page based on age
    int maxElementsPerPage;
    switch (_childAge) {
      case 4:
        maxElementsPerPage = 3; // Fewer elements for younger children
        break;
      case 5:
        maxElementsPerPage = 4; // Medium number of elements
        break;
      case 6:
        maxElementsPerPage = 5; // More elements for older children
        break;
      default:
        maxElementsPerPage = 4;
    }

    for (var element in elements) {
      // If we've reached max elements per page
      if (currentPage.length >= maxElementsPerPage) {
        pages.add(List.from(currentPage));
        currentPage.clear();
      }

      currentPage.add(element);
    }

    // Add the last page if not empty
    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }

    setState(() {
      _pages = pages;
    });
  }

  void _handleNextAfterCompletion() {
    Navigator.of(context).pop(true); // Return with refresh flag
  }

  @override
  Widget build(BuildContext context) {
    // We're now using ActivityCompletionScreen which is shown as an overlay
    // So we don't need this code anymore
    
    // Extract arguments if they exist
    Note actualNote = widget.note;
    String actualChapterName = widget.chapterName;
    String actualSubjectId = widget.subjectId;
    String actualSubjectName = widget.subjectName;
    String actualChapterId = widget.chapterId;
    String actualUserId = widget.userId;
    String actualUserName = widget.userName;
    int actualAgeGroup = widget.ageGroup;
    
    // Check if we have route arguments (for direct navigation)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      if (args.containsKey('note')) {
        actualNote = args['note'] as Note;
      }
      if (args.containsKey('chapterName')) {
        actualChapterName = args['chapterName'] as String;
      }
      if (args.containsKey('subjectId')) {
        actualSubjectId = args['subjectId'] as String;
      }
      if (args.containsKey('subjectName')) {
        actualSubjectName = args['subjectName'] as String;
      }
      if (args.containsKey('chapterId')) {
        actualChapterId = args['chapterId'] as String;
      }
      if (args.containsKey('userId')) {
        actualUserId = args['userId'] as String;
      }
      if (args.containsKey('userName')) {
        actualUserName = args['userName'] as String;
      }
      if (args.containsKey('ageGroup')) {
        actualAgeGroup = args['ageGroup'] as int;
      }
    }
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Sky blue background gradient
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade200,
              Colors.lightBlue.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Cloud decorations
              Positioned(
                top: 20,
                left: 20,
                child: _buildCloudShape(60),
              ),
              Positioned(
                top: 40,
                right: 30,
                child: _buildCloudShape(80),
              ),
              Positioned(
                bottom: 100,
                right: 40,
                child: _buildCloudShape(70),
              ),
              
              // Main content layout
              Column(
                children: [
                  // Top navigation icons
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircularButton(Icons.home, Colors.blue.shade900, () {
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                        }),
                        _buildCircularButton(Icons.volume_up, Colors.amber, () {
                          // Toggle sound - this is for general UI sounds
                          // We'll leave this empty for now as it's handled by the flashcard audio
                        }),
                        _buildCircularButton(
                          _isBgMusicPlaying ? Icons.music_note : Icons.music_off,
                          _isBgMusicPlaying ? Colors.blue.shade800 : Colors.grey.shade600,
                          () {
                            _toggleBackgroundMusic();
                          }),
                      ],
                    ),
                  ),
                  
                  // Subject title bar
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade300,
                      borderRadius: BorderRadius.zero,
                    ),
                    width: double.infinity,
                    child: Text(
                      actualSubjectName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Comic Sans MS',
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Page content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return _buildPage(_pages[index]);
                      },
                    ),
                  ),
                  
                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Previous button
                        _buildNavigationButton(
                          Icons.arrow_back_ios,
                          Colors.green,
                          _currentPage > 0 ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } : null,
                        ),
                        const SizedBox(width: 80),
                        // Next button
                        _buildNavigationButton(
                          Icons.arrow_forward_ios,
                          Colors.green,
                          _currentPage < _pages.length - 1 ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(List<NoteContentElement> elements) {
    // With flashcard style, we should have exactly one element per page
    final element = elements.isNotEmpty ? elements.first : null;
    if (element == null) return Container();
    
    // Check if this is a flashcard (has both text and image)
    bool isFlashcard = false;
    String textContent = '';
    String imageUrl = '';
    String audioUrl = '';
    
    // For container elements with multiple child elements
    if (element is ContainerElement) {
      // Check if it has both text and image elements
      TextElement? textElement;
      ImageElement? imageElement;
      AudioElement? audioElement;
      
      for (var child in element.elements) {
        if (child is TextElement) textElement = child;
        if (child is ImageElement) imageElement = child;
        if (child is AudioElement) audioElement = child;
      }
      
      if (textElement != null && imageElement != null) {
        isFlashcard = true;
        textContent = textElement.content;
        imageUrl = imageElement.imageUrl ?? '';
        audioUrl = audioElement?.audioUrl ?? '';
        
        // Use our specialized flashcard builder
        // Schedule audio to play after the widget is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (audioUrl.isNotEmpty) {
            _playAudio(audioUrl);
          }
        });
        return _buildFlashcard(textContent, imageUrl, audioUrl);
      }
    }
    
    // For individual elements that aren't part of a flashcard
    // Extract title from content if it's a text element
    String title = '';
    String description = '';
    
    if (element is TextElement) {
      final content = element.content;
      if (content.contains('\n')) {
        final parts = content.split('\n');
        title = parts.first.trim();
        description = parts.sublist(1).join('\n').trim();
      } else if (content.contains('. ')) {
        final parts = content.split('. ');
        title = parts.first.trim() + '.';
        description = parts.sublist(1).join('. ').trim();
      } else {
        title = content;
        description = '';
      }
    } else if (element is ImageElement) {
      title = element.caption ?? 'Image';
      description = '';
    } else if (element is AudioElement) {
      title = element.title ?? 'Audio';
      description = 'Listen to the pronunciation';
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Content title if it exists
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: _getFontSizeForAge() + 4,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Main content
            _buildElement(element),
            
            // Content label at bottom (for images)
            if (element is ImageElement && title.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Specialized flashcard builder with our new design
  Widget _buildFlashcard(String text, String imageUrl, String audioUrl) {
    // Get first letter of the word for the top display
    String firstLetter = text.isNotEmpty ? text[0].toUpperCase() : '';
    
    // Generate background color based on the first letter
    Color backgroundColor = _getColorForLetter(firstLetter);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 400,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Large first letter at the top
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(1.0, 1.0),
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Image in center with white container
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey,
                        ),
                  ),
                ),
              ),
              
              // Word at the bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(1.0, 1.0),
                        blurRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          
          // Content audio button (top-right)
          if (audioUrl.isNotEmpty)
            Positioned(
              top: 20.0,
              right: 20.0,
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.0),
                    onTap: () => _playAudio(audioUrl),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.volume_up,
                        size: 24.0,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildElement(NoteContentElement element) {
    if (element is TextElement) {
      return _buildTextElement(element);
    } else if (element is ImageElement) {
      return _buildImageElement(element);
    } else if (element is AudioElement) {
      return _buildAudioElement(element);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildTextElement(TextElement element) {
    // Use the fixed implementation to avoid color parsing issues
    return fix.buildTextElement(element, _getFontSizeForAge, _parseColor);
  }

  Widget _buildImageElement(ImageElement element) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Rainbow decoration at the bottom
        Positioned(
          bottom: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              'https://www.freepnglogos.com/uploads/rainbow-png/rainbow-png-transparent-images-download-clip-art-10.png',
              width: 120,
              errorBuilder: (context, error, stackTrace) => Container(),
            ),
          ),
        ),
        
        // Main image
        Container(
          padding: const EdgeInsets.all(20),
          child: element.imageUrl != null && element.imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: element.imageUrl!,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image_not_supported, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      const Text(
                        'Image not available',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  fit: BoxFit.contain,
                  height: 250,
                )
              : Container(
                  height: 200,
                  color: Colors.transparent,
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.grey, size: 60),
                  ),
                ),
        ),
      ],
    );
  }

  // Build a cloud shape for the background
  Widget _buildCloudShape(double size) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
  
  // Build a circular button for the top navigation
  Widget _buildCircularButton(IconData icon, Color color, VoidCallback? onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
  
  // Build a navigation button (prev/next)
  Widget _buildNavigationButton(IconData icon, Color color, VoidCallback? onPressed) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 25),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
  
  // Play audio for flashcards
  Future<void> _playAudio(String url) async {
    if (url.isEmpty) return;
    
    try {
      await _flashcardAudioPlayer.stop();
      await _flashcardAudioPlayer.setUrl(url);
      await _flashcardAudioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }
  
  // Toggle background music
  Future<void> _toggleBackgroundMusic() async {
    try {
      if (_isBgMusicPlaying) {
        await _bgMusicPlayer.pause();
      } else {
        await _bgMusicPlayer.play();
      }
      
      setState(() {
        _isBgMusicPlaying = !_isBgMusicPlaying;
      });
    } catch (e) {
      debugPrint('Error toggling background music: $e');
    }
  }
  
  // Get a consistent color based on the first letter
  Color _getColorForLetter(String letter) {
    if (letter.isEmpty) return Colors.blue;
    
    // Map letters to colors
    final Map<String, Color> colorMap = {
      'A': Colors.red,
      'B': Colors.blue,
      'C': Colors.green,
      'D': Colors.orange,
      'E': Colors.purple,
      'F': Colors.teal,
      'G': Colors.pink,
      'H': Colors.indigo,
      'I': Colors.amber,
      'J': Colors.cyan,
      'K': Colors.deepOrange,
      'L': Colors.lightBlue,
      'M': Colors.lightGreen,
      'N': Colors.deepPurple,
      'O': Colors.brown,
      'P': Colors.blueGrey,
      'Q': Colors.lime,
      'R': Colors.red.shade800,
      'S': Colors.blue.shade800,
      'T': Colors.green.shade800,
      'U': Colors.orange.shade800,
      'V': Colors.purple.shade800,
      'W': Colors.teal.shade800,
      'X': Colors.pink.shade800,
      'Y': Colors.indigo.shade800,
      'Z': Colors.amber.shade800,
    };
    
    return colorMap[letter] ?? Colors.blue;
  }
  
  // Helper method to parse color strings safely
  Color _parseColor(String colorString) {
    try {
      // Check if it's a hex color with # prefix
      if (colorString.startsWith('#')) {
        // Remove the # and parse
        String hexColor = colorString.substring(1);
        // Add FF for alpha if it's a 6-digit hex
        if (hexColor.length == 6) {
          hexColor = 'FF$hexColor';
        }
        return Color(int.parse(hexColor, radix: 16));
      }
      // Otherwise try to parse it as a regular int
      return Color(int.parse(colorString));
    } catch (e) {
      print('Error parsing color: $colorString - $e');
      // Return a default color on error
      return Colors.black;
    }
  }

  Widget _buildAudioElement(AudioElement element) {
    // Create audio player if it doesn't exist
    if (!_audioPlayers.containsKey(element.id)) {
      _audioPlayers[element.id] = AudioPlayer();
      _audioPlayers[element.id]!.setUrl(element.audioUrl);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          children: [
            Row(
              children: [
                StreamBuilder<PlayerState>(
                  stream: _audioPlayers[element.id]!.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final playing = playerState?.playing;

                    // If audio is currently playing, show stop button
                    if (playing == true) {
                      return GestureDetector(
                        onTap: () {
                          _audioPlayers[element.id]!.pause();
                          setState(() {
                            _currentlyPlayingAudioId = null;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.stop,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      );
                    }

                    // Show play button
                    return GestureDetector(
                      onTap: () {
                        // Stop any currently playing audio
                        if (_currentlyPlayingAudioId != null &&
                            _currentlyPlayingAudioId != element.id) {
                          _audioPlayers[_currentlyPlayingAudioId]?.pause();
                        }

                        // Play this audio
                        _audioPlayers[element.id]!.play();
                        setState(() {
                          _currentlyPlayingAudioId = element.id;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        element.title ?? 'Listen',
                        style: TextStyle(
                          fontSize: _getFontSizeForAge(),
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to listen to the audio',
                        style: TextStyle(
                          fontSize: _getFontSizeForAge() - 4,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Audio progress bar
            StreamBuilder<Duration?>(
              stream: _audioPlayers[element.id]!.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = _audioPlayers[element.id]!.duration ?? Duration.zero;

                if (duration == Duration.zero) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: duration.inMilliseconds > 0
                          ? position.inMilliseconds / duration.inMilliseconds
                          : 0.0,
                      backgroundColor: Colors.orange.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: TextStyle(
                            fontSize: _getFontSizeForAge() - 6,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            fontSize: _getFontSizeForAge() - 6,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  double _getFontSizeForAge() {
    // Determine font size based on the child's age
    switch (_childAge) {
      case 4:
        return 24.0; // Larger font for younger children
      case 5:
        return 20.0; // Medium font
      case 6:
        return 18.0; // Smaller font for older children
      default:
        return 20.0; // Default size
    }
  }
}
