import 'package:flutter/material.dart';
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
  
  // Template manager for generating flashcards
  final EnhancedNoteTemplateManager _templateManager = EnhancedNoteTemplateManager();
  
  // New flashcard service using backend proxy
  final FlashcardService _flashcardService = FlashcardService();
  
  @override
  void initState() {
    super.initState();
    _generateTestFlashcards();
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
        
        // Process child elements
        for (var child in element.elements) {
          if (child is TextElement) {
            content = child.content;
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
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Image
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.image_not_supported, size: 48),
                              const SizedBox(height: 8),
                              Text(imagePrompt),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              
              // Question text (for age 5+)
              if (_selectedAge >= 5 && questionText.isNotEmpty)
                Text(
                  questionText,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              
              // Audio button (for age 4-5)
              if ((_selectedAge == 4 || _selectedAge == 5) && audioUrl.isNotEmpty)
                ElevatedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: Text(
                    'Listen',
                    style: TextStyle(fontFamily: fontFamily),
                  ),
                  onPressed: () {
                    // Audio playback would go here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Playing audio: $audioPrompt')),
                    );
                  },
                ),
              
              // Debug info
              const Spacer(),
              Divider(),
              Text(
                'Debug Info',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Font: $fontFamily'),
              Text('Direction: $textDirection'),
              Text('Image Prompt: $imagePrompt'),
              Text('Audio Prompt: $audioPrompt'),
            ],
          ),
        ),
      ),
    );
  }
}
