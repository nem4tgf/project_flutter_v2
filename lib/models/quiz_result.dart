// lib/models/quiz_result.dart
import 'package:flutter/material.dart'; // Thường không cần nhưng để đảm bảo

class QuizResultResponse {
  final int resultId;
  final int userId;
  final int quizId;
  final int score;
  final DateTime completedAt;

  QuizResultResponse({
    required this.resultId,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.completedAt,
  });

  factory QuizResultResponse.fromJson(Map<String, dynamic> json) {
    return QuizResultResponse(
      resultId: json['resultId'] as int,
      userId: json['userId'] as int,
      quizId: json['quizId'] as int,
      score: json['score'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resultId': resultId,
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}

// Thêm DTO cho QuizResultRequest
class QuizResultRequest {
  final int userId;
  final int quizId;
  final int score;

  QuizResultRequest({
    required this.userId,
    required this.quizId,
    required this.score,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'quizId': quizId,
      'score': score,
    };
  }
}