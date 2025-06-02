import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/note_content.dart';
import '../../../models/subject.dart';
import 'note_template_base.dart';

/// Story-based note template with narrative elements and audio narration
class StoryNoteTemplate extends NoteTemplate {
  StoryNoteTemplate({
    required Subject subject,
    required Chapter chapter,
    required int ageGroup,
  }) : super(
    subject: subject,
    chapter: chapter,
    ageGroup: ageGroup,
  );
  
  @override
  String get templateName => 'Story';
  
  @override
  String get templateDescription => 'Narrative-style notes with characters and plot to engage children';
  
  @override
  String get templateIcon => '📚';
  
  @override
  Future<Note> generateNote() async {
    final List<NoteContentElement> elements = [];
    int position = 0;
    
    // Get sample media
    final List<String> audioUrls = getSampleAudioUrls();
    final List<String> imageUrls = getSampleImageUrls();
    
    // Title page
    elements.add(createTextElement(
      content: 'The Story of ${chapter.name}',
      position: position++,
      isBold: true,
      fontSize: 28,
    ));
    
    elements.add(createImageElement(
      imageUrl: imageUrls[0],
      position: position++,
      caption: 'Our story begins...',
    ));
    
    elements.add(createTextElement(
      content: 'Once upon a time in the land of learning...',
      position: position++,
      isItalic: true,
    ));
    
    elements.add(createAudioElement(
      audioUrl: audioUrls[0],
      position: position++,
      title: 'Story Introduction',
    ));
    
    // Generate story based on age group
    final int pageCount = getPageCountForAge();
    final int storyPages = pageCount - 2; // Subtract title and ending pages
    
    // Create characters
    final List<String> characters = _generateCharacters();
    
    // Beginning
    elements.add(createTextElement(
      content: _generateStoryBeginning(characters),
      position: position++,
    ));
    
    elements.add(createImageElement(
      imageUrl: imageUrls[1 % imageUrls.length],
      position: position++,
      caption: 'Meeting our characters',
    ));
    
    elements.add(createAudioElement(
      audioUrl: audioUrls[1 % audioUrls.length],
      position: position++,
      title: 'Listen to the beginning',
    ));
    
    // Middle - problem and journey
    for (int i = 0; i < storyPages - 2; i++) {
      elements.add(createTextElement(
        content: _generateStoryMiddle(characters, i),
        position: position++,
      ));
      
      elements.add(createImageElement(
        imageUrl: imageUrls[(i + 2) % imageUrls.length],
        position: position++,
        caption: _generateImageCaption(i),
      ));
      
      // Add audio narration every other page to keep it engaging but not overwhelming
      if (i % 2 == 0) {
        elements.add(createAudioElement(
          audioUrl: audioUrls[(i + 2) % audioUrls.length],
          position: position++,
          title: 'Listen to the story',
        ));
      }
    }
    
    // Resolution
    elements.add(createTextElement(
      content: _generateStoryResolution(characters),
      position: position++,
    ));
    
    elements.add(createImageElement(
      imageUrl: imageUrls[imageUrls.length - 2],
      position: position++,
      caption: 'Solving the problem',
    ));
    
    elements.add(createAudioElement(
      audioUrl: audioUrls[audioUrls.length - 2],
      position: position++,
      title: 'Listen to the resolution',
    ));
    
    // Ending and moral
    elements.add(createTextElement(
      content: 'The End',
      position: position++,
      isBold: true,
      fontSize: 26,
    ));
    
    elements.add(createImageElement(
      imageUrl: imageUrls[imageUrls.length - 1],
      position: position++,
      caption: 'Happily ever after',
    ));
    
    elements.add(createTextElement(
      content: _generateMoral(),
      position: position++,
      isItalic: true,
    ));
    
    elements.add(createAudioElement(
      audioUrl: audioUrls[audioUrls.length - 1],
      position: position++,
      title: 'Listen to the moral of the story',
    ));
    
    return Note(
      title: 'The Story of ${chapter.name}',
      description: 'A narrative journey through ${chapter.name} for age ${ageGroup} children',
      elements: elements,
      isDraft: true,
      createdAt: Timestamp.now(),
    );
  }
  
  // Helper methods to generate story content
  List<String> _generateCharacters() {
    final List<String> characterOptions = [
      'Leo the Lion',
      'Ellie the Elephant',
      'Zara the Zebra',
      'Milo the Monkey',
      'Ollie the Owl',
      'Tina the Tiger',
      'Finn the Fox',
      'Bella the Bear',
    ];
    
    // Select 2-3 characters based on age
    final int characterCount = ageGroup <= 4 ? 2 : 3;
    final List<String> selectedCharacters = [];
    
    for (int i = 0; i < characterCount; i++) {
      selectedCharacters.add(characterOptions[i]);
    }
    
    return selectedCharacters;
  }
  
  String _generateStoryBeginning(List<String> characters) {
    final String mainCharacter = characters[0];
    final String friendCharacter = characters.length > 1 ? characters[1] : '';
    
    if (ageGroup <= 4) {
      return 'One day, $mainCharacter was learning about ${chapter.name}. ${friendCharacter.isNotEmpty ? '$friendCharacter came to help.' : ''}';
    } else if (ageGroup <= 5) {
      return 'One sunny morning, $mainCharacter was excited to learn about ${chapter.name}. ${friendCharacter.isNotEmpty ? '$friendCharacter joined the adventure to help explore this new topic.' : ''}';
    } else {
      return 'In the colorful land of Knowledge, $mainCharacter was eager to discover the secrets of ${chapter.name}. ${friendCharacter.isNotEmpty ? 'Fortunately, $friendCharacter was an expert and offered to guide the journey.' : ''}';
    }
  }
  
  String _generateStoryMiddle(List<String> characters, int part) {
    final String mainCharacter = characters[0];
    final String friendCharacter = characters.length > 1 ? characters[1] : '';
    final String extraCharacter = characters.length > 2 ? characters[2] : '';
    
    final List<String> middleSegments = [
      'But learning about ${chapter.name} wasn\'t easy. $mainCharacter found it challenging to understand.',
      '${friendCharacter.isNotEmpty ? '$friendCharacter showed $mainCharacter a new way to think about it.' : 'But $mainCharacter didn\'t give up.'}',
      'They practiced together, trying different approaches.',
      '${extraCharacter.isNotEmpty ? 'Then $extraCharacter appeared with a special tool to help them.' : 'They discovered a helpful method to remember the important parts.'}',
      'They created a fun game to practice what they learned.',
      'Sometimes they made mistakes, but that was part of learning.',
    ];
    
    // Adjust complexity based on age
    if (ageGroup <= 4) {
      return middleSegments[part % middleSegments.length].split('.')[0] + '.';
    } else if (ageGroup <= 5) {
      return middleSegments[part % middleSegments.length];
    } else {
      int index = part % middleSegments.length;
      return middleSegments[index] + ' ' + (index < middleSegments.length - 1 ? middleSegments[(index + 1) % middleSegments.length] : '');
    }
  }
  
  String _generateStoryResolution(List<String> characters) {
    final String mainCharacter = characters[0];
    final String friendCharacter = characters.length > 1 ? characters[1] : '';
    
    if (ageGroup <= 4) {
      return 'Finally, $mainCharacter understood ${chapter.name}! ${friendCharacter.isNotEmpty ? 'Thanks to $friendCharacter\'s help.' : 'It was a happy day.'}';
    } else if (ageGroup <= 5) {
      return 'After much practice, $mainCharacter finally mastered ${chapter.name}. ${friendCharacter.isNotEmpty ? '$friendCharacter was proud of how much progress they had made together.' : 'It was a wonderful feeling of accomplishment.'}';
    } else {
      return 'Through perseverance and teamwork, $mainCharacter overcame the challenges and became an expert in ${chapter.name}. ${friendCharacter.isNotEmpty ? '$friendCharacter celebrated their success, knowing that learning together had made the journey more meaningful.' : 'The journey had been difficult at times, but the reward of understanding made it all worthwhile.'}';
    }
  }
  
  String _generateMoral() {
    if (ageGroup <= 4) {
      return 'Learning is fun when we try our best!';
    } else if (ageGroup <= 5) {
      return 'When we keep trying, we can learn new things, even when they seem hard at first.';
    } else {
      return 'This story teaches us that with persistence, friendship, and a positive attitude, we can overcome challenges and master new knowledge.';
    }
  }
  
  String _generateImageCaption(int index) {
    final List<String> captions = [
      'The adventure begins',
      'Facing a challenge',
      'Learning together',
      'Making discoveries',
      'Practicing new skills',
      'Overcoming obstacles',
      'Celebrating progress',
      'Sharing knowledge',
    ];
    
    return captions[index % captions.length];
  }
}
