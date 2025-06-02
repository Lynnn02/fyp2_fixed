import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/note_content.dart';
import '../../../models/subject.dart';
import 'note_template_base.dart';

/// Visual note template with emphasis on images and audio narration
class VisualNoteTemplate extends NoteTemplate {
  VisualNoteTemplate({
    required Subject subject,
    required Chapter chapter,
    required int ageGroup,
  }) : super(
    subject: subject,
    chapter: chapter,
    ageGroup: ageGroup,
  );
  
  @override
  String get templateName => 'Visual';
  
  @override
  String get templateDescription => 'Highly visual notes with many images, minimal text, and audio narration';
  
  @override
  String get templateIcon => '🖼️';
  
  @override
  Future<Note> generateNote() async {
    final List<NoteContentElement> elements = [];
    int position = 0;
    
    // Get sample media
    final List<String> audioUrls = getSampleAudioUrls();
    final List<String> imageUrls = getSampleImageUrls();
    
    // Title page
    elements.add(createTextElement(
      content: 'Visual Journey: ${chapter.name}',
      position: position++,
      isBold: true,
      fontSize: 28,
    ));
    
    elements.add(createImageElement(
      imageUrl: imageUrls[0],
      position: position++,
      caption: 'Welcome to our visual exploration of ${chapter.name}',
    ));
    
    elements.add(createAudioElement(
      audioUrl: audioUrls[0],
      position: position++,
      title: 'Introduction to our visual journey',
    ));
    
    // Content pages based on age group
    final int pageCount = getPageCountForAge();
    final int contentPages = pageCount - 2; // Subtract title and summary pages
    
    // Generate visual content with minimal text and audio narration
    for (int i = 0; i < contentPages; i++) {
      // Large image as the main focus
      elements.add(createImageElement(
        imageUrl: imageUrls[(i + 1) % imageUrls.length],
        position: position++,
        caption: _generateImageCaption(i),
      ));
      
      // Minimal text description
      elements.add(createTextElement(
        content: _generateBriefDescription(i),
        position: position++,
        isBold: i % 3 == 0, // Occasional bold for emphasis
      ));
      
      // Audio narration for each visual
      elements.add(createAudioElement(
        audioUrl: audioUrls[(i + 1) % audioUrls.length],
        position: position++,
        title: 'Listen to learn about this image',
      ));
      
      // For older children, occasionally add a second image for comparison
      if (ageGroup >= 5 && i % 3 == 1) {
        elements.add(createImageElement(
          imageUrl: imageUrls[(i + 3) % imageUrls.length],
          position: position++,
          caption: 'Another view of ' + _generateImageCaption(i).toLowerCase(),
        ));
      }
      
      // Add emojis for younger children to enhance visual engagement
      if (ageGroup <= 5) {
        elements.add(createTextElement(
          content: _generateEmojiRow(i),
          position: position++,
          fontSize: 24,
        ));
      }
    }
    
    // Summary page
    elements.add(createTextElement(
      content: 'What We Saw',
      position: position++,
      isBold: true,
    ));
    
    elements.add(createImageElement(
      imageUrl: imageUrls[imageUrls.length - 1],
      position: position++,
      caption: 'Our visual journey of ${chapter.name}',
    ));
    
    elements.add(createTextElement(
      content: _generateVisualSummary(),
      position: position++,
    ));
    
    elements.add(createAudioElement(
      audioUrl: audioUrls[audioUrls.length - 1],
      position: position++,
      title: 'Recap of our visual journey',
    ));
    
    return Note(
      title: 'Visual Journey: ${chapter.name}',
      description: 'A visual exploration of ${chapter.name} with audio narration for age ${ageGroup} children',
      elements: elements,
      isDraft: true,
      createdAt: Timestamp.now(),
    );
  }
  
  // Helper methods to generate visual content
  String _generateImageCaption(int index) {
    final List<String> captions = [
      'The Big Picture of ${chapter.name}',
      'Looking Closely at Details',
      'Colors and Shapes',
      'Patterns We Can See',
      'Different Perspectives',
      'Comparing Sizes',
      'Inside and Outside Views',
      'Parts Working Together',
      'Changes Over Time',
      'Connections to Other Things',
    ];
    
    return captions[index % captions.length];
  }
  
  String _generateBriefDescription(int index) {
    // Very simple descriptions for age 4
    final List<String> simpleDescriptions = [
      'Look at the colors!',
      'Can you see the shapes?',
      'Count how many there are.',
      'This is big and that is small.',
      'These go together.',
      'This is how it looks.',
      'See how it moves.',
      'These are different.',
      'This is special because...',
      'We use this for...',
    ];
    
    // More detailed for age 5
    final List<String> mediumDescriptions = [
      'Notice the different colors and what they show us.',
      'These shapes help us understand how it works.',
      'We can count and compare what we see.',
      'The size shows us what's important.',
      'These parts connect and work together.',
      'This is what it looks like from different sides.',
      'Watch how it changes when we look closer.',
      'These are different types we can find.',
      'This is special because of its unique features.',
      'We use this in many ways in our daily lives.',
    ];
    
    // Most detailed for age 6
    final List<String> detailedDescriptions = [
      'The colors in this image represent different aspects of ${chapter.name}. Each color helps us identify important parts.',
      'By examining these shapes, we can understand the structure and how different elements fit together.',
      'Counting and measuring helps us compare and analyze what we're observing about ${chapter.name}.',
      'The relative sizes show us the importance and relationships between different components.',
      'These interconnected parts form a system that works together to make ${chapter.name} function properly.',
      'Viewing from multiple perspectives gives us a more complete understanding of ${chapter.name}.',
      'Observing changes helps us understand processes and transformations related to ${chapter.name}.',
      'There are several varieties with different characteristics that we can classify and study.',
      'The unique features we can observe make ${chapter.name} specially adapted for its purpose.',
      'Understanding ${chapter.name} helps us appreciate its applications in our world and daily activities.',
    ];
    
    if (ageGroup <= 4) {
      return simpleDescriptions[index % simpleDescriptions.length];
    } else if (ageGroup <= 5) {
      return mediumDescriptions[index % mediumDescriptions.length];
    } else {
      return detailedDescriptions[index % detailedDescriptions.length];
    }
  }
  
  String _generateEmojiRow(int index) {
    final List<String> emojiSets = [
      '🔴 🟠 🟡 🟢 🔵 🟣',
      '🟥 🟧 🟨 🟩 🟦 🟪',
      '🐶 🐱 🐭 🐰 🦊 🐻',
      '🍎 🍌 🍇 🍉 🍓 🥝',
      '☀️ 🌙 ⭐ 🌈 ☁️ 🌧️',
      '🚗 🚌 🚂 ✈️ 🚢 🚁',
      '1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 6️⃣',
      '👍 👏 🙌 👋 👀 💡',
      '🏠 🏫 🏕️ 🏢 🏪 🏭',
      '🔍 📏 📐 ⚖️ 🧮 🔢',
    ];
    
    return emojiSets[index % emojiSets.length];
  }
  
  String _generateVisualSummary() {
    if (ageGroup <= 4) {
      return 'We saw many pictures of ${chapter.name}! We learned how it looks and what it does.';
    } else if (ageGroup <= 5) {
      return 'Our visual journey showed us different parts of ${chapter.name}. We saw colors, shapes, sizes, and how things work together. What was your favorite picture?';
    } else {
      return 'Through our visual exploration, we've observed the key features, structures, and relationships that make up ${chapter.name}. Visual learning helps us understand complex concepts by seeing patterns, making comparisons, and identifying important details. What new observations did you make during our journey?';
    }
  }
}
