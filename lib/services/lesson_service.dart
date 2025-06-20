import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/lesson.dart';

class LessonService {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080/api/lessons' : 'http://192.168.2.8:8080/api/lessons';
  final AuthService _authService;

  LessonService(this._authService);

  Future<List<Lesson>> fetchLessons() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Fetch lessons response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body) as List<dynamic>;
        return jsonList.map((json) => Lesson.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Fetch lessons error: $e');
      }
      rethrow;
    }
  }

  Future<Lesson> getLessonById(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$lessonId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get lesson response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return Lesson.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load lesson: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get lesson error: $e');
      }
      rethrow;
    }
  }
}