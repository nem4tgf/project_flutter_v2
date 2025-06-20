import 'package:flutter/material.dart';

class QuestionResponse {
  final int questionId;
  final int quizId;
  final String questionText;
  final String skill;

  QuestionResponse({
    required this.questionId,
    required this.quizId,
    required this.questionText,
    required this.skill,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      questionId: json['questionId'] as int,
      quizId: json['quizId'] as int,
      questionText: json['questionText'] as String,
      skill: json['skill'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'quizId': quizId,
      'questionText': questionText,
      'skill': skill,
    };
  }
}