import 'package:flutter/material.dart';
import 'subjects/bahasa_malaysia/huruf_kata_asas.dart';
import 'subjects/bahasa_malaysia/perkataan_mudah.dart';
import 'subjects/english/alphabet_phonics.dart';
import 'subjects/english/sight_words.dart';
import 'subjects/math/counting.dart';
import 'subjects/math/shapes_patterns.dart';
import 'subjects/science/five_senses.dart';
import 'subjects/science/living_nonliving.dart';
import 'subjects/social_emotional/emotions_expressions.dart';
import 'subjects/social_emotional/sharing_cooperation.dart';
import 'subjects/art_craft/color_exploration.dart';
import 'subjects/art_craft/simple_patterns.dart';
import 'subjects/physical_development/gross_motor.dart';
import 'subjects/physical_development/fine_motor.dart';
import 'subjects/jawi/basic_letters.dart';
import 'subjects/jawi/simple_writing.dart';
import 'subjects/iqraa/hijaiyah_letters.dart';
import 'subjects/iqraa/basic_reading.dart';

/// Manager class for accessing all subject templates
class SubjectTemplateManager {
  /// Get content for a specific subject, chapter, and game type
  static Map<String, dynamic>? getTemplateContent({
    required String subjectName,
    required String chapterName,
    required String gameType,
    required int ageGroup,
    required int rounds,
  }) {
    print('🔍 SubjectTemplateManager: Looking for content');
    print('🔍 Subject: $subjectName, Chapter: $chapterName');
    print('🔍 Game Type: $gameType, Age: $ageGroup, Rounds: $rounds');
    
    // Normalize subject and chapter names for comparison
    final normalizedSubject = subjectName.toLowerCase().trim();
    final normalizedChapter = chapterName.toLowerCase().trim();
    
    print('🔍 Normalized Subject: $normalizedSubject');
    print('🔍 Normalized Chapter: $normalizedChapter');
    
    // Bahasa Malaysia - Huruf & Kata Asas
    // Handle both exact match and partial match
    if ((normalizedSubject == "bahasa malaysia" || 
         normalizedSubject.contains('bahasa') || 
         normalizedSubject.contains('malaysia') ||
         subjectName == "Bahasa Malaysia") && 
        (normalizedChapter == "huruf & kata asas" ||
         normalizedChapter.contains('huruf') || 
         normalizedChapter.contains('kata') || 
         normalizedChapter.contains('asas') ||
         chapterName == "Huruf & Kata Asas")) {
      print('✅ Found template match: Bahasa Malaysia - Huruf & Kata Asas');
      print('✅ Matched subject "$subjectName" to "Bahasa Malaysia"');
      print('✅ Matched chapter "$chapterName" to "Huruf & Kata Asas"');
      final content = HurufKataAsasTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Bahasa Malaysia - Perkataan Mudah
    if ((normalizedSubject == "bahasa malaysia" || 
         normalizedSubject.contains('bahasa') || 
         normalizedSubject.contains('malaysia') ||
         subjectName == "Bahasa Malaysia") && 
        (normalizedChapter == "perkataan mudah" ||
         normalizedChapter.contains('perkataan') || 
         normalizedChapter.contains('mudah') ||
         chapterName == "Perkataan Mudah")) {
      print('✅ Found template match: Bahasa Malaysia - Perkataan Mudah');
      print('✅ Matched subject "$subjectName" to "Bahasa Malaysia"');
      print('✅ Matched chapter "$chapterName" to "Perkataan Mudah"');
      final content = PerkataanMudahTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // English - Alphabet & Phonics
    if ((normalizedSubject == "english" || 
         normalizedSubject.contains('english') ||
         subjectName == "English") && 
        (normalizedChapter == "alphabet & phonics" ||
         normalizedChapter.contains('alphabet') || 
         normalizedChapter.contains('phonics') ||
         chapterName == "Alphabet & Phonics")) {
      print('✅ Found template match: English - Alphabet & Phonics');
      print('✅ Matched subject "$subjectName" to "English"');
      print('✅ Matched chapter "$chapterName" to "Alphabet & Phonics"');
      final content = AlphabetPhonicsTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // English - Sight Words
    if ((normalizedSubject == "english" || 
         normalizedSubject.contains('english') ||
         subjectName == "English") && 
        (normalizedChapter == "sight words" ||
         normalizedChapter.contains('sight') || 
         normalizedChapter.contains('words') ||
         chapterName == "Sight Words")) {
      print('✅ Found template match: English - Sight Words');
      print('✅ Matched subject "$subjectName" to "English"');
      print('✅ Matched chapter "$chapterName" to "Sight Words"');
      final content = SightWordsTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Math - Counting
    if ((normalizedSubject == "math" || 
         normalizedSubject.contains('math') ||
         subjectName == "Math") && 
        (normalizedChapter == "counting" ||
         normalizedChapter.contains('counting') || 
         normalizedChapter.contains('number') ||
         chapterName == "Counting")) {
      print('✅ Found template match: Math - Counting');
      print('✅ Matched subject "$subjectName" to "Math"');
      print('✅ Matched chapter "$chapterName" to "Counting"');
      final content = CountingTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Math - Shapes & Patterns
    if ((normalizedSubject == "math" || 
         normalizedSubject.contains('math') ||
         subjectName == "Math") && 
        (normalizedChapter == "shapes & patterns" ||
         normalizedChapter.contains('shapes') || 
         normalizedChapter.contains('patterns') ||
         chapterName == "Shapes & Patterns")) {
      print('✅ Found template match: Math - Shapes & Patterns');
      print('✅ Matched subject "$subjectName" to "Math"');
      print('✅ Matched chapter "$chapterName" to "Shapes & Patterns"');
      final content = ShapesPatternsTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Science - Five Senses
    if ((normalizedSubject == "science" || 
         normalizedSubject.contains('science') ||
         subjectName == "Science") && 
        (normalizedChapter == "five senses" ||
         normalizedChapter.contains('senses') || 
         normalizedChapter.contains('five') ||
         chapterName == "Five Senses")) {
      print('✅ Found template match: Science - Five Senses');
      print('✅ Matched subject "$subjectName" to "Science"');
      print('✅ Matched chapter "$chapterName" to "Five Senses"');
      final content = FiveSensesTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Science - Living vs Non-living Things
    if ((normalizedSubject == "science" || 
         normalizedSubject.contains('science') ||
         subjectName == "Science") && 
        (normalizedChapter == "living vs non-living things" ||
         normalizedChapter.contains('living') || 
         normalizedChapter.contains('non-living') ||
         chapterName == "Living vs Non-living Things")) {
      print('✅ Found template match: Science - Living vs Non-living Things');
      print('✅ Matched subject "$subjectName" to "Science"');
      print('✅ Matched chapter "$chapterName" to "Living vs Non-living Things"');
      final content = LivingNonlivingTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Social & Emotional Learning - Emotions & Expressions
    if ((normalizedSubject == "social & emotional learning" || 
         normalizedSubject.contains('social') ||
         normalizedSubject.contains('emotional') ||
         subjectName == "Social & Emotional Learning") && 
        (normalizedChapter == "emotions & expressions" ||
         normalizedChapter.contains('emotions') || 
         normalizedChapter.contains('expressions') ||
         chapterName == "Emotions & Expressions")) {
      print('✅ Found template match: Social & Emotional Learning - Emotions & Expressions');
      print('✅ Matched subject "$subjectName" to "Social & Emotional Learning"');
      print('✅ Matched chapter "$chapterName" to "Emotions & Expressions"');
      final content = EmotionsExpressionsTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Social & Emotional Learning - Sharing & Cooperation
    if ((normalizedSubject == "social & emotional learning" || 
         normalizedSubject.contains('social') ||
         normalizedSubject.contains('emotional') ||
         subjectName == "Social & Emotional Learning") && 
        (normalizedChapter == "sharing & cooperation" ||
         normalizedChapter.contains('sharing') || 
         normalizedChapter.contains('cooperation') ||
         chapterName == "Sharing & Cooperation")) {
      print('✅ Found template match: Social & Emotional Learning - Sharing & Cooperation');
      print('✅ Matched subject "$subjectName" to "Social & Emotional Learning"');
      print('✅ Matched chapter "$chapterName" to "Sharing & Cooperation"');
      final content = SharingCooperationTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Art & Craft - Color Exploration
    if ((normalizedSubject == "art & craft" || 
         normalizedSubject.contains('art') ||
         normalizedSubject.contains('craft') ||
         subjectName == "Art & Craft") && 
        (normalizedChapter == "color exploration" ||
         normalizedChapter.contains('color') || 
         normalizedChapter.contains('exploration') ||
         chapterName == "Color Exploration")) {
      print('✅ Found template match: Art & Craft - Color Exploration');
      print('✅ Matched subject "$subjectName" to "Art & Craft"');
      print('✅ Matched chapter "$chapterName" to "Color Exploration"');
      final content = ColorExplorationTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Art & Craft - Simple Lines & Patterns
    if ((normalizedSubject == "art & craft" || 
         normalizedSubject.contains('art') ||
         normalizedSubject.contains('craft') ||
         subjectName == "Art & Craft") && 
        (normalizedChapter == "simple lines & patterns" ||
         normalizedChapter.contains('simple') || 
         normalizedChapter.contains('lines') ||
         normalizedChapter.contains('patterns') ||
         chapterName == "Simple Lines & Patterns")) {
      print('✅ Found template match: Art & Craft - Simple Lines & Patterns');
      print('✅ Matched subject "$subjectName" to "Art & Craft"');
      print('✅ Matched chapter "$chapterName" to "Simple Lines & Patterns"');
      final content = SimplePatternsTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Physical Development - Gross Motor Skills
    if ((normalizedSubject == "physical development" || 
         normalizedSubject.contains('physical') ||
         normalizedSubject.contains('development') ||
         subjectName == "Physical Development") && 
        (normalizedChapter == "gross motor skills" ||
         normalizedChapter.contains('gross') || 
         normalizedChapter.contains('motor') ||
         chapterName == "Gross Motor Skills")) {
      print('✅ Found template match: Physical Development - Gross Motor Skills');
      print('✅ Matched subject "$subjectName" to "Physical Development"');
      print('✅ Matched chapter "$chapterName" to "Gross Motor Skills"');
      final content = GrossMotorTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Physical Development - Fine Motor Skills
    if ((normalizedSubject == "physical development" || 
         normalizedSubject.contains('physical') ||
         normalizedSubject.contains('development') ||
         subjectName == "Physical Development") && 
        (normalizedChapter == "fine motor skills" ||
         normalizedChapter.contains('fine') || 
         normalizedChapter.contains('motor') ||
         chapterName == "Fine Motor Skills")) {
      print('✅ Found template match: Physical Development - Fine Motor Skills');
      print('✅ Matched subject "$subjectName" to "Physical Development"');
      print('✅ Matched chapter "$chapterName" to "Fine Motor Skills"');
      final content = FineMotorTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Jawi - Basic Letters
    if ((normalizedSubject == "jawi" || 
         normalizedSubject.contains('jawi') ||
         subjectName == "Jawi") && 
        (normalizedChapter == "basic letters" ||
         normalizedChapter.contains('basic') || 
         normalizedChapter.contains('letters') ||
         chapterName == "Basic Letters")) {
      print('✅ Found template match: Jawi - Basic Letters');
      print('✅ Matched subject "$subjectName" to "Jawi"');
      print('✅ Matched chapter "$chapterName" to "Basic Letters"');
      final content = JawiBasicLettersTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Jawi - Simple Writing
    if ((normalizedSubject == "jawi" || 
         normalizedSubject.contains('jawi') ||
         subjectName == "Jawi") && 
        (normalizedChapter == "simple writing" ||
         normalizedChapter.contains('simple') || 
         normalizedChapter.contains('writing') ||
         chapterName == "Simple Writing")) {
      print('✅ Found template match: Jawi - Simple Writing');
      print('✅ Matched subject "$subjectName" to "Jawi"');
      print('✅ Matched chapter "$chapterName" to "Simple Writing"');
      final content = JawiSimpleWritingTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Iqraa - Hijaiyah Letters
    if ((normalizedSubject == "iqraa" || 
         normalizedSubject.contains('iqraa') ||
         subjectName == "Iqraa") && 
        (normalizedChapter == "hijaiyah letters" ||
         normalizedChapter.contains('hijaiyah') || 
         normalizedChapter.contains('letters') ||
         chapterName == "Hijaiyah Letters")) {
      print('✅ Found template match: Iqraa - Hijaiyah Letters');
      print('✅ Matched subject "$subjectName" to "Iqraa"');
      print('✅ Matched chapter "$chapterName" to "Hijaiyah Letters"');
      final content = HijaiyahLettersTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // Iqraa - Basic Reading
    if ((normalizedSubject == "iqraa" || 
         normalizedSubject.contains('iqraa') ||
         subjectName == "Iqraa") && 
        (normalizedChapter == "basic reading" ||
         normalizedChapter.contains('basic') || 
         normalizedChapter.contains('reading') ||
         chapterName == "Basic Reading")) {
      print('✅ Found template match: Iqraa - Basic Reading');
      print('✅ Matched subject "$subjectName" to "Iqraa"');
      print('✅ Matched chapter "$chapterName" to "Basic Reading"');
      final content = IqraaBasicReadingTemplate.getContent(gameType, ageGroup, rounds);
      print('📦 Content returned: ${content != null ? 'YES' : 'NO'}');
      return content;
    }
    
    // No matching template found
    print('❌ Template currently not available and will be added in the future for subject: "$subjectName", chapter: "$chapterName"');
    return null;
  }
  
  /// Get list of available subjects
  static List<String> getAvailableSubjects() {
    return [
      'Bahasa Malaysia',
      'English',
      'Math',
      'Science',
      'Social & Emotional Learning',
      'Art & Craft',
      'Physical Development',
      'Jawi',
      'Iqraa',
    ];
  }
  
  /// Get list of chapters for a specific subject
  static List<String> getChaptersForSubject(String subjectName) {
    final normalizedSubject = subjectName.toLowerCase().trim();
    
    if (normalizedSubject.contains('bahasa malaysia')) {
      return [
        'Huruf & Kata Asas',
        'Perkataan Mudah',
      ];
    }
    
    if (normalizedSubject.contains('english')) {
      return [
        'Alphabet & Phonics',
        'Sight Words',
      ];
    }
    
    if (normalizedSubject.contains('math')) {
      return [
        'Counting',
        'Shapes & Patterns',
      ];
    }
    
    if (normalizedSubject.contains('science')) {
      return [
        'Five Senses',
        'Living vs Non-living Things',
      ];
    }
    
    if (normalizedSubject.contains('social') || normalizedSubject.contains('emotional')) {
      return [
        'Emotions & Expressions',
        'Sharing & Cooperation',
      ];
    }
    
    if (normalizedSubject.contains('art') || normalizedSubject.contains('craft')) {
      return [
        'Color Exploration',
        'Simple Lines & Patterns',
      ];
    }
    
    if (normalizedSubject.contains('physical') || normalizedSubject.contains('development')) {
      return [
        'Gross Motor Skills',
        'Fine Motor Skills',
      ];
    }
    
    if (normalizedSubject.contains('jawi')) {
      return [
        'Basic Letters',
        'Simple Writing',
      ];
    }
    
    if (normalizedSubject.contains('iqraa')) {
      return [
        'Hijaiyah Letters',
        'Basic Reading',
      ];
    }
    
    return [];
  }
  
  /// Get list of subjects that still need to be implemented
  static List<String> getRemainingSubjectsToImplement() {
    return [
      'Islamic Studies',
    ];
  }
}
