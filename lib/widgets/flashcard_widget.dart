import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gemini_notes_service.dart';
import '../models/subject.dart';
import '../models/note_content.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FlashcardWidget extends StatefulWidget {
  final Subject subject;
  final Chapter chapter;
  final int age;
  final String language;
  final String userId;
  final String userName;

  const FlashcardWidget({
    Key? key,
    required this.subject,
    required this.chapter,
    required this.age,
    required this.language,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  _FlashcardWidgetState createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> with TickerProviderStateMixin {
  final GeminiNotesService _geminiService = GeminiNotesService();
  final AudioPlayer _contentAudioPlayer = AudioPlayer(); // For flashcard content audio
  final AudioPlayer _bgMusicPlayer = AudioPlayer(); // For background music
  final FlutterTts _flutterTts = FlutterTts();
  final CardSwiperController _cardController = CardSwiperController();
  
  List<FlashcardItem> _flashcards = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  int _currentIndex = 0;
  bool _isContentPlaying = false; // For flashcard content audio
  bool _isBgMusicPlaying = false; // For background music
  
  // Animation controllers
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  
  // Cache key for storing responses
  String get _cacheKey => '${widget.subject.id}_${widget.chapter.id}_${widget.age}_${widget.language}';
  
  @override
  void initState() {
    super.initState();
    
    // Initialize flip animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    
    // Configure TTS for the selected language
    _configureTts();
    
    // Load flashcards
    _loadFlashcards();
  }
  
  @override
  void dispose() {
    _contentAudioPlayer.dispose();
    _bgMusicPlayer.dispose();
    _flipController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
  
  // Configure text-to-speech for the selected language
  Future<void> _configureTts() async {
    await _flutterTts.setLanguage(_getLanguageCode());
    await _flutterTts.setSpeechRate(0.5); // Slower rate for children
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }
  
  // Get the appropriate language code based on subject/language
  String _getLanguageCode() {
    switch (widget.language.toLowerCase()) {
      case 'arabic':
        return 'ar-SA';
      case 'malay':
      case 'bahasa malaysia':
        return 'ms-MY';
      case 'chinese':
      case 'mandarin':
        return 'zh-CN';
      case 'tamil':
        return 'ta-IN';
      case 'hindi':
        return 'hi-IN';
      default:
        return 'en-US';
    }
  }
  
  // Determine text direction based on language
  TextDirection _getTextDirection() {
    if (widget.language.toLowerCase() == 'arabic' || 
        widget.language.toLowerCase() == 'jawi') {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }
  
  // Load flashcards from cache or API
  Future<void> _loadFlashcards() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    
    try {
      // Try to load from cache first
      final cachedCards = await _loadFromCache();
      
      if (cachedCards != null && cachedCards.isNotEmpty) {
        setState(() {
          _flashcards = cachedCards;
          _isLoading = false;
        });
        
        // If age is 4, autoplay the first card's audio
        if (widget.age == 4 && _flashcards.isNotEmpty) {
          _playAudio(_flashcards[0].audioUrl);
        }
        
        return;
      }
      
      // If not in cache, fetch from API
      final cards = await _geminiService.generateFlashcards(
        widget.subject,
        widget.chapter,
        widget.age,
        widget.language,
      );
      
      if (cards.isNotEmpty) {
        // Save to cache
        await _saveToCache(cards);
        
        setState(() {
          _flashcards = cards;
          _isLoading = false;
        });
        
        // If age is 4, autoplay the first card's audio
        if (widget.age == 4 && _flashcards.isNotEmpty) {
          _playAudio(_flashcards[0].audioUrl);
        }
      } else {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = 'No flashcards available for this topic';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Failed to load flashcards: ${e.toString()}';
      });
    }
  }
  
  // Load flashcards from cache
  Future<List<FlashcardItem>?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_cacheKey);
      
      if (jsonData != null) {
        final List<dynamic> decoded = jsonDecode(jsonData);
        return decoded.map((item) => FlashcardItem.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Cache load error: ${e.toString()}');
    }
    
    return null;
  }
  
  // Save flashcards to cache
  Future<void> _saveToCache(List<FlashcardItem> cards) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(cards.map((card) => card.toJson()).toList());
      await prefs.setString(_cacheKey, jsonData);
    } catch (e) {
      debugPrint('Cache save error: ${e.toString()}');
    }
  }
  
  // Play content audio from URL (word or animal sound)
  Future<void> _playContentAudio(String url) async {
    if (_isContentPlaying) {
      await _contentAudioPlayer.stop();
    }
    
    setState(() {
      _isContentPlaying = true;
    });
    
    try {
      await _contentAudioPlayer.play(UrlSource(url));
      _contentAudioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          _isContentPlaying = false;
        });
      });
    } catch (e) {
      setState(() {
        _isContentPlaying = false;
      });
      
      // Fallback to TTS if audio URL fails
      if (_flashcards.isNotEmpty && _currentIndex < _flashcards.length) {
        _flutterTts.speak(_flashcards[_currentIndex].questionText);
      }
    }
  }
  
  // Toggle background music
  Future<void> _toggleBackgroundMusic() async {
    if (_isBgMusicPlaying) {
      await _bgMusicPlayer.pause();
      setState(() {
        _isBgMusicPlaying = false;
      });
    } else {
      // Background music URL - use a cheerful, child-friendly tune
      const String bgMusicUrl = 'https://firebasestorage.googleapis.com/v0/b/fyp-app-a0b2e.appspot.com/o/background_music%2Fcheerful_learning.mp3?alt=media';
      
      try {
        await _bgMusicPlayer.play(UrlSource(bgMusicUrl));
        _bgMusicPlayer.setReleaseMode(ReleaseMode.loop); // Loop the background music
        setState(() {
          _isBgMusicPlaying = true;
        });
      } catch (e) {
        print('Error playing background music: $e');
      }
    }
  }
  
  // Flip card animation
  void _flipCard() {
    setState(() {
      if (_isFlipped) {
        _flipController.reverse();
      } else {
        _flipController.forward();
      }
      _isFlipped = !_isFlipped;
    });
  }
  
  // Handle card change
  void _onCardChanged(int index) {
    setState(() {
      _currentIndex = index;
      _isFlipped = false;
      _flipController.reset();
    });
    
    // For age 4, autoplay audio on card change
    if (widget.age == 4 && _flashcards.isNotEmpty) {
      _playContentAudio(_flashcards[index].audioUrl);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Determine if we're on a phone or tablet
    final bool isPhone = MediaQuery.of(context).size.width < 600;
    
    return Directionality(
      textDirection: _getTextDirection(),
      child: _buildContent(isPhone),
    );
  }
  
  Widget _buildContent(bool isPhone) {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_isError) {
      return _buildErrorState();
    }
    
    if (_flashcards.isEmpty) {
      return _buildEmptyState();
    }
    
    return isPhone ? _buildPhoneLayout() : _buildTabletLayout();
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading flashcards...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadFlashcards,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'No flashcards available for this topic',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPhoneLayout() {
    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            controller: _cardController,
            cardsCount: _flashcards.length,
            onSwipe: (previousIndex, currentIndex, direction) {
              _onCardChanged(currentIndex);
              return true;
            },
            numberOfCardsDisplayed: 1,
            backCardOffset: const Offset(0, 0),
            padding: const EdgeInsets.all(24.0),
            cardBuilder: (context, index) => _buildFlashcard(_flashcards[index]),
          ),
        ),
        _buildNavigationControls(),
      ],
    );
  }
  
  Widget _buildTabletLayout() {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: _flashcards.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                  
                  if (widget.age == 4) {
                    _playAudio(_flashcards[index].audioUrl);
                  }
                },
                child: _buildFlashcard(_flashcards[index], isSelected: index == _currentIndex),
              );
            },
          ),
        ),
        _buildNavigationControls(),
      ],
    );
  }
  
  // Get a consistent color for a flashcard based on its content
  Color _getCardColor(FlashcardItem card) {
    // List of bright, kid-friendly colors
    final List<Color> cardColors = [
      Color(0xFF8E44AD), // Purple
      Color(0xFF3498DB), // Blue
      Color(0xFF1ABC9C), // Teal
      Color(0xFFE74C3C), // Red
      Color(0xFF2ECC71), // Green
      Color(0xFFF39C12), // Orange
      Color(0xFF7F8C8D), // Gray
      Color(0xFFD35400), // Dark Orange
      Color(0xFF27AE60), // Emerald
      Color(0xFF8E44AD), // Purple
      Color(0xFFE67E22), // Carrot
      Color(0xFF16A085), // Green Sea
    ];
    
    // Use the first letter of the question text to determine the color
    if (card.questionText.isNotEmpty) {
      final int charCode = card.questionText.toLowerCase().codeUnitAt(0);
      return cardColors[charCode % cardColors.length];
    }
    
    // Default color if no text
    return cardColors[0];
  }

  Widget _buildFlashcard(FlashcardItem card, {bool isSelected = false}) {
    // Get a consistent color for this card
    final cardColor = _getCardColor(card);
    
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..rotateY(_isFlipped ? pi : 0);
          
        return GestureDetector(
          onTap: _flipCard,
          child: Transform(
            transform: transform,
            alignment: Alignment.center,
            child: Card(
              elevation: isSelected ? 8 : 4,
              color: cardColor, // Apply the card color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: isSelected 
                  ? BorderSide(color: Colors.white, width: 2.0)
                  : BorderSide.none,
              ),
              child: _isFlipped 
                ? _buildCardBack(card)
                : _buildCardFront(card),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCardFront(FlashcardItem card) {
    // Extract the first letter of the question text for the top letter display
    String firstLetter = '';
    if (card.questionText.isNotEmpty) {
      firstLetter = card.questionText[0].toUpperCase();
    }
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top letter display
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              firstLetter,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: _getFontFamily(),
                shadows: [
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          
          // Center image with sound button overlay
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                // Image container
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: card.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                
                // Content sound button overlay (for word/animal sound)
                Positioned(
                  top: 24.0,
                  right: 32.0,
                  child: Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20.0),
                        onTap: () => _playContentAudio(card.audioUrl),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            _isContentPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                            size: 24.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Background music toggle button
                Positioned(
                  top: 24.0,
                  left: 32.0,
                  child: Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20.0),
                        onTap: _toggleBackgroundMusic,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            _isBgMusicPlaying ? Icons.music_note : Icons.music_off,
                            size: 24.0,
                            color: _isBgMusicPlaying ? Theme.of(context).primaryColor : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom word display
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              card.questionText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: _getFontFamily(),
                shadows: [
                  Shadow(
                    offset: Offset(1.0, 1.0),
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
    );
  }
  
  Widget _buildCardBack(FlashcardItem card) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text(
                card.answerText,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: _getFontFamily(),
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _currentIndex > 0
                ? () {
                    if (_cardController.state?.cards.isNotEmpty ?? false) {
                      _cardController.swipeLeft();
                    } else {
                      setState(() {
                        _currentIndex = (_currentIndex - 1).clamp(0, _flashcards.length - 1);
                      });
                    }
                  }
                : null,
          ),
          Text(
            '${_currentIndex + 1} / ${_flashcards.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _currentIndex < _flashcards.length - 1
                ? () {
                    if (_cardController.state?.cards.isNotEmpty ?? false) {
                      _cardController.swipeRight();
                    } else {
                      setState(() {
                        _currentIndex = (_currentIndex + 1).clamp(0, _flashcards.length - 1);
                      });
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
  
  // Get appropriate font family based on language
  String? _getFontFamily() {
    switch (widget.language.toLowerCase()) {
      case 'arabic':
        return 'Amiri';
      case 'jawi':
        return 'Scheherazade';
      case 'chinese':
      case 'mandarin':
        return 'NotoSansSC';
      case 'tamil':
        return 'NotoSansTamil';
      default:
        return null; // Use default font
    }
  }
}

// Flashcard item model
class FlashcardItem {
  final String imageUrl;
  final String audioUrl;
  final String questionText;
  final String answerText;
  
  FlashcardItem({
    required this.imageUrl,
    required this.audioUrl,
    required this.questionText,
    required this.answerText,
  });
  
  factory FlashcardItem.fromJson(Map<String, dynamic> json) {
    return FlashcardItem(
      imageUrl: json['image_url'] ?? '',
      audioUrl: json['audio_url'] ?? '',
      questionText: json['question_text'] ?? '',
      answerText: json['answer_text'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'audio_url': audioUrl,
      'question_text': questionText,
      'answer_text': answerText,
    };
  }
}
