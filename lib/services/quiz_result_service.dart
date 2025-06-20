// lib/services/quiz_result_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/quiz_result.dart'; // Import model QuizResultResponse và QuizResultRequest

class QuizResultService {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080/api/quiz-results' : 'http://192.168.2.8:8080/api/quiz-results';
  final AuthService _authService;

  QuizResultService(this._authService);

  // Lưu kết quả bài kiểm tra
  Future<QuizResultResponse> saveQuizResult(QuizResultRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Save quiz result response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) { // Backend trả về 200, nhưng 201 cũng hợp lệ cho tạo mới
        return QuizResultResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Không thể lưu kết quả bài kiểm tra: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lưu kết quả bài kiểm tra: $e');
      }
      rethrow;
    }
  }

  // Lấy kết quả bài kiểm tra theo User ID và Quiz ID
  Future<QuizResultResponse> getQuizResultByUserAndQuiz(int userId, int quizId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId/quiz/$quizId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get quiz result by user and quiz response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return QuizResultResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Không tìm thấy kết quả bài kiểm tra cho user/quiz này: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lấy kết quả bài kiểm tra theo user/quiz: $e');
      }
      rethrow;
    }
  }

  // Lấy tất cả kết quả bài kiểm tra của một người dùng
  Future<List<QuizResultResponse>> getQuizResultsByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get quiz results by user response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => QuizResultResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Không thể tải kết quả bài kiểm tra của người dùng: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tải kết quả bài kiểm tra của người dùng: $e');
      }
      rethrow;
    }
  }

  // Lấy tất cả kết quả cho một bài kiểm tra cụ thể
  Future<List<QuizResultResponse>> getQuizResultsByQuiz(int quizId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quiz/$quizId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get quiz results by quiz response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => QuizResultResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Không thể tải kết quả bài kiểm tra theo quiz: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tải kết quả bài kiểm tra theo quiz: $e');
      }
      rethrow;
    }
  }
}