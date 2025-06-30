import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import '../../../models/note_content.dart';
import '../../../models/container_element.dart';
import '../../../models/subject.dart';
import '../../../models/chapter.dart';
import 'widgets/note_completion_dialog.dart';
import '../../../services/flashcard_service.dart';
import '../../../services/flashcard_media_service.dart';
import 'flashcard_template_generator_complete.dart';
import '../../../utils/language_detector.dart';
import '../../../models/flashcard_element.dart' as custom_flashcard;

class EnhancedNotePreviewScreen extends StatefulWidget {
  final dynamic subject;
  final dynamic chapter;
  final int age;
  final String language;
  final String templateName;

  const EnhancedNotePreviewScreen({
    Key? key,
    required this.subject,
    required this.chapter,
    required this.age,
    required this.language,
    this.templateName = 'Flashcard',
  }) : super(key: key);

  @override
  State<EnhancedNotePreviewScreen> createState() => _EnhancedNotePreviewScreenState();
}

class _EnhancedNotePreviewScreenState extends State<EnhancedNotePreviewScreen> {
  // Background music player
  AudioPlayer? _bgMusicPlayer;
  bool _isMusicPlaying = false;
  bool _bgMusicAvailable = false;
  
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _noteTitle = '';
  String _noteDescription = '';
  List<NoteContentElement> _noteElements = [];
  
  // Age group for flashcard descriptions
  late int _selectedAgeGroup;
  
  // Initialize the flashcard service
  final FlashcardService _flashcardService = FlashcardService();
  // final GeminiNotesService _geminiService = GeminiNotesService(); // Remove Gemini dependency
  
  // Page view controller
  late PageController _pageController;
  int _currentPage = 0;
  
  // Language and text direction
  bool _isRTL = false;
  String _detectedLanguage = 'en';
  // Add Amiri font to pubspec.yaml if not already added
  String _fontFamily = 'Roboto';
  
  // Variables for completion tracking
  DateTime _startTime = DateTime.now();
  int _studyMinutes = 0;
  bool _showingCompletionDialog = false;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTime = DateTime.now(); // Record start time for completion tracking
    _selectedAgeGroup = widget.age;
    
    // Initialize audio player safely
    try {
      _bgMusicPlayer = AudioPlayer();
      _bgMusicAvailable = true;
    } catch (e) {
      print('Could not initialize audio player: $e');
      _bgMusicAvailable = false;
    }
    
    _loadNoteContent();
    
    // Initialize background music only if audio player is available
    if (_bgMusicAvailable) {
      _initBackgroundMusic();
    }
    
    // Debug print for language and font
    print('Language: ${widget.language}, Font: $_fontFamily, RTL: $_isRTL');
    print('Selected age group: $_selectedAgeGroup');
  }

  // Initialize background music
  Future<void> _initBackgroundMusic() async {
    if (_bgMusicPlayer == null || !_bgMusicAvailable) {
      setState(() {
        _isMusicPlaying = false;
      });
      return;
    }
    
    try {
      // Check if the asset exists first
      bool assetExists = true;
      try {
        await _bgMusicPlayer!.setAsset('assets/bg_music.mp3');
      } catch (e) {
        print('Background music asset not found: $e');
        assetExists = false;
      }
      
      if (assetExists) {
        await _bgMusicPlayer!.setLoopMode(LoopMode.all); // Loop continuously
        await _bgMusicPlayer!.play();
        setState(() {
          _isMusicPlaying = true;
        });
      } else {
        // Silently fail if the asset doesn't exist
        setState(() {
          _isMusicPlaying = false;
        });
      }
    } catch (e) {
      print('Error playing background music: $e');
      // Make sure we set the state to not playing
      setState(() {
        _isMusicPlaying = false;
      });
    }
  }
  
  // Toggle background music
  void _toggleBackgroundMusic() {
    if (_bgMusicPlayer == null || !_bgMusicAvailable) {
      setState(() {
        _isMusicPlaying = false;
      });
      return;
    }
    
    try {
      if (_isMusicPlaying) {
        _bgMusicPlayer!.pause();
      } else {
        _bgMusicPlayer!.play();
      }
      setState(() {
        _isMusicPlaying = !_isMusicPlaying;
      });
    } catch (e) {
      print('Error toggling background music: $e');
      // If there's an error, assume music is not playing
      setState(() {
        _isMusicPlaying = false;
      });
    }
  }
  
  // Load note content
  Future<void> _loadNoteContent() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Set the note title based on subject and chapter
      String subjectName;
      String chapterName;
      
      // Extract subject name
      if (widget.subject is String) {
        subjectName = widget.subject as String;
      } else if (widget.subject != null) {
        subjectName = widget.subject.name;
      } else {
        subjectName = 'General';
      }
      
      // Extract chapter name
      if (widget.chapter is String) {
        chapterName = widget.chapter as String;
      } else if (widget.chapter != null) {
        chapterName = widget.chapter.name;
      } else {
        chapterName = 'Introduction';
      }
      
      _noteTitle = '$subjectName: $chapterName';
      
      // Generate flashcard elements using our static generator
      String subjectStr = subjectName;
      String chapterStr = chapterName;
      
      // Generate flashcards using the template generator
      final customFlashcardElements = FlashcardTemplateGenerator.generateFlashcardElements(
        subject: subjectStr,
        chapter: chapterStr,
        age: widget.age,
        language: widget.language,
      );
      
      // Convert custom FlashcardElement objects to NoteContentElement objects
      _noteElements = customFlashcardElements.map<NoteContentElement>((element) => 
        FlashcardElement(
          id: element.id,
          position: element.position,
          createdAt: element.createdAt,
          title: element.title,
          letter: element.letter,
          imageAsset: element.imageAsset,
          descriptions: element.descriptions,
          cardColor: element.cardColor,
          metadata: element.metadata,
        )
      ).toList();
      
      // Set the selected age group from widget
      _selectedAgeGroup = widget.age;
    } catch (e) {
      print('Error loading note data: $e');
      // Fallback to sample elements if there's an error
      _noteElements = _createSampleElements();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Show completion dialog with fixed score of 100 and 5 stars
  void _showCompletionDialog() {
    setState(() {
      _showingCompletionDialog = true;
    });
    
    // Calculate study time in minutes
    final now = DateTime.now();
    final duration = now.difference(_startTime);
    _studyMinutes = (duration.inSeconds / 60).ceil(); // Round up to nearest minute
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NoteCompletionDialog(
        points: 100, // Fixed score of 100
        stars: 5,    // Fixed 5 stars
        subject: widget.subject.name,
        minutes: _studyMinutes,
        onTryAgain: () {
          Navigator.of(context).pop();
          setState(() {
            _currentPage = 0;
            _pageController.jumpToPage(0);
            _showingCompletionDialog = false;
          });
        },
        onContinue: () {
          Navigator.of(context).pop();
          setState(() {
            _showingCompletionDialog = false;
          });
        },
      ),
    );
  }
  
  @override
  void dispose() {
    // Safely dispose the audio player if it exists
    if (_backgroundMusicPlayer != null) {
      try {
        _backgroundMusicPlayer!.dispose();
      } catch (e) {
        print('Error disposing audio player: $e');
      }
    }
    
    _pageController.dispose();
    super.dispose();
  }
  

  
  List<NoteContentElement> _createSampleElements() {
    final timestamp = Timestamp.now();
    
    // Create different sample content based on age
    switch (widget.age) {
      case 4:
        // Age 4: Simple image with label and auto-play audio
        return _createAge4SampleElements(timestamp);
      case 5:
        // Age 5: Image with short paragraph and play button
        return _createAge5SampleElements(timestamp);
      case 6:
      default:
        // Age 6+: Image with detailed paragraph and optional audio
        return _createAge6SampleElements(timestamp);
    }
  }
  
  List<NoteContentElement> _createAge4SampleElements(Timestamp timestamp) {
    // We'll use Timestamp.now() instead of the passed timestamp
    // For age 4: Simple image with label and auto-play audio
    List<NoteContentElement> elements = [];
    
    // A for Ant flashcard
    elements.add(ImageElement(
      id: 'image_age4',
      position: 1,
      createdAt: Timestamp.now(),
      imageUrl: 'https://picsum.photos/id/237/300/200',  // Dog image from Lorem Picsum
      caption: '',
    ));
    
    elements.add(TextElement(
      id: 'ant_label',
      position: 2,
      createdAt: Timestamp.now(),
      content: "• A is for Ant",
      isBold: true,
      fontSize: 24.0,
    ));
    
    elements.add(AudioElement(
      id: 'audio_age4',
      position: 3,
      createdAt: Timestamp.now(),
      audioUrl: 'https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg',
      title: 'Ant',
      duration: 2,
      metadata: {'autoPlay': true},
    ));
    
    return elements;
  }
  
  List<NoteContentElement> _createAge5SampleElements(Timestamp timestamp) {
    // We'll use Timestamp.now() instead of the passed timestamp
    // For age 5: Image with short paragraph and play button
    List<NoteContentElement> elements = [];
    
    elements.add(ImageElement(
      id: 'image_age5',
      position: 1,
      createdAt: Timestamp.now(),
      imageUrl: 'https://picsum.photos/id/40/300/200',  // Cat image from Lorem Picsum
      caption: '',
    ));
    
    elements.add(TextElement(
      id: 'cat_text',
      position: 2,
      createdAt: Timestamp.now(),
      content: "The letter C is for Cat, which says 'meow'.",
      isBold: false,
      fontSize: 22.0,
    ));
    
    elements.add(AudioElement(
      id: 'audio_age5',
      position: 3,
      createdAt: Timestamp.now(),
      audioUrl: 'https://actions.google.com/sounds/v1/animals/cat_purr_close.ogg',
      title: 'Cat',
      duration: 4,
      metadata: {'showPlayButton': true},
    ));
    
    return elements;
  }
  
  List<NoteContentElement> _createAge6SampleElements(Timestamp timestamp) {
    // We'll use Timestamp.now() instead of the passed timestamp
    // For age 6+: Image with detailed paragraph and optional audio
    List<NoteContentElement> elements = [];
    
    elements.add(ImageElement(
      id: 'image_age6',
      position: 1,
      createdAt: Timestamp.now(),
      imageUrl: 'https://picsum.photos/id/1074/300/200',  // Bear image from Lorem Picsum
      caption: '',
    ));
    
    elements.add(TextElement(
      id: 'bear_text',
      position: 2,
      createdAt: Timestamp.now(),
      content: "Bears are large mammals with fur, non-retractable claws, short tails, and excellent sense of smell. They eat both plants and animals and can be found in forests, mountains, and arctic regions.",
      isBold: false,
      fontSize: 20.0,
    ));
    
    elements.add(AudioElement(
      id: 'bear_audio',
      position: 3,
      createdAt: Timestamp.now(),
      audioUrl: 'https://actions.google.com/sounds/v1/animals/bear_growl.ogg',
      title: 'About Bears',
      duration: 8,
      metadata: {'showPlayButton': true},
    ));
    
    return elements;
  }
  
  // Audio playback functionality has been removed as we only use background music
  // This method is kept as a placeholder in case audio functionality needs to be restored later
  void _placeholderAudioMethod() {
    // No implementation needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not play audio: Failed to load URL')),
    );
  }
  
  // Helper method to check if an asset exists
  Future<bool> _checkAssetExists(String assetPath) async {
    try {
      // Try to load the asset as a ByteData
      await DefaultAssetBundle.of(context).load(assetPath);
      print('Asset exists: $assetPath');
      return true;
    } catch (e) {
      print('Asset does not exist: $assetPath - $e');
      return false;
    }
  }
  
  // Build a single flashcard
  Widget _buildFlashcard(FlashcardElement flashcard) {
    
    return GestureDetector(
      onTap: () {
        // Card tap action (audio removed)
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Letter at the top (e.g., "Mm")
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                flashcard.letter,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                  fontFamily: _fontFamily,
                ),
              ),
            ),
            
            // Image in the middle
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Builder(builder: (context) {
                  // Debug print the image asset path
                  print('Attempting to load image: ${flashcard.imageAsset}');
                  
                  // Check if the asset path is valid
                  if (flashcard.imageAsset.isEmpty) {
                    return const Center(
                      child: Text('No image path specified', style: TextStyle(color: Colors.red)),
                    );
                  }
                  
                  // Try to load the specific image first
                  return FutureBuilder<bool>(
                    // Check if the asset exists
                    future: _checkAssetExists(flashcard.imageAsset),
                    builder: (context, snapshot) {
                      // If asset exists, use it
                      if (snapshot.hasData && snapshot.data == true) {
                        return Image.asset(
                          flashcard.imageAsset,
                          fit: BoxFit.contain,
                        );
                      } 
                      // If asset doesn't exist or check failed, try the fallback
                      else {
                        // Try to use a generic placeholder based on subject
                        final subjectFolder = flashcard.metadata?['subject']?.toString().toLowerCase() ?? 'malay';
                        final fallbackPath = 'assets/logo.png';
                        
                        print('Using fallback image: $fallbackPath for ${flashcard.imageAsset}');
                        
                        return Image.asset(
                          fallbackPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading fallback image: $fallbackPath - $error');
                            // If even fallback fails, show error UI
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  color: Colors.grey[200],
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey[400]),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Title: ${flashcard.title}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Text(
                                  'Path: ${flashcard.imageAsset}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  );
                }),
              ),
            ),
            
            // Description at the bottom
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                flashcard.getDescription(_selectedAgeGroup),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontFamily: _fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade700,
        elevation: 4,
        title: Text(
          'Preview: $_noteTitle',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Publish button
          TextButton.icon(
            icon: const Icon(Icons.publish, color: Colors.white),
            label: const Text('Publish', style: TextStyle(color: Colors.white)),
            onPressed: _publishNote,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorView()
              : _buildKidFriendlyNotePreview(),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text('Error: $_errorMessage'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNoteContent,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
  
  // Original note preview method - kept for reference
  Widget _buildNotePreview() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _noteTitle,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              fontFamily: _fontFamily,
            ),
            textAlign: TextAlign.center,
            textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
        Expanded(
          child: Directionality(
            textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _noteElements.length,
              itemBuilder: (context, index) {
                return _buildKidFriendlyElement(_noteElements[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
  
  // New kid-friendly note preview with rainbow background and navigation buttons
  Widget _buildKidFriendlyNotePreview() {
    // Group elements into pages/cards for the PageView based on age
    List<List<dynamic>> pages = [];
    
    // If there are no elements, create an empty page
    if (_noteElements.isEmpty) {
      pages.add([]);
    } else {
      // First, check if we have container elements - each container becomes a separate page
      // Get container elements if any
      List<ContainerElement> containers = _noteElements
          .where((element) => element is ContainerElement)
          .map((e) => e as ContainerElement)
          .toList();
      
      // If we have containers, each becomes a separate page with its elements
      if (containers.isNotEmpty) {
        for (var container in containers) {
          if (container.elements.isNotEmpty) {
            pages.add(container.elements);
          }
        }
      }
      
      // If no containers or no elements in containers, fall back to the original grouping logic
      if (pages.isEmpty) {
        // For age 4: Group by letter flashcards (image + label + audio)
        // For age 5-6: Group by content type (image + text + audio)
        
        // First, identify all audio elements
        Map<String, dynamic> audioElements = {};
        for (var element in _noteElements) {
          if (element is AudioElement) {
            audioElements[element.id] = element;
          }
        }
        
        // Force creation of at least 3 pages by splitting elements
        if (_noteElements.length >= 3) {
          int elementsPerPage = (_noteElements.length / 3).ceil();
          for (int i = 0; i < _noteElements.length; i += elementsPerPage) {
            int end = (i + elementsPerPage < _noteElements.length) ? i + elementsPerPage : _noteElements.length;
            pages.add(_noteElements.sublist(i, end));
          }
          // Skip the rest of the processing since we've already created pages
          // Don't return early, just continue with the normal flow
        }
      }
      
      // For all ages, create flashcards with image and text on the same page
      // First, organize elements by type for easier matching
      List<ImageElement> imageElements = [];
      List<TextElement> textElements = [];
      List<AudioElement> audioElements = [];
      List<FlashcardElement> flashcardElements = [];
      
      for (var element in _noteElements) {
        if (element is ImageElement) {
          imageElements.add(element);
        } else if (element is TextElement) {
          textElements.add(element);
        } else if (element is AudioElement) {
          audioElements.add(element);
        } else if (element is FlashcardElement) {
          flashcardElements.add(element);
        }
      }
      
      // Clear existing pages
      pages.clear();
      
      // If we have FlashcardElement objects, create one page per flashcard
      if (flashcardElements.isNotEmpty) {
        // Each flashcard gets its own page
        for (var flashcard in flashcardElements) {
          pages.add([flashcard]);
        }
      } else {
        // Fall back to the original logic for other element types
        // Match images with their corresponding text by position
        // This ensures each flashcard has one concept (image + related text)
        int maxElements = imageElements.length > textElements.length ? 
                          imageElements.length : textElements.length;
        
        for (int i = 0; i < maxElements; i++) {
          List<dynamic> flashcard = [];
          
          // Add image if available for this position
          if (i < imageElements.length) {
            flashcard.add(imageElements[i]);
          }
          
          // Add text if available for this position
          if (i < textElements.length) {
            flashcard.add(textElements[i]);
          }
          
          // Only add non-empty flashcards
          if (flashcard.isNotEmpty) {
            pages.add(flashcard);
          }
        }
      }
      
      // Ensure we have at least one page
      if (pages.isEmpty) {
        pages.add(_noteElements);
      }
      
      print('Created ${pages.length} flashcard pages');
      for (int i = 0; i < pages.length; i++) {
        print('Page $i has ${pages[i].length} elements');
      }
      
      // If no pages were created, create one with all elements
      if (pages.isEmpty) {
        pages.add(_noteElements);
      }
    }
    
    return Stack(
      children: [
        // Rainbow background
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/rainbow.png'),
              fit: BoxFit.cover,
            ),
            color: Color(0xFFAEE1F9), // Light blue background as fallback
          ),
        ),
        
        // No cloud decorations as they're already in the background
        
        // Content area
        Column(
          children: [
            // Title at the top
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade300,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _noteTitle,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: _fontFamily,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
              ),
            ),
            
            // PageView for flashcards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(), // Add physics for better scrolling
                  onPageChanged: (index) {
                    print('Page changed to $index');
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return _buildFlashcardPage(pages[index]);
                  },
                ),
              ),
            ),
            
            // Navigation controls at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous button
                  _buildCircularButton(
                    icon: Icons.arrow_back_rounded,
                    color: Colors.red.shade500,
                    onPressed: _currentPage > 0
                      ? () {
                          print('Moving to previous page: ${_currentPage - 1}');
                          
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  ),
                  
                  // Next button
                  _buildCircularButton(
                    icon: Icons.arrow_forward_rounded,
                    color: Colors.green.shade500,
                    onPressed: _currentPage < pages.length - 1
                      ? () {
                          print('Moving to next page: ${_currentPage + 1} of ${pages.length}');
                          
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : () {
                          // Show completion dialog when reaching the last page
                          if (!_showingCompletionDialog) {
                            _showCompletionDialog();
                          }
                        },
                  ),
                  
                  // Background music toggle button
                  _buildCircularButton(
                    icon: _isMusicPlaying ? Icons.music_note_rounded : Icons.music_off_rounded,
                    color: Colors.purple.shade400,
                    onPressed: () {
                      _toggleBackgroundMusic();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_isMusicPlaying ? 'Background music playing' : 'Background music paused')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Helper method to build a flashcard page based on age
  Widget _buildFlashcardPage(List<dynamic> elements) {
    // Debug the elements on this page
    print('Building flashcard with ${elements.length} elements');
    
    // Check if we have a FlashcardElement
    FlashcardElement? flashcardElement;
    
    for (var element in elements) {
      if (element is FlashcardElement) {
        flashcardElement = element;
        print('Flashcard: ${flashcardElement.title} with letter ${flashcardElement.letter}');
        // Once we find a flashcard element, break the loop
        break;
      } else if (element is ImageElement) {
        print('Image: ${element.imageUrl.substring(0, math.min(30, element.imageUrl.length))}...');
      } else if (element is TextElement) {
        print('Text: ${element.content.substring(0, math.min(30, element.content.length))}...');
      }
    }
    
    // If we found a flashcard element, build it directly
    if (flashcardElement != null) {
      return _buildFlashcard(flashcardElement);
    }
    
    // Otherwise, fall back to the original logic for other element types
    // Find image and text elements in this page
    ImageElement? imageElement;
    TextElement? textElement;
    String? highlightedWord;
    
    for (var element in elements) {
      if (element is ImageElement) {
        imageElement = element;
      } else if (element is TextElement) {
        textElement = textElement ?? element; // Take the first text element
        
        // Extract highlighted word if present
        if (textElement != null && textElement.content.contains('**')) {
          final regex = RegExp(r'\*\*(.*?)\*\*');
          final match = regex.firstMatch(textElement.content);
          if (match != null && match.group(1) != null) {
            highlightedWord = match.group(1);
          }
        }
      }
    }
    
    // We already handled FlashcardElement above, so if we get here, we're dealing with other element types
    // Prepare bottom label for age 4-5
    Widget? bottomLabel;
    if (widget.age <= 5) {
      // Find a suitable text element to use as label
      for (var element in elements) {
        if (element is TextElement) {
          final cleanedText = element.content
            .replaceAll('**', '')
            .replaceAll('•', '')
            .trim();
            
          if (cleanedText.isNotEmpty) {
            bottomLabel = Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.indigo[700],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                ),
              ),
              child: Text(
                cleanedText.toUpperCase(),
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: _fontFamily,
                ),
                textAlign: TextAlign.center,
                textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
              ),
            );
            break;
          }
        }
      }
    }
    
    // Build the appropriate flashcard based on age
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: widget.age == 6 ? Colors.white : 
               widget.age == 5 ? Colors.yellow.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Directionality(
        textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: elements.isEmpty
                      ? const Text('No content available')
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image - for all ages
                              if (imageElement != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: imageElement.imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageElement.imageUrl,
                                          fit: BoxFit.contain,
                                          height: widget.age == 4 ? 250 : 200,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: widget.age == 4 ? 250 : 200,
                                              color: Colors.grey[300],
                                              child: const Center(child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey)),
                                            );
                                          },
                                        )
                                      : Container(
                                          height: widget.age == 4 ? 250 : 200,
                                          color: Colors.grey[300],
                                          child: const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
                                        ),
                                  ),
                                ),
                              
                              // Text content based on age
                              if (textElement != null)
                                _buildAgeSpecificText(textElement, highlightedWord),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            
            // Add the bottom label if we have one
            if (bottomLabel != null) bottomLabel,
          ],
        ),
      ),
    );
  }
  
  // Helper method to build age-specific text content
  Widget _buildAgeSpecificText(TextElement textElement, String? highlightedWord) {
    // Process the text content based on age
    String processedText = textElement.content;
    
    // Remove markdown formatting if present
    if (processedText.contains('**')) {
      processedText = processedText.replaceAll('**', '');
    }
    
    // Remove bullet points for age 5-6
    if (widget.age >= 5 && processedText.contains('• ')) {
      processedText = processedText.replaceAll('• ', '');
    }
    
    // Set text direction based on language
    TextDirection textDirection = _isRTL ? TextDirection.rtl : TextDirection.ltr;
    
    // For Age 4: Large bullet-style text
    if (widget.age == 4) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        child: Text(
          '• ${highlightedWord ?? processedText}',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            fontFamily: _fontFamily,
            color: Colors.purple[700],
          ),
          textAlign: TextAlign.center,
          textDirection: textDirection,
        ),
      );
    }
    // For Age 5: Single short sentence with key-term highlights
    else if (widget.age == 5) {
      // If we have a highlighted word, make it bold/colored
      if (highlightedWord != null) {
        // Create a rich text with the highlighted word in bold/color
        final parts = processedText.split(highlightedWord);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 22.0,
                  fontFamily: _fontFamily,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(text: parts[0]),
                  TextSpan(
                    text: highlightedWord,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  if (parts.length > 1) TextSpan(text: parts[1]),
                ],
              ),
            ),
          ),
        );
      } else {
        // No highlighted word, just show the text
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              processedText,
              style: TextStyle(
                fontSize: 22.0,
                fontFamily: _fontFamily,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              textDirection: textDirection,
            ),
          ),
        );
      }
    }
    // For Age 6: Longer explanatory paragraph
    else {
      // If we have a highlighted word, make it bold
      if (highlightedWord != null) {
        // Create a rich text with the highlighted word in bold
        final parts = processedText.split(highlightedWord);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: _fontFamily,
                color: Colors.black87,
              ),
              children: [
                TextSpan(text: parts[0]),
                TextSpan(
                  text: highlightedWord,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (parts.length > 1) TextSpan(text: parts[1]),
              ],
            ),
          ),
        );
      } else {
        // No highlighted word, just show the text
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Text(
            processedText,
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: _fontFamily,
              color: Colors.black87,
            ),
            textAlign: TextAlign.start,
            textDirection: textDirection,
          ),
        );
      }
    }
    return Container(); // Fallback empty container
  }
  // Helper method to build circular navigation buttons
  Widget _buildCircularButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        iconSize: 32.0,
      ),
    );
  }
  
  // Helper method to format duration for audio display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
  
  // Method to publish the note
  void _publishNote() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Create a note document with the current elements
      final noteDoc = {
        'title': _noteTitle,
        'subject': widget.subject,
        'chapter': widget.chapter,
        'language': widget.language,
        'templateName': widget.templateName,
        'ageGroup': widget.age,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'isPublished': true,
        'elements': _noteElements.map((e) => e.toJson()).toList(),
        'score': 100, // Fixed score of 100 for completion tracking
        'stars': 5,   // Fixed 5 stars for progress tracking
        'type': 'note', // Specify that this is a note for the child module
        'completionStatus': 'completed', // Mark as completed
      };
      
      // Get the reference to the subject document
      DocumentReference subjectRef = FirebaseFirestore.instance
          .collection('subjects')
          .doc(widget.subject.id);
      
      // Save to Firestore in the notes collection for child module access
      await FirebaseFirestore.instance
          .collection('notes')
          .add(noteDoc);
      
      // Update the subject document to include this note
      await subjectRef.update({
        'hasPublishedNote': true,
        'noteLastUpdated': Timestamp.now(),
      });
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note published successfully!')),
      );
      
      // Navigate back to content management screen
      Navigator.of(context).pop();
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error publishing note: ${e.toString()}')),
      );
    }
  }
  
  // The duplicate _regenerateFlashcards method was removed
  // The original implementation is at the top of the file
  
  // We've removed the audio element UI since we're using background music instead
  // of individual audio elements for each flashcard
  
  // Helper method to build a kid-friendly element
  Widget _buildKidFriendlyElement(NoteContentElement element) {
    if (element is TextElement) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          element.content,
          style: TextStyle(
            fontSize: element.fontSize ?? 16.0,
            fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
            fontFamily: _fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (element is ImageElement) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 200,
                ),
                child: element.imageUrl.startsWith('http')
                    ? Image.network(
                        element.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(height: 8),
                                  Text('Failed to load image: ${error.toString().substring(0, math.min(50, error.toString().length))}'),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        element.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(height: 8),
                                  Text('Failed to load image: ${element.imageUrl}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            if (element.caption != null && element.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  element.caption!,
                  style: TextStyle(fontFamily: _fontFamily),
                ),
              ),
          ],
        ),
      );
    } else if (element is AudioElement) {
      // We're not showing audio elements anymore since we're using background music
      return const SizedBox.shrink();
    } else if (element is FlashcardElement) {
      // Use the dedicated flashcard builder for FlashcardElement objects
      return _buildFlashcard(element);
    } else {
      return const SizedBox.shrink();
    }
  }
}