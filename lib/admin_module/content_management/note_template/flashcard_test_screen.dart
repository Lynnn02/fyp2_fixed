import 'package:flutter/material.dart';
import '../../../models/note_content_element.dart';
import '../../../models/flashcard_element.dart';
import '../../../services/flashcard_service.dart';
import 'enhanced_note_template_manager.dart';
import 'flashcard_template_generator_complete.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isRtl = false;
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Flashcard data
  List<Map<String, dynamic>> _flashcards = [];
  int _currentCardIndex = 0;
  
  // Debug state
  bool _showDebugInfo = false;
  
  // Template manager for generating flashcards
  final EnhancedNoteTemplateManager _templateManager = EnhancedNoteTemplateManager();
  
  // Flashcard service
  final FlashcardService _flashcardService = FlashcardService();
  
  @override
  void initState() {
    super.initState();
    _generateTestFlashcards();
  }
  

  
  // Generate test flashcards
  Future<void> _generateTestFlashcards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Generate flashcards using the template generator
      final flashcardElements = FlashcardTemplateGenerator.generateFlashcardElements(
        subject: _selectedSubject,
        chapter: _selectedChapter,
        age: _selectedAge,
        language: _selectedLanguage,
      );
      
      // Convert FlashcardElement objects to Map format for compatibility
      _flashcards = flashcardElements.map((element) => {
        'title': element.title,
        'letter': element.letter,
        'image_asset': element.imageAsset,
        'description': element.getDescription(_selectedAge),
      }).toList();
      
      setState(() {
        _currentCardIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error generating flashcards: $e';
        _isLoading = false;
      });
    }
  }
  
  // Build the age selector
  Widget _buildAgeSelector() {
    return Row(
      children: [
        const Text('Age: '),
        const SizedBox(width: 8),
        ToggleButtons(
          isSelected: [
            _selectedAge == 4,
            _selectedAge == 5,
            _selectedAge == 6,
          ],
          onPressed: (int index) {
            setState(() {
              _selectedAge = index + 4;
            });
          },
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('4')),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('5')),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('6')),
          ],
        ),
      ],
    );
  }
  
  // Helper method to get color based on letter
  Color _getColorForLetter(String letter) {
    // Simple hash function to generate a color based on the letter
    final int hash = letter.codeUnitAt(0) % 5;
    switch (hash) {
      case 0:
        return Colors.blue.shade700;
      case 1:
        return Colors.red.shade700;
      case 2:
        return Colors.green.shade700;
      case 3:
        return Colors.orange.shade700;
      case 4:
        return Colors.purple.shade700;
      default:
        return Colors.indigo.shade700;
    }
  }
  
  // Build a flashcard
  Widget _buildFlashcard(Map<String, dynamic> flashcard) {
    final String title = flashcard['title'] ?? '';
    final String letter = flashcard['letter'] ?? '';
    final String description = flashcard['description'] ?? '';
    final String imageAsset = flashcard['image_asset'] ?? '';
    
    // Determine if we should use RTL text direction
    final bool isRtl = _isRtl;
    
    // Get color based on letter
    final Color backgroundColor = _getColorForLetter(letter);
    
    // Determine font family based on subject
    final String fontFamily = _selectedSubject == 'Jawi' || _selectedSubject == 'Hijaiyah'
        ? 'Amiri'
        : 'Roboto';
    
    // Get first letter for display
    final String firstLetter = letter.isNotEmpty ? letter : title.isNotEmpty ? title[0] : '';
    
    // For debugging: image prompt
    final String imagePrompt = '$title for children age $_selectedAge';
    
    // For network images (if any)
    final String imageUrl = '';
    
    // For text direction
    final TextDirection textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;
    
    // Question text
    final String questionText = title;
    
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
                  
                  // Image in the middle
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 5.0,
                                color: Colors.black.withOpacity(0.2),
                              ),
                            ],
                          ),
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
              
              // Info button (top-left)
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
                      onTap: () {
                        setState(() {
                          _showDebugInfo = !_showDebugInfo;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.info_outline,
                          size: 24.0,
                          color: Colors.blue,
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
  
  // Build the flashcard preview
  Widget _buildFlashcardPreview() {
    if (_flashcards.isEmpty) {
      return const Center(child: Text('No flashcards available'));
    }
    
    return _buildFlashcard(_flashcards[_currentCardIndex]);
  }
  
  // Build the progress indicator
  Widget _buildProgressIndicator() {
    if (_flashcards.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _currentCardIndex > 0
                ? () {
                    setState(() {
                      _currentCardIndex--;
                    });
                  }
                : null,
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: _flashcards.isEmpty ? 0 : (_currentCardIndex + 1) / _flashcards.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          Text(
            ' ${_currentCardIndex + 1}/${_flashcards.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _currentCardIndex < _flashcards.length - 1
                ? () {
                    setState(() {
                      _currentCardIndex++;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Test'),
        actions: [
          // Debug toggle
          IconButton(
            icon: Icon(_showDebugInfo ? Icons.bug_report : Icons.bug_report_outlined),
            onPressed: () {
              setState(() {
                _showDebugInfo = !_showDebugInfo;
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Controls
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject selector
                  Row(
                    children: [
                      const Text('Subject: '),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedSubject,
                        items: const [
                          DropdownMenuItem(value: 'Jawi', child: Text('Jawi')),
                          DropdownMenuItem(value: 'Hijaiyah', child: Text('Hijaiyah')),
                          DropdownMenuItem(value: 'Science', child: Text('Science')),
                          DropdownMenuItem(value: 'Math', child: Text('Math')),
                          DropdownMenuItem(value: 'Art', child: Text('Art')),
                          DropdownMenuItem(value: 'Social', child: Text('Social')),
                          DropdownMenuItem(value: 'Motor', child: Text('Motor')),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _selectedSubject = value!;
                            // Set RTL for Arabic-based subjects
                            _isRtl = _selectedSubject == 'Jawi';
                            _selectedLanguage = _isRtl ? 'ms' : 'en';
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      
                      // Chapter selector
                      const Text('Chapter: '),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedChapter,
                        items: const [
                          DropdownMenuItem(value: 'Huruf', child: Text('Huruf')),
                          DropdownMenuItem(value: 'Tulisan', child: Text('Tulisan')),
                          DropdownMenuItem(value: 'Hijaiyah', child: Text('Hijaiyah')),
                          DropdownMenuItem(value: 'Iqraa', child: Text('Iqraa')),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _selectedChapter = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Age selector
                  _buildAgeSelector(),
                  
                  const SizedBox(height: 16),
                  
                  // Generate button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _generateTestFlashcards,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Generate Flashcards'),
                  ),
                ],
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
                        ? const Center(child: Text('No flashcards generated yet'))
                        : _buildFlashcardPreview(),
          ),
          
          // Progress indicator
          if (!_isLoading && _errorMessage.isEmpty && _flashcards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildProgressIndicator(),
            ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}