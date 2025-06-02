import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int ageGroup;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.ageGroup,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'questions': questions.map((q) => q.toJson()).toList(),
        'ageGroup': ageGroup,
      };

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
      ageGroup: json['ageGroup'] as int,
    );
  }

  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quiz.fromJson({
      'id': doc.id,
      ...data,
    });
  }
}

class QuizQuestion {
  final String question;
  final String imageUrl;
  final List<String> options;
  final int correctAnswer;

  QuizQuestion({
    required this.question,
    required this.imageUrl,
    required this.options,
    required this.correctAnswer,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'imageUrl': imageUrl,
        'options': options,
        'correctAnswer': correctAnswer,
      };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      imageUrl: json['imageUrl'] as String,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctAnswer: json['correctAnswer'] as int,
    );
  }
}
