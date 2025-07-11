import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/enrollment.dart';
import './auth_service.dart';

class EnrollmentService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  EnrollmentService(this._authService);

  Map<String, String> _getAuthHeaders() {
    if (!_authService.isAuthenticated) {
      throw Exception('Người dùng chưa được xác thực. Vui lòng đăng nhập lại.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_authService.token}',
    };
  }

  void _handleErrorResponse(http.Response response, String defaultMessage) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      _authService.logout();
      throw Exception('Phiên đăng nhập đã hết hạn hoặc không có quyền truy cập. Vui lòng đăng nhập lại.');
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      try {
        final error = json.decode(response.body);
        if (error is Map<String, dynamic> && error.containsKey('status')) {
          throw Exception(error['status'] ?? defaultMessage);
        }
        throw Exception(error['message'] ?? defaultMessage);
      } catch (e) {
        throw Exception('$defaultMessage. Phản hồi lỗi: ${response.body}');
      }
    } else {
      throw Exception('$defaultMessage. Mã trạng thái: ${response.statusCode}');
    }
  }

  Future<EnrollmentResponse> enrollUserInLesson(EnrollmentRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/enrollments'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return EnrollmentResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Đăng ký bài học thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  Future<EnrollmentResponse> getEnrollmentById(int enrollmentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/enrollments/$enrollmentId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return EnrollmentResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải thông tin đăng ký với ID: $enrollmentId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  Future<List<EnrollmentResponse>> getAllEnrollments() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/enrollments'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => EnrollmentResponse.fromJson(json)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải tất cả đăng ký.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  Future<List<EnrollmentResponse>> getEnrollmentsByUserId(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/enrollments/user/$userId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => EnrollmentResponse.fromJson(json)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải đăng ký cho người dùng ID: $userId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  Future<List<EnrollmentResponse>> getEnrollmentsByLessonId(int lessonId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/enrollments/lesson/$lessonId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => EnrollmentResponse.fromJson(json)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải đăng ký cho bài học ID: $lessonId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  Future<PaginatedResponse<EnrollmentResponse>> searchEnrollments(EnrollmentSearchRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/enrollments/search'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return PaginatedResponse.fromJson(
        json.decode(response.body),
            (jsonMap) => EnrollmentResponse.fromJson(jsonMap),
      );
    } else {
      _handleErrorResponse(response, 'Tìm kiếm đăng ký thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  Future<void> deleteEnrollment(int enrollmentId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/enrollments/$enrollmentId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa đăng ký thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}