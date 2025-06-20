// lib/services/progress_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/progress.dart'; // Import model ProgressResponse và ProgressRequest

class ProgressService {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080/api/progress' : 'http://192.168.2.8:8080/api/progress';
  final AuthService _authService;

  ProgressService(this._authService);

  /// Fetches the overall lesson progress for a specific user and lesson.
  /// This corresponds to the /user/{userId}/lesson/{lessonId}/overall endpoint.
  Future<ProgressResponse> getOverallLessonProgress(int userId, int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId/lesson/$lessonId/overall'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get overall lesson progress response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return ProgressResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        String errorMessage = 'Failed to load overall lesson progress: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage += ' - ${errorBody['message']}';
          }
        } catch (_) {
          // ignore
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading overall lesson progress: $e');
      }
      rethrow;
    }
  }

  /// Fetches the progress for a specific activity type within a lesson for a user.
  /// This corresponds to the /user/{userId}/lesson/{lessonId}/activity/{activityType} endpoint.
  Future<ProgressResponse> getProgressByActivity(int userId, int lessonId, String activityType) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId/lesson/$lessonId/activity/$activityType'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get progress by activity response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return ProgressResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        String errorMessage = 'Failed to load progress for activity type $activityType: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage += ' - ${errorBody['message']}';
          }
        } catch (_) {
          // ignore
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading progress for activity type: $e');
      }
      rethrow;
    }
  }

  /// Fetches all progress records for a given user.
  /// This endpoint remains the same.
  Future<List<ProgressResponse>> getProgressByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get progress by user response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => ProgressResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        String errorMessage = 'Failed to load all user progress: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage += ' - ${errorBody['message']}';
          }
        } catch (_) {
          // ignore
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading all user progress: $e');
      }
      rethrow;
    }
  }

  /// Updates or creates a progress record.
  /// This endpoint remains the same, but the request body now uses 'activityType'.
  Future<ProgressResponse> updateProgress(ProgressRequest request) async {
    try {
      final body = json.encode(request.toJson());

      if (kDebugMode) {
        print('POST $_baseUrl: $body');
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Update progress response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return ProgressResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        String errorMessage = 'Failed to update progress: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMessage += ' - ${errorBody['message']}';
          }
        } catch (_) {
          // ignore
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating progress: $e');
      }
      rethrow;
    }
  }
}
