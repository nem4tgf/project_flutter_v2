import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/lesson.dart';
import './auth_service.dart';

class LessonService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  LessonService(this._authService);

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

  /// Endpoint: `POST /api/lessons`
  /// Chỉ ADMIN
  Future<LessonResponse> createLesson(LessonRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/lessons'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return LessonResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tạo bài học thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/lessons/{lessonId}`
  /// Truy cập công khai
  Future<LessonResponse> getLessonById(int lessonId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/lessons/$lessonId'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      return LessonResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải bài học với ID: $lessonId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/lessons`
  /// Truy cập công khai
  Future<List<LessonResponse>> getAllActiveLessons() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/lessons'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => LessonResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách bài học.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PUT /api/lessons/{lessonId}`
  /// Chỉ ADMIN
  Future<LessonResponse> updateLesson(int lessonId, LessonRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/lessons/$lessonId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return LessonResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật bài học thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `DELETE /api/lessons/{lessonId}/soft`
  /// Chỉ ADMIN
  Future<void> softDeleteLesson(int lessonId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/lessons/$lessonId/soft'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa bài học thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PATCH /api/lessons/{lessonId}/restore`
  /// Chỉ ADMIN
  Future<LessonResponse> restoreLesson(int lessonId) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/api/lessons/$lessonId/restore'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return LessonResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Khôi phục bài học thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `POST /api/lessons/search`
  /// Truy cập công khai
  Future<LessonPageResponse> searchLessons(LessonSearchRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/lessons/search'),
      headers: _getAuthHeaders(requireAuth: false),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return LessonPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm bài học thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}