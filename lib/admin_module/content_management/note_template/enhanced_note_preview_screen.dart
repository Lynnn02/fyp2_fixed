import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import '../../../models/note_content.dart';
import '../../../models/subject.dart';
import '../../../services/content_service.dart';
import '../../../services/gemini_service.dart';
import '../../../widgets/admin_ui_style.dart';
import 'enhanced_note_template_manager.dart';

class EnhancedNotePreviewScreen extends StatefulWidget {
  final Subject subject;
  final Chapter chapter;
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
  final GeminiService _geminiService = GeminiService();
  final EnhancedNoteTemplateManager _templateManager = EnhancedNoteTemplateManager();
  final ContentService _contentService = ContentService();
  final Set<String> _audioElementsInitialized = <String>{}; // Track initialized audio elements
  
  List<NoteContentElement> _noteElements = [];
  String _noteTitle = '';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isPublishing = false;
  
  // Card and paging information
  int _cardCount = 0;
  int _cardsPerPage = 1;
  int _totalPages = 0;
  int _currentPage = 0;
  PageController _pageController = PageController();
  
  // Audio player
  final Map<String, AudioPlayer> _audioPlayers = {};
  String? _currentlyPlayingAudioId;
  
  late TextEditingController _titleController;
  
  // Color for template based on age
  Color _getAgeColor(int age) {
    if (age <= 6) return Colors.green;
    if (age <= 10) return Colors.blue;
    if (age <= 14) return Colors.purple;
    return Colors.indigo;
  }
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _titleController = TextEditingController(text: 'Flashcard: ${widget.chapter.name}');
    
    // Use post-frame callback to ensure the widget is fully built before accessing MediaQuery
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNoteContent();
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  Future<void> _loadNoteContent() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Get screen width for responsive card layout - safely access MediaQuery now
      double screenWidth = MediaQuery.of(context).size.width;
      
      // Use template manager to generate content with card count and paging
      final response = await _templateManager.generateInteractiveNoteContent(
        templateId: 'flashcard',
        subject: widget.subject.name,
        chapter: widget.chapter.name,
        age: widget.age,
        screenWidth: screenWidth,
      );
      
      final List<NoteContentElement> noteElements = _createElementsFromResponse(response, widget.subject.name, widget.chapter.name);
      
      setState(() {
        _noteElements = noteElements;
        _noteTitle = response['title'] ?? 'Flashcard: ${widget.chapter.name}';
        _cardCount = response['cardCount'] ?? noteElements.length;
        _cardsPerPage = response['cardsPerPage'] ?? 1;
        _totalPages = response['totalPages'] ?? (noteElements.length / _cardsPerPage).ceil();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }
  
  List<NoteContentElement> _createElementsFromResponse(Map<String, dynamic>? response, String subjectName, String chapterName) {
    if (response == null) {
      return _createFallbackNoteElements();
    }
    
    try {
      final List<NoteContentElement> elements = [];
      final timestamp = Timestamp.now();
      
      // Extract elements from the response
      final List<dynamic> rawElements = response['elements'] ?? [];
      int position = 0;
      
      for (var element in rawElements) {
        position++;
        final String type = element['type'] ?? '';
        final String id = DateTime.now().millisecondsSinceEpoch.toString() + position.toString();
        
        switch (type) {
          case 'text':
            elements.add(TextElement(
              id: id,
              position: position,
              createdAt: timestamp,
              content: element['content'] ?? '',
              isBold: element['isBold'] ?? false,
              isItalic: element['isItalic'] ?? false,
              isList: element['isList'] ?? false,
              fontSize: element['fontSize']?.toDouble() ?? _templateManager.getFontSizeForAge(widget.age),
            ));
            break;
            
          case 'image':
            elements.add(ImageElement(
              id: id,
              position: position,
              createdAt: timestamp,
              imageUrl: element['imageUrl'] ?? 'https://via.placeholder.com/400x300?text=Image+Placeholder',
              caption: element['caption'],
            ));
            break;
            
          case 'audio':
            elements.add(AudioElement(
              id: id,
              position: position,
              createdAt: timestamp,
              audioUrl: element['audioUrl'] ?? '',
              title: element['title'],
            ));
            break;
        }
      }
      
      return elements.isEmpty ? _createFallbackNoteElements() : elements;
    } catch (e) {
      print('Error converting response to note elements: $e');
      return _createFallbackNoteElements();
    }
  }
  
  List<NoteContentElement> _createFallbackNoteElements() {
    final timestamp = Timestamp.now();
    final List<NoteContentElement> elements = [];
    
    // Add title text element
    elements.add(TextElement(
      id: 'title_1',
      position: 1,
      createdAt: timestamp,
      content: "${widget.subject.name}: ${widget.chapter.name}",
      isBold: true,
      fontSize: 24.0,
    ));
    
    // Add error message
    elements.add(TextElement(
      id: 'error_2',
      position: 2,
      createdAt: timestamp,
      content: "Could not load note content. Please try again later.",
      isItalic: true,
      fontSize: 18.0,
    ));
    
    return elements;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: ${widget.templateName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text('Error: $_errorMessage'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _noteTitle,
                        style: TextStyle(
                          fontSize: _templateManager.getFontSizeForAge(widget.age, isTitle: true),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _totalPages,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, pageIndex) {
                          return _buildPageContent(pageIndex);
                        },
                      ),
                    ),
                    if (_totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < _totalPages; i++)
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == _currentPage ? Colors.blue : Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
  
  Future<void> _saveNote() async {
    setState(() {
      _isPublishing = true;
    });
    
    try {
      // Create a Note model from the generated elements
      final Note note = Note(
        title: _noteTitle,
        elements: _noteElements,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        isDraft: true,
      );
      
      // Save note to database
      await _contentService.saveNoteToChapter(
        widget.subject.id,
        widget.chapter.id,
        note,
      );
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }
  
  // Toggle audio playback
  Future<void> _toggleAudioPlayback(AudioElement element) async {
    final String audioId = element.id;
    
    // If this audio is already playing, pause it
    if (_currentlyPlayingAudioId == audioId) {
      if (_audioPlayers.containsKey(audioId)) {
        await _audioPlayers[audioId]!.pause();
        setState(() {
          _currentlyPlayingAudioId = null;
        });
      }
      return;
    }
    
    // Stop any currently playing audio
    if (_currentlyPlayingAudioId != null && _audioPlayers.containsKey(_currentlyPlayingAudioId)) {
      await _audioPlayers[_currentlyPlayingAudioId]!.stop();
    }
    
    // Create a new player if needed
    if (!_audioPlayers.containsKey(audioId)) {
      _audioPlayers[audioId] = AudioPlayer();
    }
    
    // Play the new audio
    try {
      if (element.audioUrl.isNotEmpty) {
        await _audioPlayers[audioId]!.setUrl(element.audioUrl);
        await _audioPlayers[audioId]!.play();
        setState(() {
          _currentlyPlayingAudioId = audioId;
        });
      } else {
        // Show error if no audio URL
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No audio URL available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Build content for a specific page
  Widget _buildPageContent(int pageIndex) {
    // Calculate which elements belong on this page
    int startIndex = pageIndex * _cardsPerPage;
    int endIndex = startIndex + _cardsPerPage;
    if (endIndex > _noteElements.length) endIndex = _noteElements.length;
    
    // Get elements for this page
    List<NoteContentElement> pageElements = _noteElements.sublist(startIndex, endIndex);
    
    // Build card layout based on cards per page
    if (_cardsPerPage == 1 || pageElements.length == 1) {
      // Single card layout
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildCardContent(pageElements.first),
      );
    } else {
      // Multi-card layout (typically 2 cards side by side)
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pageElements.map((element) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildCardContent(element),
              ),
            );
          }).toList(),
        ),
      );
    }
  }
  
  // Build content for a single card
  Widget _buildCardContent(NoteContentElement element) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildElement(element),
      ),
    );
  }
  
  // Build individual element based on its type
  Widget _buildElement(NoteContentElement element) {
    final templateColor = _getAgeColor(widget.age);
    
    if (element is TextElement) {
      // Age-specific text rendering
      if (widget.age == 4) {
        // Age 4: Simple bullet points with larger font
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            element.content,
            style: TextStyle(
              fontSize: element.fontSize ?? _templateManager.getFontSizeForAge(widget.age),
              fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
              color: element.textColor != null ? Color(int.parse(element.textColor!)) : null,
              height: 1.5, // More spacing for readability
            ),
          ),
        );
      } else if (widget.age == 5) {
        // Age 5: Short paragraphs with key-term highlights
        // Check if content contains the play button icon
        String content = element.content;
        bool hasPlayIcon = content.contains('🔊');
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: TextStyle(
                  fontSize: element.fontSize ?? _templateManager.getFontSizeForAge(widget.age),
                  fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
                  color: element.textColor != null ? Color(int.parse(element.textColor!)) : null,
                ),
              ),
            ],
          ),
        );
      } else {
        // Age 6: Detailed paragraphs with mini-quizzes
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            element.content,
            style: TextStyle(
              fontSize: element.fontSize ?? _templateManager.getFontSizeForAge(widget.age),
              fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
              color: element.textColor != null ? Color(int.parse(element.textColor!)) : null,
            ),
          ),
        );
      }
    } else if (element is ImageElement) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: element.imageUrl.isNotEmpty
                  ? Image.network(
                      element.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.image_not_supported)),
                        );
                      },
                    )
                  : Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image)),
                    ),
            ),
            if (element.caption != null && element.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  element.caption!,
                  style: TextStyle(
                    fontSize: _templateManager.getFontSizeForAge(widget.age) - 2,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ),
          ],
        ),
      );
    } else if (element is AudioElement) {
      final String audioId = element.id;
      final bool isPlaying = _currentlyPlayingAudioId == audioId;
      final bool shouldAutoPlay = element.metadata?['autoPlay'] == true || widget.age == 4;
      
      // Auto-play for age 4 when the element is first rendered
      if (shouldAutoPlay && !_audioElementsInitialized.contains(audioId)) {
        // Add to initialized set to prevent multiple auto-plays
        _audioElementsInitialized.add(audioId);
        // Use Future.delayed to ensure the widget is fully built before playing
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _toggleAudioPlayback(element);
          }
        });
      }
      
      // Age-specific audio UI
      if (widget.age == 4) {
        // Age 4: Simple auto-play audio with minimal controls
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: templateColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: templateColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isPlaying ? Icons.volume_up : Icons.volume_up_outlined, 
                     color: Theme.of(context).primaryColor,
                     size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Listening...', // Simpler text for age 4
                    style: TextStyle(
                      fontSize: _templateManager.getFontSizeForAge(widget.age) - 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (widget.age == 5) {
        // Age 5: Audio with play button
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: templateColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: templateColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.audiotrack, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    element.title ?? 'Listen',
                    style: TextStyle(
                      fontSize: _templateManager.getFontSizeForAge(widget.age) - 2,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () => _toggleAudioPlayback(element),
                ),
              ],
            ),
          ),
        );
      } else {
        // Age 6: Full audio controls
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: templateColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: templateColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.audiotrack, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        element.title ?? 'Audio',
                        style: TextStyle(
                          fontSize: _templateManager.getFontSizeForAge(widget.age),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () => _toggleAudioPlayback(element),
                    ),
                  ],
                ),
                // Additional controls for age 6
                Slider(
                  value: 0.5, // Placeholder - would need actual audio position tracking
                  onChanged: (value) {},
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        );
      }
    } else {
      // Default fallback for any other element type
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Unsupported content type: ${element.type}',
            style: TextStyle(
              fontSize: _templateManager.getFontSizeForAge(widget.age),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
