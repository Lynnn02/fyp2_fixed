import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
// These imports would need to be adjusted to match your project structure
// import '../../../models/subject.dart'; 
// import '../../../models/note_content.dart';
// import '../../../services/content_service.dart';
// import '../../../services/gemini_service.dart';
// import '../../../widgets/admin_ui_style.dart';

// This is a fixed version of the NoteTemplatePreviewScreen
// Replace your current file with this corrected version
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
  
  // Generate more content
  Future<void> _generateMoreContent() async {
    setState(() {
      _isGeneratingMoreContent = true;
    });
    
    try {
      // Generate additional content based on the current template and subject
      final additionalContent = await _geminiService.generateNoteContent(
        subject: widget.subject.name,
        chapter: widget.chapter.name,
        age: widget.subject.moduleId,
        templateType: widget.templateId,
        pageCount: 5, // Generate 5 more pages
      );
      
      if (additionalContent != null && additionalContent['elements'] != null) {
        // Parse the new elements
        final newElements = _parseElements(additionalContent);
        
        // Add them to the existing elements
        setState(() {
          _elements.addAll(newElements);
          _isGeneratingMoreContent = false;
        });
      } else {
        setState(() {
          _isGeneratingMoreContent = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to generate more content')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isGeneratingMoreContent = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating content: ${e.toString()}')),
        );
      }
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
            duration: element['duration'] != null ? Duration(milliseconds: element['duration'] as int) : null,
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
  
  // Group elements into pages for display
  List<List<NoteContentElement>> _groupElementsIntoPages() {
    final List<List<NoteContentElement>> pages = [];
    
    // Sort elements by position
    final sortedElements = List<NoteContentElement>.from(_elements);
    sortedElements.sort((a, b) => a.position.compareTo(b.position));
    
    // Determine elements per page based on age group
    int elementsPerPage = 5;
    if (widget.subject.moduleId <= 4) {
      elementsPerPage = 3; // Fewer elements for younger children
    } else if (widget.subject.moduleId >= 6) {
      elementsPerPage = 7; // More elements for older children
    }
    
    // Group elements into pages
    for (int i = 0; i < sortedElements.length; i += elementsPerPage) {
      final end = (i + elementsPerPage < sortedElements.length) ? i + elementsPerPage : sortedElements.length;
      pages.add(sortedElements.sublist(i, end));
    }
    
    return pages;
  }
  
  // Get template color based on template ID
  Color _getTemplateColor() {
    switch (widget.templateId) {
      case 'balanced':
        return Colors.blue;
      case 'story':
        return Colors.purple;
      case 'factual':
        return Colors.green;
      case 'interactive':
        return Colors.orange;
      case 'visual':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }
  
  // Get template icon based on template ID
  IconData _getTemplateIcon() {
    switch (widget.templateId) {
      case 'balanced':
        return Icons.balance;
      case 'story':
        return Icons.book;
      case 'factual':
        return Icons.info;
      case 'interactive':
        return Icons.touch_app;
      case 'visual':
        return Icons.image;
      default:
        return Icons.note;
    }
  }
  
  // Format duration for audio display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  // Toggle audio playback
  void _toggleAudioPlayback(AudioElement element) async {
    if (_isPlaying && _currentAudioElementId == element.id) {
      // Pause current audio
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      try {
        // Stop any currently playing audio
        if (_isPlaying) {
          await _audioPlayer.stop();
        }
        
        // Play the selected audio
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
  
  // Publish the note
  Future<void> _publishNote() async {
    // Validate the title is not empty
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for the note')),
      );
      return;
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
            'createdAt': element.createdAt,
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
      await _contentService.saveNoteToChapter(
        widget.subject.id,
        widget.chapter.id,
        note,
      );
      
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
  
  // Build the bottom action bar with review controls
  Widget _buildBottomActionBar() {
    // Count approved and rejected elements
    int totalElements = _elements.length;
    int approvedElements = _approvedElements.values.where((approved) => approved).length;
    int rejectedElements = _approvedElements.values.where((approved) => approved == false).length;
    int pendingElements = totalElements - approvedElements - rejectedElements;
    
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
                        Text('Approved: $approvedElements', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _elements.isEmpty ? 0 : approvedElements / _elements.length,
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
                        Text('Pending: $pendingElements', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _elements.isEmpty ? 0 : pendingElements / _elements.length,
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
                        Text('Rejected: $rejectedElements', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _elements.isEmpty ? 0 : rejectedElements / _elements.length,
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
                    color: _getTemplateColor(),
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
                    color: _getTemplateColor(),
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
                        // Get elements on current page
                        final currentPageElements = _groupElementsIntoPages()[_currentPage];
                        // Mark all elements on this page as rejected
                        for (var element in currentPageElements) {
                          _approvedElements[element.id] = false;
                        }
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
                        // Get elements on current page
                        final currentPageElements = _groupElementsIntoPages()[_currentPage];
                        // Mark all elements on this page as approved
                        for (var element in currentPageElements) {
                          _approvedElements[element.id] = true;
                        }
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
                onPressed: pendingElements > 0 ? null : () => _publishNote(),
                icon: const Icon(Icons.publish),
                label: Text(pendingElements > 0 ? 'Review All Items First' : 'Publish Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getTemplateColor(),
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
}
