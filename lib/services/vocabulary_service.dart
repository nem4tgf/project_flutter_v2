import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/vocabulary_models.dart';
import './auth_service.dart';

class VocabularyService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  VocabularyService(this._authService);

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

  /// Endpoint: POST /api/vocabulary
  /// Chỉ ADMIN
  Future<VocabularyResponse> createVocabulary(VocabularyRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/vocabulary'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return VocabularyResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tạo từ vựng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/vocabulary/{wordId}
  /// Công khai
  Future<VocabularyResponse> getVocabularyById(int wordId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/vocabulary/$wordId'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      return VocabularyResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải thông tin từ vựng với ID: $wordId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/vocabulary
  /// Công khai
  Future<VocabularyPageResponse> searchVocabularies({
    String? word,
    String? meaning,
    DifficultyLevel? difficultyLevel,
    int page = 0,
    int size = 10,
    String sortBy = 'wordId',
    String sortDir = 'ASC',
  }) async {
    final request = VocabularySearchRequest(
      word: word,
      meaning: meaning,
      difficultyLevel: difficultyLevel,
      page: page,
      size: size,
      sortBy: sortBy,
      sortDir: sortDir,
    );

    final response = await http.get(
      Uri.parse('$_baseUrl/api/vocabulary').replace(
        queryParameters: request.toJson().map((key, value) => MapEntry(key, value.toString())),
      ),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      return VocabularyPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm từ vựng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: PUT /api/vocabulary/{wordId}
  /// Chỉ ADMIN
  Future<VocabularyResponse> updateVocabulary(int wordId, VocabularyRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/vocabulary/$wordId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return VocabularyResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật từ vựng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: DELETE /api/vocabulary/{wordId}
  /// Chỉ ADMIN
  Future<void> deleteVocabulary(int wordId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/vocabulary/$wordId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa từ vựng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}