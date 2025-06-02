import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/note_content.dart';
import '../../../models/subject.dart';
import 'note_template_base.dart';

/// Interactive note template with audio elements for enhanced engagement
class InteractiveNoteTemplate extends NoteTemplate {
  InteractiveNoteTemplate({
    required Subject subject,
    required Chapter chapter,
    required int ageGroup,
  }) : super(
    subject: subject,
    chapter: chapter,
    ageGroup: ageGroup,
  );
  
  @override
  String get templateName => 'Interactive';
  
  @override
  String get templateDescription => 'Engaging notes with questions, activities, and audio narration';
  
  @override
  String get templateIcon => '🎮';
  
  @override
  Future<Note> generateNote() async {
    final List<NoteContentElement> elements = [];
    int position = 0;
    
    // Get sample media
    final List<String> audioUrls = getSampleAudioUrls();
    final List<String> imageUrls = getSampleImageUrls();
    
    // Title page
    elements.add(createTextElement(
      content: 'Interactive Learning: ${chapter.name}',
      position: position++,
      isBold: true,
      fontSize: 28,
    ));
    
    elements.add(createImageElement(
      imageUrl: imageUrls[0],
      position: position++,
      caption: 'Welcome to ${chapter.name}',
    ));
    
    elements.add(createTextElement(
      content: 'Let\'s learn about ${chapter.name} together with fun activities!',
      position: position++,
    ));
    
    elements.add(createAudioElement(
      audioUrl: audioUrls[0],
      position: position++,
      title: 'Welcome Message',
    ));
    
    // Content pages based on age group
    final int pageCount = getPageCountForAge();
    final int contentPages = pageCount - 2; // Subtract title and summary pages
    
    for (int i = 0; i < contentPages; i++) {
      // Add a section title
      elements.add(createTextElement(
        content: 'Activity ${i + 1}: ${_generateActivityTitle(i)}',
        position: position++,
        isBold: true,
      ));
      
      // Add an image
      elements.add(createImageElement(
        imageUrl: imageUrls[i % imageUrls.length],
        position: position++,
        caption: 'Activity ${i + 1}',
      ));
      
      // Add activity instructions
      elements.add(createTextElement(
        content: _generateActivityInstructions(i),
        position: position++,
      ));
      
      // Add audio narration for the activity
      elements.add(createAudioElement(
        audioUrl: audioUrls[i % audioUrls.length],
        position: position++,
        title: 'Listen to the instructions',
      ));
      
      // Add question or interactive element
      elements.add(createTextElement(
        content: _generateQuestion(i),
        position: position++,
        isBold: true,
        isItalic: true,
      ));
    }
    
    // Summary page
    elements.add(createTextElement(
      content: 'Great Job!',
      position: position++,
      isBold: true,
    ));
    
    elements.add(createImageElement(
      imageUrl: imageUrls[imageUrls.length - 1],
      position: position++,
      caption: 'You\'ve completed all activities!',
    ));
    
    elements.add(createTextElement(
      content: 'You\'ve learned about ${chapter.name}. Keep practicing!',
      position: position++,
    ));
    
    elements.add(createAudioElement(
      audioUrl: audioUrls[audioUrls.length - 1],
      position: position++,
      title: 'Congratulations!',
    ));
    
    return Note(
      title: 'Interactive Learning: ${chapter.name}',
      description: 'An interactive learning experience about ${chapter.name} for age ${ageGroup} children',
      elements: elements,
      isDraft: true,
      createdAt: Timestamp.now(),
    );
  }
  
  // Helper methods to generate content
  String _generateActivityTitle(int index) {
    final List<String> titles = [
      'Explore and Learn',
      'Listen and Repeat',
      'Match and Connect',
      'Find and Circle',
      'Count and Compare',
      'Draw and Color',
      'Sort and Organize',
      'Listen and Answer',
      'Sing Along',
      'Act It Out',
    ];
    
    return titles[index % titles.length];
  }
  
  String _generateActivityInstructions(int index) {
    final List<String> instructions = [
      'Look at the picture and identify what you see. Can you name everything?',
      'Listen to the audio and repeat what you hear. Practice saying it clearly.',
      'Connect the items that go together. Draw lines between matching pairs.',
      'Find all the items that belong to the same group. Circle them with your finger.',
      'Count the objects in the picture. How many do you see?',
      'Draw a picture of what you learned. Use bright colors!',
      'Put these items in the correct order. What comes first?',
      'Listen to the question and think about your answer. Share it with someone!',
      'Learn this fun song about ${chapter.name}. Sing along with the audio!',
      'Act out what you learned. Can you show it with movements?',
    ];
    
    String baseInstruction = instructions[index % instructions.length];
    
    // Adjust complexity based on age
    if (ageGroup <= 4) {
      return baseInstruction.split('.')[0] + '.'; // Just the first sentence
    } else if (ageGroup <= 5) {
      return baseInstruction; // Full instruction
    } else {
      return baseInstruction + ' Think about why this is important for learning about ${chapter.name}.'; // Extended instruction
    }
  }
  
  String _generateQuestion(int index) {
    final List<String> questions = [
      'What did you see in the picture?',
      'Can you repeat what you heard?',
      'Which items match together?',
      'What items belong in the same group?',
      'How many objects did you count?',
      'What did you draw? Tell someone about it!',
      'What is the correct order?',
      'What is your answer to the question?',
      'Did you enjoy the song? What was it about?',
      'How did you act out what you learned?',
    ];
    
    return questions[index % questions.length];
  }
}
