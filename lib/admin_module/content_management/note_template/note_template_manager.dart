import '../../../models/subject.dart';
import '../../../models/note_content.dart';
import 'note_template_base.dart';
import 'balanced_note_template.dart';
import 'factual_note_template.dart';
import 'interactive_note_template.dart';
import 'story_note_template.dart';
import 'visual_note_template.dart';

/// Manages the creation and retrieval of note templates
class NoteTemplateManager {
  /// Get a list of all available template names
  static List<Map<String, String>> getAvailableTemplates() {
    return [
      {'id': 'balanced', 'name': 'Balanced', 'icon': '⚖️', 'description': 'Well-rounded notes with balanced text, images, and audio elements'},
      {'id': 'story', 'name': 'Story', 'icon': '📚', 'description': 'Narrative-style notes with characters and plot to engage children'},
      {'id': 'factual', 'name': 'Factual', 'icon': '📝', 'description': 'Educational notes with clear facts, explanations, and audio narration'},
      {'id': 'interactive', 'name': 'Interactive', 'icon': '🎮', 'description': 'Engaging notes with questions, activities, and audio narration'},
      {'id': 'visual', 'name': 'Visual', 'icon': '🖼️', 'description': 'Highly visual notes with many images, minimal text, and audio narration'},
    ];
  }
  
  /// Create a template based on the template ID
  static NoteTemplate createTemplate({
    required String templateId,
    required Subject subject,
    required Chapter chapter,
  }) {
    final int ageGroup = subject.moduleId;
    
    switch (templateId) {
      case 'balanced':
        return BalancedNoteTemplate(
          subject: subject,
          chapter: chapter,
          ageGroup: ageGroup,
        );
      case 'story':
        return StoryNoteTemplate(
          subject: subject,
          chapter: chapter,
          ageGroup: ageGroup,
        );
      case 'factual':
        return FactualNoteTemplate(
          subject: subject,
          chapter: chapter,
          ageGroup: ageGroup,
        );
      case 'interactive':
        return InteractiveNoteTemplate(
          subject: subject,
          chapter: chapter,
          ageGroup: ageGroup,
        );
      case 'visual':
        return VisualNoteTemplate(
          subject: subject,
          chapter: chapter,
          ageGroup: ageGroup,
        );
      default:
        // Default to balanced template
        return BalancedNoteTemplate(
          subject: subject,
          chapter: chapter,
          ageGroup: ageGroup,
        );
    }
  }
  
  /// Generate a note based on the template ID
  static Future<Note> generateNote({
    required String templateId,
    required Subject subject,
    required Chapter chapter,
  }) async {
    final template = createTemplate(
      templateId: templateId,
      subject: subject,
      chapter: chapter,
    );
    
    return await template.generateNote();
  }
  
  /// Get template details by ID
  static Map<String, String>? getTemplateDetails(String templateId) {
    final templates = getAvailableTemplates();
    return templates.firstWhere(
      (template) => template['id'] == templateId,
      orElse: () => {'id': 'balanced', 'name': 'Balanced', 'icon': '⚖️', 'description': 'Well-rounded notes with balanced text, images, and audio elements'},
    );
  }
}
