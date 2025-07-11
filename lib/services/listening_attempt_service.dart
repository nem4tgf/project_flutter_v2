import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/listening_attempt_models.dart';
import './auth_service.dart';

class ListeningAttemptService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  ListeningAttemptService(this._authService);

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

  /// Endpoint: POST /api/listening-attempts
  /// USER và ADMIN
  Future<UserListeningAttemptResponse> saveListeningAttempt(UserListeningAttemptRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/listening-attempts'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return UserListeningAttemptResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Lưu lần thử nghe thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: PUT /api/listening-attempts/{attemptId}
  /// Chỉ ADMIN
  Future<UserListeningAttemptResponse> updateListeningAttempt(int attemptId, UserListeningAttemptRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/listening-attempts/$attemptId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return UserListeningAttemptResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật lần thử nghe thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/listening-attempts/{id}
  /// USER (chỉ của chính mình) và ADMIN
  Future<UserListeningAttemptResponse> getListeningAttemptById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/listening-attempts/$id'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return UserListeningAttemptResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải thông tin lần thử nghe với ID: $id.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/listening-attempts/user/{userId}
  /// USER (chỉ của chính mình) và ADMIN
  Future<List<UserListeningAttemptResponse>> getListeningAttemptsByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/listening-attempts/user/$userId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => UserListeningAttemptResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách lần thử nghe của người dùng ID: $userId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/listening-attempts/practice-activity/{practiceActivityId}
  /// USER và ADMIN
  Future<List<UserListeningAttemptResponse>> getListeningAttemptsByPracticeActivity(int practiceActivityId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/listening-attempts/practice-activity/$practiceActivityId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => UserListeningAttemptResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách lần thử nghe cho hoạt động ID: $practiceActivityId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/listening-attempts/search
  /// Chỉ ADMIN
  Future<UserListeningAttemptPageResponse> searchListeningAttempts({
    int? userId,
    int? practiceActivityId,
    int? minAccuracyScore,
    int? maxAccuracyScore,
    int page = 0,
    int size = 10,
  }) async {
    final queryParams = {
      if (userId != null) 'userId': userId.toString(),
      if (practiceActivityId != null) 'practiceActivityId': practiceActivityId.toString(),
      if (minAccuracyScore != null) 'minAccuracyScore': minAccuracyScore.toString(),
      if (maxAccuracyScore != null) 'maxAccuracyScore': maxAccuracyScore.toString(),
      'page': page.toString(),
      'size': size.toString(),
    };

    final response = await http.get(
      Uri.parse('$_baseUrl/api/listening-attempts/search').replace(queryParameters: queryParams),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return UserListeningAttemptPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm lần thử nghe thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: DELETE /api/listening-attempts/{id}
  /// Chỉ ADMIN
  Future<void> deleteListeningAttempt(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/listening-attempts/$id'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa lần thử nghe thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}