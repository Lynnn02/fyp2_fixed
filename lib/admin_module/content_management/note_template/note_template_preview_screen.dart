import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../models/subject.dart'; // This contains both Subject and Chapter classes
import '../../../models/note_content.dart';
import '../../../services/content_service.dart';
import '../../../services/gemini_service.dart';
import '../../../widgets/admin_ui_style.dart';

class NoteTemplatePreviewScreen extends StatefulWidget {
  final Subject subject;
  final Chapter chapter;
  final String templateId;
  final Map<String, dynamic>? noteContent;
  final int pageLimit;

  const NoteTemplatePreviewScreen({
    Key? key,
    required this.subject,
    required this.chapter,
    required this.templateId,
    this.noteContent,
    this.pageLimit = 10,
  }) : super(key: key);

  @override
  State<NoteTemplatePreviewScreen> createState() => _NoteTemplatePreviewScreenState();
}

class _NoteTemplatePreviewScreenState extends State<NoteTemplatePreviewScreen> {
  final ContentService _contentService = ContentService();
  final GeminiService _geminiService = GeminiService();
  
  late TextEditingController _titleController;
  List<NoteContentElement> _elements = [];
  final Map<String, TextEditingController> _textControllers = {};
  
  // Page management
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<int, bool> _selectedPages = {};
  
  // State management
  bool _isSaving = false;
  bool _isGeneratingMoreContent = false;
  bool _isFullyGenerated = false;
  bool _isReviewMode = false;
  final Map<String, bool> _approvedElements = {}; // Track approved/rejected elements by ID
  
  // Audio playback
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentAudioElementId;

  // Image picker instance
  final ImagePicker _imagePicker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.noteContent != null ? (widget.noteContent!['title'] as String? ?? 'New Note') : 'New Note');
    _elements = widget.noteContent != null ? _parseElements(widget.noteContent!) : [];
    
    // Check if the content is fully generated and ready for review
    if (widget.noteContent != null) {
      _isFullyGenerated = widget.noteContent!['isComplete'] == true;
      _isReviewMode = _isFullyGenerated;
      
      // If in review mode, initialize all elements as pending approval
      if (_isReviewMode) {
        for (var element in _elements) {
          _approvedElements[element.id] = false; // Start with all elements pending approval
        }
      }
    } else {
      // Automatically generate flashcard content if no content is provided
      _generateFlashcardContent();
    }
    
    // Initialize all pages as selected by default
    _initializeSelectedPages();
    
    // Set up audio player listeners
    _setupAudioPlayer();
  }
  
  void _initializeSelectedPages() {
    // Group elements into pages first
    final pages = _groupElementsIntoPages();
    
    // Initialize all pages as selected by default
    for (int i = 0; i < pages.length; i++) {
      _selectedPages[i] = true;
    }
  }
  
  // Set up audio player listeners
  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });
    
    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });
    
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _position = Duration.zero;
        _isPlaying = false;
      });
    });
  }
  

  
  // Toggle audio playback for audio elements
  Future<void> _toggleAudioPlayback(AudioElement element) async {
    if (_isPlaying && _currentAudioElementId == element.id) {
      // If this audio is already playing, pause it
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      // If another audio is playing, stop it first
      if (_isPlaying) {
        await _audioPlayer.stop();
      }
      
      // Play the selected audio
      try {
        await _audioPlayer.play(UrlSource(element.audioUrl));
        setState(() {
          _isPlaying = true;
          _currentAudioElementId = element.id;
        });
      } catch (e) {
        // Handle playback error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not play audio: ${e.toString()}'))
        );
      }
    }
  }
  
  // Format duration for audio player display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    _titleController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  // Parse elements from note content
  List<NoteContentElement> _parseElements(Map<String, dynamic> content) {
    final List<dynamic> elementData = content['elements'] as List<dynamic>;
    final List<NoteContentElement> elements = [];
    
    for (final element in elementData) {
      final String type = element['type'] as String;
      
      switch (type) {
        case 'text':
          elements.add(TextElement(
            id: element['id'] as String? ?? const Uuid().v4(),
            content: element['content'] as String? ?? '',
            fontSize: element['fontSize'] as double? ?? 16.0,
            isBold: element['isBold'] as bool? ?? false,
            isItalic: element['isItalic'] as bool? ?? false,
            textColor: element['textColor'] as String?,
            position: element['position'] as int? ?? elements.length,
            createdAt: element['createdAt'] as Timestamp? ?? Timestamp.now(),
          ));
          break;
        case 'image':
          elements.add(ImageElement(
            id: element['id'] as String? ?? const Uuid().v4(),
            imageUrl: element['imageUrl'] as String? ?? '',
            caption: element['caption'] as String? ?? '',
            width: element['width'] as double? ?? 300.0,
            height: element['height'] as double? ?? 200.0,
            position: element['position'] as int? ?? elements.length,
            createdAt: element['createdAt'] as Timestamp? ?? Timestamp.now(),
          ));
          break;
        case 'audio':
          elements.add(AudioElement(
            id: element['id'] as String? ?? const Uuid().v4(),
            audioUrl: element['audioUrl'] as String? ?? '',
            title: element['title'] as String? ?? 'Audio',
            filePath: element['filePath'] as String?,
            duration: element['duration'] != null ? (element['duration'] as double) : null,
            position: element['position'] as int? ?? elements.length,
            createdAt: element['createdAt'] as Timestamp? ?? Timestamp.now(),
          ));
          break;
      }
    }
    
    // Sort elements by position
    elements.sort((a, b) => a.position.compareTo(b.position));
    
    return elements;
  }
  
  // Get note type name (simplified to just AI-generated notes)
  String _getNoteName() {
    return 'AI-Generated Notes';
  }
  
  // Get note color (simplified to a single color)
  Color _getNoteColor() {
    return Colors.blue;
  }
  
  // Get note icon (simplified to a single icon)
  IconData _getNoteIcon() {
    return Icons.auto_awesome; // Using the auto_awesome icon to represent AI generation
  }
  
  // Helper method to get flashcard title based on element type
  String _getFlashcardTitle(NoteContentElement element) {
    if (element is TextElement) {
      // For text elements, use the first few words of content
      String content = element.content.trim();
      if (content.isNotEmpty) {
        List<String> words = content.split(' ');
        if (words.length > 3) {
          return '${words.take(3).join(' ')}...';
        }
        return content;
      }
      return 'Text Flashcard';
    } else if (element is ImageElement) {
      String caption = element.caption ?? '';
      if (caption.isNotEmpty) {
        return caption;
      }
      return 'Image Flashcard';
    } else if (element is AudioElement) {
      return element.title ?? 'Audio Flashcard';
    } else {
      return 'Flashcard';
    }
  }
  
  // Build page header with approval controls
  Widget _buildPageHeader(int pageIndex, String pageTitle) {
    final bool? isApproved = _selectedPages[pageIndex];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page title label
          Text(
            pageTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          
          // Approval buttons
          Row(
            children: [
              // Reject button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedPages[pageIndex] = false;
                  });
                },
                icon: const Icon(Icons.cancel, size: 16),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isApproved == false ? Colors.white : Colors.red,
                  backgroundColor: isApproved == false ? Colors.red : Colors.transparent,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: const Size(0, 32),
                ),
              ),
              const SizedBox(width: 8),
              // Approve button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedPages[pageIndex] = true;
                  });
                },
                icon: const Icon(Icons.check_circle, size: 16),
                label: const Text('Approve'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isApproved == true ? Colors.white : Colors.green,
                  backgroundColor: isApproved == true ? Colors.green : Colors.transparent,
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Group elements into pages for display
  List<List<NoteContentElement>> _groupElementsIntoPages() {
    final List<List<NoteContentElement>> pages = [];
    
    // For kid-friendly flashcards, we'll create pages with a maximum of 3 elements per page
    // This ensures each page isn't overwhelming for children
    const int maxElementsPerPage = 3;
    
    // Sort elements by position
    final sortedElements = List<NoteContentElement>.from(_elements);
    sortedElements.sort((a, b) => a.position.compareTo(b.position));
    
    // Group elements into pages
    for (int i = 0; i < sortedElements.length; i += maxElementsPerPage) {
      final int end = (i + maxElementsPerPage < sortedElements.length) 
          ? i + maxElementsPerPage 
          : sortedElements.length;
      
      pages.add(sortedElements.sublist(i, end));
    }
    
    // If no pages were created, add an empty page
    if (pages.isEmpty) {
      pages.add([]);
    }
    
    return pages;
  }
  
  // Get a fun background color based on page index for kids
  Color _getPageBackgroundColor(int pageIndex) {
    // Create a list of kid-friendly colors
    final List<Color> kidFriendlyColors = [
      Colors.blue.shade50,
      Colors.purple.shade50,
      Colors.green.shade50,
      Colors.orange.shade50,
      Colors.pink.shade50,
      Colors.teal.shade50,
      Colors.amber.shade50,
      Colors.indigo.shade50,
      Colors.lime.shade50,
      Colors.cyan.shade50,
    ];
    
    // Return a color based on page index (cycle through colors)
    return kidFriendlyColors[pageIndex % kidFriendlyColors.length];
  }
  
  // Get a theme color based on page index for consistent styling
  Color _getPageThemeColor(int pageIndex) {
    // Create a list of vibrant theme colors
    final List<MaterialColor> themeColors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.lime,
      Colors.cyan,
    ];
    
    // Return a color based on page index (cycle through colors)
    return themeColors[pageIndex % themeColors.length];
  }
  
  // Get a fun decoration icon based on page index and content
  IconData _getDecorationIcon(int pageIndex, List<NoteContentElement> pageElements) {
    // Check if there are any text elements with specific keywords
    bool hasAnimalContent = false;
    bool hasMathContent = false;
    bool hasLanguageContent = false;
    bool hasScienceContent = false;
    
    for (final element in pageElements) {
      if (element is TextElement) {
        final String content = element.content.toLowerCase();
        if (content.contains('animal') || content.contains('dog') || content.contains('cat')) {
          hasAnimalContent = true;
        } else if (content.contains('math') || content.contains('number') || content.contains('count')) {
          hasMathContent = true;
        } else if (content.contains('letter') || content.contains('word') || content.contains('read')) {
          hasLanguageContent = true;
        } else if (content.contains('science') || content.contains('experiment') || content.contains('nature')) {
          hasScienceContent = true;
        }
      }
    }
    
    // Return an appropriate icon based on content
    if (hasAnimalContent) {
      final List<IconData> animalIcons = [Icons.pets, Icons.cruelty_free, Icons.emoji_nature];
      return animalIcons[pageIndex % animalIcons.length];
    } else if (hasMathContent) {
      final List<IconData> mathIcons = [Icons.calculate, Icons.bar_chart, Icons.add_circle];
      return mathIcons[pageIndex % mathIcons.length];
    } else if (hasLanguageContent) {
      final List<IconData> languageIcons = [Icons.menu_book, Icons.abc, Icons.text_fields];
      return languageIcons[pageIndex % languageIcons.length];
    } else if (hasScienceContent) {
      final List<IconData> scienceIcons = [Icons.science, Icons.biotech, Icons.psychology];
      return scienceIcons[pageIndex % scienceIcons.length];
    } else {
      // Default fun icons
      final List<IconData> defaultIcons = [
        Icons.star, Icons.favorite, Icons.emoji_emotions, 
        Icons.lightbulb, Icons.auto_awesome, Icons.celebration,
        Icons.school, Icons.palette, Icons.emoji_events
      ];
      return defaultIcons[pageIndex % defaultIcons.length];
    }
  }
  
  // Check if the note exceeds the page limit
  bool _exceedsPageLimit(int totalPages) {
    return totalPages > widget.pageLimit;
  }
  
  // Get page count message
  String _getPageCountMessage(int totalPages) {
    if (totalPages <= widget.pageLimit) {
      return 'Page $totalPages of $totalPages';
    } else {
      return 'Page $totalPages of ${widget.pageLimit} (Limit Exceeded)';
    }
  }
  
  // Get max pages to show
  int _getMaxPagesToShow() {
    return widget.pageLimit;
  }
  
  // Play audio
  Future<void> _playAudio(AudioElement element) async {
    try {
      await _audioPlayer.play(UrlSource(element.audioUrl));
        
      setState(() {
        _isPlaying = true;
        _currentAudioElementId = element.id;
        _position = Duration.zero;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: ${e.toString()}')),
      );
    }
  }
  
  // Pick image from gallery or camera
  Future<void> _pickImage(ImageElement element) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery, element);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera, element);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Get image from source
  Future<void> _getImage(ImageSource source, ImageElement element) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading image...')),
        );
        
        // Upload image to Firebase Storage
        final String? imageUrl = await _contentService.uploadImage(
          File(pickedFile.path),
          'notes/${widget.subject.id}/${widget.chapter.id}/${element.id}',
        );
        
        if (imageUrl != null && mounted) {
          setState(() {
            // Replace the element with updated image URL
            final int index = _elements.indexWhere((e) => e.id == element.id);
            if (index != -1) {
              _elements[index] = ImageElement(
                id: element.id,
                imageUrl: imageUrl,
                caption: element.caption,
                position: element.position,
                createdAt: element.createdAt,
                width: element.width,
                height: element.height,
              );
            }
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }
  
  // Generate more content
  Future<void> _generateMoreContent() async {
    // Call the flashcard content generation method
    await _generateFlashcardContent();
  }
  
  // Helper methods for age-based content generation
  int _getAgeBasedPageCount(int age) {
    switch (age) {
      case 4:
        return 10; // 10 pages for age 4
      case 5:
        return 15; // 15 pages for age 5
      case 6:
        return 20; // 20 pages for age 6
      default:
        return 10; // Default to 10 pages
    }
  }
  
  double _getAgeBasedFontSize(int age) {
    switch (age) {
      case 4:
        return 24.0; // Larger font for age 4
      case 5:
        return 20.0; // Medium font for age 5
      case 6:
        return 18.0; // Smaller font for age 6
      default:
        return 20.0; // Default font size
    }
  }
  
  double _getAgeBasedImageRatio(int age) {
    switch (age) {
      case 4:
        return 0.7; // 70% images for age 4
      case 5:
        return 0.5; // 50% images for age 5
      case 6:
        return 0.4; // 40% images for age 6
      default:
        return 0.5; // Default image ratio
    }
  }
  
  // Get the appropriate note style based on age and subject
  String _getAgeAppropriateStyle(int age, String subject) {
    // For younger kids (age 4), use more visual and simple content
    if (age == 4) {
      if (subject.toLowerCase().contains('math')) {
        return 'visual_counting'; // Visual counting style for math
      } else if (subject.toLowerCase().contains('language') || subject.toLowerCase().contains('english')) {
        return 'picture_words'; // Picture words for language
      } else {
        return 'colorful_simple'; // Colorful and simple for other subjects
      }
    }
    // For middle age (age 5)
    else if (age == 5) {
      if (subject.toLowerCase().contains('science')) {
        return 'discovery'; // Discovery style for science
      } else if (subject.toLowerCase().contains('math')) {
        return 'pattern_based'; // Pattern-based for math
      } else {
        return 'balanced_visual'; // Balanced visual content for other subjects
      }
    }
    // For older kids (age 6)
    else {
      if (subject.toLowerCase().contains('history') || subject.toLowerCase().contains('social')) {
        return 'storytelling'; // Storytelling for history/social studies
      } else if (subject.toLowerCase().contains('science')) {
        return 'exploratory'; // Exploratory for science
      } else {
        return 'concept_focused'; // Concept-focused for other subjects
      }
    }
  }
  
  // Get color based on age group
  Color _getAgeColor(int age) {
    switch (age) {
      case 4:
        return Colors.purple;
      case 5:
        return Colors.blue;
      case 6:
        return Colors.green;
      default:
        return Colors.orange;
    }
  }
  
  // Convert color string to Color object
  Color _getColorFromString(String colorString) {
    try {
      return Color(int.parse(colorString));
    } catch (e) {
      return Colors.black;
    }
  }
  
  // Publish the note
  Future<void> _publishNote() async {
    // Validate the title is not empty
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for the note')),
      );
      return;
    }
    
    // In review mode, validate that all pages have been reviewed
    if (_isReviewMode) {
      final pages = _groupElementsIntoPages();
      bool allPagesReviewed = true;
      
      for (int i = 0; i < pages.length; i++) {
        if (!_selectedPages.containsKey(i)) {
          allPagesReviewed = false;
          break;
        }
      }
      
      if (!allPagesReviewed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please review all flashcards before publishing')),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Get pages and filter out unselected pages
      final List<List<NoteContentElement>> pages = _groupElementsIntoPages();
      List<NoteContentElement> selectedElements = [];
      
      // Only include elements from selected pages
      for (int i = 0; i < pages.length; i++) {
        if (_selectedPages[i] ?? true) {
          selectedElements.addAll(pages[i]);
        }
      }
      
      // Create a new list with properly positioned elements
      final List<NoteContentElement> positionedElements = [];
      
      // Process each selected element and create a new one with the correct position
      for (int i = 0; i < selectedElements.length; i++) {
        final element = selectedElements[i];
        
        if (element is TextElement) {
          positionedElements.add(TextElement(
            id: element.id,
            content: element.content,
            fontSize: element.fontSize,
            isBold: element.isBold,
            isItalic: element.isItalic,
            textColor: element.textColor,
            position: i,
            createdAt: element.createdAt,
          ));
        } else if (element is ImageElement) {
          positionedElements.add(ImageElement(
            id: element.id,
            imageUrl: element.imageUrl,
            caption: element.caption,
            width: element.width,
            height: element.height,
            position: i,
            createdAt: element.createdAt,
          ));
        } else if (element is AudioElement) {
          positionedElements.add(AudioElement(
            id: element.id,
            position: i,
            createdAt: element.createdAt,
            audioUrl: element.audioUrl,
            title: element.title,
            filePath: element.filePath,
            duration: element.duration,
          ));
        }
      }
      
      // Replace the original list with the positioned elements
      selectedElements = positionedElements;
      
      // Prepare the elements for saving
      final List<Map<String, dynamic>> elementData = [];
      
      for (final element in selectedElements) {
        if (element is TextElement) {
          elementData.add({
            'id': element.id,
            'type': 'text',
            'content': element.content,
            'fontSize': element.fontSize,
            'isBold': element.isBold,
            'isItalic': element.isItalic,
            'textColor': element.textColor,
            'position': element.position,
            'createdAt': element.createdAt,
          });
        } else if (element is ImageElement) {
          elementData.add({
            'id': element.id,
            'type': 'image',
            'imageUrl': element.imageUrl,
            'caption': element.caption,
            'width': element.width,
            'height': element.height,
            'position': element.position,
            'createdAt': element.createdAt,
          });
        } else if (element is AudioElement) {
          elementData.add({
            'id': element.id,
            'type': 'audio',
            'position': element.position,
            'createdAt': element.createdAt,
            'audioUrl': element.audioUrl,
            'title': element.title,
            'filePath': element.filePath,
            'duration': element.duration, // Duration is already stored as a double
          });
        }
      }

      // Create the note object with only the selected elements
      final note = Note(
        title: _titleController.text,
        elements: selectedElements,
        isDraft: false,
        createdAt: Timestamp.now(),
      );

      // Save the note to the chapter
      await _contentService.saveNoteToChapter(widget.subject.id, widget.chapter.id, note);
      
      if (mounted) {
        // Show success message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Note published successfully!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        
        // Navigate back to the previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error publishing note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  // Helper method to build element type indicator for statistics
  Widget _buildElementTypeIndicator(String type, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(type, style: TextStyle(color: color)),
        Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // Build the bottom action bar with review controls
  Widget _buildBottomActionBar() {
    // Count approved, rejected, and pending pages
    int approvedPages = 0;
    int rejectedPages = 0;
    int pendingPages = 0;
    int totalPages = _groupElementsIntoPages().length;
    
    for (final entry in _selectedPages.entries) {
      if (entry.value == true) {
        approvedPages++;
      } else if (entry.value == false) {
        rejectedPages++;
      } else {
        pendingPages++;
      }
    }
    
    // Ensure all pages are accounted for
    pendingPages = totalPages - approvedPages - rejectedPages;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicators
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text('Approved: $approvedPages', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: totalPages == 0 ? 0 : approvedPages / totalPages,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pending, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text('Pending: $pendingPages', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: totalPages == 0 ? 0 : pendingPages / totalPages,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cancel, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text('Rejected: $rejectedPages', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: totalPages == 0 ? 0 : rejectedPages / totalPages,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Navigation
              Row(
                children: [
                  IconButton(
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    color: _getNoteColor(),
                    disabledColor: Colors.grey.shade300,
                  ),
                  Text('Page ${_currentPage + 1}'),
                  IconButton(
                    onPressed: _currentPage < _groupElementsIntoPages().length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    color: _getNoteColor(),
                    disabledColor: Colors.grey.shade300,
                  ),
                ],
              ),
              
              // Approve all / Reject all buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                                // Mark current page as rejected
                        _selectedPages[_currentPage] = false;
                      });
                    },
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text('Reject All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        // Mark current page as approved
                        _selectedPages[_currentPage] = true;
                      });
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Approve All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              
              // Publish button
              ElevatedButton.icon(
                onPressed: pendingPages > 0 ? null : () => _publishNote(),
                icon: const Icon(Icons.publish),
                label: Text(pendingPages > 0 ? 'Review All Flashcards First' : 'Publish Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getNoteColor(),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Generate flashcard content automatically based on subject and age
  Future<void> _generateFlashcardContent() async {
    if (_isGeneratingMoreContent) return;
    
    setState(() {
      _isGeneratingMoreContent = true;
    });
    
    try {
      // Prepare parameters for content generation
      final Map<String, dynamic> params = {
        'subject': widget.subject.name,
        'chapter': widget.chapter.name,
        'age': widget.subject.moduleId, // Using moduleId as age (4, 5, or 6)
        'style': _getAgeAppropriateStyle(widget.subject.moduleId, widget.subject.name),
      };
      
      // Generate content using GeminiService
      final List<NoteContentElement> generatedElements = await _geminiService.generateFlashcardContent(params);
      
      // Update the title based on the subject and chapter
      _titleController.text = '${widget.subject.name}: ${widget.chapter.name} Flashcards';
      
      setState(() {
        // Add generated elements to the existing elements
        _elements.addAll(generatedElements);
        _isGeneratingMoreContent = false;
        
        // Initialize text controllers for any new text elements
        for (final element in generatedElements) {
          if (element is TextElement) {
            _textControllers[element.id] = TextEditingController(text: element.content);
          }
        }
        
        // Update selected pages
        _initializeSelectedPages();
      });
    } catch (e) {
      setState(() {
        _isGeneratingMoreContent = false;
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating content: ${e.toString()}'))
      );
    }
  }
  
  // Build a simple flashcard layout that matches the design in the image
  Widget _buildSimpleFlashcardLayout(int pageIndex, List<NoteContentElement> pageElements, int totalPages) {
    // With flashcard style, we should have exactly one element per page
    final NoteContentElement element = pageElements.isNotEmpty ? pageElements.first : TextElement(
      id: 'empty',
      position: 0,
      createdAt: Timestamp.now(),
      content: 'No content available',
      isBold: true,
      isItalic: false,
      isList: false,
    );
    
    // Extract title from content if it's a text element
    String title = '';
    String description = '';
    
    // Get subject name for the title
    String subjectName = widget.subject.name.toUpperCase();
    
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
    
    return Container(
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
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircularButton(Icons.home, Colors.blue.shade900, () {
                      // Navigate to home
                    }),
                    _buildCircularButton(Icons.volume_up, Colors.amber, () {
                      // Toggle sound
                    }),
                    _buildCircularButton(Icons.music_note, Colors.blue.shade800, () {
                      // Toggle background music
                    }),
                  ],
                ),
              ),
              
              // Subject title bar
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade300,
                  borderRadius: BorderRadius.zero,
                ),
                width: double.infinity,
                child: Text(
                  subjectName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
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
              
              // Main content area
              Expanded(
                child: Center(
                  child: _buildFlashcardContent(element, title, description),
                ),
              ),
              
              // Content label at bottom (for images)
              if (element is ImageElement && title.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade800,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 30, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous button
                    _buildNavigationButton(
                      Icons.arrow_back_ios,
                      Colors.green,
                      pageIndex > 0 ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } : null,
                    ),
                    const SizedBox(width: 100),
                    // Next button
                    _buildNavigationButton(
                      Icons.arrow_forward_ios,
                      Colors.green,
                      pageIndex < totalPages - 1 ? () {
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
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
  
  // Build a navigation button (prev/next)
  Widget _buildNavigationButton(IconData icon, Color color, VoidCallback? onPressed) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 30),
        onPressed: onPressed,
      ),
    );
  }
  
  // Build the flashcard content based on element type
  // Helper methods to extract title and description from elements
  String _getFlashcardDescription(NoteContentElement element) {
    if (element is TextElement) {
      final content = element.content;
      if (content.contains('\n')) {
        final parts = content.split('\n');
        return parts.sublist(1).join('\n').trim();
      } else if (content.contains('. ')) {
        final parts = content.split('. ');
        return parts.sublist(1).join('. ').trim();
      }
    } else if (element is AudioElement) {
      return 'Listen to the pronunciation';
    }
    return '';
  }
  
  Widget _buildFlashcardContent(NoteContentElement element, String title, String description) {
    if (element is ImageElement) {
      return _buildImageFlashcard(element);
    } else if (element is AudioElement) {
      return _buildAudioFlashcard(element, title, description);
    } else if (element is TextElement) {
      return _buildTextFlashcard(title, description);
    }
    return Container();
  }
  
  // Build image content with rainbow decoration
  Widget _buildImageFlashcard(ImageElement element) {
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
              width: 150,
              errorBuilder: (context, error, stackTrace) => Container(),
            ),
          ),
        ),
        
        // Main image
        Container(
          padding: const EdgeInsets.all(20),
          child: element.imageUrl != null && element.imageUrl!.isNotEmpty
              ? Image.network(
                  element.imageUrl!,
                  fit: BoxFit.contain,
                  height: 300,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_not_supported, color: Colors.red, size: 80),
                        const SizedBox(height: 16),
                        const Text(
                          'Image not available',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  },
                )
              : const Placeholder(fallbackHeight: 200, fallbackWidth: 200),
        ),
      ],
    );
  }
  
  // Build audio content
  Widget _buildAudioFlashcard(AudioElement element, String title, String description) {
    bool isPlaying = _isPlaying && _currentAudioElementId == element.id;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue.shade400,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.white,
              size: 60,
            ),
            onPressed: () {
              if (element.audioUrl != null && element.audioUrl!.isNotEmpty) {
                _toggleAudioPlayback(element);
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          description,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  // Build text content
  Widget _buildTextFlashcard(String title, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          description,
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  // Build tablet layout (for medium screens) - flashcard style
  Widget _buildTabletLayout(int pageIndex, List<NoteContentElement> pageElements, int totalPages, bool exceededLimit) {
    // With flashcard style, we should have exactly one element per page
    final NoteContentElement element = pageElements.first;
    String elementType = element is TextElement ? 'Text' : (element is ImageElement ? 'Image' : 'Audio');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Page header with controls
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getNoteColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Flashcard ${pageIndex + 1} of $totalPages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getNoteColor(),
                ),
              ),
              // Page inclusion checkbox
              Row(
                children: [
                  const Text('Include'),
                  Checkbox(
                    value: _selectedPages[pageIndex] ?? true,
                    activeColor: _getNoteColor(),
                    onChanged: _isReviewMode ? null : (value) {
                      setState(() {
                        _selectedPages[pageIndex] = value ?? true;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(8),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                // Page header with approval controls in review mode
                if (_isReviewMode)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildPageHeader(pageIndex, 'Flashcard ${pageIndex + 1}'),
                  ),
                
                // Flashcard content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: _buildFlashcardContent(element, _getFlashcardTitle(element), _getFlashcardDescription(element)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Build mobile layout (for small screens) - flashcard style with kid-friendly design
  Widget _buildMobileLayout(int pageIndex, List<NoteContentElement> pageElements, int totalPages, bool exceededLimit) {
    // With flashcard style, we should have exactly one element per page
    final NoteContentElement element = pageElements.first;
    String elementType = element is TextElement ? 'Text' : (element is ImageElement ? 'Image' : 'Audio');
    
    // Get age from subject moduleId for age-appropriate content
    final int age = widget.subject.moduleId;
    
    // Get age-appropriate colors based on age group
    final Color primaryColor = _getAgeColor(widget.subject.moduleId);
    final Color backgroundColor = primaryColor.withOpacity(0.1);
    
    return Column(
      children: [
        // Page header with controls - more colorful for kids
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Flashcard ${pageIndex + 1} of $totalPages',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getNoteColor(),
                ),
              ),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            color: Colors.white,
            child: Stack(
              children: [
                // Background pattern for visual interest (subtle)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          backgroundColor,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Content layout
                Column(
                  children: [
                    // Page header with approval controls in review mode
                    if (_isReviewMode)
                      Container(
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: _buildPageHeader(pageIndex, 'Flashcard ${pageIndex + 1}'),
                      ),
                    
                    // Flashcard content with enhanced styling
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: _buildKidFriendlyFlashcardElement(element, primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Build the main page content
  Widget _buildPageContent(int pageIndex, List<NoteContentElement> pageElements, int totalPages, bool exceededLimit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning if page limit exceeded
          if (exceededLimit && pageIndex == 0)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade700),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This note exceeds the recommended page limit of ${widget.pageLimit}. Consider removing some content.',
                      style: TextStyle(color: Colors.amber.shade800),
                    ),
                  ),
                ],
              ),
            ),
          
          // Page elements
          ...pageElements.map((element) {
            // Build element based on type
            if (element is TextElement) {
              return _buildTextElement(element);
            } else if (element is ImageElement) {
              return _buildImageElement(element);
            } else if (element is AudioElement) {
              return _buildAudioElement(element);
            } else {
              return const SizedBox.shrink();
            }
          }).toList(),
        ],
      ),
    );
  }
  
  // Build text element
  Widget _buildTextElement(TextElement element) {
    // Get or create a text controller for this element
    if (!_textControllers.containsKey(element.id)) {
      _textControllers[element.id] = TextEditingController(text: element.content);
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // No element header in flashcard style - approval is at page level
            
            // Text content
            TextField(
              controller: _textControllers[element.id],
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter text content',
              ),
              enabled: !_isReviewMode, // Disable editing in review mode
              style: TextStyle(
                fontSize: element.fontSize,
                fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
                color: element.textColor != null ? _getColorFromString(element.textColor!) : null,
              ),
              onChanged: (value) {
                // Update the element content
                setState(() {
                  final int index = _elements.indexWhere((e) => e.id == element.id);
                  if (index != -1) {
                    _elements[index] = TextElement(
                      id: element.id,
                      content: value,
                      fontSize: element.fontSize,
                      isBold: element.isBold,
                      isItalic: element.isItalic,
                      textColor: element.textColor,
                      position: element.position,
                      createdAt: element.createdAt,
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Build image element
  Widget _buildImageElement(ImageElement element) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // No element header in flashcard style - approval is at page level
            
            // Image content
            GestureDetector(
              onTap: _isReviewMode ? null : () => _pickImage(element),
              child: Container(
                width: element.width,
                height: element.height,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: element.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          element.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(height: 8),
                                  Text('Error loading image: $error'),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              _isReviewMode ? 'No image available' : 'Tap to add image',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            
            // Caption
            if (element.caption != null && element.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  element.caption ?? '',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Build audio element
  Widget _buildAudioElement(AudioElement element) {
    final bool isCurrentlyPlaying = _isPlaying && _currentAudioElementId == element.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // No element header in flashcard style - approval is at page level
            
            // Audio player
            Row(
              children: [
                // Play/pause button
                IconButton(
                  icon: Icon(isCurrentlyPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: element.audioUrl.isNotEmpty ? () => _toggleAudioPlayback(element) : null,
                  color: _getNoteColor(),
                ),
                
                // Progress bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        element.title ?? 'Audio',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      
                      // Progress slider
                      if (isCurrentlyPlaying)
                        Slider(
                          value: _position.inSeconds.toDouble(),
                          max: _duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            _audioPlayer.seek(Duration(seconds: value.toInt()));
                          },
                        )
                      else
                        const SizedBox(height: 24),
                      
                      // Duration display
                      if (isCurrentlyPlaying)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(_position)),
                            Text(_formatDuration(_duration)),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Build kid-friendly flashcard element with enhanced visuals and AI-generated images
  Widget _buildKidFriendlyFlashcardElement(NoteContentElement element, Color themeColor) {
    // Get age from subject moduleId for age-appropriate content
    final int age = widget.subject.moduleId;
    
    if (element is TextElement) {
      return _buildKidFriendlyTextElement(element, themeColor);
    } else if (element is ImageElement) {
      return _buildKidFriendlyImageElement(element, themeColor);
    } else if (element is AudioElement) {
      return _buildKidFriendlyAudioElement(element, themeColor);
    } else {
      return const SizedBox.shrink();
    }
  }
  
  // Build kid-friendly text element with enhanced visuals
  Widget _buildKidFriendlyTextElement(TextElement element, Color themeColor) {
    // Get or create a text controller for this element
    if (!_textControllers.containsKey(element.id)) {
      _textControllers[element.id] = TextEditingController(text: element.content);
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fun icon for text
          Icon(
            Icons.menu_book,
            color: themeColor,
            size: 40,
          ),
          const SizedBox(height: 16),
          
          // Text content with enhanced styling
          TextField(
            controller: _textControllers[element.id],
            maxLines: null,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter text content',
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
            enabled: !_isReviewMode, // Disable editing in review mode
            style: TextStyle(
              fontSize: (element.fontSize ?? 16.0) + 2, // Slightly larger for better readability
              fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
              fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
              color: element.textColor != null ? _getColorFromString(element.textColor!) : themeColor,
              height: 1.5, // Better line spacing for readability
            ),
            onChanged: (value) {
              // Update the element content
              setState(() {
                final int index = _elements.indexWhere((e) => e.id == element.id);
                if (index != -1) {
                  _elements[index] = TextElement(
                    id: element.id,
                    content: value,
                    fontSize: element.fontSize,
                    isBold: element.isBold,
                    isItalic: element.isItalic,
                    textColor: element.textColor,
                    position: element.position,
                    createdAt: element.createdAt,
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }
  
  // Build kid-friendly image element with AI-generated images
  Widget _buildKidFriendlyImageElement(ImageElement element, Color themeColor) {
    // Generate a deterministic but unique image URL based on content
    String getAIImageUrl(String caption, int age) {
      // Create a hash from the caption to ensure consistent images for the same content
      final String contentHash = caption.hashCode.toString();
      
      // Use Unsplash Source for reliable, high-quality images
      // This service provides random but relevant images based on search terms
      final String baseUrl = 'https://source.unsplash.com/featured/600x400';
      
      // Create query parameters based on caption and age
      String query = '?$contentHash';
      
      // Add age-appropriate keywords based on the child's age
      if (age <= 4) {
        query += '&children,colorful,simple,cartoon';
      } else if (age <= 5) {
        query += '&children,educational,colorful';
      } else {
        query += '&educational,learning';
      }
      
      // Add subject-specific terms if available in the caption
      if (caption.toLowerCase().contains('animal')) {
        query += ',animals,nature';
      } else if (caption.toLowerCase().contains('math')) {
        query += ',numbers,math';
      } else if (caption.toLowerCase().contains('language')) {
        query += ',books,letters';
      }
      
      return baseUrl + query;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image content with fun border
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: element.width,
              height: element.height,
              decoration: BoxDecoration(
                border: Border.all(color: themeColor, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: element.imageUrl.isNotEmpty
                    ? Image.network(
                        element.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: themeColor,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // If there's an error loading the image, use our AI-generated image instead
                          return Image.network(
                            getAIImageUrl(element.caption ?? 'educational flashcard', widget.subject.moduleId),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: themeColor,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image, size: 60, color: themeColor),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Image not available',
                                      style: TextStyle(color: themeColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      )
                    : Image.network(
                        getAIImageUrl(element.caption ?? 'educational flashcard', widget.subject.moduleId),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: themeColor,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 60, color: themeColor),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: TextStyle(color: themeColor),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          
          // Caption with fun styling
          if (element.caption != null && element.caption!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                element.caption ?? '',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: themeColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
  
  // Build kid-friendly audio element with enhanced visuals
  Widget _buildKidFriendlyAudioElement(AudioElement element, Color themeColor) {
    final bool isCurrentlyPlaying = _isPlaying && _currentAudioElementId == element.id;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title with fun icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note, color: themeColor, size: 24),
              const SizedBox(width: 8),
              Text(
                element.title ?? 'Fun Audio',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Play button with animation
          InkWell(
            onTap: element.audioUrl.isNotEmpty ? () => _toggleAudioPlayback(element) : null,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeColor.withOpacity(0.1),
                border: Border.all(color: themeColor, width: 3),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrentlyPlaying ? 30 : 40,
                  height: isCurrentlyPlaying ? 30 : 40,
                  child: Icon(
                    isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
                    color: themeColor,
                    size: isCurrentlyPlaying ? 30 : 40,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Progress bar with fun styling
          if (isCurrentlyPlaying)
            Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: themeColor,
                    inactiveTrackColor: themeColor.withOpacity(0.2),
                    thumbColor: themeColor,
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                
                // Duration display with fun styling
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDuration(_position),
                          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDuration(_duration),
                          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  // Play a fun page turn sound effect
  void _playPageTurnSound() {
    // Only play if no audio is currently playing
    if (!_isPlaying) {
      // This is a simple implementation that could be enhanced with actual sound files
      // For now, we'll just provide visual feedback without sound to avoid errors
      // since the sound file might not be available
    }
  }
  
  // Build a summary page with compliments
  Widget _buildSummaryPage(int totalPages) {
    return Container(
      color: Colors.lightBlue.shade50,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Confetti animation (simulated with static elements)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('🎉', style: TextStyle(fontSize: 40)),
                  Text('🎊', style: TextStyle(fontSize: 40)),
                  Text('🎈', style: TextStyle(fontSize: 40)),
                  Text('🎉', style: TextStyle(fontSize: 40)),
                ],
              ),
              SizedBox(height: 30),
              // Congratulations text
              Text(
                'Great Job!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      "You've completed all ${totalPages - 1} flashcards!",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Keep practicing to master the content.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatCard('Flashcards', '${totalPages - 1}', Icons.style),
                  SizedBox(width: 20),
                  _buildStatCard('Selected', '${_selectedPages.values.where((selected) => selected ?? false).length}', Icons.check_circle),
                ],
              ),
              SizedBox(height: 40),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _pageController.jumpToPage(0);
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Start Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement save functionality
                    },
                    icon: Icon(Icons.save),
                    label: Text('Save Flashcards'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
  
  // Helper method to build stat cards for the summary page
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 120,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Group elements into pages
    final List<List<NoteContentElement>> pages = _groupElementsIntoPages();
    final bool exceededLimit = pages.length > widget.pageLimit;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Create Flashcards',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create flashcards for children to learn'))
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: pages.isEmpty
                ? const Center(child: Text('No content available. Generate content to continue.'))
                : Center( // Center the content to maintain consistent sizing
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 800, // Fixed maximum width for all screen sizes
                        maxHeight: 700, // Fixed maximum height for all screen sizes
                      ),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: pages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        // Add smooth page transition effect
                        pageSnapping: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, pageIndex) {
                          // Get elements for this page
                          final pageElements = pages[pageIndex];
                          
                          // Use a single fixed layout for all screen sizes
                          return Container(
                            margin: const EdgeInsets.all(16),
                            child: _buildSimpleFlashcardLayout(pageIndex, pageElements, pages.length),
                          );
                        },
                      ),
                    ),
                  ),
          ),
          
          // Save button at bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : () => _publishNote(),
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(_isSaving ? 'Publishing...' : 'Publish', style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
