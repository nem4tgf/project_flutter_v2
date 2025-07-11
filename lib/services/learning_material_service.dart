import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/learning_material.dart';
import './auth_service.dart';

class LearningMaterialService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  LearningMaterialService(this._authService);

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
        throw Exception('$defaultMessage. Phản hồi lỗi: ${response.body}');
      }
    } else {
      throw Exception('$defaultMessage. Mã trạng thái: ${response.statusCode}');
    }
  }

  /// Endpoint: `POST /api/learning-materials`
  /// Chỉ ADMIN
  Future<LearningMaterialResponse> createLearningMaterial(LearningMaterialRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/learning-materials'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return LearningMaterialResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tạo tài liệu học tập thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/learning-materials/{materialId}`
  /// Truy cập công khai
  Future<LearningMaterialResponse> getLearningMaterialById(int materialId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/learning-materials/$materialId'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      return LearningMaterialResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải tài liệu học tập với ID: $materialId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/learning-materials/lesson/{lessonId}`
  /// Truy cập công khai
  Future<List<LearningMaterialResponse>> getLearningMaterialsByLessonId(int lessonId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/learning-materials/lesson/$lessonId'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => LearningMaterialResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải tài liệu học tập cho bài học này.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PUT /api/learning-materials/{materialId}`
  /// Chỉ ADMIN
  Future<LearningMaterialResponse> updateLearningMaterial(int materialId, LearningMaterialRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/learning-materials/$materialId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return LearningMaterialResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật tài liệu học tập thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `DELETE /api/learning-materials/{materialId}`
  /// Chỉ ADMIN
  Future<void> deleteLearningMaterial(int materialId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/learning-materials/$materialId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa tài liệu học tập thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `POST /api/learning-materials/search`
  /// Chỉ ADMIN
  Future<PaginatedResponse<LearningMaterialResponse>> searchLearningMaterials(LearningMaterialSearchRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/learning-materials/search'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return PaginatedResponse.fromJson(
        json.decode(response.body),
            (json) => LearningMaterialResponse.fromJson(json),
      );
    } else {
      _handleErrorResponse(response, 'Tìm kiếm tài liệu học tập thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}