import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import '../../../models/note_content.dart';
import '../../../models/subject.dart';
import '../../../services/content_service.dart';
import '../../../widgets/admin_ui_style.dart';
import 'enhanced_note_template_manager.dart';

class EnhancedNotePreviewScreen extends StatefulWidget {
  final Map<String, dynamic> noteContent;
  final Subject subject;
  final Chapter chapter;
  final String templateId;
  final int ageGroup;

  const EnhancedNotePreviewScreen({
    Key? key,
    required this.noteContent,
    required this.subject,
    required this.chapter,
    required this.templateId,
    required this.ageGroup,
  }) : super(key: key);

  @override
  State<EnhancedNotePreviewScreen> createState() => _EnhancedNotePreviewScreenState();
}

class _EnhancedNotePreviewScreenState extends State<EnhancedNotePreviewScreen> {
  final EnhancedNoteTemplateManager _templateManager = EnhancedNoteTemplateManager();
  final ContentService _contentService = ContentService();
  late PageController _pageController;
  int _currentPage = 0;
  List<List<NoteContentElement>> _pages = [];
  bool _isPublishing = false;
  bool _isEditing = false;
  late Note _note;
  
  // Audio player
  final Map<String, AudioPlayer> _audioPlayers = {};
  String? _currentlyPlayingAudioId;
  
  // Text editing controllers
  late TextEditingController _titleController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _note = _templateManager.convertToNoteModel(widget.noteContent);
    _titleController = TextEditingController(text: _note.title);
    _groupElementsIntoPages();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    
    // Dispose all audio players
    for (final player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
    
    super.dispose();
  }
  
  void _groupElementsIntoPages() {
    final elements = _note.elements;
    final List<List<NoteContentElement>> pages = [];
    List<NoteContentElement> currentPage = [];
    
    // Determine how many elements per page based on age
    int elementsPerPage = 3;
    switch (widget.ageGroup) {
      case 4:
        elementsPerPage = 2; // Fewer elements per page for younger children
        break;
      case 5:
        elementsPerPage = 3;
        break;
      case 6:
        elementsPerPage = 4; // More elements per page for older children
        break;
    }
    
    for (int i = 0; i < elements.length; i++) {
      currentPage.add(elements[i]);
      
      // Start a new page if we've reached the limit or if this is an image (which takes more space)
      if (currentPage.length >= elementsPerPage || 
          (elements[i] is ImageElement && currentPage.length > 1)) {
        pages.add(List.from(currentPage));
        currentPage = [];
      }
    }
    
    // Add any remaining elements
    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }
    
    setState(() {
      _pages = pages;
    });
  }
  
  Future<void> _publishNote() async {
    setState(() {
      _isPublishing = true;
    });
    
    try {
      // Update note title if edited
      _note = Note(
        id: _note.id,
        title: _titleController.text,
        createdAt: _note.createdAt,
        updatedAt: Timestamp.now(),
        elements: _note.elements,
      );
      
      // Save note to database
      await _contentService.addNote(
        _note,
        widget.subject.id,
        widget.chapter.id,
        widget.ageGroup,
      );
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note published successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to previous screens
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error publishing note: $e'),
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
  
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }
  
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
        return Colors.teal;
    }
  }
  
  String _getTemplateIcon() {
    switch (widget.templateId) {
      case 'balanced':
        return '📚';
      case 'story':
        return '📖';
      case 'factual':
        return '📋';
      case 'interactive':
        return '🎮';
      case 'visual':
        return '🖼️';
      default:
        return '📝';
    }
  }
  
  String _getTemplateDisplayName() {
    switch (widget.templateId) {
      case 'balanced':
        return 'Balanced Note';
      case 'story':
        return 'Story Note';
      case 'factual':
        return 'Factual Note';
      case 'interactive':
        return 'Interactive Note';
      case 'visual':
        return 'Visual Note';
      default:
        return 'Note';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final Color templateColor = _getTemplateColor();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview ${_getTemplateDisplayName()}'),
        backgroundColor: templateColor,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditing ? 'Save changes' : 'Edit note',
          ),
        ],
      ),
      body: Column(
        children: [
          // Note info section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: templateColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: templateColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: _isEditing
                ? _buildEditForm(templateColor)
                : _buildNoteInfo(templateColor),
          ),
          
          // Page indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Page ${_currentPage + 1} of ${_pages.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: templateColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Note content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildPage(_pages[index]);
              },
            ),
          ),
          
          // Page dots indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? templateColor
                        : templateColor.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isPublishing || _isEditing ? null : _publishNote,
                  icon: _isPublishing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.publish),
                  label: Text(_isPublishing ? 'Publishing...' : 'Publish Note'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: templateColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoteInfo(Color templateColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _getTemplateIcon(),
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _note.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.school,
              size: 18,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Subject: ${widget.subject.name}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.book,
              size: 18,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Chapter: ${widget.chapter.name}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.child_care,
              size: 18,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Age Group: ${widget.ageGroup} years',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            const Icon(
              Icons.format_list_numbered,
              size: 18,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Pages: ${_pages.length}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildEditForm(Color templateColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note Title:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Enter note title',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Note content is generated based on subject, chapter, and age group. You can edit the title but not the content in this preview.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPage(List<NoteContentElement> elements) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: elements.map((element) => _buildElement(element)).toList(),
        ),
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
    final fontSize = _templateManager.getFontSizeForAge(widget.ageGroup);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        element.content,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
  
  Widget _buildImageElement(ImageElement element) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // If we have an image URL, show it; otherwise, show a placeholder
          if (element.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: element.imageUrl,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => _buildImagePlaceholder(),
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            _buildImagePlaceholder(),
          
          // Caption
          if (element.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                element.caption,
                style: TextStyle(
                  fontSize: _templateManager.getFontSizeForAge(widget.ageGroup) - 2,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildImagePlaceholder() {
    final Color templateColor = _getTemplateColor();
    
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: templateColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: templateColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 48,
            color: templateColor.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Image will appear here',
            style: TextStyle(
              fontSize: 16,
              color: templateColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAudioElement(AudioElement element) {
    // Initialize audio player if not already done
    if (!_audioPlayers.containsKey(element.id)) {
      final player = AudioPlayer();
      _audioPlayers[element.id] = player;
      
      // Set audio source if URL is available
      if (element.audioUrl.isNotEmpty) {
        player.setUrl(element.audioUrl);
      }
    }
    
    final player = _audioPlayers[element.id]!;
    final Color templateColor = _getTemplateColor();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: templateColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: templateColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Play/pause button
                StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing ?? false;
                    
                    return GestureDetector(
                      onTap: () {
                        if (element.audioUrl.isEmpty) {
                          // Show message that audio will be available after publishing
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Audio will be available after publishing'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        
                        if (playing) {
                          player.pause();
                          setState(() {
                            _currentlyPlayingAudioId = null;
                          });
                        } else {
                          // Stop any currently playing audio
                          if (_currentlyPlayingAudioId != null && 
                              _currentlyPlayingAudioId != element.id) {
                            _audioPlayers[_currentlyPlayingAudioId]?.pause();
                          }
                          
                          player.play();
                          setState(() {
                            _currentlyPlayingAudioId = element.id;
                          });
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: templateColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
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
                        element.title ?? 'Audio',
                        style: TextStyle(
                          fontSize: _templateManager.getFontSizeForAge(widget.ageGroup),
                          fontWeight: FontWeight.bold,
                          color: templateColor.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        element.audioUrl.isEmpty
                            ? 'Audio will be available after publishing'
                            : 'Tap to play/pause',
                        style: TextStyle(
                          fontSize: _templateManager.getFontSizeForAge(widget.ageGroup) - 4,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Audio progress bar (only show if we have a URL)
            if (element.audioUrl.isNotEmpty)
              StreamBuilder<Duration?>(
                stream: player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = player.duration ?? Duration.zero;

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
                        backgroundColor: templateColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(templateColor),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: TextStyle(
                              fontSize: 12,
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
}
