import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/question.dart'; // Import model QuestionResponse

class QuestionService {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080/api/questions' : 'http://10.24.26.179:8080/api/questions';
  final AuthService _authService;

  QuestionService(this._authService);

  // Lấy danh sách câu hỏi theo ID Quiz
  Future<List<QuestionResponse>> getQuestionsByQuizId(int quizId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quiz/$quizId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get questions by quizId response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => QuestionResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Không thể tải câu hỏi theo Quiz ID: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tải câu hỏi theo Quiz ID: $e');
      }
      rethrow;
    }
  }

// Bạn có thể thêm các phương thức khác nếu cần, ví dụ: getQuestionById, searchQuestions
}