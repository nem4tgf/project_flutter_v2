// lib/models/quiz.dart
import 'package:flutter/material.dart'; // Thường không cần nhưng để đảm bảo

class QuizResponse {
  final int quizId;
  final int lessonId;
  final String title;
  final String skill;
  // final int? durationMinutes; // <<< BỎ TRƯỜNG NÀY ĐỂ KHỚP VỚI BACKEND DTO
  final DateTime createdAt;

  QuizResponse({
    required this.quizId,
    required this.lessonId,
    required this.title,
    required this.skill,
    // this.durationMinutes, // <<< BỎ TRƯỜNG NÀY
    required this.createdAt,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    return QuizResponse(
      quizId: json['quizId'] as int,
      lessonId: json['lessonId'] as int,
      title: json['title'] as String,
      skill: json['skill'] as String,
      // durationMinutes: json['durationMinutes'] as int?, // <<< BỎ TRƯỜNG NÀY
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'lessonId': lessonId,
      'title': title,
      'skill': skill,
      // 'durationMinutes': durationMinutes, // <<< BỎ TRƯỜNG NÀY
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Thêm DTO cho QuizRequest (Nếu bạn có ý định tạo/cập nhật Quiz từ Flutter)
class QuizRequest {
  final int lessonId;
  final String title;
  final String skill;

  QuizRequest({
    required this.lessonId,
    required this.title,
    required this.skill,
  });

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'title': title,
      'skill': skill,
    };
  }
}