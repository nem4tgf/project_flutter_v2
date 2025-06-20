import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/answer.dart'; // Import model AnswerResponse

class AnswerService {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080/api/answers' : 'http://10.24.26.179:8080/api/answers';
  final AuthService _authService;

  AnswerService(this._authService);

  // Lấy danh sách đáp án theo ID Câu hỏi (chỉ các đáp án đang hoạt động)
  Future<List<AnswerResponse>> getAnswersByQuestionId(int questionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/question/$questionId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get answers by questionId response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => AnswerResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Không thể tải đáp án theo Question ID: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tải đáp án theo Question ID: $e');
      }
      rethrow;
    }
  }

// Bạn có thể thêm các phương thức khác nếu cần, ví dụ: getAnswerById, searchAnswers
}