import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';
import './auth_service.dart';

class QuizService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  QuizService(this._authService);

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

  /// Endpoint: `GET /api/quizzes`
  /// Công khai
  Future<List<QuizResponse>> getAllQuizzes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/quizzes'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => QuizResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách bài kiểm tra.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `POST /api/quizzes`
  /// Chỉ ADMIN
  Future<QuizResponse> createQuiz(QuizRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/quizzes'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return QuizResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tạo bài kiểm tra thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/quizzes/{quizId}`
  /// Công khai
  Future<QuizResponse> getQuizById(int quizId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/quizzes/$quizId'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      return QuizResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải bài kiểm tra với ID: $quizId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/quizzes/lesson/{lessonId}`
  /// Công khai
  Future<List<QuizResponse>> getQuizzesByLessonId(int lessonId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/quizzes/lesson/$lessonId'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => QuizResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách bài kiểm tra cho lesson ID: $lessonId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/quizzes/search`
  /// Công khai
  Future<QuizPageResponse> searchQuizzes({
    int? lessonId,
    String? title,
    QuizType? quizType,
    int page = 0,
    int size = 10,
    String sortBy = 'quizId',
    String sortDir = 'ASC',
  }) async {
    final request = QuizSearchRequest(
      lessonId: lessonId,
      title: title,
      quizType: quizType,
      page: page,
      size: size,
      sortBy: sortBy,
      sortDir: sortDir,
    );

    final uri = Uri.parse('$_baseUrl/api/quizzes/search').replace(queryParameters: request.toQueryParams());

    final response = await http.get(uri, headers: _getAuthHeaders(requireAuth: false));

    if (response.statusCode == 200) {
      return QuizPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm bài kiểm tra thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PUT /api/quizzes/{quizId}`
  /// Chỉ ADMIN
  Future<QuizResponse> updateQuiz(int quizId, QuizRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/quizzes/$quizId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return QuizResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật bài kiểm tra thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `DELETE /api/quizzes/{quizId}`
  /// Chỉ ADMIN
  Future<void> deleteQuiz(int quizId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/quizzes/$quizId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa bài kiểm tra thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}