import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart'; // Thêm UserUpdateRequest vào hide
import '../models/auth_models.dart';
import './auth_service.dart';

class UserService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  UserService(this._authService);

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

  /// Endpoint: GET /api/users
  /// Chỉ ADMIN
  Future<List<UserResponse>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => UserResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách người dùng.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/users/{userId}
  /// USER và ADMIN (USER chỉ xem được thông tin của chính mình)
  Future<UserResponse> getUserById(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/$userId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải thông tin người dùng với ID: $userId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/users/current
  /// Yêu cầu xác thực
  Future<UserResponse> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/current'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final user = UserResponse.fromJson(json.decode(response.body));
      await _authService.updateCurrentUser(user); // Cập nhật currentUser trong AuthService
      return user;
    } else {
      _handleErrorResponse(response, 'Không thể tải thông tin người dùng hiện tại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: PUT /api/users/{userId}
  /// USER và ADMIN (USER chỉ cập nhật được thông tin của chính mình)
  Future<UserResponse> updateUser(int userId, UserUpdateRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/users/$userId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final updatedUser = UserResponse.fromJson(json.decode(response.body));
      if (_authService.currentUser?.userId == updatedUser.userId) {
        await _authService.updateCurrentUser(updatedUser);
      }
      return updatedUser;
    } else {
      _handleErrorResponse(response, 'Cập nhật người dùng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: DELETE /api/users/{userId}
  /// Chỉ ADMIN
  Future<void> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/users/$userId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa người dùng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: POST /api/users/search
  /// Chỉ ADMIN
  Future<UserPageResponse> searchUsers({
    String? username,
    String? email,
    String? fullName,
    Role? role,
    int page = 0,
    int size = 10,
    String sortBy = 'userId',
    String sortDir = 'ASC',
  }) async {
    final request = UserSearchRequest(
      username: username,
      email: email,
      fullName: fullName,
      role: role,
      page: page,
      size: size,
      sortBy: sortBy,
      sortDir: sortDir,
    );

    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/search'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return UserPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm người dùng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: POST /api/users/admin-create
  /// Chỉ ADMIN
  Future<UserResponse> adminCreateUser(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/admin-create'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return UserResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tạo người dùng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}