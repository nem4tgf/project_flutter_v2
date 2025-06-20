import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/learning_material.dart'; // Đảm bảo import model LearningMaterial

class LearningMaterialService {
  // Base URL cho API learning-materials, tương tự như flashcards
  final String _baseUrl = kIsWeb ? 'http://localhost:8080/api/learning-materials' : 'http://192.168.2.8:8080/api/learning-materials';
  final AuthService _authService;

  LearningMaterialService(this._authService);

  // Lấy danh sách tài liệu học tập theo ID bài học
  Future<List<LearningMaterial>> getLearningMaterialsByLessonId(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lesson/$lessonId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get learning materials response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => LearningMaterial.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        // Cung cấp thông báo lỗi chi tiết hơn nếu có thể từ body
        String errorMessage = 'Không thể tải tài liệu học tập: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage += ' - ${errorBody['message']}';
          }
        } catch (_) {
          errorMessage += ' - ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tải tài liệu học tập: $e');
      }
      rethrow;
    }
  }
}