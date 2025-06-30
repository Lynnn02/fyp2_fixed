import 'package:flutter/material.dart';
import '../../../models/subject.dart'; // Contains both Subject and Chapter classes
import '../../../widgets/custom_app_bar.dart';
import 'enhanced_note_preview_screen.dart';
import '../../../services/gemini_notes_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';

class NoteTemplateSelectionScreen extends StatefulWidget {
  final Subject subject;
  final Chapter chapter;
  final int age; // Age group: 4, 5, or 6
  final String? language; // Optional language parameter

  const NoteTemplateSelectionScreen({
    Key? key,
    required this.subject,
    required this.chapter,
    required this.age,
    this.language,
  }) : super(key: key);

  @override
  State<NoteTemplateSelectionScreen> createState() => _NoteTemplateSelectionScreenState();
}

class _NoteTemplateSelectionScreenState extends State<NoteTemplateSelectionScreen> {
  final GeminiNotesService _geminiService = GeminiNotesService();
  bool _isLoading = false;
  String _detectedLanguage = 'en';
  late int _selectedAge;
  
  @override
  void initState() {
    super.initState();
    _selectedAge = widget.age;
    _detectLanguage();
  }
  
  /// Detect language based on subject name or use provided language
  Future<void> _detectLanguage() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // First check if we have a cached language detection
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'language_${widget.subject.id}';
      final cachedLanguage = prefs.getString(cacheKey);
      
      if (cachedLanguage != null) {
        setState(() {
          _detectedLanguage = cachedLanguage;
          _isLoading = false;
        });
        return;
      }
      
      // If no cached data, detect language from subject name
      final detectedLanguage = widget.language ?? _detectLanguageFromName(widget.subject.name);
      
      // Cache the detected language
      await prefs.setString(cacheKey, detectedLanguage);
      
      setState(() {
        _detectedLanguage = detectedLanguage;
        _isLoading = false;
      });
      
    } catch (e) {
      // Default to English if detection fails
      setState(() {
        _detectedLanguage = widget.language ?? 'en';
        _isLoading = false;
      });
    }
  }
  
  /// Detect language based on subject name
  String _detectLanguageFromName(String subjectName) {
    final lowerSubject = subjectName.toLowerCase();
    
    // Detect language based on common words or patterns in subject name
    if (lowerSubject.contains('عربي') || lowerSubject.contains('arabic')) {
      return 'ar';
    } else if (lowerSubject.contains('جاوي') || lowerSubject.contains('jawi')) {
      return 'ms-Arab';
    } else if (lowerSubject.contains('bahasa') || lowerSubject.contains('melayu')) {
      return 'ms';
    } else if (lowerSubject.contains('中文') || lowerSubject.contains('chinese')) {
      return 'zh';
    } else if (lowerSubject.contains('தமிழ்') || lowerSubject.contains('tamil')) {
      return 'ta';
    } else if (lowerSubject.contains('हिंदी') || lowerSubject.contains('hindi')) {
      return 'hi';
    }
    
    // Default to English
    return 'en';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Flashcard Note Settings',
        showBackButton: true,
      ),
      body: _isLoading ? _buildLoadingState() : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderInfo(),
          _buildAgeSelector(),
          const SizedBox(height: 24),
          _buildLanguageDisplay(),
          const SizedBox(height: 32),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Analyzing content for ${widget.subject.name}: ${widget.chapter.name}...',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Finding the best template for age ${widget.age} learners',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subject.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.chapter.name,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            'Flashcard notes will be generated with age-appropriate content:',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAgeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Age Group:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAgeButton(4),
              _buildAgeButton(5),
              _buildAgeButton(6),
            ],
          ),
          const SizedBox(height: 12),
          _buildAgeDescription(),
        ],
      ),
    );
  }
  
  Widget _buildAgeButton(int age) {
    final bool isSelected = _selectedAge == age;
    final color = _getAgeColor(age);
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedAge = age;
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$age',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
            Text(
              'years',
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAgeDescription() {
    String description;
    switch (_selectedAge) {
      case 4:
        description = '• Simple bullet points\n• Optional audio for each point\n• Large font size';
        break;
      case 5:
        description = '• Short paragraphs\n• Highlighted key terms\n• 🔊 Audio play buttons';
        break;
      case 6:
        description = '• Detailed paragraphs\n• Embedded mini-quizzes\n• More complex content';
        break;
      default:
        description = 'Age-appropriate content will be generated';
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getAgeColor(_selectedAge).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getAgeColor(_selectedAge).withOpacity(0.3)),
      ),
      child: Text(
        description,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
  
  Widget _buildLanguageDisplay() {
    final languageName = _getLanguageDisplay(_detectedLanguage);
    final bool isRtl = ['ar', 'ms-Arab'].contains(_detectedLanguage.split('-').first);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Language:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  isRtl ? Icons.format_textdirection_r_to_l : Icons.format_textdirection_l_to_r,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                Text(
                  languageName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  isRtl ? '(Right to Left)' : '(Left to Right)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Detected from subject name. Content will be generated in $languageName.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGenerateButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _generateFlashcardNote,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Generate Flashcard Note',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Color _getAgeColor(int age) {
    switch (age) {
      case 4:
        return Colors.green;
      case 5:
        return Colors.blue;
      case 6:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getLanguageDisplay(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'Arabic';
      case 'ms-Arab':
        return 'Jawi';
      case 'ms':
        return 'Malay';
      case 'zh':
        return 'Chinese';
      case 'ta':
        return 'Tamil';
      case 'hi':
        return 'Hindi';
      default:
        return 'English';
    }
  }

  Future<void> _generateFlashcardNote() async {
    // Navigate to the enhanced note preview screen with all required parameters
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedNotePreviewScreen(
          subject: widget.subject,
          chapter: widget.chapter,
          age: _selectedAge,
          language: _detectedLanguage,
        ),
      ),
    );
    
    // If we got a true result (note was published), pass it back to the content management screen
    if (result == true) {
      // Pop back to content management screen with the result
      Navigator.pop(context, true);
    }
  }
}
