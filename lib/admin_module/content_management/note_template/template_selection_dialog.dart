import 'package:flutter/material.dart';
import 'note_template_manager.dart';

class TemplateSelectionDialog extends StatefulWidget {
  final Function(String) onTemplateSelected;
  final int ageGroup;

  const TemplateSelectionDialog({
    Key? key,
    required this.onTemplateSelected,
    required this.ageGroup,
  }) : super(key: key);

  @override
  _TemplateSelectionDialogState createState() => _TemplateSelectionDialogState();
}

class _TemplateSelectionDialogState extends State<TemplateSelectionDialog> {
  String _selectedTemplateId = 'balanced';

  @override
  Widget build(BuildContext context) {
    final templates = NoteTemplateManager.getAvailableTemplates();

    return AlertDialog(
      title: const Text('Select Note Template'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Age ${widget.ageGroup} Content',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildAgeSpecificInfo(widget.ageGroup),
            const SizedBox(height: 16),
            const Text(
              'Choose a template style:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  final isSelected = _selectedTemplateId == template['id'];
                  
                  return Card(
                    elevation: isSelected ? 4 : 1,
                    color: isSelected ? Colors.blue.shade50 : null,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTemplateId = template['id']!;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Text(
                              template['icon']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template['name']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.blue.shade700 : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    template['description']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.blue,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onTemplateSelected(_selectedTemplateId);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Generate Note'),
        ),
      ],
    );
  }

  Widget _buildAgeSpecificInfo(int age) {
    String content;
    switch (age) {
      case 4:
        content = '• 10 pages with simple content\n• Large fonts\n• Basic vocabulary\n• Many images (70%)\n• Audio narration';
        break;
      case 5:
        content = '• 15 pages with moderate content\n• Medium-large fonts\n• Age-appropriate vocabulary\n• Balanced text and images (50/50)\n• Audio narration';
        break;
      case 6:
        content = '• 20 pages with detailed content\n• Medium fonts\n• More advanced vocabulary\n• More text than images (60/40)\n• Audio narration';
        break;
      default:
        content = '• 15 pages with age-appropriate content\n• Suitable fonts\n• Balanced text and images\n• Audio narration';
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(content),
    );
  }
}
