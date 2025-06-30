import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

import '../../models/note_content.dart';
import '../../services/content_service.dart';
import '../../services/score_service.dart';
import '../../widgets/child_ui_style.dart';
import '../../admin_module/content_management/note_template/widgets/note_completion_dialog.dart';
import 'fixed_text_element.dart' as fix;

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
  final String language; // Added language parameter

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
    this.language = 'ms', // Default to Malay language
  }) : super(key: key);

  @override
  State<NoteViewerScreen> createState() => _NoteViewerScreenState();
}

class _NoteViewerScreenState extends State<NoteViewerScreen> {
  final ContentService _contentService = ContentService();
  final ScoreService _scoreService = ScoreService();
  
  // Page controller for swipe navigation
  late PageController _pageController;
  int _currentPage = 0;
  
  // Note content organized into pages
  List<List<NoteContentElement>> _pages = [];
  
  // Child's age for adapting content
  int _childAge = 5; // Default age
  
  // Scoring variables
  bool _scoreSubmitted = false;
  bool _completedReading = false;
  bool _showCompletionScreen = false;
  int _earnedPoints = 0;
  DateTime _startTime = DateTime.now();
  
  // Audio players for note content and flashcards
  final Map<String, AudioPlayer> _audioPlayers = <String, AudioPlayer>{};
  AudioPlayer? _audioPlayer; // For flashcard audio
  AudioPlayer? _backgroundMusicPlayer; // For background music
  String? _currentlyPlayingAudioId;
  bool _isBackgroundMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    print('NoteViewerScreen - initState called');
    print('Note ID: ${widget.note.id}');
    print('Note title: ${widget.note.title}');
    print('Note elements count: ${widget.note.elements.length}');
    if (widget.note.elements.isNotEmpty) {
      print('First element type: ${widget.note.elements.first.type}');
    } else {
      print('WARNING: Note has no elements!');
    }
    
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
      
      _backgroundMusicPlayer = AudioPlayer();
      try {
        await _backgroundMusicPlayer!.setUrl(bgMusicUrl);
        await _backgroundMusicPlayer!.setLoopMode(LoopMode.one); // Loop the music
      } catch (error) {
        debugPrint('Error setting background music URL: $error');
        // Use a fallback URL or asset if available
      }
      _isBackgroundMusicPlaying = false; // Initialize to false
    } catch (e) {
      debugPrint('Error setting up background music: $e');
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    
    // Dispose of all audio players in the map
    for (final player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
    
    // Dispose of flashcard audio player
    _audioPlayer?.dispose();
    
    // Dispose of background music player
    _backgroundMusicPlayer?.dispose();
    
    super.dispose();
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
        
        // Only check completion when we reach the last page
        if (page == _pages.length - 1) {
          _checkCompletion();
        }
      }
    }
  }

  // Submit score when the user completes reading the note
  void _checkCompletion() {
    if (_currentPage == _pages.length - 1 && !_scoreSubmitted) {
      _submitScore();
    }
  }
  
  // Submit score to the database
  Future<void> _submitScore() async {
    if (_scoreSubmitted) return; // Prevent duplicate submissions
    
    try {
      // Always use 100 points as requested
      const int totalPoints = 100;
      
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
      
      // Always use 5 stars as requested
      const int stars = 5;
      
      // Show completion dialog with animation
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'Note Completion',
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation1, animation2) {
          return NoteCompletionDialog(
            points: totalPoints,
            stars: stars,
            subject: widget.subjectName,
            minutes: studyMinutes,
            onTryAgain: () {
              // Reset to first page
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              Navigator.of(context).pop();
            },
            onContinue: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to chapter selection
            },
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          );
        },
      );
    } catch (e) {
      print('Error submitting score: $e');
    }
  }



  void _groupElementsIntoPages() {
    print('_groupElementsIntoPages called');
    final elements = widget.note.elements;
    print('Processing ${elements.length} elements');
    
    List<List<NoteContentElement>> pages = [];
    
    // First, check if there are flashcard elements
    List<NoteContentElement> flashcardElements = [];
    List<NoteContentElement> otherElements = [];
    
    for (var element in elements) {
      if (element.type == 'flashcard') {
        flashcardElements.add(element);
      } else {
        otherElements.add(element);
      }
    }
    
    print('Found ${flashcardElements.length} flashcard elements and ${otherElements.length} other elements');
    
    // If we have flashcards, each flashcard gets its own page
    if (flashcardElements.isNotEmpty) {
      print('Creating pages for flashcards - one page per flashcard');
      for (var flashcard in flashcardElements) {
        pages.add([flashcard]);
      }
    } else {
      // For non-flashcard content, group by age-appropriate counts
      print('No flashcards found, grouping other elements by age');
      List<NoteContentElement> currentPage = [];
      
      // Determine max elements per page based on age
      int maxElementsPerPage;
      switch (widget.ageGroup) {
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
      print('Max elements per page for age ${widget.ageGroup}: $maxElementsPerPage');
      
      for (var element in otherElements) {
        // If we've reached max elements per page
        if (currentPage.length >= maxElementsPerPage) {
          pages.add(List.from(currentPage));
          currentPage.clear();
        }
        
        currentPage.add(element);
      }
      
      // Add the last page if not empty
      if (currentPage.isNotEmpty) {
        pages.add(List.from(currentPage));
      }
    }
    
    print('Created ${pages.length} pages');
    for (var i = 0; i < pages.length; i++) {
      print('Page $i has ${pages[i].length} elements');
    }
    
    setState(() {
      _pages = pages;
      print('_pages updated with ${_pages.length} pages');
    });
  }

  void _handleNextAfterCompletion() {
    Navigator.of(context).pop(true); // Return with refresh flag
  }

  @override
  Widget build(BuildContext context) {
    // We're now using ActivityCompletionScreen which is shown as an overlay
    // So we don't need this code anymore
    
    print('Build method called');
    print('Pages count: ${_pages.length}');
    if (_pages.isEmpty) {
      print('WARNING: No pages available to display!');
    } else {
      for (var i = 0; i < _pages.length; i++) {
        print('Page $i has ${_pages[i].length} elements');
      }
    }
    
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
                  // App bar with back button - similar to admin preview UI
                  Container(
                    color: Colors.indigo.shade700,
                    padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 16),
                    child: Row(
                      children: [
                        // Back button
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(width: 8),
                        // Chapter name in dark blue header
                        Expanded(
                          child: Text(
                            actualChapterName, // Display chapter name from Firebase
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Background music toggle button
                        IconButton(
                          icon: Icon(
                            _isBackgroundMusicPlaying ? Icons.music_note : Icons.music_off,
                            color: Colors.white,
                          ),
                          onPressed: _toggleBackgroundMusic,
                        ),
                      ],
                    ),
                  ),
                  
                  // Blue header with chapter title - similar to admin preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade400,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      actualNote.title, // Display the note title from Firebase
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Comic Sans MS',
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Page content
                  Expanded(
                    child: _pages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'No note content available',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Note ID: ${actualNote.id}\nTitle: ${actualNote.title}\nElements: ${actualNote.elements.length}',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            print('Page changed to index: $index');
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: _pages.length,
                          itemBuilder: (context, index) {
                            print('Building page at index: $index');
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
    print('_buildPage called with ${elements.length} elements');
    
    // Check if this page contains a flashcard element
    bool hasFlashcard = elements.any((element) => element.type == 'flashcard');
    
    if (hasFlashcard) {
      // Extract flashcard data
      NoteContentElement flashcardElement = elements.firstWhere((element) => element.type == 'flashcard');
      Map<String, dynamic> flashcardData = flashcardElement.toJson();
      
      // Extract required fields with better error handling
      String text = flashcardData['description'] ?? flashcardData['title'] ?? '';
      String imageUrl = flashcardData['imageAsset'] ?? '';
      String audioUrl = flashcardData['audioUrl'] ?? '';
      
      print('Building flashcard with text: $text, image: $imageUrl, audio: $audioUrl');
      
      // Extract letter from the flashcard data
      String letter = '';
      if (flashcardData.containsKey('letter')) {
        letter = flashcardData['letter'] as String? ?? '';
      }
      
      // Build specialized flashcard UI
      return _buildFlashcard(text, imageUrl, audioUrl, letter, widget.language);
    }
    
    // Check if this is a container-based flashcard (has both text and image)
    bool isFlashcard = false;
    String textContent = '';
    String imageUrl = '';
    String audioUrl = '';
    
    // For container elements with multiple child elements
    if (elements.length == 1 && elements.first is ContainerElement) {
      // Check if it has both text and image elements
      TextElement? textElement;
      ImageElement? imageElement;
      AudioElement? audioElement;
      
      final containerElement = elements.first as ContainerElement;
      for (var childElement in containerElement.elements) {
        if (childElement is TextElement) {
          textElement = childElement;
          textContent = childElement.content;
        } else if (childElement is ImageElement) {
          imageElement = childElement;
          imageUrl = childElement.imageUrl;
        } else if (childElement is AudioElement) {
          audioElement = childElement;
          audioUrl = childElement.audioUrl;
        }
      }
      
      // If we have both text and image, treat as a flashcard
      if (textElement != null && imageElement != null) {
        isFlashcard = true;
        // Generate letter from text content if needed
        String letterToUse = '';
        if (textContent.isNotEmpty) {
          final firstChar = textContent.substring(0, 1).toUpperCase();
          letterToUse = '$firstChar${firstChar.toLowerCase()}';
        }
        return _buildFlashcard(textContent, imageUrl, audioUrl, letterToUse, widget.language);
      }
    }
    
    // For image and text pairs (not in a container)
    if (elements.length == 2) {
      TextElement? textElement;
      ImageElement? imageElement;
      AudioElement? audioElement;
      
      for (var element in elements) {
        if (element is TextElement) {
          textElement = element;
          textContent = element.content;
        } else if (element is ImageElement) {
          imageElement = element;
          imageUrl = element.imageUrl;
        } else if (element is AudioElement) {
          audioElement = element;
          audioUrl = element.audioUrl;
        }
      }
      
      // If we have both text and image, treat as a flashcard
      if (textElement != null && imageElement != null) {
        isFlashcard = true;
        // Generate letter from text content if needed
        String letterToUse = '';
        if (textContent.isNotEmpty) {
          final firstChar = textContent.substring(0, 1).toUpperCase();
          letterToUse = '$firstChar${firstChar.toLowerCase()}';
        }
        return _buildFlashcard(textContent, imageUrl, audioUrl, letterToUse, widget.language);
      }
    }
    
    // If we have a single image with a title, treat as a simple flashcard
    if (elements.length == 1 && elements.first is ImageElement) {
      final imageElement = elements.first as ImageElement;
      imageUrl = imageElement.imageUrl;
      textContent = imageElement.caption ?? '';
      
      // Extract letter from text content if needed
      String letter = '';
      if (textContent.isNotEmpty) {
        final firstChar = textContent.substring(0, 1).toUpperCase();
        letter = '$firstChar${firstChar.toLowerCase()}';
      }
      
      return _buildFlashcard(textContent, imageUrl, '', letter, widget.language);
    }
    
    // For regular elements, build a scrollable list view
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: elements.length,
        itemBuilder: (context, index) {
          return _buildElement(elements[index]);
        },
      ),
    );
  }
  
  // Specialized flashcard builder with our new design - matching admin preview UI
  Widget _buildFlashcard(String text, String imageUrl, String audioUrl, String letter, [String language = 'ms']) {
    // If no letter is provided, use the first letter of the text
    if (letter.isEmpty && text.isNotEmpty) {
      final firstChar = text.substring(0, 1).toUpperCase();
      letter = '$firstChar${firstChar.toLowerCase()}';
    }
    
    print('Building flashcard with letter: $letter, text: $text');

    
    // Use white background with rounded corners like in admin module
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Letter at the top (e.g., "Aa") - pink color as shown in image
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
                fontFamily: _getFontForLanguage(language),
              ),
            ),
          ),
          
          // Image in the middle
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Center(
                child: Builder(builder: (context) {
                  print('Attempting to load image: $imageUrl');
                  
                  // Check if the asset path is valid
                  if (imageUrl.isEmpty) {
                    return const Center(
                      child: Text('No image available', style: TextStyle(color: Colors.grey)),
                    );
                  }
                  
                  // Handle asset images
                  if (imageUrl.startsWith('assets/')) {
                    return Image.asset(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading asset image: $error');
                        return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                      },
                    );
                  } else {
                    // Handle network images
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) {
                        print('Error loading network image: $error');
                        return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                      },
                    );
                  }
                }),
              ),
            ),
          ),
          
          // Text content below the image
          if (text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _getFontSizeForAge(),
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontFamily: _getFontForLanguage(language),
                ),
              ),
            ),
          
          // Audio button at the bottom
          if (audioUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25.0),
                    onTap: () => _playAudio(audioUrl),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.volume_up,
                        size: 30.0,
                        color: Colors.white,
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
    print('Building element of type: ${element.type}');
  
    if (element.type == 'flashcard') {
      // Extract flashcard data from the element
      String text = '';
      String imageUrl = '';
      String audioUrl = '';
      String extractedLetter = ''; // Renamed from 'letter' to avoid conflict
      String language = widget.language; // Default to widget language
      
      // Try to extract data from the element
      try {
        final data = element.toJson();
        print('Flashcard data: $data');
        
        // CRITICAL: Extract the letter directly from the top-level field
        if (data.containsKey('letter')) {
          extractedLetter = data['letter'] as String? ?? '';
          print('Found letter in top-level field: $extractedLetter');
        }
        
        // Extract image from imageAsset field
        if (data.containsKey('imageAsset')) {
          imageUrl = data['imageAsset'] as String? ?? '';
          print('Found imageAsset: $imageUrl');
        }
        
        // Extract age-appropriate description
        if (data.containsKey('descriptions') && data['descriptions'] is Map) {
          final descriptions = data['descriptions'] as Map;
          String ageKey = widget.ageGroup.toString();
          
          // Try to get description for the child's age group
          if (descriptions.containsKey(ageKey)) {
            text = descriptions[ageKey] as String? ?? '';
            print('Using age-appropriate description for age ${widget.ageGroup}: $text');
          }
          // Fallback to age 5 description if the specific age isn't available
          else if (descriptions.containsKey('5')) {
            text = descriptions['5'] as String? ?? '';
            print('Using age 5 description as fallback: $text');
          }
          // Fallback to any available description
          else if (descriptions.isNotEmpty) {
            final firstKey = descriptions.keys.first.toString();
            text = descriptions[firstKey] as String? ?? '';
            print('Using description for age $firstKey as fallback: $text');
          }
        }
        
        // Extract language information if available in metadata
        if (data.containsKey('metadata') && data['metadata'] is Map) {
          final metadata = data['metadata'] as Map;
          if (metadata.containsKey('language')) {
            language = metadata['language'] as String? ?? widget.language;
            print('Found language in metadata: $language');
          }
        }
        
        // If no description found, try using title
        if (text.isEmpty && data.containsKey('title')) {
          text = data['title'] as String? ?? '';
          print('Using title as fallback: $text');
        }
        
        // Generate letter from text content if not already extracted
        String textContent = text;
        if (extractedLetter.isEmpty && textContent.isNotEmpty) {
          final firstChar = textContent.substring(0, 1).toUpperCase();
          extractedLetter = '$firstChar${firstChar.toLowerCase()}';
        }  
        print('Final letter to use: $extractedLetter');
        
        print('Extracted flashcard - text: $text, imageUrl: $imageUrl, letter: $extractedLetter, language: $language');
        return _buildFlashcard(text, imageUrl, audioUrl, extractedLetter, language);
      } catch (e) {
        print('Error processing flashcard: $e');
      }
    } else if (element is TextElement) {
      return _buildTextElement(element);
    } else if (element is ImageElement) {
      return _buildImageElement(element);
    } else if (element is AudioElement) {
      return _buildAudioElement(element);
    }
    
    // Fallback for unknown element types
    print('Unknown element type: ${element.type}');
    return Center(
      child: Text('Unsupported element type: ${element.type}'),
    );
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
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer();
      }
      
      await _audioPlayer!.stop();
      await _audioPlayer!.setUrl(url);
      await _audioPlayer!.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }
  
  // Toggle background music
  Future<void> _toggleBackgroundMusic() async {
    try {
      if (_backgroundMusicPlayer == null) {
        _backgroundMusicPlayer = AudioPlayer();
        _isBackgroundMusicPlaying = false;
        return;
      }
      
      if (_isBackgroundMusicPlaying) {
        await _backgroundMusicPlayer!.pause();
      } else {
        await _backgroundMusicPlayer!.play();
      }
      
      setState(() {
        _isBackgroundMusicPlaying = !_isBackgroundMusicPlaying;
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
                  stream: _audioPlayers[element.id]?.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final playing = playerState?.playing;
                    final currentPlayingId = _currentlyPlayingAudioId;

                    // If audio is currently playing, show stop button
                    if (playing == true) {
                      return GestureDetector(
                        onTap: () {
                          _audioPlayers[element.id]?.pause();
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

                    // Otherwise show play button
                    return GestureDetector(
                      onTap: () {
                        // Stop any currently playing audio
                        if (currentPlayingId != null &&
                            currentPlayingId != element.id &&
                            _audioPlayers.containsKey(currentPlayingId)) {
                          _audioPlayers[currentPlayingId]?.pause();
                        }

                        // Play this audio
                        _audioPlayers[element.id]?.play();
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
              stream: _audioPlayers[element.id]?.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = _audioPlayers[element.id]?.duration ?? Duration.zero;

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

  // Format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  double _getFontSizeForAge() {
    // Determine font size based on the child's age
    int age = widget.ageGroup;
    
    switch (age) {
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
  
  // Helper method to get the appropriate font family based on language
  String _getFontForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'ar': // Arabic
        return 'Amiri'; // Arabic font
      case 'jw': // Jawi
        return 'Scheherazade'; // Font suitable for Jawi
      case 'zh': // Chinese
        return 'Noto Sans SC';
      case 'ms': // Malay
      default:
        return 'Roboto'; // Default font for Latin scripts
    }
  }
}
