  // Build the standard action bar for editing mode
  Widget _buildStandardActionBar(int totalPages) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page navigation
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
              IconButton(
                onPressed: _currentPage < totalPages - 1
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
          
          // Generate more content button
          ElevatedButton.icon(
            onPressed: _isGeneratingMoreContent ? null : _generateMoreContent,
            icon: _isGeneratingMoreContent
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.add),
            label: Text(_isGeneratingMoreContent ? 'Generating...' : 'Generate More Content'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _getTemplateColor(),
            ),
          ),
          
          // Save button
          ElevatedButton.icon(
            onPressed: _isSaving ? null : () => _publishNote(),
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : 'Save Note'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getTemplateColor(),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build desktop layout (for large screens)
  Widget _buildDesktopLayout(int pageIndex, List<NoteContentElement> pageElements, int totalPages, bool exceededLimit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content area (70%)
        Expanded(
          flex: 7,
          child: _buildPageContent(pageIndex, pageElements, totalPages, exceededLimit),
        ),
        const SizedBox(width: 16),
        // Side panel with page controls and metadata (30%)
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page info card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Page ${pageIndex + 1} of $totalPages',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getTemplateColor(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Page inclusion checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _selectedPages[pageIndex] ?? true,
                            activeColor: _getTemplateColor(),
                            onChanged: _isReviewMode ? null : (value) {
                              setState(() {
                                _selectedPages[pageIndex] = value ?? true;
                              });
                            },
                          ),
                          const Text('Include this page'),
                        ],
                      ),
                      // Age-appropriate indicator
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getAgeColor(widget.subject.moduleId).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.child_care,
                              size: 16,
                              color: _getAgeColor(widget.subject.moduleId),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Age ${widget.subject.moduleId}+',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getAgeColor(widget.subject.moduleId),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Element statistics
              if (_isReviewMode)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Page Elements',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _buildElementTypeIndicator('Text', pageElements.whereType<TextElement>().length, Colors.blue),
                        const SizedBox(height: 4),
                        _buildElementTypeIndicator('Images', pageElements.whereType<ImageElement>().length, Colors.green),
                        const SizedBox(height: 4),
                        _buildElementTypeIndicator('Audio', pageElements.whereType<AudioElement>().length, Colors.orange),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Build tablet layout (for medium screens)
  Widget _buildTabletLayout(int pageIndex, List<NoteContentElement> pageElements, int totalPages, bool exceededLimit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page header with controls
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getTemplateColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page ${pageIndex + 1} of $totalPages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getTemplateColor(),
                ),
              ),
              // Page inclusion checkbox
              Row(
                children: [
                  const Text('Include page'),
                  Checkbox(
                    value: _selectedPages[pageIndex] ?? true,
                    activeColor: _getTemplateColor(),
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
        // Page content
        Expanded(
          child: _buildPageContent(pageIndex, pageElements, totalPages, exceededLimit),
        ),
      ],
    );
  }
  
  // Build mobile layout (for small screens)
  Widget _buildMobileLayout(int pageIndex, List<NoteContentElement> pageElements, int totalPages, bool exceededLimit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page header
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTemplateColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getTemplateColor().withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Page ${pageIndex + 1} of $totalPages',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getTemplateColor(),
                    ),
                  ),
                  if (!_isReviewMode)
                    Text(
                      'Tap to edit elements',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                ],
              ),
              // Page inclusion checkbox (only in edit mode)
              if (!_isReviewMode)
                Checkbox(
                  value: _selectedPages[pageIndex] ?? true,
                  activeColor: _getTemplateColor(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPages[pageIndex] = value ?? true;
                    });
                  },
                ),
            ],
          ),
        ),
        // Page content
        Expanded(
          child: _buildPageContent(pageIndex, pageElements, totalPages, exceededLimit),
        ),
      ],
    );
  }
  
  // Build the main page content (common across layouts)
  Widget _buildPageContent(int pageIndex, List<NoteContentElement> pageElements, int totalPages, bool exceededLimit) {
    final isExceededPage = exceededLimit && pageIndex >= widget.pageLimit;
    
    return Stack(
      children: [
        // Page content
        ListView(
          children: [
            // Page elements
            ...pageElements.map((element) => _buildElementPreview(element)).toList(),
            
            // Add more content button (only on last page and not in review mode)
            if (pageIndex == totalPages - 1 && !_isReviewMode)
              Container(
                margin: const EdgeInsets.only(top: 24),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingMoreContent ? null : _generateMoreContent,
                    icon: _isGeneratingMoreContent
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: Text(_isGeneratingMoreContent ? 'Generating...' : 'Generate More Content'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _getTemplateColor(),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        // Warning overlay for pages that exceed the limit
        if (isExceededPage)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'This page exceeds the ${widget.pageLimit}-page limit for this age group',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Consider removing some content to make the note more appropriate for children.',
                      style: TextStyle(color: Colors.grey.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  // Helper to build element type indicator for statistics
  Widget _buildElementTypeIndicator(String type, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text('$type: $count'),
      ],
    );
  }
  
  // Build element preview with appropriate controls
  Widget _buildElementPreview(NoteContentElement element) {
    Widget elementWidget;
    
    if (element is TextElement) {
      elementWidget = _buildTextElementPreview(element);
    } else if (element is ImageElement) {
      elementWidget = _buildImageElementPreview(element);
    } else if (element is AudioElement) {
      elementWidget = _buildAudioElementPreview(element);
    } else {
      // Fallback for unknown element types
      elementWidget = const SizedBox.shrink();
    }
    
    // If in review mode, wrap with approval controls
    if (_isReviewMode) {
      return _wrapWithApprovalControls(elementWidget, element);
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: elementWidget,
      );
    }
  }
  
  // Build text element preview
  Widget _buildTextElementPreview(TextElement element) {
    // Create a text controller if it doesn't exist
    if (!_textControllers.containsKey(element.id)) {
      _textControllers[element.id] = TextEditingController(text: element.content);
    }
    
    return TextField(
      controller: _textControllers[element.id],
      decoration: InputDecoration(
        border: _isReviewMode ? InputBorder.none : const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(12),
        filled: true,
        fillColor: _isReviewMode ? Colors.transparent : Colors.grey.shade50,
      ),
      style: TextStyle(
        fontWeight: element.isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: element.isItalic ? FontStyle.italic : FontStyle.normal,
        fontSize: element.fontSize,
        color: element.textColor != null ? _getColorFromString(element.textColor!) : null,
      ),
      maxLines: null,
      onChanged: (value) {
        // Update the element content
        setState(() {
          // Update the text content in a way that works with the TextElement class
          _elements[_elements.indexWhere((e) => e.id == element.id)] = TextElement(
            id: element.id,
            content: value,
            fontSize: element.fontSize,
            isBold: element.isBold,
            isItalic: element.isItalic,
            textColor: element.textColor,
            position: element.position,
            createdAt: element.createdAt,
          );
        });
      },
      readOnly: _isReviewMode, // Make read-only in review mode
    );
  }
  
  // Build image element preview
  Widget _buildImageElementPreview(ImageElement element) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
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
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
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
                        Icon(Icons.image, color: Colors.grey.shade400, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          _isReviewMode ? 'No image provided' : 'Tap to add image',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        
        // Caption
        if (element.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              element.caption,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
  
  // Build audio element preview
  Widget _buildAudioElementPreview(AudioElement element) {
    final bool isPlaying = _isPlaying && _currentAudioElementId == element.id;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and play button
          Row(
            children: [
              IconButton(
                onPressed: element.audioUrl.isNotEmpty ? () => _toggleAudioPlayback(element) : null,
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: element.audioUrl.isNotEmpty ? _getTemplateColor() : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  element.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          // Progress bar (only for the currently playing audio)
          if (isPlaying)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _duration.inMilliseconds > 0
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0,
                    backgroundColor: Colors.grey.shade300,
                    color: _getTemplateColor(),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  // Wrap element with approval controls for review mode
  Widget _wrapWithApprovalControls(Widget elementWidget, NoteContentElement element) {
    final bool isApproved = _approvedElements[element.id] ?? false;
    final bool isRejected = _approvedElements.containsKey(element.id) && !_approvedElements[element.id]!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isApproved
              ? Colors.green
              : isRejected
                  ? Colors.red
                  : Colors.orange,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Element content
          Padding(
            padding: const EdgeInsets.all(12),
            child: elementWidget,
          ),
          
          // Approval controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isApproved
                  ? Colors.green.withOpacity(0.1)
                  : isRejected
                      ? Colors.red.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status indicator
                Row(
                  children: [
                    Icon(
                      isApproved
                          ? Icons.check_circle
                          : isRejected
                              ? Icons.cancel
                              : Icons.pending,
                      color: isApproved
                          ? Colors.green
                          : isRejected
                              ? Colors.red
                              : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isApproved
                          ? 'Approved'
                          : isRejected
                              ? 'Rejected'
                              : 'Pending Review',
                      style: TextStyle(
                        fontSize: 14,
                        color: isApproved
                            ? Colors.green
                            : isRejected
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                  ],
                ),
                
                // Action buttons
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _approvedElements[element.id] = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _approvedElements[element.id] = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to get color from a string
  Color _getColorFromString(String colorString) {
    if (colorString.startsWith('#')) {
      return Color(int.parse('0xFF${colorString.substring(1)}'));
    } else if (colorString.startsWith('0x')) {
      return Color(int.parse(colorString));
    } else {
      // Default color if parsing fails
      return Colors.black;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Group elements into pages
    final List<List<NoteContentElement>> pages = _groupElementsIntoPages();
    final int totalPages = pages.length;
    
    // Check if we've exceeded the page limit
    final bool exceededLimit = totalPages > widget.pageLimit;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.templateId.capitalize()} Note Template'),
        backgroundColor: _getTemplateColor(),
        foregroundColor: Colors.white,
        actions: [
          // Show review mode toggle if content is fully generated
          if (_isFullyGenerated)
            Switch(
              value: _isReviewMode,
              onChanged: (value) {
                setState(() {
                  _isReviewMode = value;
                });
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withOpacity(0.5),
              inactiveThumbColor: Colors.grey.shade300,
              inactiveTrackColor: Colors.grey.shade400,
            ),
          const SizedBox(width: 8),
          if (_isFullyGenerated)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text('Review Mode'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Title input
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Note Title',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              readOnly: _isReviewMode, // Make read-only in review mode
            ),
          ),
          
          // Content pages
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, pageIndex) {
                // Get elements for this page
                final pageElements = pages[pageIndex] ?? [];
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive layout - use different layouts for different screen sizes
                      if (constraints.maxWidth > 900) { // Desktop layout
                        return _buildDesktopLayout(pageIndex, pageElements, totalPages, exceededLimit);
                      } else if (constraints.maxWidth > 600) { // Tablet layout
                        return _buildTabletLayout(pageIndex, pageElements, totalPages, exceededLimit);
                      } else { // Mobile layout
                        return _buildMobileLayout(pageIndex, pageElements, totalPages, exceededLimit);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          
          // Warning if page limit exceeded
          if (exceededLimit)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.amber.shade100,
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Warning: You have exceeded the recommended page limit of ${widget.pageLimit}. Some content may be truncated.',
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          
          // Bottom action bar - show review controls in review mode, otherwise show standard controls
          _isReviewMode ? _buildBottomActionBar() : _buildStandardActionBar(totalPages),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    // Dispose controllers
    _titleController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

// Helper extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
