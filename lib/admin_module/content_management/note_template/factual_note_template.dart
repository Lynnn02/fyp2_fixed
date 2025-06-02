import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/note_content.dart';
import '../../../models/subject.dart';
import 'note_template_base.dart';

/// Factual note template with educational content and audio explanations
class FactualNoteTemplate extends NoteTemplate {
  FactualNoteTemplate({
    required Subject subject,
    required Chapter chapter,
    required int ageGroup,
  }) : super(
    subject: subject,
    chapter: chapter,
    ageGroup: ageGroup,
  );
  
  @override
  String get templateName => 'Factual';
  
  @override
  String get templateDescription => 'Educational notes with clear facts, explanations, and audio narration';
  
  @override
  String get templateIcon => '📝';
  
  @override
  Future<Note> generateNote() async {
    final List<NoteContentElement> elements = [];
    int position = 0;
    
    // Get sample media
    final List<String> audioUrls = getSampleAudioUrls();
    final List<String> imageUrls = getSampleImageUrls();
    
    // Title page
    elements.add(createTextElement(
      content: 'Learning About ${chapter.name}',
      position: position++,
      isBold: true,
      fontSize: 28,
    ));
    
    elements.add(createImageElement(
      imageUrl: imageUrls[0],
      position: position++,
      caption: 'Exploring ${chapter.name}',
    ));
    
    elements.add(createTextElement(
      content: 'Let\'s discover interesting facts about ${chapter.name}!',
      position: position++,
    ));
    
    elements.add(createAudioElement(
      audioUrl: audioUrls[0],
      position: position++,
      title: 'Introduction to ${chapter.name}',
    ));
    
    // Content pages based on age group
    final int pageCount = getPageCountForAge();
    final int contentPages = pageCount - 2; // Subtract title and summary pages
    
    // Generate fact sections
    final List<String> factTitles = _generateFactTitles();
    
    for (int i = 0; i < contentPages; i++) {
      final int factIndex = i % factTitles.length;
      
      // Add a section title
      elements.add(createTextElement(
        content: factTitles[factIndex],
        position: position++,
        isBold: true,
      ));
      
      // Add an image
      elements.add(createImageElement(
        imageUrl: imageUrls[(i + 1) % imageUrls.length],
        position: position++,
        caption: 'Visual representation of ${factTitles[factIndex].toLowerCase()}',
      ));
      
      // Add fact content
      elements.add(createTextElement(
        content: _generateFactContent(factIndex),
        position: position++,
      ));
      
      // Add audio explanation for the fact
      elements.add(createAudioElement(
        audioUrl: audioUrls[(i + 1) % audioUrls.length],
        position: position++,
        title: 'Listen to learn about ${factTitles[factIndex].toLowerCase()}',
      ));
      
      // Add "Did you know?" section for older children
      if (ageGroup >= 5 && i % 2 == 1) {
        elements.add(createTextElement(
          content: 'Did you know? ${_generateInterestingFact(factIndex)}',
          position: position++,
          isItalic: true,
        ));
      }
    }
    
    // Summary page
    elements.add(createTextElement(
      content: 'What We Learned About ${chapter.name}',
      position: position++,
      isBold: true,
    ));
    
    elements.add(createImageElement(
      imageUrl: imageUrls[imageUrls.length - 1],
      position: position++,
      caption: 'Summary of our learning',
    ));
    
    elements.add(createTextElement(
      content: _generateSummary(),
      position: position++,
    ));
    
    elements.add(createAudioElement(
      audioUrl: audioUrls[audioUrls.length - 1],
      position: position++,
      title: 'Listen to the summary',
    ));
    
    return Note(
      title: 'Learning About ${chapter.name}',
      description: 'Educational facts about ${chapter.name} for age ${ageGroup} children',
      elements: elements,
      isDraft: true,
      createdAt: Timestamp.now(),
    );
  }
  
  // Helper methods to generate factual content
  List<String> _generateFactTitles() {
    return [
      'What is ${chapter.name}?',
      'Important Features',
      'How it Works',
      'Why it Matters',
      'Examples in Real Life',
      'Fun Facts',
      'History of ${chapter.name}',
      'Types of ${chapter.name}',
      'Comparing Different ${chapter.name}',
      'Using ${chapter.name} Every Day',
    ];
  }
  
  String _generateFactContent(int factIndex) {
    // Base content for different fact types
    final List<String> factContents = [
      '${chapter.name} is an important concept in ${subject.name}. It helps us understand how things work.',
      'When we look at ${chapter.name}, we can see several important features that make it special.',
      '${chapter.name} works by following specific steps or rules. This helps everything stay organized.',
      'Learning about ${chapter.name} is important because it helps us understand the world around us.',
      'We can find examples of ${chapter.name} in many places in our daily lives.',
      'There are many interesting things to discover about ${chapter.name}.',
      'People have been learning about ${chapter.name} for a long time.',
      'There are different types of ${chapter.name} that we can explore and learn about.',
      'We can compare different aspects of ${chapter.name} to understand it better.',
      'We use ${chapter.name} in our everyday activities, sometimes without even realizing it!',
    ];
    
    String baseContent = factContents[factIndex % factContents.length];
    
    // Adjust complexity based on age
    if (ageGroup <= 4) {
      return baseContent;
    } else if (ageGroup <= 5) {
      return baseContent + ' ' + _generateAdditionalDetail(factIndex);
    } else {
      return baseContent + ' ' + _generateAdditionalDetail(factIndex) + ' ' + _generateAdvancedConcept(factIndex);
    }
  }
  
  String _generateAdditionalDetail(int factIndex) {
    final List<String> details = [
      'It has special characteristics that make it unique.',
      'We can observe it and learn from what we see.',
      'This helps us solve problems and find answers.',
      'When we understand this concept, we can apply it to new situations.',
      'This knowledge helps us make better decisions.',
      'Scientists and researchers continue to study this topic.',
      'There are patterns we can recognize and remember.',
      'This connects to other things we learn about in school.',
      'We can create diagrams or models to represent this concept.',
      'This is part of a bigger system that works together.',
    ];
    
    return details[factIndex % details.length];
  }
  
  String _generateAdvancedConcept(int factIndex) {
    final List<String> advancedConcepts = [
      'The concept can be broken down into smaller parts for easier understanding.',
      'There are cause and effect relationships that explain how it functions.',
      'We can classify and categorize different aspects to organize our knowledge.',
      'Patterns and sequences help us predict what might happen next.',
      'We can measure and compare different examples to see similarities and differences.',
      'This concept has evolved over time as we learn more about it.',
      'Different cultures might have different perspectives on this topic.',
      'We can use tools and technology to explore this concept further.',
      'There are still questions that scientists are trying to answer about this topic.',
      'Learning this helps develop critical thinking and problem-solving skills.',
    ];
    
    return advancedConcepts[factIndex % advancedConcepts.length];
  }
  
  String _generateInterestingFact(int factIndex) {
    final List<String> interestingFacts = [
      'The word "${chapter.name}" comes from an old word that means "to learn".',
      'Some animals also use forms of ${chapter.name.toLowerCase()} in their daily lives!',
      'The biggest example of ${chapter.name.toLowerCase()} ever recorded was twice the normal size!',
      'People in different countries might learn about ${chapter.name.toLowerCase()} in different ways.',
      'There are over 100 different types of ${chapter.name.toLowerCase()} that scientists have discovered.',
      'The first person to study ${chapter.name.toLowerCase()} lived over 200 years ago.',
      'If you lined up all the ${chapter.name.toLowerCase()} in the world, they would reach the moon and back!',
      'Some people have jobs where they work with ${chapter.name.toLowerCase()} every day.',
      'The smallest ${chapter.name.toLowerCase()} is too tiny to see without a microscope.',
      'In the future, we might discover even more amazing things about ${chapter.name.toLowerCase()}!',
    ];
    
    return interestingFacts[factIndex % interestingFacts.length];
  }
  
  String _generateSummary() {
    if (ageGroup <= 4) {
      return 'We learned about ${chapter.name}! It is important and interesting. Remember what we discovered together.';
    } else if (ageGroup <= 5) {
      return 'We have explored ${chapter.name} and learned many interesting facts. We discovered what it is, why it matters, and how we can find it in our world. Keep exploring to learn more!';
    } else {
      return 'In this educational journey, we've explored the key aspects of ${chapter.name}. We've learned about its features, importance, real-world applications, and interesting facts. Understanding ${chapter.name} helps us make connections to other concepts in ${subject.name} and builds a foundation for future learning. What other questions do you have about this topic?';
    }
  }
}
