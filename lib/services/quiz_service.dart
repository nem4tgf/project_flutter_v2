// lib/services/quiz_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/quiz.dart'; // Import model QuizResponse và QuizRequest

class QuizService {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080/api/quizzes' : 'http://10.24.26.179:8080/api/quizzes';
  final AuthService _authService;

  QuizService(this._authService);

  // Lấy danh sách tất cả bài kiểm tra
  Future<List<QuizResponse>> getAllQuizzes() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get all quizzes response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => QuizResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Không thể tải tất cả bài kiểm tra: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tải tất cả bài kiểm tra: $e');
      }
      rethrow;
    }
  }

  // Lấy danh sách bài kiểm tra theo ID bài học (đã có)
  Future<List<QuizResponse>> getQuizzesByLessonId(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lesson/$lessonId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get quizzes by lessonId response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => QuizResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Không thể tải bài kiểm tra theo bài học: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tải bài kiểm tra theo bài học: $e');
      }
      rethrow;
    }
  }

  // Lấy bài kiểm tra theo ID
  Future<QuizResponse> getQuizById(int quizId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$quizId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get quiz by ID response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return QuizResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Không thể tải bài kiểm tra theo ID: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tải bài kiểm tra theo ID: $e');
      }
      rethrow;
    }
  }

  // Tạo bài kiểm tra mới
  Future<QuizResponse> createQuiz(QuizRequest request) async {
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
        print('Create quiz response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 201) { // HttpStatus.CREATED
        return QuizResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Không thể tạo bài kiểm tra: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tạo bài kiểm tra: $e');
      }
      rethrow;
    }
  }

  // Cập nhật bài kiểm tra
  Future<QuizResponse> updateQuiz(int quizId, QuizRequest request) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$quizId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Update quiz response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return QuizResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Không thể cập nhật bài kiểm tra: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi cập nhật bài kiểm tra: $e');
      }
      rethrow;
    }
  }

  // Xóa bài kiểm tra
  Future<void> deleteQuiz(int quizId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$quizId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Delete quiz response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode != 204) { // 204 No Content
        throw Exception('Không thể xóa bài kiểm tra: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi xóa bài kiểm tra: $e');
      }
      rethrow;
    }
  }
}