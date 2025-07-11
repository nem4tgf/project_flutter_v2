import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/speaking_attemp.dart';
import './auth_service.dart';

class SpeakingAttemptService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  SpeakingAttemptService(this._authService);

  Map<String, String> _getAuthHeaders({bool requireAuth = true}) {
    if (requireAuth && !_authService.isAuthenticated) {
      throw Exception('Người dùng chưa được xác thực. Vui lòng đăng nhập lại.');
    }
    final headers = {'Content-Type': 'application/json'};
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
        throw Exception('$defaultMessage. Mã trạng thái: ${response.statusCode}');
      }
    } else {
      throw Exception('$defaultMessage. Mã trạng thái: ${response.statusCode}');
    }
  }

  /// Endpoint: POST /api/speaking-attempts
  /// USER và ADMIN
  Future<UserSpeakingAttemptResponse> saveSpeakingAttempt(UserSpeakingAttemptRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/speaking-attempts'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return UserSpeakingAttemptResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Lưu lần thử nói thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: PUT /api/speaking-attempts/{attemptId}
  /// Chỉ ADMIN
  Future<UserSpeakingAttemptResponse> updateSpeakingAttempt(int attemptId, UserSpeakingAttemptRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/speaking-attempts/$attemptId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return UserSpeakingAttemptResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật lần thử nói thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/speaking-attempts/{attemptId}
  /// USER (chỉ của chính mình) và ADMIN
  Future<UserSpeakingAttemptResponse> getSpeakingAttemptById(int attemptId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/speaking-attempts/$attemptId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return UserSpeakingAttemptResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải thông tin lần thử nói với ID: $attemptId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/speaking-attempts/user/{userId}
  /// USER (chỉ của chính mình) và ADMIN
  Future<List<UserSpeakingAttemptResponse>> getSpeakingAttemptsByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/speaking-attempts/user/$userId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => UserSpeakingAttemptResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách lần thử nói của người dùng ID: $userId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/speaking-attempts/practice-activity/{practiceActivityId}
  /// USER và ADMIN
  Future<List<UserSpeakingAttemptResponse>> getSpeakingAttemptsByPracticeActivity(int practiceActivityId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/speaking-attempts/practice-activity/$practiceActivityId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => UserSpeakingAttemptResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách lần thử nói cho hoạt động ID: $practiceActivityId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/speaking-attempts/search
  /// Chỉ ADMIN
  Future<UserSpeakingAttemptPageResponse> searchSpeakingAttempts({
    int? userId,
    int? practiceActivityId,
    int? minOverallScore,
    int? maxOverallScore,
    int page = 0,
    int size = 10,
  }) async {
    final queryParams = {
      if (userId != null) 'userId': userId.toString(),
      if (practiceActivityId != null) 'practiceActivityId': practiceActivityId.toString(),
      if (minOverallScore != null) 'minOverallScore': minOverallScore.toString(),
      if (maxOverallScore != null) 'maxOverallScore': maxOverallScore.toString(),
      'page': page.toString(),
      'size': size.toString(),
    };

    final response = await http.get(
      Uri.parse('$_baseUrl/api/speaking-attempts/search').replace(queryParameters: queryParams),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return UserSpeakingAttemptPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm lần thử nói thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: DELETE /api/speaking-attempts/{attemptId}
  /// Chỉ ADMIN
  Future<void> deleteSpeakingAttempt(int attemptId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/speaking-attempts/$attemptId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa lần thử nói thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}