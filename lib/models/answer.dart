import 'package:flutter/material.dart';

class AnswerResponse {
  final int answerId;
  final int questionId;
  final String answerText;
  final bool isCorrect;
  final bool isActive;
  final bool isDeleted; // Thêm trường này nếu cần hiển thị trạng thái xóa mềm

  AnswerResponse({
    required this.answerId,
    required this.questionId,
    required this.answerText,
    required this.isCorrect,
    required this.isActive,
    required this.isDeleted,
  });

  factory AnswerResponse.fromJson(Map<String, dynamic> json) {
    return AnswerResponse(
      answerId: json['answerId'] as int,
      questionId: json['questionId'] as int,
      answerText: json['content'] as String, // Backend trả về 'content'
      isCorrect: json['isCorrect'] as bool,
      isActive: json['isActive'] as bool,
      isDeleted: json['isDeleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answerId': answerId,
      'questionId': questionId,
      'content': answerText,
      'isCorrect': isCorrect,
      'isActive': isActive,
      'isDeleted': isDeleted,
    };
  }
}