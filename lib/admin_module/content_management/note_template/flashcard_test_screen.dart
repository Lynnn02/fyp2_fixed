import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../models/note_content.dart';
import '../../../models/container_element.dart';
import '../../../services/flashcard_media_service.dart';
import '../../../services/flashcard_service.dart';
import 'enhanced_note_template_manager.dart';
import 'flashcard_template_generator.dart';

class FlashcardTestScreen extends StatefulWidget {
  const FlashcardTestScreen({Key? key}) : super(key: key);

  @override
  State<FlashcardTestScreen> createState() => _FlashcardTestScreenState();
}

class _FlashcardTestScreenState extends State<FlashcardTestScreen> {
  // Test configuration
  int _selectedAge = 5;
  String _selectedSubject = 'Jawi';
  String _selectedChapter = 'Huruf';
  String _selectedLanguage = 'ms';
  bool _isRtl = true;
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Flashcard data
  List<Map<String, dynamic>> _flashcards = [];
  int _currentCardIndex = 0;
  
  // Audio state
  final AudioPlayer _contentAudioPlayer = AudioPlayer();
  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isBgMusicPlaying = false;
  bool _showDebugInfo = false;
  
  // Template manager for generating flashcards
  final EnhancedNoteTemplateManager _templateManager = EnhancedNoteTemplateManager();
  
  // New flashcard service using backend proxy
  final FlashcardService _flashcardService = FlashcardService();
  
  @override
  void initState() {
    super.initState();
    _generateTestFlashcards();
    _setupBackgroundMusicPlayer();
    
    // Set up audio player completion listener
    _contentAudioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }
  
  // Play audio for flashcards
  Future<void> _playAudio(String url) async {
    // If already playing, stop the audio
    if (_isPlaying) {
      await _contentAudioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
      return;
    }
    
    // Check if URL is valid
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio available for this flashcard')),
      );
      return;
    }
    
    try {
      setState(() {
        _isPlaying = true;
      });
      
      await _contentAudioPlayer.stop();
      await _contentAudioPlayer.setSource(UrlSource(url));
      await _contentAudioPlayer.resume();
      
      // The onPlayerComplete listener will set _isPlaying to false when done
    } catch (e) {
      setState(() {
        _isPlaying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }
  
  // Set up background music player with looping
  void _setupBackgroundMusicPlayer() async {
    try {
      // Use a cheerful, child-friendly background music
      const bgMusicUrl = 'https://example.com/childrens_background_music.mp3';
      // You should replace this with an actual music URL or asset
      // For now we'll just set it up without playing
      _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgMusicPlayer.setSource(UrlSource(bgMusicUrl));
    } catch (e) {
      debugPrint('Error setting up background music: $e');
    }
  }
  
  // Toggle background music
  Future<void> _toggleBackgroundMusic() async {
    try {
      if (_isBgMusicPlaying) {
        await _bgMusicPlayer.pause();
      } else {
        await _bgMusicPlayer.resume();
      }
      
      setState(() {
        _isBgMusicPlaying = !_isBgMusicPlaying;
      });
    } catch (e) {
      debugPrint('Error toggling background music: $e');
    }
  }

  @override
  void dispose() {
    _contentAudioPlayer.dispose();
    _bgMusicPlayer.dispose();
    super.dispose();
  }
  
  // Helper method to convert NoteContentElements to the format expected by the UI
  List<Map<String, dynamic>> _convertElementsToFlashcards(List<NoteContentElement> elements) {
    final result = <Map<String, dynamic>>[];
    
    for (var element in elements) {
      if (element is ContainerElement) {
        // Extract data from container element
        String title = element.title ?? 'Flashcard';
        String content = '';
        String imageUrl = '';
        String audioUrl = '';
        String label = '';
        String questionText = '';
        
        // Process child elements
        for (var child in element.elements) {
          if (child is TextElement) {
            content = child.content;
            questionText = child.content; // Use content as the question text
            if (questionText.isNotEmpty) {
              label = questionText[0].toUpperCase(); // First letter as label
            }
          } else if (child is ImageElement) {
            imageUrl = child.imageUrl ?? '';
          } else if (child is AudioElement) {
            audioUrl = child.audioUrl ?? '';
          }
        }
        
        // Add to result
        result.add({
          'title': title,
          'content': content,
          'imageUrl': imageUrl,
          'audioUrl': audioUrl,
          'language': _selectedLanguage,
          'isRtl': _isRtl,
          'label': label,
          'question_text': questionText,
          'fontFamily': _isRtl ? 'Amiri' : 'Roboto',
          'textDirection': _isRtl ? 'rtl' : 'ltr',
          'image_prompt': 'Image for $questionText',
          'audio_prompt': 'Audio for $questionText'
        });
      }
    }
    
    return result;
  }
  
  Future<void> _generateTestFlashcards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Use the new backend proxy service to generate flashcards
      final elements = await _flashcardService.generateFlashcards(
        subject: _selectedSubject,
        chapter: _selectedChapter,
        age: _selectedAge,
        language: _selectedLanguage,
        count: 5, // Generate 5 test cards
      );
      
      // Convert NoteContentElements to the format expected by the UI
      final processedFlashcards = _convertElementsToFlashcards(elements);
      
      setState(() {
        _flashcards = processedFlashcards;
        _currentCardIndex = 0;
        _isLoading = false;
      });
      
      debugPrint('Generated ${processedFlashcards.length} test flashcards');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error generating flashcards: $e';
        _isLoading = false;
      });
      debugPrint('Error in _generateTestFlashcards: $e');
    }
  }
  
  void _nextCard() {
    if (_currentCardIndex < _flashcards.length - 1) {
      setState(() {
        _currentCardIndex++;
      });
    }
  }
  
  // Method to regenerate flashcards by clearing cache first
  Future<void> _regenerateFlashcards() async {
    // Clear cache for this specific subject/chapter combination
    final cacheKey = 'flashcard_cache_${_selectedSubject}_${_selectedChapter}_${_selectedAge}_${_selectedLanguage}';
    await _flashcardService.clearCache(specificKey: cacheKey);
    
    // Generate new flashcards
    await _generateTestFlashcards();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flashcards regenerated successfully!')),
    );
  }
  
  // Toggle debug information display
  void _toggleDebugInfo() {
    setState(() {
      _showDebugInfo = !_showDebugInfo;
    });
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
  
  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Test'),
        actions: [
          // Debug toggle button
          IconButton(
            icon: Icon(_showDebugInfo ? Icons.bug_report : Icons.bug_report_outlined),
            onPressed: _toggleDebugInfo,
            tooltip: 'Toggle debug information',
          ),
          // Regenerate button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _regenerateFlashcards,
            tooltip: 'Regenerate flashcards with fresh content',
          ),
        ],
      ),
      body: Column(
        children: [
          // Configuration controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Age selection
                    Row(
                      children: [
                        const Text('Age: '),
                        const SizedBox(width: 8),
                        ToggleButtons(
                          isSelected: [
                            _selectedAge == 4,
                            _selectedAge == 5,
                            _selectedAge == 6,
                          ],
                          onPressed: (index) {
                            setState(() {
                              _selectedAge = index + 4;
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('4'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('5'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('6'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Subject and chapter selection
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Subject',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedSubject,
                            items: const [
                              DropdownMenuItem(value: 'Jawi', child: Text('Jawi')),
                              DropdownMenuItem(value: 'English', child: Text('English')),
                              DropdownMenuItem(value: 'Math', child: Text('Math')),
                              DropdownMenuItem(value: 'Science', child: Text('Science')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedSubject = value!;
                                // Update RTL based on subject
                                _isRtl = _selectedSubject == 'Jawi';
                                _selectedLanguage = _isRtl ? 'ms' : 'en';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Chapter',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedChapter,
                            items: const [
                              DropdownMenuItem(value: 'Huruf', child: Text('Huruf')),
                              DropdownMenuItem(value: 'Alphabet', child: Text('Alphabet')),
                              DropdownMenuItem(value: 'Animals', child: Text('Animals')),
                              DropdownMenuItem(value: 'Numbers', child: Text('Numbers')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedChapter = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _generateTestFlashcards,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Generate Test Flashcards'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Flashcard preview
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                    : _flashcards.isEmpty
                        ? const Center(child: Text('No flashcards generated'))
                        : _buildFlashcardPreview(),
          ),
          
          // Navigation controls
          if (_flashcards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentCardIndex > 0 ? _previousCard : null,
                  ),
                  Text('${_currentCardIndex + 1} / ${_flashcards.length}'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentCardIndex < _flashcards.length - 1 ? _nextCard : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildFlashcardPreview() {
    if (_currentCardIndex >= _flashcards.length) {
      return const Center(child: Text('No flashcard to display'));
    }
    
    final flashcard = _flashcards[_currentCardIndex];
    final String label = flashcard['label'] ?? '';
    final String imagePrompt = flashcard['image_prompt'] ?? '';
    final String questionText = flashcard['question_text'] ?? '';
    final String audioPrompt = flashcard['audio_prompt'] ?? '';
    final String fontFamily = flashcard['fontFamily'] ?? 'Roboto';
    final String textDirection = flashcard['textDirection'] ?? 'ltr';
    final String imageUrl = flashcard['imageUrl'] ?? '';
    final String audioUrl = flashcard['audioUrl'] ?? '';
    
    final bool isRtl = textDirection == 'rtl';
    
    // Get first letter of the word for the top display
    String firstLetter = questionText.isNotEmpty ? questionText[0].toUpperCase() : '';
    
    // Generate background color based on the first letter
    Color backgroundColor = _getColorForLetter(firstLetter);
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        fontFamily: fontFamily,
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
                    flex: 3,
                    child: Stack(
                      alignment: Alignment.center,
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
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
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
                      ],
                    ),
                  ),
                  
                  // Word at the bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      questionText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: fontFamily,
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
              Positioned(
                top: 20.0,
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
                      onTap: () => _playAudio(audioUrl),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                          size: 24.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Background music button (top-left)
              Positioned(
                top: 20.0,
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
                          color: _isBgMusicPlaying ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Debug info
              if (_showDebugInfo)
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black.withOpacity(0.7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Debug Info',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text('Font: $fontFamily', style: const TextStyle(color: Colors.white)),
                        Text('Direction: $textDirection', style: const TextStyle(color: Colors.white)),
                        Text('Image Prompt: $imagePrompt', style: const TextStyle(color: Colors.white)),
                        Text('Audio Prompt: $audioPrompt', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
