import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/note_content.dart';
import '../../../models/subject.dart';
import 'note_template_base.dart';

/// Balanced note template with a mix of text, images, and audio
class BalancedNoteTemplate extends NoteTemplate {
  BalancedNoteTemplate({
    required Subject subject,
    required Chapter chapter,
    required int ageGroup,
  }) : super(
    subject: subject,
    chapter: chapter,
    ageGroup: ageGroup,
  );
  
  @override
  String get templateName => 'Balanced';
  
  @override
  String get templateDescription => 'Well-rounded notes with balanced text, images, and audio elements';
  
  @override
  String get templateIcon => '⚖️';
  
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
      caption: 'Welcome to our lesson on ${chapter.name}',
    ));
    
    elements.add(createTextElement(
      content: _generateIntroduction(),
      position: position++,
    ));
    
    elements.add(createAudioElement(
      audioUrl: audioUrls[0],
      position: position++,
      title: 'Introduction to our lesson',
    ));
    
    // Content pages based on age group
    final int pageCount = getPageCountForAge();
    final int contentPages = pageCount - 2; // Subtract title and summary pages
    
    // Generate balanced content
    for (int i = 0; i < contentPages; i++) {
      // Section title
      elements.add(createTextElement(
        content: _generateSectionTitle(i),
        position: position++,
        isBold: true,
      ));
      
      // Main content with age-appropriate text
      elements.add(createTextElement(
        content: _generateMainContent(i),
        position: position++,
      ));
      
      // Image to illustrate the concept
      elements.add(createImageElement(
        imageUrl: imageUrls[(i + 1) % imageUrls.length],
        position: position++,
        caption: _generateImageCaption(i),
      ));
      
      // Audio narration
      elements.add(createAudioElement(
        audioUrl: audioUrls[(i + 1) % audioUrls.length],
        position: position++,
        title: 'Listen to learn about ' + _generateSectionTitle(i).toLowerCase(),
      ));
      
      // For age 5-6, add interactive elements
      if (ageGroup >= 5) {
        elements.add(createTextElement(
          content: _generateInteractivePrompt(i),
          position: position++,
          isItalic: true,
        ));
      }
      
      // For age 6, occasionally add more detailed explanations
      if (ageGroup >= 6 && i % 2 == 0) {
        elements.add(createTextElement(
          content: _generateDetailedExplanation(i),
          position: position++,
        ));
      }
    }
    
    // Summary page
    elements.add(createTextElement(
      content: 'What We Learned',
      position: position++,
      isBold: true,
    ));
    
    elements.add(createImageElement(
      imageUrl: imageUrls[imageUrls.length - 1],
      position: position++,
      caption: 'Reviewing what we learned about ${chapter.name}',
    ));
    
    elements.add(createTextElement(
      content: _generateSummary(),
      position: position++,
    ));
    
    elements.add(createAudioElement(
      audioUrl: audioUrls[audioUrls.length - 1],
      position: position++,
      title: 'Summary of our lesson',
    ));
    
    return Note(
      title: 'Learning About ${chapter.name}',
      description: 'A balanced educational journey through ${chapter.name} for age ${ageGroup} children',
      elements: elements,
      isDraft: true,
      createdAt: Timestamp.now(),
    );
  }
  
  // Helper methods to generate balanced content
  String _generateIntroduction() {
    if (ageGroup <= 4) {
      return 'Today we will learn about ${chapter.name}. It will be fun!';
    } else if (ageGroup <= 5) {
      return 'Welcome to our lesson about ${chapter.name}. We will discover many interesting things together!';
    } else {
      return 'In this educational journey, we will explore ${chapter.name}, an important topic in ${subject.name}. We'll learn about key concepts, see examples, and discover why this knowledge matters.';
    }
  }
  
  String _generateSectionTitle(int index) {
    final List<String> titles = [
      'What is ${chapter.name}?',
      'Key Features',
      'How It Works',
      'Examples',
      'Why It Matters',
      'Comparing Different Types',
      'Using What We Learn',
      'Fun Activities',
      'Questions to Think About',
      'Connections to Other Topics',
    ];
    
    return titles[index % titles.length];
  }
  
  String _generateMainContent(int index) {
    // Base content adjusted for different ages
    final List<String> contentBase = [
      '${chapter.name} is part of what we learn in ${subject.name}.',
      'When we look at ${chapter.name}, we can see important parts.',
      'This is how ${chapter.name} works in our world.',
      'Here are some examples we can see around us.',
      'Learning about ${chapter.name} helps us understand many things.',
      'There are different kinds of ${chapter.name} to explore.',
      'We can use what we learn in many ways.',
      'Let\'s try some fun activities with ${chapter.name}.',
      'Thinking about questions helps us learn more.',
      '${chapter.name} connects to other things we learn about.',
    ];
    
    // Additional content for age 5
    final List<String> ageAddition5 = [
      ' It has special qualities that make it interesting to study.',
      ' Each part has a job to do.',
      ' It follows patterns that we can observe and understand.',
      ' These examples help us see how it works in real life.',
      ' When we understand this, we can solve problems better.',
      ' Each type has special features that make it unique.',
      ' This knowledge is useful in our daily activities.',
      ' Activities help us practice what we've learned.',
      ' Asking questions is how we become better learners.',
      ' Making connections helps us remember what we learn.',
    ];
    
    // Additional content for age 6
    final List<String> ageAddition6 = [
      ' Scientists and researchers continue to study this topic to learn more about its properties and characteristics.',
      ' The structure and organization of these parts create a system that functions efficiently.',
      ' Understanding the processes involved helps us predict outcomes and explain why things happen the way they do.',
      ' By examining these examples, we can identify patterns and principles that apply more broadly.',
      ' This knowledge forms a foundation for more advanced concepts we will learn later.',
      ' Classification helps us organize our knowledge and recognize similarities and differences.',
      ' Practical applications demonstrate the relevance of what we're learning to our lives and future studies.',
      ' Engaging with the material through activities deepens our understanding and helps us remember key concepts.',
      ' Critical thinking skills develop when we question, analyze, and evaluate what we're learning.',
      ' Interdisciplinary connections show how knowledge in one area relates to and enhances understanding in other subjects.',
    ];
    
    String content = contentBase[index % contentBase.length];
    
    if (ageGroup >= 5) {
      content += ageAddition5[index % ageAddition5.length];
    }
    
    if (ageGroup >= 6) {
      content += ageAddition6[index % ageAddition6.length];
    }
    
    return content;
  }
  
  String _generateImageCaption(int index) {
    final List<String> captions = [
      'Visual representation of ${chapter.name}',
      'Key features we can observe',
      'How it works in action',
      'Real-world example',
      'Why this matters for our learning',
      'Different types compared',
      'Using this knowledge in practice',
      'Activity demonstration',
      'Thinking about important questions',
      'Connections to other topics we learn',
    ];
    
    return captions[index % captions.length];
  }
  
  String _generateInteractivePrompt(int index) {
    final List<String> prompts = [
      'Can you describe what you see in the picture?',
      'What do you think is the most important feature?',
      'How do you think this works?',
      'Have you seen examples like this before?',
      'Why do you think learning about this is important?',
      'What differences do you notice between these types?',
      'How could you use this knowledge in your life?',
      'Would you like to try this activity?',
      'What questions do you have about this topic?',
      'Can you think of other topics that connect to this?',
    ];
    
    return prompts[index % prompts.length];
  }
  
  String _generateDetailedExplanation(int index) {
    final List<String> explanations = [
      'When we examine ${chapter.name} more closely, we discover that it consists of several components that work together. Each component has a specific role that contributes to the overall function.',
      'The features we observe follow specific patterns and principles. These patterns help us predict how similar examples might behave or function.',
      'The process involves a sequence of steps that follow logical rules. Understanding these rules helps us explain why certain outcomes occur.',
      'By analyzing multiple examples, we can identify common characteristics and variations. This comparison enhances our understanding of the concept.',
      'The significance of this knowledge extends beyond immediate applications. It forms a foundation for more advanced concepts we will explore later.',
      'Classification systems help us organize our observations and recognize relationships between different categories. This organization makes complex information easier to understand and remember.',
      'Practical applications demonstrate how theoretical knowledge translates into real-world solutions. These connections make learning more meaningful and relevant.',
      'Engaging in hands-on activities reinforces conceptual understanding through experiential learning. This multi-sensory approach helps create stronger neural connections.',
      'Inquiry-based learning encourages critical thinking and deeper exploration of topics. Questions lead to discoveries that might not be apparent through direct instruction alone.',
      'Interdisciplinary connections reveal how knowledge in different subjects interrelates. These connections help create a more comprehensive understanding of our world.',
    ];
    
    return explanations[index % explanations.length];
  }
  
  String _generateSummary() {
    if (ageGroup <= 4) {
      return 'We learned about ${chapter.name}! We saw what it looks like and why it\'s important. Keep exploring to learn more!';
    } else if (ageGroup <= 5) {
      return 'In our lesson, we discovered what ${chapter.name} is, its important features, how it works, and why it matters. We saw examples and tried activities to help us understand better. What was your favorite part of our learning journey?';
    } else {
      return 'Throughout this educational journey, we've explored the fundamental concepts of ${chapter.name}. We've examined its key features, processes, real-world applications, and connections to other topics. We've engaged with the material through various activities and questions that promote critical thinking. This knowledge provides a foundation for future learning and practical applications in ${subject.name} and beyond. What new insights did you gain from this exploration?';
    }
  }
}
