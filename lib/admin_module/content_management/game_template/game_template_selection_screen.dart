import 'package:flutter/material.dart';
import 'package:fyp2/admin_module/content_management/game_template/game_template_preview_screen.dart';
import '../../../services/game_template_manager.dart';
import '../../../models/subject.dart';
import '../../../models/language_option.dart';
import 'data_driven_game_template.dart';

class GameTemplateSelectionScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final String chapterName;
  final int ageGroup;
  
  const GameTemplateSelectionScreen({
    Key? key,
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.chapterName,
    required this.ageGroup,
  }) : super(key: key);

  @override
  _GameTemplateSelectionScreenState createState() => _GameTemplateSelectionScreenState();
}

class _GameTemplateSelectionScreenState extends State<GameTemplateSelectionScreen> with SingleTickerProviderStateMixin {
  final GameTemplateManager _templateManager = GameTemplateManager();
  late List<GameTemplateInfo> _availableTemplates;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _selectedTemplateIndex = -1;
  bool _isGenerating = false;
  
  @override
  void initState() {
    super.initState();
    _availableTemplates = _templateManager.getAvailableTemplates(widget.ageGroup);
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _selectTemplate(int index) {
    setState(() {
      _selectedTemplateIndex = index;
    });
    
    _animationController.reset();
    _animationController.forward();
  }
  
  void _previewTemplate() async {
    if (_selectedTemplateIndex < 0) return;
    
    final selectedTemplate = _availableTemplates[_selectedTemplateIndex];
    
    setState(() {
      _isGenerating = true;
    });
    
    try {
      // Generate content for the selected template
      final gameContent = await _templateManager.generateGameContent(
        templateType: selectedTemplate.id,
        subjectName: widget.subjectName,
        chapterName: widget.chapterName,
        ageGroup: widget.ageGroup,
      );
      
      if (!mounted) return;
      
      // Navigate to preview screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameTemplatePreviewScreen(
            templateInfo: selectedTemplate,
            gameContent: gameContent,
            subjectId: widget.subjectId,
            subjectName: widget.subjectName,
            chapterId: widget.chapterId,
            chapterName: widget.chapterName,
            ageGroup: widget.ageGroup,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating game content: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Game Template'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade300, Colors.indigo.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with chapter info
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white.withOpacity(0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creating Game for:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subjectName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chapter: ${widget.chapterName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Age Group: ${widget.ageGroup} years',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Instructions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select a game template to create an age-appropriate game for your students:',
                  style: TextStyle(
                    fontSize: widget.ageGroup == 4 ? 18 : 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Template grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _availableTemplates.length,
                  itemBuilder: (context, index) {
                    final template = _availableTemplates[index];
                    final isSelected = _selectedTemplateIndex == index;
                    
                    return GestureDetector(
                      onTap: () => _selectTemplate(index),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isSelected ? _scaleAnimation.value : 1.0,
                            child: child,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected 
                                    ? template.color.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: isSelected ? 10 : 5,
                                spreadRadius: isSelected ? 2 : 0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected ? template.color : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Template icon
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: template.color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  template.icon,
                                  size: 48,
                                  color: template.color,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Template name
                              Text(
                                template.name,
                                style: TextStyle(
                                  fontSize: widget.ageGroup == 4 ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              
                              // Template description
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  template.description,
                                  style: TextStyle(
                                    fontSize: widget.ageGroup == 4 ? 14 : 12,
                                    color: Colors.grey.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
                      onPressed: _selectedTemplateIndex >= 0 && !_isGenerating
                          ? _previewTemplate
                          : null,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.visibility),
                      label: Text(_isGenerating ? 'Generating...' : 'Preview Game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
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
        ),
      ),
    );
  }
}
