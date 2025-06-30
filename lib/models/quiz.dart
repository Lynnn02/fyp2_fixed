import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final String subject;
  final String chapter;
  final int ageGroup;
  final Timestamp createdAt;
  
  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.subject,
    required this.chapter,
    required this.ageGroup,
    required this.createdAt,
  });
  
  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    List<QuizQuestion> questions = [];
    if (data['questions'] != null) {
      questions = (data['questions'] as List)
          .map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
          .toList();
    }
    
    return Quiz(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      questions: questions,
      subject: data['subject'] ?? '',
      chapter: data['chapter'] ?? '',
      ageGroup: data['ageGroup'] ?? 4,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'subject': subject,
      'chapter': chapter,
      'ageGroup': ageGroup,
      'createdAt': createdAt,
    };
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? imageUrl;
  
  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.imageUrl,
  });
  
  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
      imageUrl: map['imageUrl'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'imageUrl': imageUrl,
    };
  }
}
