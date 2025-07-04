import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../models/note_content_element.dart';
import '../../../models/flashcard_element.dart';

/// FlashcardTemplateGenerator is responsible for generating flashcard content
/// based on subject, chapter, age, and language.
/// 
/// It supports the following subjects and chapters:
/// - Bahasa Malaysia: Huruf & Kata Asas, Perkataan Mudah
/// - English: Alphabet & Phonics, Sight Words
/// - Math: Counting 1-10, Shapes & Patterns
/// - Science: Five Senses, Living vs Non-living Things
/// - Social & Emotional Learning: Emotions & Expressions, Sharing & Cooperation
/// - Art & Craft: Color Exploration & Mixing, Simple Lines & Patterns
/// - Physical Development: Gross Motor Skills, Fine Motor Skills
/// - Jawi: Pengenalan Huruf Jawi, Penulisan Jawi Mudah
/// - Iqraa (Arabic): Huruf Hijaiyah, Bacaan Iqraa Asas
class FlashcardTemplateGenerator {
  /// Convert a list of flashcard maps to a JSON string
  static String toJson(List<Map<String, dynamic>> flashcards) {
    return jsonEncode(flashcards);
  }
  
  /// Generate flashcard elements for the given subject, chapter, age, and language
  static List<FlashcardElement> generateFlashcardElements({
    required String subject,
    required String chapter,
    required int age,
    required String language,
  }) {
    // Get the raw flashcard data
    final flashcardData = generateFlashcards(
      subject: subject,
      chapter: chapter,
      age: age,
      language: language,
      count: _getCardCountForAge(age),
    );
    
    final List<FlashcardElement> flashcardElements = [];
    
    for (var data in flashcardData) {
      // Create descriptions map with age-appropriate descriptions
      final Map<int, String> descriptions = {};
      
      // Get the base description from the data
      final baseDescription = data['description'] as String;
      
      // Create age-appropriate descriptions for ages 4, 5, and 6
      descriptions[4] = _createSimplifiedDescription(baseDescription, data['title'] as String);
      descriptions[5] = baseDescription; // Use the original description for age 5
      descriptions[6] = _createEnhancedDescription(baseDescription, data['title'] as String);
      
      // Debug print the descriptions
      print('Flashcard ${data['title']} descriptions: $descriptions');
      
      // Create FlashcardElement
      flashcardElements.add(FlashcardElement(
        id: const Uuid().v4(),
        position: flashcardElements.length,
        createdAt: Timestamp.now(),
        title: data['title'] as String,
        letter: data['letter'] as String? ?? _generateLetterFromTitle(data['title'] as String),
        imageAsset: data['image_asset'] as String? ?? _getImageAssetPath(subject, data['title'] as String),
        descriptions: descriptions,
        metadata: {
          'subject': subject,
          'chapter': chapter,
          'language': language,
        },
      ));
    }
    
    return flashcardElements;
  }
  
  // Helper method to generate a letter from the title
  static String _generateLetterFromTitle(String title) {
    if (title.isEmpty) return '';
    final firstLetter = title.substring(0, 1).toUpperCase();
    final secondLetter = title.substring(0, 1).toLowerCase();
    return '$firstLetter$secondLetter';
  }
  
  /// Create a simplified description for younger children (age 4)
  static String _createSimplifiedDescription(String baseDescription, String title) {
    // For age 4, create a very simple description - just the title
    switch (title.toLowerCase()) {
      case 'ayam':
        return 'Ayam';
      case 'bola':
        return 'Bola';
      case 'cacing':
        return 'Cacing';
      case 'durian':
        return 'Durian';
      case 'epal':
        return 'Epal';
      case 'foto':
        return 'Foto';
      case 'gajah':
        return 'Gajah';
      case 'harimau':
        return 'Harimau';
      case 'ikan':
        return 'Ikan';
      case 'jeruk':
        return 'Jeruk';
      case 'kucing':
        return 'Kucing';
      case 'lampu':
        return 'Lampu';
      case 'meja':
        return 'Meja';
      case 'nanas':
        return 'Nanas';
      case 'orang':
        return 'Orang';
      case 'pokok':
        return 'Pokok';
      default:
        return title;
    }
  }
  
  /// Create an enhanced description for older children (age 6)
  static String _createEnhancedDescription(String baseDescription, String title) {
    // For age 6, provide more detailed descriptions
    switch (title.toLowerCase()) {
      case 'ayam':
        return 'Ini ayam, ayam bunyi berkokok.';
      case 'bola':
        return 'Ini bola, bola boleh ditendang.';
      case 'cacing':
        return 'Ini cacing, cacing hidup dalam tanah.';
      case 'durian':
        return 'Ini durian, durian raja buah-buahan.';
      case 'epal':
        return 'Ini epal, epal buah yang sihat.';
      case 'foto':
        return 'Ini foto, foto merakam kenangan.';
      case 'gajah':
        return 'Ini gajah, gajah haiwan yang besar.';
      case 'harimau':
        return 'Ini harimau, harimau raja hutan.';
      case 'ikan':
        return 'Ini ikan, ikan hidup dalam air.';
      case 'jeruk':
        return 'Ini jeruk, jeruk buah yang masam.';
      case 'kucing':
        return 'Ini kucing, kucing bunyi meow.';
      case 'lampu':
        return 'Ini lampu, lampu memberi cahaya.';
      case 'meja':
        return 'Ini meja, meja untuk meletak barang.';
      case 'nanas':
        return 'Ini nanas, nanas buah yang manis.';
      case 'orang':
        return 'Ini orang, orang hidup bersama.';
      case 'pokok':
        return 'Ini pokok, pokok memberi oksigen.';
      default:
        return 'Ini $title, $title penting untuk dipelajari.';
    }
  }
  
  // Helper method to get the correct image asset path based on subject
  static String _getImageAssetPath(String subject, String title) {
    // Convert subject to lowercase for comparison
    final lowerSubject = subject.toLowerCase();
    final lowerTitle = title.toLowerCase();
    
    // Map subject names to their asset folder names
    String folderName;
    if (lowerSubject.contains('malay') || lowerSubject == 'bahasa malaysia') {
      folderName = 'malay';
    } else if (lowerSubject == 'mathematics' || lowerSubject == 'math') {
      folderName = 'math';
    } else if (lowerSubject == 'science') {
      folderName = 'science';
    } else if (lowerSubject == 'english') {
      folderName = 'english';
    } else {
      // Default to the lowercase subject name if no special mapping
      folderName = lowerSubject;
    }
    
    // Use the actual image path
    final imagePath = 'assets/flashcards/$folderName/$lowerTitle.png';
    
    // Print the path for debugging
    print('Generated image path: $imagePath');
    
    return imagePath;
  }
  
  /// Get the number of cards to generate based on age
  static int _getCardCountForAge(int age) {
    // For all cases, use age-based counts
    switch (age) {
      case 4:
        return 6; // 6 cards for age 4
      case 5:
        return 8; // 8 cards for age 5
      case 6:
        return 10; // 10 cards for age 6
      default:
        return 8; // Default to 8 cards
    }
  }
  
  /// Generate random pastel color
  static Color _generateRandomColor() {
    final List<Color> colors = [
      const Color(0xFFFFD3B6), // Pastel Orange
      const Color(0xFFFFAAA5), // Pastel Red
      const Color(0xFFFFDBA5), // Pastel Yellow
      const Color(0xFFA5FFD6), // Pastel Green
      const Color(0xFFA5C8FF), // Pastel Blue
      const Color(0xFFD5A5FF), // Pastel Purple
      const Color(0xFFFFA5E0), // Pastel Pink
      const Color(0xFFE5EDB7), // Pastel Lime
    ];
    
    // Use timestamp microseconds to get a "random" index
    final index = DateTime.now().microsecondsSinceEpoch % colors.length;
    return colors[index];
  }
  
  /// Generate flashcards based on subject, chapter, age, and language
  static List<Map<String, dynamic>> generateFlashcards({
    required String subject,
    required String chapter,
    required int age,
    required String language,
    required int count,
  }) {
    // Normalize subject and chapter for comparison
    final normalizedSubject = subject.toLowerCase().trim();
    final normalizedChapter = chapter.toLowerCase().trim();
    
    // Generate flashcards based on subject and chapter
    
    // Bahasa Malaysia
    if (normalizedSubject.contains('bahasa') || normalizedSubject.contains('malay')) {
      if (normalizedChapter.contains('huruf') || normalizedChapter.contains('kata asas') || 
          normalizedChapter.contains('alphabet') || normalizedChapter.contains('letters')) {
        return _generateMalayLettersFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('perkataan') || normalizedChapter.contains('mudah') || 
                normalizedChapter.contains('simple words')) {
        return _generateMalaySimpleWordsFlashcards(subject, age, language, count);
      }
    }
    
    // English
    else if (normalizedSubject.contains('english') || normalizedSubject.contains('inggeris')) {
      if (normalizedChapter.contains('alphabet') || normalizedChapter.contains('phonics') || 
          normalizedChapter.contains('letters')) {
        return _generateEnglishAlphabetFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('sight') || normalizedChapter.contains('words')) {
        return _generateEnglishSightWordsFlashcards(subject, age, language, count);
      }
    }
    
    // Math
    else if (normalizedSubject.contains('math') || normalizedSubject.contains('matematik')) {
      if (normalizedChapter.contains('counting') || normalizedChapter.contains('numbers') || 
          normalizedChapter.contains('nombor')) {
        return _generateCountingFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('shapes') || normalizedChapter.contains('patterns') || 
                normalizedChapter.contains('bentuk')) {
        return _generateShapesAndPatternsFlashcards(subject, age, language, count);
      }
    }
    
    // Science
    else if (normalizedSubject.contains('science') || normalizedSubject.contains('sains')) {
      if (normalizedChapter.contains('five senses') || normalizedChapter.contains('deria')) {
        return _generateFiveSensesFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('living') || normalizedChapter.contains('non-living') || 
                normalizedChapter.contains('hidup') || normalizedChapter.contains('bukan hidup')) {
        return _generateLivingNonLivingFlashcards(subject, age, language, count);
      }
    }
    
    // Social & Emotional Learning
    else if (normalizedSubject.contains('social') || normalizedSubject.contains('emotional') || 
             normalizedSubject.contains('sosial') || normalizedSubject.contains('emosi')) {
      if (normalizedChapter.contains('emotions') || normalizedChapter.contains('expressions') || 
          normalizedChapter.contains('emosi') || normalizedChapter.contains('ekspresi')) {
        return _generateEmotionsFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('sharing') || normalizedChapter.contains('cooperation') || 
                normalizedChapter.contains('berkongsi') || normalizedChapter.contains('kerjasama')) {
        return _generateSharingCooperationFlashcards(subject, age, language, count);
      }
    }
    
    // Art & Craft
    else if (normalizedSubject.contains('art') || normalizedSubject.contains('craft') || 
             normalizedSubject.contains('seni')) {
      if (normalizedChapter.contains('color') || normalizedChapter.contains('mixing') || 
          normalizedChapter.contains('warna')) {
        return _generateColorExplorationFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('lines') || normalizedChapter.contains('patterns') || 
                normalizedChapter.contains('garisan') || normalizedChapter.contains('corak')) {
        return _generateLinesAndPatternsFlashcards(subject, age, language, count);
      }
    }
    
    // Physical Development
    else if (normalizedSubject.contains('physical') || normalizedSubject.contains('motor')) {
      if (normalizedChapter.contains('gross') || normalizedChapter.contains('large')) {
        return _generateGrossMotorSkillsFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('fine') || normalizedChapter.contains('small')) {
        return _generateFineMotorSkillsFlashcards(subject, age, language, count);
      }
    }
    
    // Jawi
    else if (normalizedSubject.contains('jawi')) {
      if (normalizedChapter.contains('huruf') || normalizedChapter.contains('letters') || 
          normalizedChapter.contains('pengenalan')) {
        return _generateJawiLettersFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('penulisan') || normalizedChapter.contains('writing')) {
        return _generateJawiSimpleWritingFlashcards(subject, age, language, count);
      }
    }
    
    // Hijaiyah / Iqraa
    else if (normalizedSubject.contains('hijaiyah') || normalizedSubject.contains('iqraa') || 
             normalizedSubject.contains('arabic')) {
      if (normalizedChapter.contains('huruf') || normalizedChapter.contains('letters')) {
        return _generateHijaiyahLettersFlashcards(subject, age, language, count);
      } else if (normalizedChapter.contains('bacaan') || normalizedChapter.contains('reading')) {
        return _generateBasicIqraaReadingFlashcards(subject, age, language, count);
      }
    }
    
    // Animals (special case)
    else if (normalizedSubject.contains('animal') || normalizedSubject.contains('haiwan')) {
      return _generateAnimalFlashcards(subject, age, language, count);
    }
    
    // Default to English alphabet if no match
    return _generateDefaultFlashcards(subject, age, language, count);
  }
  
  // Generate Malay letters flashcards
  static List<Map<String, dynamic>> _generateMalayLettersFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Ayam',
        'letter': 'Aa',
        'description': 'Ayam berkaki dua.',
        'image_asset': 'assets/flashcards/malay/ayam.png',
      },
      {
        'title': 'Bola',
        'letter': 'Bb',
        'description': 'Bola berbentuk bulat.',
        'image_asset': 'assets/flashcards/malay/bola.png',
      },
      {
        'title': 'Cacing',
        'letter': 'Cc',
        'description': 'Cacing tiada kaki.',
        'image_asset': 'assets/flashcards/malay/cacing.png',
      },
      {
        'title': 'Durian',
        'letter': 'Dd',
        'description': 'Durian berbau kuat.',
        'image_asset': 'assets/flashcards/malay/durian.png',
      },
      {
        'title': 'Epal',
        'letter': 'Ee',
        'description': 'Epal berwarna merah.',
        'image_asset': 'assets/flashcards/malay/epal.png',
      },
      {
        'title': 'Foto',
        'letter': 'Ff',
        'description': 'Foto merakam gambar.',
        'image_asset': 'assets/flashcards/malay/foto.png',
      },
      {
        'title': 'Gajah',
        'letter': 'Gg',
        'description': 'Gajah mempunyai belalai.',
        'image_asset': 'assets/flashcards/malay/gajah.png',
      },
      {
        'title': 'Harimau',
        'letter': 'Hh',
        'description': 'Harimau mempunyai belang.',
        'image_asset': 'assets/flashcards/malay/harimau.png',
      },
      {
        'title': 'Ikan',
        'letter': 'Ii',
        'description': 'Ikan bernafas dengan insang.',
        'image_asset': 'assets/flashcards/malay/ikan.png',
      },
      {
        'title': 'Jeruk',
        'letter': 'Jj',
        'description': 'Jeruk rasanya masam.',
        'image_asset': 'assets/flashcards/malay/jeruk.png',
      },
      {
        'title': 'Kucing',
        'letter': 'Kk',
        'description': 'Kucing mempunyai misai.',
        'image_asset': 'assets/flashcards/malay/kucing.png',
      },
      {
        'title': 'Lampu',
        'letter': 'Ll',
        'description': 'Lampu memberikan cahaya.',
        'image_asset': 'assets/flashcards/malay/lampu.png',
      },
      {
        'title': 'Meja',
        'letter': 'Mm',
        'description': 'Meja mempunyai empat kaki.',
        'image_asset': 'assets/flashcards/malay/meja.png',
      },
      {
        'title': 'Nanas',
        'letter': 'Nn',
        'description': 'Nanas mempunyai duri.',
        'image_asset': 'assets/flashcards/malay/nanas.png',
      },
      {
        'title': 'Orang',
        'letter': 'Oo',
        'description': 'Orang mempunyai dua tangan.',
        'image_asset': 'assets/flashcards/malay/orang.png',
      },
      {
        'title': 'Pokok',
        'letter': 'Pp',
        'description': 'Pokok mempunyai daun.',
        'image_asset': 'assets/flashcards/malay/pokok.png',
      },
    ];
    
    print('Generating $count flashcards for age $age');
    return flashcards.take(count).toList();
  }
  
  // Generate Malay simple words flashcards
  static List<Map<String, dynamic>> _generateMalaySimpleWordsFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Saya',
        'letter': 'Sa',
        'description': 'Saya bermaksud diri sendiri.',
        'image_asset': 'assets/flashcards/malay/saya.png',
      },
      {
        'title': 'Kamu',
        'letter': 'Ka',
        'description': 'Kamu bermaksud orang yang diajak bicara.',
        'image_asset': 'assets/flashcards/malay/kamu.png',
      },
      {
        'title': 'Makan',
        'letter': 'Ma',
        'description': 'Makan adalah perbuatan memasukkan makanan ke dalam mulut.',
        'image_asset': 'assets/flashcards/malay/makan.png',
      },
      {
        'title': 'Minum',
        'letter': 'Mi',
        'description': 'Minum adalah perbuatan memasukkan air ke dalam mulut.',
        'image_asset': 'assets/flashcards/malay/minum.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate English alphabet flashcards
  static List<Map<String, dynamic>> _generateEnglishAlphabetFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Apple',
        'letter': 'Aa',
        'description': 'A is for Apple, a red fruit that grows on trees.',
        'image_asset': 'assets/flashcards/english/apple.png',
      },
      {
        'title': 'Ball',
        'letter': 'Bb',
        'description': 'B is for Ball, a round toy that bounces.',
        'image_asset': 'assets/flashcards/english/ball.png',
      },
      {
        'title': 'Cat',
        'letter': 'Cc',
        'description': 'C is for Cat, a furry pet that meows.',
        'image_asset': 'assets/flashcards/english/cat.png',
      },
      {
        'title': 'Dog',
        'letter': 'Dd',
        'description': 'D is for Dog, a friendly pet that barks.',
        'image_asset': 'assets/flashcards/english/dog.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate English sight words flashcards
  static List<Map<String, dynamic>> _generateEnglishSightWordsFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'The',
        'letter': 'Th',
        'description': 'The is used before specific or particular nouns.',
        'image_asset': 'assets/flashcards/english/the.png',
      },
      {
        'title': 'And',
        'letter': 'An',
        'description': 'And is used to connect words or groups of words.',
        'image_asset': 'assets/flashcards/english/and.png',
      },
      {
        'title': 'A',
        'letter': 'Aa',
        'description': 'A is used before nouns that begin with a consonant sound.',
        'image_asset': 'assets/flashcards/english/a.png',
      },
      {
        'title': 'To',
        'letter': 'To',
        'description': 'To is used to express motion in the direction of a place.',
        'image_asset': 'assets/flashcards/english/to.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate counting flashcards
  static List<Map<String, dynamic>> _generateCountingFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'One',
        'letter': '1',
        'description': 'One is the first number in counting.',
        'image_asset': 'assets/flashcards/math/one.png',
      },
      {
        'title': 'Two',
        'letter': '2',
        'description': 'Two is the number after one.',
        'image_asset': 'assets/flashcards/math/two.png',
      },
      {
        'title': 'Three',
        'letter': '3',
        'description': 'Three is the number after two.',
        'image_asset': 'assets/flashcards/math/three.png',
      },
      {
        'title': 'Four',
        'letter': '4',
        'description': 'Four is the number after three.',
        'image_asset': 'assets/flashcards/math/four.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate shapes and patterns flashcards
  static List<Map<String, dynamic>> _generateShapesAndPatternsFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Circle',
        'letter': 'Ci',
        'description': 'A circle is a round shape with no corners.',
        'image_asset': 'assets/flashcards/math/circle.png',
      },
      {
        'title': 'Square',
        'letter': 'Sq',
        'description': 'A square has four equal sides and four corners.',
        'image_asset': 'assets/flashcards/math/square.png',
      },
      {
        'title': 'Triangle',
        'letter': 'Tr',
        'description': 'A triangle has three sides and three corners.',
        'image_asset': 'assets/flashcards/math/triangle.png',
      },
      {
        'title': 'Rectangle',
        'letter': 'Re',
        'description': 'A rectangle has four sides and four corners.',
        'image_asset': 'assets/flashcards/math/rectangle.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate gross motor skills flashcards
  static List<Map<String, dynamic>> _generateGrossMotorSkillsFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Running',
        'letter': 'Ru',
        'description': 'Running is moving quickly on your feet.',
        'image_asset': 'assets/flashcards/motor/running.png',
      },
      {
        'title': 'Jumping',
        'letter': 'Ju',
        'description': 'Jumping is pushing off the ground with your feet.',
        'image_asset': 'assets/flashcards/motor/jumping.png',
      },
      {
        'title': 'Throwing',
        'letter': 'Th',
        'description': 'Throwing is sending an object through the air with your hand.',
        'image_asset': 'assets/flashcards/motor/throwing.png',
      },
      {
        'title': 'Kicking',
        'letter': 'Ki',
        'description': 'Kicking is hitting something with your foot.',
        'image_asset': 'assets/flashcards/motor/kicking.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate fine motor skills flashcards
  static List<Map<String, dynamic>> _generateFineMotorSkillsFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Drawing',
        'letter': 'Dr',
        'description': 'Drawing is making pictures with a pencil or crayon.',
        'image_asset': 'assets/flashcards/motor/drawing.png',
      },
      {
        'title': 'Cutting',
        'letter': 'Cu',
        'description': 'Cutting is using scissors to divide paper.',
        'image_asset': 'assets/flashcards/motor/cutting.png',
      },
      {
        'title': 'Buttoning',
        'letter': 'Bu',
        'description': 'Buttoning is fastening clothes with buttons.',
        'image_asset': 'assets/flashcards/motor/buttoning.png',
      },
      {
        'title': 'Beading',
        'letter': 'Be',
        'description': 'Beading is putting beads on a string.',
        'image_asset': 'assets/flashcards/motor/beading.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate Jawi letters flashcards
  static List<Map<String, dynamic>> _generateJawiLettersFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Alif',
        'letter': 'ا',
        'description': 'Alif adalah huruf pertama dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/alif.png',
      },
      {
        'title': 'Ba',
        'letter': 'ب',
        'description': 'Ba adalah huruf kedua dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/ba.png',
      },
      {
        'title': 'Ta',
        'letter': 'ت',
        'description': 'Ta adalah huruf ketiga dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/ta.png',
      },
      {
        'title': 'Jim',
        'letter': 'ج',
        'description': 'Jim adalah huruf kelima dalam abjad Jawi.',
        'image_asset': 'assets/flashcards/jawi/jim.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate Jawi simple writing flashcards
  static List<Map<String, dynamic>> _generateJawiSimpleWritingFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Saya',
        'letter': 'سايا',
        'description': 'Saya dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/saya.png',
      },
      {
        'title': 'Kamu',
        'letter': 'كامو',
        'description': 'Kamu dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/kamu.png',
      },
      {
        'title': 'Dia',
        'letter': 'دي',
        'description': 'Dia dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/dia.png',
      },
      {
        'title': 'Kita',
        'letter': 'كيت',
        'description': 'Kita dalam tulisan Jawi.',
        'image_asset': 'assets/flashcards/jawi/kita.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate Hijaiyah letters flashcards
  static List<Map<String, dynamic>> _generateHijaiyahLettersFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Alif',
        'letter': 'ا',
        'description': 'Alif adalah huruf pertama dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/alif.png',
      },
      {
        'title': 'Ba',
        'letter': 'ب',
        'description': 'Ba adalah huruf kedua dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/ba.png',
      },
      {
        'title': 'Ta',
        'letter': 'ت',
        'description': 'Ta adalah huruf ketiga dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/ta.png',
      },
      {
        'title': 'Tha',
        'letter': 'ث',
        'description': 'Tha adalah huruf keempat dalam abjad Hijaiyah.',
        'image_asset': 'assets/flashcards/hijaiyah/tha.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate Basic Iqraa reading flashcards
  static List<Map<String, dynamic>> _generateBasicIqraaReadingFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Alif Fathah',
        'letter': 'اَ',
        'description': 'Alif dengan baris atas dibaca "a".',
        'image_asset': 'assets/flashcards/iqraa/alif_fathah.png',
      },
      {
        'title': 'Ba Fathah',
        'letter': 'بَ',
        'description': 'Ba dengan baris atas dibaca "ba".',
        'image_asset': 'assets/flashcards/iqraa/ba_fathah.png',
      },
      {
        'title': 'Ta Fathah',
        'letter': 'تَ',
        'description': 'Ta dengan baris atas dibaca "ta".',
        'image_asset': 'assets/flashcards/iqraa/ta_fathah.png',
      },
      {
        'title': 'Tha Fathah',
        'letter': 'ثَ',
        'description': 'Tha dengan baris atas dibaca "tsa".',
        'image_asset': 'assets/flashcards/iqraa/tha_fathah.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate animal flashcards
  static List<Map<String, dynamic>> _generateAnimalFlashcards(
      String subject, int age, String language, int count) {
    final List<Map<String, dynamic>> flashcards = [
      {
        'title': 'Lion',
        'letter': 'Ll',
        'description': 'Lions are big cats that live in Africa.',
        'image_asset': 'assets/flashcards/animals/lion.png',
      },
      {
        'title': 'Elephant',
        'letter': 'Ee',
        'description': 'Elephants have long trunks and big ears.',
        'image_asset': 'assets/flashcards/animals/elephant.png',
      },
      {
        'title': 'Giraffe',
        'letter': 'Gg',
        'description': 'Giraffes have very long necks.',
        'image_asset': 'assets/flashcards/animals/giraffe.png',
      },
      {
        'title': 'Zebra',
        'letter': 'Zz',
        'description': 'Zebras have black and white stripes.',
        'image_asset': 'assets/flashcards/animals/zebra.png',
      },
    ];
    
    return flashcards.take(count).toList();
  }
  
  // Generate Five Senses flashcards with age-appropriate content
  static List<Map<String, dynamic>> _generateFiveSensesFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Base cards for all ages
    final baseCards = [
      {
        'title': 'Sight',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/science/sight.png',
      },
      {
        'title': 'Hearing',
        'letter': 'Hh',
        'image_asset': 'assets/flashcards/science/hearing.png',
      },
      {
        'title': 'Touch',
        'letter': 'Tt',
        'image_asset': 'assets/flashcards/science/touch.png',
      },
      {
        'title': 'Taste',
        'letter': 'Tt',
        'image_asset': 'assets/flashcards/science/taste.png',
      },
      {
        'title': 'Smell',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/science/smell.png',
      },
    ];
    
    // Additional cards for older children
    final advancedCards = [
      {
        'title': 'Eyes',
        'letter': 'Ee',
        'image_asset': 'assets/flashcards/science/eyes.png',
      },
      {
        'title': 'Ears',
        'letter': 'Ee',
        'image_asset': 'assets/flashcards/science/ears.png',
      },
      {
        'title': 'Skin',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/science/skin.png',
      },
      {
        'title': 'Tongue',
        'letter': 'Tt',
        'image_asset': 'assets/flashcards/science/tongue.png',
      },
      {
        'title': 'Nose',
        'letter': 'Nn',
        'image_asset': 'assets/flashcards/science/nose.png',
      },
    ];
    
    // Age-specific descriptions
    for (var card in baseCards) {
      var title = card['title'] as String;
      var description = '';
      
      // Different descriptions based on age
      if (age <= 4) {
        // Simple descriptions for younger children
        switch (title) {
          case 'Sight':
            description = 'We see with our eyes.';
            break;
          case 'Hearing':
            description = 'We hear with our ears.';
            break;
          case 'Touch':
            description = 'We feel with our hands.';
            break;
          case 'Taste':
            description = 'We taste with our tongue.';
            break;
          case 'Smell':
            description = 'We smell with our nose.';
            break;
        }
      } else if (age == 5) {
        // More detailed for age 5
        switch (title) {
          case 'Sight':
            description = 'Our eyes help us see colors and shapes.';
            break;
          case 'Hearing':
            description = 'Our ears help us hear sounds and music.';
            break;
          case 'Touch':
            description = 'Our skin helps us feel hot, cold, soft or hard.';
            break;
          case 'Taste':
            description = 'Our tongue helps us taste sweet, sour, salty and bitter.';
            break;
          case 'Smell':
            description = 'Our nose helps us smell flowers, food and more.';
            break;
        }
      } else {
        // Most detailed for age 6
        switch (title) {
          case 'Sight':
            description = 'Our eyes are sense organs that detect light and send signals to our brain so we can see. We use our sight to read, navigate, and appreciate colors.';
            break;
          case 'Hearing':
            description = 'Our ears detect sound vibrations in the air. Hearing helps us communicate, enjoy music, and stay aware of our surroundings.';
            break;
          case 'Touch':
            description = 'Touch receptors in our skin help us feel temperature, pressure, and texture. This sense protects us from danger and helps us explore our world.';
            break;
          case 'Taste':
            description = 'Our tongue has taste buds that detect sweet, sour, salty, bitter and umami flavors. This helps us enjoy food and avoid harmful substances.';
            break;
          case 'Smell':
            description = 'Our nose can detect thousands of different scents. Smell is closely linked with taste and helps us enjoy food and detect dangers like smoke or gas.';
            break;
        }
      }
      
      // Add description to card
      card['description'] = description;
      flashcards.add(card);
    }
    
    // Add additional cards for older ages
    if (age >= 5) {
      for (var card in advancedCards) {
        var title = card['title'] as String;
        var description = '';
        
        // Age-specific descriptions for advanced cards
        if (age == 5) {
          // Simpler descriptions for age 5
          switch (title) {
            case 'Eyes':
              description = 'Eyes are organs that help us see.';
              break;
            case 'Ears':
              description = 'Ears are organs that help us hear.';
              break;
            case 'Skin':
              description = 'Skin covers our body and helps us feel touch.';
              break;
            case 'Tongue':
              description = 'Tongue helps us taste food.';
              break;
            case 'Nose':
              description = 'Nose helps us smell different scents.';
              break;
          }
        } else {
          // More detailed for age 6
          switch (title) {
            case 'Eyes':
              description = 'Eyes have parts like pupils, iris, and retina that work together to help us see.';
              break;
            case 'Ears':
              description = 'Ears have outer, middle, and inner parts that capture sound and send signals to our brain.';
              break;
            case 'Skin':
              description = 'Skin is our largest organ. It has receptors that detect touch, temperature, and pain.';
              break;
            case 'Tongue':
              description = 'Our tongue has tiny bumps called taste buds that detect different flavors in food.';
              break;
            case 'Nose':
              description = 'Inside our nose, special cells detect smells and send signals to our brain.';
              break;
          }
        }
        
        // Add description to card
        card['description'] = description;
        flashcards.add(card);
      }
    }
    
    return flashcards.take(count).toList();
  }
  
  // Generate Living vs Non-living Things flashcards with age-appropriate content
  static List<Map<String, dynamic>> _generateLivingNonLivingFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Living things
    final livingThings = [
      {
        'title': 'Plants',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/science/plants.png',
        'category': 'Living',
      },
      {
        'title': 'Animals',
        'letter': 'Aa',
        'image_asset': 'assets/flashcards/science/animals.png',
        'category': 'Living',
      },
      {
        'title': 'Humans',
        'letter': 'Hh',
        'image_asset': 'assets/flashcards/science/humans.png',
        'category': 'Living',
      },
      {
        'title': 'Birds',
        'letter': 'Bb',
        'image_asset': 'assets/flashcards/science/birds.png',
        'category': 'Living',
      },
      {
        'title': 'Insects',
        'letter': 'Ii',
        'image_asset': 'assets/flashcards/science/insects.png',
        'category': 'Living',
      },
    ];
    
    // Non-living things
    final nonLivingThings = [
      {
        'title': 'Rocks',
        'letter': 'Rr',
        'image_asset': 'assets/flashcards/science/rocks.png',
        'category': 'Non-living',
      },
      {
        'title': 'Water',
        'letter': 'Ww',
        'image_asset': 'assets/flashcards/science/water.png',
        'category': 'Non-living',
      },
      {
        'title': 'Air',
        'letter': 'Aa',
        'image_asset': 'assets/flashcards/science/air.png',
        'category': 'Non-living',
      },
      {
        'title': 'Toys',
        'letter': 'Tt',
        'image_asset': 'assets/flashcards/science/toys.png',
        'category': 'Non-living',
      },
      {
        'title': 'Furniture',
        'letter': 'Ff',
        'image_asset': 'assets/flashcards/science/furniture.png',
        'category': 'Non-living',
      },
    ];
    
    // Add descriptions based on age
    for (var item in [...livingThings, ...nonLivingThings]) {
      var title = item['title'] as String;
      var category = item['category'] as String;
      var description = '';
      
      // Age-specific descriptions
      if (age <= 4) {
        // Simple descriptions for younger children
        if (category == 'Living') {
          description = '$title are living things. They grow and need food and water.';
        } else {
          description = '$title are non-living things. They don\'t grow or need food.';
        }
      } else if (age == 5) {
        // More detailed for age 5
        if (category == 'Living') {
          switch (title) {
            case 'Plants':
              description = 'Plants are living things. They grow, need water, sunlight, and air to live.';
              break;
            case 'Animals':
              description = 'Animals are living things. They move, eat food, and breathe air.';
              break;
            case 'Humans':
              description = 'Humans are living things. We grow, eat food, and need water and air.';
              break;
            case 'Birds':
              description = 'Birds are living things. They have feathers, lay eggs, and can fly.';
              break;
            case 'Insects':
              description = 'Insects are small living things with six legs. They grow and change.';
              break;
          }
        } else {
          switch (title) {
            case 'Rocks':
              description = 'Rocks are non-living things. They don\'t grow or change on their own.';
              break;
            case 'Water':
              description = 'Water is a non-living thing. It flows and takes the shape of its container.';
              break;
            case 'Air':
              description = 'Air is a non-living thing that surrounds us. We need it to breathe.';
              break;
            case 'Toys':
              description = 'Toys are non-living things made by people. They don\'t grow or eat.';
              break;
            case 'Furniture':
              description = 'Furniture is non-living. Things like chairs and tables don\'t grow or change.';
              break;
          }
        }
      } else {
        // Most detailed for age 6
        if (category == 'Living') {
          switch (title) {
            case 'Plants':
              description = 'Plants are living organisms that can make their own food through photosynthesis. They grow, reproduce, and respond to their environment. Plants need water, sunlight, air, and nutrients to survive.';
              break;
            case 'Animals':
              description = 'Animals are living organisms that need to eat food to get energy. They can move, grow, reproduce, and respond to their environment. Different animals live in different habitats.';
              break;
            case 'Humans':
              description = 'Humans are living beings that belong to the animal kingdom. We grow, reproduce, and need food, water, and oxygen to survive. Humans have complex brains that help us think, learn, and create.';
              break;
            case 'Birds':
              description = 'Birds are living creatures with feathers, wings, and beaks. They lay eggs, build nests, and most can fly. Birds have hollow bones that help them stay light for flying.';
              break;
            case 'Insects':
              description = 'Insects are small living creatures with six legs and three body parts: head, thorax, and abdomen. Most have wings and antennae. Insects grow by molting - shedding their old exoskeleton as they grow.';
              break;
          }
        } else {
          switch (title) {
            case 'Rocks':
              description = 'Rocks are non-living objects made of minerals. They don\'t grow, breathe, or reproduce. Rocks can be formed by cooling lava, pressure on sediments, or changes to existing rocks.';
              break;
            case 'Water':
              description = 'Water is a non-living substance that covers most of Earth. It doesn\'t grow or reproduce, but it can change forms between solid (ice), liquid (water), and gas (water vapor).';
              break;
            case 'Air':
              description = 'Air is a non-living mixture of gases including oxygen, nitrogen, and carbon dioxide. It has no fixed shape or volume. Living things need the oxygen in air to survive.';
              break;
            case 'Toys':
              description = 'Toys are non-living objects made by people from materials like plastic, wood, or metal. They don\'t grow, eat, or reproduce. Toys need someone to move them - they can\'t move on their own.';
              break;
            case 'Furniture':
              description = 'Furniture consists of non-living objects made to support human activities. Unlike living things, furniture doesn\'t need food, water, or air. It\'s constructed from materials like wood, metal, or plastic.';
              break;
          }
        }
      }
      
      // Add description to item
      item['description'] = description;
      flashcards.add(item);
    }
    
    return flashcards.take(count).toList();
  }
  
  // Generate Emotions & Expressions flashcards with age-appropriate content
  static List<Map<String, dynamic>> _generateSharingCooperationFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Basic sharing concepts for all ages
    final basicConcepts = [
      {
        'title': 'Taking Turns',
        'letter': 'Tt',
        'image_asset': 'assets/flashcards/social/taking_turns.png',
      },
      {
        'title': 'Sharing Toys',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/social/sharing_toys.png',
      },
      {
        'title': 'Helping Others',
        'letter': 'Hh',
        'image_asset': 'assets/flashcards/social/helping.png',
      },
      {
        'title': 'Listening',
        'letter': 'Ll',
        'image_asset': 'assets/flashcards/social/listening.png',
      },
      {
        'title': 'Being Kind',
        'letter': 'Kk',
        'image_asset': 'assets/flashcards/social/kindness.png',
      },
    ];
    
    // More advanced cooperation concepts for older children
    final advancedConcepts = [
      {
        'title': 'Teamwork',
        'letter': 'Tt',
        'image_asset': 'assets/flashcards/social/teamwork.png',
      },
      {
        'title': 'Apologizing',
        'letter': 'Aa',
        'image_asset': 'assets/flashcards/social/apologizing.png',
      },
      {
        'title': 'Patience',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/social/patience.png',
      },
      {
        'title': 'Empathy',
        'letter': 'Ee',
        'image_asset': 'assets/flashcards/social/empathy.png',
      },
      {
        'title': 'Problem Solving',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/social/problem_solving.png',
      },
    ];
    
    // Add descriptions based on age
    for (var card in basicConcepts) {
      var title = card['title'] as String;
      var description = '';
      
      // Age-specific descriptions
      if (age <= 4) {
        // Simple descriptions for younger children
        switch (title) {
          case 'Taking Turns':
            description = 'Wait for your turn, then others wait for theirs.';
            break;
          case 'Sharing Toys':
            description = 'Let friends play with your toys too.';
            break;
          case 'Helping Others':
            description = 'Do nice things to help your friends.';
            break;
          case 'Listening':
            description = 'Pay attention when others are talking.';
            break;
          case 'Being Kind':
            description = 'Say and do nice things for others.';
            break;
        }
      } else if (age == 5) {
        // More detailed for age 5
        switch (title) {
          case 'Taking Turns':
            description = 'Everyone gets a chance to play or speak. When it\'s not your turn, wait patiently.';
            break;
          case 'Sharing Toys':
            description = 'Let others play with your toys. Sharing makes playtime fun for everyone.';
            break;
          case 'Helping Others':
            description = 'When someone needs help, try to assist them. Helping makes others happy.';
            break;
          case 'Listening':
            description = 'Look at the person who is talking and think about what they say.';
            break;
          case 'Being Kind':
            description = 'Use nice words and do helpful things. Kindness makes everyone feel good.';
            break;
        }
      } else {
        // Most detailed for age 6
        switch (title) {
          case 'Taking Turns':
            description = 'Taking turns means everyone gets a fair chance to participate. It\'s an important part of playing games and having conversations. When we take turns, we show respect for others and learn patience.';
            break;
          case 'Sharing Toys':
            description = 'Sharing means letting others use things that belong to you. When we share our toys and materials, we build friendships and learn that giving can be as rewarding as receiving.';
            break;
          case 'Helping Others':
            description = 'Helping others means offering assistance when someone needs it. We can help in many ways, like cleaning up together, explaining something, or offering comfort when someone is sad.';
            break;
          case 'Listening':
            description = 'Active listening means paying full attention when others speak. Good listeners look at the speaker, think about what is being said, and ask questions to understand better.';
            break;
          case 'Being Kind':
            description = 'Kindness means doing and saying things that make others feel good. Acts of kindness include using polite words, including others in activities, and showing appreciation for what others do.';
            break;
        }
      }
      
      // Add description to card
      card['description'] = description;
      flashcards.add(card);
    }
    
    // Add advanced concepts for older children
    if (age >= 5) {
      for (var card in advancedConcepts.take(age == 5 ? 2 : 5)) {
        var title = card['title'] as String;
        var description = '';
        
        if (age == 5) {
          // Simpler descriptions for age 5
          switch (title) {
            case 'Teamwork':
              description = 'Working together to get something done.';
              break;
            case 'Apologizing':
              description = 'Saying sorry when you make a mistake.';
              break;
          }
        } else {
          // More detailed for age 6
          switch (title) {
            case 'Teamwork':
              description = 'Teamwork means working together toward a common goal. When we work as a team, we can accomplish more than we could alone. Everyone contributes their skills and ideas.';
              break;
            case 'Apologizing':
              description = 'Apologizing means saying sorry when we\'ve done something wrong. A good apology shows we understand what we did wrong and will try not to do it again.';
              break;
            case 'Patience':
              description = 'Patience means waiting calmly without getting upset. Being patient helps us handle delays and gives others the time they need to learn or complete tasks.';
              break;
            case 'Empathy':
              description = 'Empathy means understanding how another person feels. When we show empathy, we try to imagine what it\'s like to be in someone else\'s situation.';
              break;
            case 'Problem Solving':
              description = 'Problem solving means finding good solutions when there\'s a difficulty. It involves thinking about what\'s happening, talking about ideas, and trying solutions.';
              break;
          }
        }
        
        // Add description to card
        card['description'] = description;
        flashcards.add(card);
      }
    }
    
    return flashcards.take(count).toList();
  }
  
  static List<Map<String, dynamic>> _generateEmotionsFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Basic emotions for all ages
    final basicEmotions = [
      {
        'title': 'Happy',
        'letter': 'Hh',
        'image_asset': 'assets/flashcards/emotions/happy.png',
      },
      {
        'title': 'Sad',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/emotions/sad.png',
      },
      {
        'title': 'Angry',
        'letter': 'Aa',
        'image_asset': 'assets/flashcards/emotions/angry.png',
      },
      {
        'title': 'Scared',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/emotions/scared.png',
      },
      {
        'title': 'Excited',
        'letter': 'Ee',
        'image_asset': 'assets/flashcards/emotions/excited.png',
      },
    ];
    
    // More complex emotions for older children
    final complexEmotions = [
      {
        'title': 'Proud',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/emotions/proud.png',
      },
      {
        'title': 'Surprised',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/emotions/surprised.png',
      },
      {
        'title': 'Confused',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/emotions/confused.png',
      },
      {
        'title': 'Calm',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/emotions/calm.png',
      },
      {
        'title': 'Frustrated',
        'letter': 'Ff',
        'image_asset': 'assets/flashcards/emotions/frustrated.png',
      },
    ];
    
    // Add descriptions based on age
    for (var card in basicEmotions) {
      var title = card['title'] as String;
      var description = '';
      
      // Age-specific descriptions
      if (age <= 4) {
        // Simple descriptions for younger children
        switch (title) {
          case 'Happy':
            description = 'When we smile and feel good.';
            break;
          case 'Sad':
            description = 'When we feel upset and might cry.';
            break;
          case 'Angry':
            description = 'When we feel mad about something.';
            break;
          case 'Scared':
            description = 'When we feel afraid of something.';
            break;
          case 'Excited':
            description = 'When we feel really happy about something new.';
            break;
        }
      } else if (age == 5) {
        // More detailed for age 5
        switch (title) {
          case 'Happy':
            description = 'When we feel good inside and smile. We feel happy when good things happen.';
            break;
          case 'Sad':
            description = 'When we feel down and might cry. We feel sad when something bad happens.';
            break;
          case 'Angry':
            description = 'When we feel upset and mad. Our face might get red and we want to yell.';
            break;
          case 'Scared':
            description = 'When we feel afraid of something. Our heart beats fast and we might hide.';
            break;
          case 'Excited':
            description = 'When we feel really happy and can\'t wait for something. We might jump or clap.';
            break;
        }
      } else {
        // Most detailed for age 6
        switch (title) {
          case 'Happy':
            description = 'Happiness is a feeling of joy and contentment. When we\'re happy, we smile, laugh, and feel good inside. Many things can make us happy like playing with friends or doing something we enjoy.';
            break;
          case 'Sad':
            description = 'Sadness is a feeling we get when something bad happens. When we\'re sad, we might cry or want to be alone. It\'s okay to feel sad sometimes, and talking about our feelings can help us feel better.';
            break;
          case 'Angry':
            description = 'Anger is a strong feeling we get when something unfair happens. When we\'re angry, our face might get red and we might want to yell. Taking deep breaths can help us calm down.';
            break;
          case 'Scared':
            description = 'Fear is what we feel when we think something might hurt us. When we\'re scared, our heart beats fast and we want to run away or hide. Being scared helps keep us safe from danger.';
            break;
          case 'Excited':
            description = 'Excitement is a happy, energetic feeling we get when we\'re looking forward to something good. When we\'re excited, we might feel butterflies in our stomach and have more energy.';
            break;
        }
      }
      
      // Add description to card
      card['description'] = description;
      flashcards.add(card);
    }
    
    // Add complex emotions for older children
    if (age >= 5) {
      for (var card in complexEmotions.take(age == 5 ? 3 : 5)) { // Fewer complex emotions for age 5
        var title = card['title'] as String;
        var description = '';
        
        // Age-specific descriptions
        if (age == 5) {
          switch (title) {
            case 'Proud':
              description = 'When we feel good about something we did well.';
              break;
            case 'Surprised':
              description = 'When something unexpected happens and our eyes get big.';
              break;
            case 'Confused':
              description = 'When we don\'t understand something and need help.';
              break;
          }
        } else {
          // For age 6
          switch (title) {
            case 'Proud':
              description = 'Pride is a good feeling we get when we accomplish something difficult. When we feel proud, we stand tall and want to show others what we\'ve done.';
              break;
            case 'Surprised':
              description = 'Surprise is what we feel when something unexpected happens. When we\'re surprised, our eyes get wide and we might gasp.';
              break;
            case 'Confused':
              description = 'Confusion happens when we don\'t understand something. When we\'re confused, we might ask questions to help us understand better.';
              break;
            case 'Calm':
              description = 'Calmness is a peaceful feeling when we\'re relaxed. When we\'re calm, our breathing is slow and our mind feels quiet.';
              break;
            case 'Frustrated':
              description = 'Frustration is what we feel when we try to do something but keep having problems. When we\'re frustrated, taking a break can help us try again.';
              break;
          }
        }
        
        // Add description to card
        card['description'] = description;
        flashcards.add(card);
      }
    }
    
    return flashcards.take(count).toList();
  }
  
  // Generate Color Exploration & Mixing flashcards with age-appropriate content
  static List<Map<String, dynamic>> _generateColorExplorationFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Basic colors for all ages
    final basicColors = [
      {
        'title': 'Red',
        'letter': 'Rr',
        'image_asset': 'assets/flashcards/colors/red.png',
        'color_code': '#FF0000',
      },
      {
        'title': 'Blue',
        'letter': 'Bb',
        'image_asset': 'assets/flashcards/colors/blue.png',
        'color_code': '#0000FF',
      },
      {
        'title': 'Yellow',
        'letter': 'Yy',
        'image_asset': 'assets/flashcards/colors/yellow.png',
        'color_code': '#FFFF00',
      },
      {
        'title': 'Green',
        'letter': 'Gg',
        'image_asset': 'assets/flashcards/colors/green.png',
        'color_code': '#00FF00',
      },
      {
        'title': 'Orange',
        'letter': 'Oo',
        'image_asset': 'assets/flashcards/colors/orange.png',
        'color_code': '#FFA500',
      },
    ];
    
    // Additional colors for older children
    final advancedColors = [
      {
        'title': 'Purple',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/colors/purple.png',
        'color_code': '#800080',
      },
      {
        'title': 'Pink',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/colors/pink.png',
        'color_code': '#FFC0CB',
      },
      {
        'title': 'Brown',
        'letter': 'Bb',
        'image_asset': 'assets/flashcards/colors/brown.png',
        'color_code': '#A52A2A',
      },
      {
        'title': 'Black',
        'letter': 'Bb',
        'image_asset': 'assets/flashcards/colors/black.png',
        'color_code': '#000000',
      },
      {
        'title': 'White',
        'letter': 'Ww',
        'image_asset': 'assets/flashcards/colors/white.png',
        'color_code': '#FFFFFF',
      },
    ];
    
    // Add descriptions based on age
    for (var card in basicColors) {
      var title = card['title'] as String;
      var description = '';
      
      // Age-specific descriptions
      if (age <= 4) {
        // Simple descriptions for younger children
        switch (title) {
          case 'Red':
            description = 'Red like an apple.';
            break;
          case 'Blue':
            description = 'Blue like the sky.';
            break;
          case 'Yellow':
            description = 'Yellow like the sun.';
            break;
          case 'Green':
            description = 'Green like grass.';
            break;
          case 'Orange':
            description = 'Orange like an orange fruit.';
            break;
        }
      } else if (age == 5) {
        // More detailed for age 5
        switch (title) {
          case 'Red':
            description = 'Red is a bright color like apples, strawberries, and fire trucks.';
            break;
          case 'Blue':
            description = 'Blue is the color of the sky and ocean. It can be light or dark.';
            break;
          case 'Yellow':
            description = 'Yellow is a sunny color like bananas, lemons, and the sun.';
            break;
          case 'Green':
            description = 'Green is the color of grass, leaves, and many vegetables.';
            break;
          case 'Orange':
            description = 'Orange is a mix of red and yellow, like oranges and carrots.';
            break;
        }
      } else {
        // Most detailed for age 6
        switch (title) {
          case 'Red':
            description = 'Red is a primary color. It can be found in nature in apples, roses, and ladybugs. Red can express strong feelings like love or anger. Red and yellow mixed together make orange.';
            break;
          case 'Blue':
            description = 'Blue is a primary color. It\'s the color of the sky and ocean. Blue often makes people feel calm and peaceful. Blue and yellow mixed together make green.';
            break;
          case 'Yellow':
            description = 'Yellow is a primary color. It\'s bright like the sun and often makes people feel happy and cheerful. Yellow and blue mixed together make green.';
            break;
          case 'Green':
            description = 'Green is a secondary color made by mixing blue and yellow. It\'s the color of plants, leaves, and grass. Green reminds us of nature and growth.';
            break;
          case 'Orange':
            description = 'Orange is a secondary color made by mixing red and yellow. It\'s a warm color like autumn leaves, oranges, and pumpkins. Orange is energetic and exciting.';
            break;
        }
      }
      
      // Add description to card
      card['description'] = description;
      flashcards.add(card);
    }
    
    // Add advanced colors for older children
    if (age >= 5) {
      for (var card in advancedColors.take(age == 5 ? 2 : 5)) { // Fewer complex emotions for age 5
        var title = card['title'] as String;
        var description = '';
        
        if (age == 5) {
          // Simpler descriptions for age 5
          switch (title) {
            case 'Purple':
              description = 'Purple is a mix of red and blue, like grapes and some flowers.';
              break;
            case 'Pink':
              description = 'Pink is a light red color like cotton candy and cherry blossoms.';
              break;
          }
        } else {
          // More detailed for age 6
          switch (title) {
            case 'Purple':
              description = 'Purple is a secondary color made by mixing red and blue. It can be light like lavender or dark like eggplants. Purple was once a color worn by kings and queens.';
              break;
            case 'Pink':
              description = 'Pink is made by adding white to red. It comes in many shades from light pink like cherry blossoms to bright pink like flamingos. Pink is often associated with sweetness and kindness.';
              break;
            case 'Brown':
              description = 'Brown is made by mixing different colors together like red, yellow, and black. It\'s the color of soil, tree trunks, and chocolate. Brown is a natural, earthy color.';
              break;
            case 'Black':
              description = 'Black is the absence of color. It absorbs all light instead of reflecting it. Black can make other colors stand out when placed next to them. It\'s the color of night sky.';
              break;
            case 'White':
              description = 'White reflects all colors of light. It makes colors lighter when mixed with them to create tints. White is associated with cleanliness and simplicity.';
              break;
          }
        }
        
        // Add description to card
        card['description'] = description;
        flashcards.add(card);
      }
    }
    
    return flashcards.take(count).toList();
  }
  
  // Generate Lines & Patterns flashcards with age-appropriate content
  static List<Map<String, dynamic>> _generateLinesAndPatternsFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Basic lines and patterns for all ages
    final basicPatterns = [
      {
        'title': 'Straight Line',
        'letter': 'Ll',
        'image_asset': 'assets/flashcards/patterns/straight_line.png',
      },
      {
        'title': 'Curved Line',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/patterns/curved_line.png',
      },
      {
        'title': 'Zigzag',
        'letter': 'Zz',
        'image_asset': 'assets/flashcards/patterns/zigzag.png',
      },
      {
        'title': 'Spiral',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/patterns/spiral.png',
      },
      {
        'title': 'Circle Pattern',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/patterns/circle_pattern.png',
      },
    ];
    
    // Advanced patterns for older children
    final advancedPatterns = [
      {
        'title': 'Checkered Pattern',
        'letter': 'Cc',
        'image_asset': 'assets/flashcards/patterns/checkered.png',
      },
      {
        'title': 'Stripes',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/patterns/stripes.png',
      },
      {
        'title': 'Polka Dots',
        'letter': 'Pp',
        'image_asset': 'assets/flashcards/patterns/polka_dots.png',
      },
      {
        'title': 'Symmetry',
        'letter': 'Ss',
        'image_asset': 'assets/flashcards/patterns/symmetry.png',
      },
      {
        'title': 'Repeating Pattern',
        'letter': 'Rr',
        'image_asset': 'assets/flashcards/patterns/repeating.png',
      },
    ];
    
    // Add descriptions based on age
    for (var card in basicPatterns) {
      var title = card['title'] as String;
      var description = '';
      
      // Age-specific descriptions
      if (age <= 4) {
        // Simple descriptions for younger children
        switch (title) {
          case 'Straight Line':
            description = 'A line that goes from one point to another without curves.';
            break;
          case 'Curved Line':
            description = 'A line that bends like a rainbow.';
            break;
          case 'Zigzag':
            description = 'A line that goes up and down with sharp corners.';
            break;
          case 'Spiral':
            description = 'A line that curves around and around getting bigger or smaller.';
            break;
          case 'Circle Pattern':
            description = 'Many circles arranged together to make a design.';
            break;
        }
      } else if (age == 5) {
        // More detailed for age 5
        switch (title) {
          case 'Straight Line':
            description = 'A straight line is the shortest path between two points. You can draw horizontal, vertical, or diagonal straight lines.';
            break;
          case 'Curved Line':
            description = 'A curved line bends smoothly without sharp corners. Curved lines can make shapes like waves, hills, or arches.';
            break;
          case 'Zigzag':
            description = 'A zigzag is made of straight lines that change direction with sharp angles. It looks like lightning or mountain peaks.';
            break;
          case 'Spiral':
            description = 'A spiral is a curved line that winds around a center point, getting farther away or closer to the center as it goes.';
            break;
          case 'Circle Pattern':
            description = 'Circle patterns use many circles arranged in different ways. The circles can be different sizes and sometimes overlap.';
            break;
        }
      } else {
        // Most detailed for age 6
        switch (title) {
          case 'Straight Line':
            description = 'A straight line is a path that doesn\'t curve or bend. Lines can be horizontal (flat like the horizon), vertical (up and down like a flagpole), or diagonal (slanted). Straight lines are used in many designs and structures.';
            break;
          case 'Curved Line':
            description = 'A curved line changes direction smoothly without sharp angles. Curves can be gentle or dramatic, and they create flowing, dynamic compositions. In nature, we see curved lines in rivers, hills, and many plants.';
            break;
          case 'Zigzag':
            description = 'A zigzag pattern consists of connected lines that form sharp angles as they change direction. Zigzags create a sense of energy and movement in artwork. We can see zigzags in lightning bolts, mountain ranges, and many decorative patterns.';
            break;
          case 'Spiral':
            description = 'A spiral is a curved line that winds around a central point, moving closer to or farther from the center. Spirals appear in nature in snail shells, some plants, and even in huge galaxy formations in space.';
            break;
          case 'Circle Pattern':
            description = 'Circle patterns use circles as repeating elements in a design. Artists can vary the size, spacing, color, and arrangement of circles to create different effects. Circle patterns can be simple or complex and are found in many cultures\' art and design.';
            break;
        }
      }
      
      // Add description to card
      card['description'] = description;
      flashcards.add(card);
    }
    
    // Add advanced patterns for older children
    if (age >= 5) {
      for (var card in advancedPatterns.take(age == 5 ? 2 : 5)) {
        var title = card['title'] as String;
        var description = '';
        
        if (age == 5) {
          // Simpler descriptions for age 5
          switch (title) {
            case 'Checkered Pattern':
              description = 'A pattern of squares in two colors arranged like a checkerboard game.';
              break;
            case 'Stripes':
              description = 'Lines of color next to each other, like on a zebra or tiger.';
              break;
          }
        } else {
          // More detailed for age 6
          switch (title) {
            case 'Checkered Pattern':
              description = 'A checkered pattern alternates squares of two colors in rows and columns, like a chess or checkers board. This pattern creates a strong visual contrast and is used in many types of designs, from floors to clothing.';
              break;
            case 'Stripes':
              description = 'Stripes are parallel lines of different colors or textures. They can be vertical, horizontal, or diagonal. Stripes can be different widths and can create various visual effects depending on their arrangement and colors.';
              break;
            case 'Polka Dots':
              description = 'Polka dots are a pattern of equally sized dots arranged in a regular grid. The dots are usually evenly spaced on a contrasting background. This pattern is playful and has been popular in fashion and design for many years.';
              break;
            case 'Symmetry':
              description = 'Symmetry happens when one half of a design mirrors the other half. If you draw a line down the middle, both sides match. Butterflies, human faces, and many flowers show symmetry in nature.';
              break;
            case 'Repeating Pattern':
              description = 'A repeating pattern uses the same element or group of elements over and over in a regular way. The repeated elements can be simple shapes or complex designs. Many fabrics, wallpapers, and decorations use repeating patterns.';
              break;
          }
        }
        
        // Add description to card
        card['description'] = description;
        flashcards.add(card);
      }
    }
    
    return flashcards.take(count).toList();
  }
  
  // Generate default flashcards when no specific template is available
  static List<Map<String, dynamic>> _generateDefaultFlashcards(
      String subject, int age, String language, int count) {
    List<Map<String, dynamic>> flashcards = [];
    
    // Create generic flashcards based on subject
    final String normalizedSubject = subject.toLowerCase().trim();
    
    if (normalizedSubject.contains('english')) {
      // Default to English alphabet if subject is related to English
      return _generateEnglishAlphabetFlashcards(subject, age, language, count);
    } else if (normalizedSubject.contains('bahasa') || normalizedSubject.contains('malay')) {
      // Default to Malay letters if subject is related to Bahasa Malaysia
      return _generateMalayLettersFlashcards(subject, age, language, count);
    } else if (normalizedSubject.contains('math') || normalizedSubject.contains('matematik')) {
      // Default to counting if subject is related to Math
      return _generateCountingFlashcards(subject, age, language, count);
    } else if (normalizedSubject.contains('jawi')) {
      // Default to Jawi letters if subject is related to Jawi
      return _generateJawiLettersFlashcards(subject, age, language, count);
    } else if (normalizedSubject.contains('iqraa') || normalizedSubject.contains('hijaiyah')) {
      // Default to Hijaiyah letters if subject is related to Iqraa/Arabic
      return _generateHijaiyahLettersFlashcards(subject, age, language, count);
    } else {
      // Generic flashcards for any subject
      List<Map<String, dynamic>> genericFlashcards = [
        {
          'title': 'Learning $subject',
          'letter': subject.isNotEmpty ? subject[0].toUpperCase() + subject[0].toLowerCase() : 'Aa',
          'image_asset': 'assets/flashcards/generic/learning.png',
          'description': 'Let\'s learn about $subject together!',
        },
        {
          'title': 'Exploring',
          'letter': 'Ee',
          'image_asset': 'assets/flashcards/generic/exploring.png',
          'description': 'Exploring new things helps us learn and grow.',
        },
        {
          'title': 'Discovery',
          'letter': 'Dd',
          'image_asset': 'assets/flashcards/generic/discovery.png',
          'description': 'Discovering new ideas is exciting!',
        },
        {
          'title': 'Knowledge',
          'letter': 'Kk',
          'image_asset': 'assets/flashcards/generic/knowledge.png',
          'description': 'Knowledge helps us understand the world better.',
        },
        {
          'title': 'Questions',
          'letter': 'Qq',
          'image_asset': 'assets/flashcards/generic/questions.png',
          'description': 'Asking questions helps us learn more.',
        },
      ];
      
      return genericFlashcards.take(count).toList();
    }
  }
}
