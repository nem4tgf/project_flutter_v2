import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/flashcard.dart';
import '../models/user_flashcard.dart';
import './auth_service.dart';

class FlashcardService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  FlashcardService(this._authService);

  Map<String, String> _getAuthHeaders() {
    if (!_authService.isAuthenticated) {
      throw Exception('Người dùng chưa được xác thực. Vui lòng đăng nhập lại.');
    }
    final headers = {'Content-Type': 'application/json'};
    if (_authService.token != null) {
      headers['Authorization'] = 'Bearer ${_authService.token}';
    }
    return headers;
  }

  void _handleErrorResponse(http.Response response, String defaultMessage) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      _authService.logout();
      throw Exception('Phiên đăng nhập đã hết hạn hoặc không có quyền truy cập. Vui lòng đăng nhập lại.');
    } else if (response.statusCode == 400) {
      try {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? defaultMessage);
      } catch (e) {
        throw Exception('$defaultMessage. Mã trạng thái: ${response.statusCode}');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Không tìm thấy tài nguyên. $defaultMessage');
    } else {
      throw Exception('$defaultMessage. Mã trạng thái: ${response.statusCode}');
    }
  }

  /// Endpoint: POST /api/flashcards
  /// USER và ADMIN
  Future<FlashcardResponse> createUserFlashcard(UserFlashcardRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/flashcards'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return FlashcardResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tạo flashcard người dùng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: GET /api/flashcards/{userFlashcardId}
  /// USER (chỉ của chính mình) và ADMIN
  Future<FlashcardResponse> getUserFlashcardById(int userFlashcardId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/flashcards/$userFlashcardId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return FlashcardResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải flashcard người dùng với ID: $userFlashcardId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: POST /api/flashcards/search
  /// USER (chỉ của chính mình) và ADMIN
  Future<FlashcardPageResponse> searchUserFlashcards(FlashcardSearchRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/flashcards/search'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return FlashcardPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm flashcard người dùng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: DELETE /api/flashcards/{userFlashcardId}
  /// USER (chỉ của chính mình) và ADMIN
  Future<void> deleteUserFlashcard(int userFlashcardId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/flashcards/$userFlashcardId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa flashcard người dùng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}