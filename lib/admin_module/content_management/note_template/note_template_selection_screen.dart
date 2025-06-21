import 'package:flutter/material.dart';
import '../../../models/subject.dart'; // Contains both Subject and Chapter classes
import '../../../widgets/custom_app_bar.dart';
import 'note_template_preview_screen.dart';

class NoteTemplateSelectionScreen extends StatefulWidget {
  final Subject subject;
  final Chapter chapter;

  const NoteTemplateSelectionScreen({
    Key? key,
    required this.subject,
    required this.chapter,
  }) : super(key: key);

  @override
  State<NoteTemplateSelectionScreen> createState() => _NoteTemplateSelectionScreenState();
}

class _NoteTemplateSelectionScreenState extends State<NoteTemplateSelectionScreen> {
  final List<Map<String, dynamic>> _templates = [
    {
      'id': 'balanced',
      'name': 'Balanced',
      'description': 'A balanced mix of text, images, and interactive elements',
      'icon': Icons.balance,
      'color': Colors.blue,
    },
    {
      'id': 'story',
      'name': 'Story',
      'description': 'Narrative style with characters and plot development',
      'icon': Icons.book,
      'color': Colors.purple,
    },
    {
      'id': 'factual',
      'name': 'Factual',
      'description': 'Focus on facts and information with clear explanations',
      'icon': Icons.info,
      'color': Colors.green,
    },
    {
      'id': 'interactive',
      'name': 'Interactive',
      'description': 'Engaging style with questions and activities',
      'icon': Icons.touch_app,
      'color': Colors.orange,
    },
    {
      'id': 'visual',
      'name': 'Visual',
      'description': 'Highly visual with many images and minimal text',
      'icon': Icons.image,
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Select Note Template',
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subject: ${widget.subject.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chapter: ${widget.chapter.name}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Choose a template style for your note:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return _buildTemplateCard(template);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    return InkWell(
      onTap: () => _selectTemplate(template['id']),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                template['icon'],
                size: 48,
                color: template['color'],
              ),
              const SizedBox(height: 16),
              Text(
                template['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  template['description'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTemplate(String templateId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteTemplatePreviewScreen(
          subject: widget.subject,
          chapter: widget.chapter,
          templateId: templateId,
        ),
      ),
    );
  }
}
