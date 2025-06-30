import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../models/note_content.dart';

// Export all methods to be used in flashcard_template_generator.dart
export 'missing_methods.dart';

// Implementation of missing methods for flashcard_template_generator.dart

// Generate Malay simple words flashcards
List<Map<String, dynamic>> _generateMalaySimpleWordsFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'Kucing',
      'letter': 'Kk',
      'description': 'Kucing adalah haiwan peliharaan yang comel.',
      'image_asset': 'assets/flashcards/malay/kucing.png',
    },
    {
      'title': 'Anjing',
      'letter': 'Aa',
      'description': 'Anjing adalah haiwan peliharaan yang setia.',
      'image_asset': 'assets/flashcards/malay/anjing.png',
    },
    {
      'title': 'Rumah',
      'letter': 'Rr',
      'description': 'Rumah adalah tempat kita tinggal.',
      'image_asset': 'assets/flashcards/malay/rumah.png',
    },
    {
      'title': 'Pokok',
      'letter': 'Pp',
      'description': 'Pokok memberikan kita udara segar.',
      'image_asset': 'assets/flashcards/malay/pokok.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

// Generate English alphabet flashcards
List<Map<String, dynamic>> _generateEnglishAlphabetFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'Apple',
      'letter': 'Aa',
      'description': 'A is for Apple. It is a red fruit.',
      'image_asset': 'assets/flashcards/english/apple.png',
    },
    {
      'title': 'Ball',
      'letter': 'Bb',
      'description': 'B is for Ball. We play with balls.',
      'image_asset': 'assets/flashcards/english/ball.png',
    },
    {
      'title': 'Cat',
      'letter': 'Cc',
      'description': 'C is for Cat. Cats say meow.',
      'image_asset': 'assets/flashcards/english/cat.png',
    },
    {
      'title': 'Dog',
      'letter': 'Dd',
      'description': 'D is for Dog. Dogs are friendly pets.',
      'image_asset': 'assets/flashcards/english/dog.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

// Generate English sight words flashcards
List<Map<String, dynamic>> _generateEnglishSightWordsFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'The',
      'letter': 'Tt',
      'description': 'The is a common word we use before nouns.',
      'image_asset': 'assets/flashcards/english/the.png',
    },
    {
      'title': 'And',
      'letter': 'Aa',
      'description': 'And is used to join words together.',
      'image_asset': 'assets/flashcards/english/and.png',
    },
    {
      'title': 'A',
      'letter': 'Aa',
      'description': 'A is used before singular nouns.',
      'image_asset': 'assets/flashcards/english/a.png',
    },
    {
      'title': 'To',
      'letter': 'Tt',
      'description': 'To shows direction or purpose.',
      'image_asset': 'assets/flashcards/english/to.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

// Generate counting flashcards
List<Map<String, dynamic>> _generateCountingFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'One',
      'letter': '1',
      'description': 'One apple.',
      'image_asset': 'assets/flashcards/math/one.png',
    },
    {
      'title': 'Two',
      'letter': '2',
      'description': 'Two bananas.',
      'image_asset': 'assets/flashcards/math/two.png',
    },
    {
      'title': 'Three',
      'letter': '3',
      'description': 'Three oranges.',
      'image_asset': 'assets/flashcards/math/three.png',
    },
    {
      'title': 'Four',
      'letter': '4',
      'description': 'Four strawberries.',
      'image_asset': 'assets/flashcards/math/four.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

// Generate shapes and patterns flashcards
List<Map<String, dynamic>> _generateShapesAndPatternsFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'Circle',
      'letter': 'Cc',
      'description': 'A circle is round like a ball.',
      'image_asset': 'assets/flashcards/math/circle.png',
    },
    {
      'title': 'Square',
      'letter': 'Ss',
      'description': 'A square has four equal sides.',
      'image_asset': 'assets/flashcards/math/square.png',
    },
    {
      'title': 'Triangle',
      'letter': 'Tt',
      'description': 'A triangle has three sides.',
      'image_asset': 'assets/flashcards/math/triangle.png',
    },
    {
      'title': 'Rectangle',
      'letter': 'Rr',
      'description': 'A rectangle has four sides, with opposite sides equal.',
      'image_asset': 'assets/flashcards/math/rectangle.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

// Generate gross motor skills flashcards
List<Map<String, dynamic>> _generateGrossMotorSkillsFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'Running',
      'letter': 'Rr',
      'description': 'Running is moving fast with your legs.',
      'image_asset': 'assets/flashcards/motor/running.png',
    },
    {
      'title': 'Jumping',
      'letter': 'Jj',
      'description': 'Jumping is pushing off the ground with both feet.',
      'image_asset': 'assets/flashcards/motor/jumping.png',
    },
    {
      'title': 'Hopping',
      'letter': 'Hh',
      'description': 'Hopping is jumping on one foot.',
      'image_asset': 'assets/flashcards/motor/hopping.png',
    },
    {
      'title': 'Skipping',
      'letter': 'Ss',
      'description': 'Skipping is stepping and hopping in a pattern.',
      'image_asset': 'assets/flashcards/motor/skipping.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

// Generate fine motor skills flashcards
List<Map<String, dynamic>> _generateFineMotorSkillsFlashcards(
    String subject, int age, String language, int count) {
  final List<Map<String, dynamic>> flashcards = [
    {
      'title': 'Drawing',
      'letter': 'Dd',
      'description': 'Drawing is making pictures with a pencil or crayon.',
      'image_asset': 'assets/flashcards/motor/drawing.png',
    },
    {
      'title': 'Cutting',
      'letter': 'Cc',
      'description': 'Cutting is using scissors to make shapes.',
      'image_asset': 'assets/flashcards/motor/cutting.png',
    },
    {
      'title': 'Beading',
      'letter': 'Bb',
      'description': 'Beading is putting beads on a string.',
      'image_asset': 'assets/flashcards/motor/beading.png',
    },
    {
      'title': 'Buttoning',
      'letter': 'Bb',
      'description': 'Buttoning is fastening buttons on clothes.',
      'image_asset': 'assets/flashcards/motor/buttoning.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

// Generate Jawi letters flashcards
List<Map<String, dynamic>> _generateJawiLettersFlashcards(
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
      'title': 'Tha',
      'letter': 'ث',
      'description': 'Tha adalah huruf keempat dalam abjad Jawi.',
      'image_asset': 'assets/flashcards/jawi/tha.png',
    },
  ];
  
  return flashcards.take(count).toList();
}

// Generate Jawi simple writing flashcards
List<Map<String, dynamic>> _generateJawiSimpleWritingFlashcards(
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
List<Map<String, dynamic>> _generateHijaiyahLettersFlashcards(
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
List<Map<String, dynamic>> _generateBasicIqraaReadingFlashcards(
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
List<Map<String, dynamic>> _generateAnimalFlashcards(
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