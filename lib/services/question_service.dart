import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import './auth_service.dart';

class QuestionService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  QuestionService(this._authService);

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

  /// Endpoint: `POST /api/questions`
  /// Chỉ ADMIN
  Future<QuestionResponse> createQuestion(QuestionRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/questions'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return QuestionResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tạo câu hỏi thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/questions/{questionId}`
  /// Công khai
  Future<QuestionResponse> getQuestionById(int questionId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/questions/$questionId'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      return QuestionResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải câu hỏi với ID: $questionId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/questions/quiz/{quizId}`
  /// Công khai
  Future<List<QuestionResponse>> getQuestionsByQuizId(int quizId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/questions/quiz/$quizId'),
      headers: _getAuthHeaders(requireAuth: false),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => QuestionResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách câu hỏi cho quiz ID: $quizId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/questions/search`
  /// Công khai
  Future<QuestionPageResponse> searchQuestions({
    int? quizId,
    String? questionText,
    QuestionType? questionType,
    int page = 0,
    int size = 10,
    String sortBy = 'questionId',
    String sortDir = 'ASC',
  }) async {
    final request = QuestionSearchRequest(
      quizId: quizId,
      questionText: questionText,
      questionType: questionType,
      page: page,
      size: size,
      sortBy: sortBy,
      sortDir: sortDir,
    );

    final uri = Uri.parse('$_baseUrl/api/questions/search').replace(queryParameters: request.toQueryParams());

    final response = await http.get(uri, headers: _getAuthHeaders(requireAuth: false));

    if (response.statusCode == 200) {
      return QuestionPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm câu hỏi thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PUT /api/questions/{questionId}`
  /// Chỉ ADMIN
  Future<QuestionResponse> updateQuestion(int questionId, QuestionRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/questions/$questionId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return QuestionResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật câu hỏi thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `DELETE /api/questions/{questionId}`
  /// Chỉ ADMIN
  Future<void> deleteQuestion(int questionId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/questions/$questionId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa câu hỏi thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}