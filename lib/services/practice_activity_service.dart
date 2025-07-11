import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/practice_activity.dart';
import './auth_service.dart';

class PracticeActivityService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  PracticeActivityService(this._authService);

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

  /// Endpoint: `POST /api/practice-activities`
  /// Chỉ ADMIN
  Future<PracticeActivityResponse> createPracticeActivity(PracticeActivityRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/practice-activities'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return PracticeActivityResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tạo hoạt động luyện tập thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/practice-activities/{activityId}`
  /// Công khai
  Future<PracticeActivityResponse> getPracticeActivityById(int activityId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/practice-activities/$activityId'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      return PracticeActivityResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải hoạt động luyện tập với ID: $activityId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/practice-activities/lesson/{lessonId}`
  /// Công khai
  Future<List<PracticeActivityResponse>> getPracticeActivitiesByLessonId(int lessonId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/practice-activities/lesson/$lessonId'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => PracticeActivityResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách hoạt động luyện tập cho bài học ID: $lessonId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/practice-activities`
  /// Công khai
  Future<List<PracticeActivityResponse>> getAllPracticeActivities() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/practice-activities'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => PracticeActivityResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách hoạt động luyện tập.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/practice-activities/search`
  /// Công khai
  Future<PracticeActivityPageResponse> searchPracticeActivities({
    int? lessonId,
    String? title,
    ActivitySkill? skill,
    ActivityType? activityType,
    int page = 0,
    int size = 10,
    String sortBy = 'activityId',
    String sortDir = 'ASC',
  }) async {
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDir': sortDir,
      if (lessonId != null) 'lessonId': lessonId.toString(),
      if (title != null && title.isNotEmpty) 'title': title,
      if (skill != null) 'skill': skill.toString().split('.').last,
      if (activityType != null) 'activityType': activityType.toString().split('.').last,
    };

    final uri = Uri.parse('$_baseUrl/api/practice-activities/search').replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _getAuthHeaders(requireAuth: false));

    if (response.statusCode == 200) {
      return PracticeActivityPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm hoạt động luyện tập thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PUT /api/practice-activities/{activityId}`
  /// Chỉ ADMIN
  Future<PracticeActivityResponse> updatePracticeActivity(int activityId, PracticeActivityRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/practice-activities/$activityId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return PracticeActivityResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật hoạt động luyện tập thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `DELETE /api/practice-activities/{activityId}`
  /// Chỉ ADMIN
  Future<void> deletePracticeActivity(int activityId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/practice-activities/$activityId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa hoạt động luyện tập thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}