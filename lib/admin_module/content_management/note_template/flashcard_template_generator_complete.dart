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
    return _generateEnglishAlphabetFlashcards(subject, age, language, count);
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
}
