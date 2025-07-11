import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/quiz_result.dart';
import './auth_service.dart';

class QuizResultService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  QuizResultService(this._authService);

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

  /// Endpoint: `POST /api/quiz-results`
  /// USER và ADMIN
  Future<QuizResultResponse> saveQuizResult(QuizResultRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/quiz-results'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return QuizResultResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Lưu kết quả bài kiểm tra thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PUT /api/quiz-results/{resultId}`
  /// Chỉ ADMIN
  Future<QuizResultResponse> updateQuizResult(int resultId, QuizResultRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/quiz-results/$resultId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return QuizResultResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật kết quả bài kiểm tra thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/quiz-results/user/{userId}/quiz/{quizId}`
  /// USER và ADMIN
  Future<QuizResultResponse> getQuizResultByUserAndQuiz(int userId, int quizId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/quiz-results/user/$userId/quiz/$quizId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return QuizResultResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải kết quả bài kiểm tra cho user ID: $userId, quiz ID: $quizId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/quiz-results/user/{userId}`
  /// USER và ADMIN
  Future<List<QuizResultResponse>> getQuizResultsByUser(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/quiz-results/user/$userId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => QuizResultResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách kết quả bài kiểm tra cho user ID: $userId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/quiz-results/quiz/{quizId}`
  /// Chỉ ADMIN
  Future<List<QuizResultResponse>> getQuizResultsByQuiz(int quizId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/quiz-results/quiz/$quizId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => QuizResultResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách kết quả bài kiểm tra cho quiz ID: $quizId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/quiz-results/search`
  /// Chỉ ADMIN
  Future<QuizResultPageResponse> searchQuizResults({
    int? userId,
    int? quizId,
    double? minScore,
    double? maxScore,
    int page = 0,
    int size = 10,
    String sortBy = 'resultId',
    String sortDir = 'ASC',
  }) async {
    final request = QuizResultSearchRequest(
      userId: userId,
      quizId: quizId,
      minScore: minScore,
      maxScore: maxScore,
      page: page,
      size: size,
      sortBy: sortBy,
      sortDir: sortDir,
    );

    final uri = Uri.parse('$_baseUrl/api/quiz-results/search').replace(queryParameters: request.toQueryParams());

    final response = await http.get(uri, headers: _getAuthHeaders());

    if (response.statusCode == 200) {
      return QuizResultPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm kết quả bài kiểm tra thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `DELETE /api/quiz-results/{resultId}`
  /// Chỉ ADMIN
  Future<void> deleteQuizResult(int resultId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/quiz-results/$resultId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa kết quả bài kiểm tra thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}