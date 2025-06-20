// lib/services/flashcard_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/flashcard.dart'; // Đảm bảo import model FlashcardResponse đã được sửa

class FlashcardService {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080/api/flashcards' : 'http://192.168.2.8:8080/api/flashcards';
  final AuthService _authService;

  FlashcardService(this._authService);

  Future<List<FlashcardResponse>> getFlashcards(int userId, int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lesson/$lessonId/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get flashcards response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => FlashcardResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Không thể lấy flashcard: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lấy flashcard: $e');
      }
      rethrow;
    }
  }

  // Phương thức mới để đánh dấu flashcard
  Future<UserFlashcardResponse> markFlashcard(UserFlashcardRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/mark'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Mark flashcard response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return UserFlashcardResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Không thể đánh dấu flashcard: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi đánh dấu flashcard: $e');
      }
      rethrow;
    }
  }

}