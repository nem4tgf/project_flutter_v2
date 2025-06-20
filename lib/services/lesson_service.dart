import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/lesson.dart';

class LessonService {
  // Thay đổi URL cơ sở cho môi trường development/production
  final String _baseUrl = kIsWeb
      ? 'http://localhost:8080/api/lessons' // Dành cho web
      : 'http://10.24.26.179:8080/api/lessons'; // Dành cho mobile (thay đổi IP nếu cần)
  final AuthService _authService;

  LessonService(this._authService);

  /// Lấy danh sách tất cả các bài học từ API.
  /// Bao gồm logic xử lý lỗi và log debug.
  Future<List<Lesson>> fetchLessons() async {
    try {
      final response = await http
          .get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          // Thêm token Authorization nếu người dùng đã đăng nhập
          if (_authService.token != null)
            'Authorization': 'Bearer ${_authService.token}',
        },
      )
          .timeout(const Duration(seconds: 30)); // Đặt timeout cho request

      if (kDebugMode) {
        print('Fetch lessons response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
        // Chuyển đổi mỗi phần tử JSON thành đối tượng Lesson
        return jsonList
            .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Ném ngoại lệ nếu phản hồi không thành công
        throw Exception(
            'Failed to load lessons: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Fetch lessons error: $e');
      }
      return []; // Trả về danh sách rỗng thay vì rethrow để tránh crash
    }
  }

  /// Lấy thông tin chi tiết một bài học theo ID.
  /// Bao gồm logic xử lý lỗi và log debug.
  Future<Lesson> getLessonById(int lessonId) async {
    try {
      final response = await http
          .get(
        Uri.parse('$_baseUrl/$lessonId'),
        headers: {
          'Content-Type': 'application/json',
          // Thêm token Authorization nếu người dùng đã đăng nhập
          if (_authService.token != null)
            'Authorization': 'Bearer ${_authService.token}',
        },
      )
          .timeout(const Duration(seconds: 30)); // Đặt timeout cho request

      if (kDebugMode) {
        print('Get lesson response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        // Chuyển đổi JSON thành đối tượng Lesson
        return Lesson.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        // Ném ngoại lệ nếu phản hồi không thành công
        throw Exception(
            'Failed to load lesson: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get lesson error: $e');
      }
      rethrow; // Re-throw cho trường hợp getLessonById để xử lý ở UI
    }
  }
}
