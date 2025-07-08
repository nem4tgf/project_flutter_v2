// lib/services/user_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Để dùng kIsWeb
import 'package:http/http.dart' as http;
// Không cần Provider.of ở đây, vì nó được inject qua constructor
// import 'package:provider/provider.dart';

// Import các model DTO
import '../models/user.dart'; // Chứa Role enum
import '../models/user_response_models.dart'; // Chứa UserResponse, UserPageResponse, UserSearchRequest, UserUpdateRequest
import '../models/auth_models.dart'; // Chứa RegisterRequest (cho adminCreateUser)

import 'auth_service.dart'; // Import AuthService để lấy token và gọi updateCurrentUser

class UserService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService; // Dependency injection của AuthService

  UserService(this._authService); // Constructor nhận AuthService

  // Phương thức lấy headers với token từ AuthService
  Map<String, String> _getAuthHeaders() {
    if (!_authService.isAuthenticated) {
      // Nếu không được xác thực, có thể đăng xuất hoặc ném lỗi để xử lý ở UI
      // Đây là một ví dụ, bạn có thể chọn cách xử lý phù hợp nhất
      throw Exception('Người dùng chưa được xác thực. Vui lòng đăng nhập lại.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_authService.token}',
    };
  }

  // Endpoint: GET /api/users
  // Chỉ ADMIN mới có quyền truy cập.
  Future<List<UserResponse>> getAllUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => UserResponse.fromJson(item)).toList();
    } else if (response.statusCode == 401) {
      _authService.logout(); // Token hết hạn, tự động đăng xuất
      throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền truy cập chức năng này.');
    } else {
      throw Exception('Không thể tải danh sách người dùng: ${response.statusCode}');
    }
  }

  // Endpoint: GET /api/users/{userId}
  // Cả USER và ADMIN đều có quyền. USER chỉ được xem thông tin của chính mình.
  Future<UserResponse> getUserById(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/$userId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return UserResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      _authService.logout();
      throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền xem thông tin người dùng này.');
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy người dùng với ID: $userId');
    } else {
      throw Exception('Không thể tải thông tin người dùng: ${response.statusCode}');
    }
  }

  // Endpoint: PUT /api/users/{userId}
  // Cả USER và ADMIN đều có quyền. USER chỉ có thể cập nhật thông tin của chính mình.
  Future<UserResponse> updateUser(int userId, UserUpdateRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/users/$userId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()), // toJson() sẽ loại bỏ các trường null
    );

    if (response.statusCode == 200) {
      final updatedUser = UserResponse.fromJson(json.decode(response.body));
      // Nếu người dùng hiện tại tự cập nhật, cập nhật lại currentUser trong AuthService
      if (_authService.currentUser?.userId == updatedUser.userId) {
        await _authService.updateCurrentUser(updatedUser); // <-- Gọi phương thức công khai trong AuthService
      }
      return updatedUser;
    } else if (response.statusCode == 401) {
      _authService.logout();
      throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền cập nhật người dùng này.');
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Cập nhật người dùng thất bại. Vui lòng kiểm tra lại thông tin.');
    } else {
      throw Exception('Cập nhật người dùng thất bại: ${response.statusCode}');
    }
  }

  // Endpoint: DELETE /api/users/{userId}
  // Chỉ ADMIN mới có quyền.
  Future<void> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/users/$userId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) { // HttpStatus.NO_CONTENT
      // Thành công
    } else if (response.statusCode == 401) {
      _authService.logout();
      throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền xóa người dùng này.');
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy người dùng với ID: $userId');
    } else {
      throw Exception('Xóa người dùng thất bại: ${response.statusCode}');
    }
  }

  // Endpoint: POST /api/users/search
  // Chỉ ADMIN mới có quyền.
  Future<UserPageResponse> searchUsers(UserSearchRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/search'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return UserPageResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      _authService.logout();
      throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền tìm kiếm người dùng.');
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Tìm kiếm người dùng thất bại.');
    } else {
      throw Exception('Tìm kiếm người dùng thất bại: ${response.statusCode}');
    }
  }

  // Endpoint: POST /api/users/admin-create
  // Chỉ ADMIN mới có quyền.
  Future<UserResponse> adminCreateUser(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/admin-create'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) { // HttpStatus.CREATED
      return UserResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      _authService.logout();
      throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền tạo người dùng mới.');
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Tạo người dùng thất bại. Vui lòng kiểm tra lại thông tin.');
    } else {
      throw Exception('Tạo người dùng thất bại: ${response.statusCode}');
    }
  }
}