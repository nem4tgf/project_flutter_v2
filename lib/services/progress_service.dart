import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/progress.dart';
import './auth_service.dart';

class ProgressService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  ProgressService(this._authService);

  Map<String, String> _getAuthHeaders({bool requireAuth = true}) {
    if (requireAuth && !_authService.isAuthenticated) {
      throw Exception('Người dùng chưa được xác thực. Vui lòng đăng nhập lại.');
    }
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authService.token != null && requireAuth) {
      headers['Authorization'] = 'Bearer ${_authService.token}';
    }
    return headers;
  }

  void _handleErrorResponse(http.Response response, String defaultMessage) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      _authService.logout();
      throw Exception('Phiên đăng nhập đã hết hạn hoặc không có quyền truy cập. Vui lòng đăng nhập lại.');
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      try {
        final errorBody = json.decode(response.body);
        String errorMessage = errorBody['message'] ?? defaultMessage;
        throw Exception(errorMessage);
      } catch (e) {
        // Backend trả về null body cho 400/404
        throw Exception('$defaultMessage. Mã trạng thái: ${response.statusCode}');
      }
    } else {
      throw Exception('$defaultMessage. Mã trạng thái: ${response.statusCode}');
    }
  }

  /// Endpoint: `POST /api/progress`
  /// USER và ADMIN
  Future<ProgressResponse> createProgress(ProgressRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/progress'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return ProgressResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tạo tiến độ thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PUT /api/progress/{progressId}`
  /// USER và ADMIN
  Future<ProgressResponse> updateProgress(int progressId, ProgressRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/progress/$progressId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ProgressResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật tiến độ thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/progress/user/{userId}/lesson/{lessonId}/activity/{activityType}`
  /// USER và ADMIN
  Future<ProgressResponse> getProgressByActivity(int userId, int lessonId, ActivityType activityType) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/progress/user/$userId/lesson/$lessonId/activity/${activityType.toString().split('.').last}'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return ProgressResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải tiến độ cho user ID: $userId, lesson ID: $lessonId, activity type: $activityType.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/progress/user/{userId}/lesson/{lessonId}/overall`
  /// USER và ADMIN
  Future<ProgressResponse> getOverallLessonProgress(int userId, int lessonId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/progress/user/$userId/lesson/$lessonId/overall'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return ProgressResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải tiến độ tổng thể cho user ID: $userId, lesson ID: $lessonId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/progress/user/{userId}`
  /// USER và ADMIN
  Future<List<ProgressResponse>> getProgressByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/progress/user/$userId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => ProgressResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách tiến độ cho user ID: $userId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `DELETE /api/progress/{progressId}`
  /// Chỉ ADMIN
  Future<void> deleteProgress(int progressId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/progress/$progressId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa tiến độ thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `POST /api/progress/search`
  /// Chỉ ADMIN
  Future<ProgressPageResponse> searchProgress(ProgressSearchRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/progress/search'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ProgressPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm tiến độ thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}