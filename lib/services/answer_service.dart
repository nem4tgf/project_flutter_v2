// lib/services/answer_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Để dùng kIsWeb
import 'package:http/http.dart' as http;

import '../models/answer.dart';
import 'auth_service.dart';


class AnswerService extends ChangeNotifier {
  // *******************************************************************
  // * QUAN TRỌNG: VUI LÒNG CẬP NHẬT URL NÀY VỚI URL Ngrok MỚI NHẤT CỦA BẠN HOẶC IP BACKEND! *
  // * URL Ngrok miễn phí thay đổi mỗi khi bạn khởi động lại Ngrok.    *
  // * Hãy kiểm tra terminal Ngrok hoặc địa chỉ IP của máy chủ backend.  *
  // *******************************************************************
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';

  final AuthService _authService; // Khai báo AuthService để sử dụng

  // Constructor để nhận AuthService khi AnswerService được khởi tạo
  AnswerService(this._authService);

  // Phương thức private để lấy headers xác thực, sử dụng _authService
  Map<String, String> _getAuthHeaders() {
    // Kiểm tra xem người dùng đã xác thực chưa
    if (!_authService.isAuthenticated) {
      throw Exception('Người dùng chưa được xác thực. Vui lòng đăng nhập lại.');
    }
    // Lấy token từ AuthService và trả về headers
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_authService.token}',
    };
  }

  // Phương thức private chung để xử lý phản hồi lỗi từ API, tương tự AuthService
  void _handleErrorResponse(http.Response response, String defaultMessage) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      // Nếu là lỗi 401/403, đăng xuất người dùng thông qua AuthService
      _authService.logout();
      throw Exception('Phiên đăng nhập đã hết hạn hoặc không có quyền truy cập. Vui lòng đăng nhập lại.');
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      try {
        final error = json.decode(response.body);
        String errorMessage = error['content'] ?? error['message'] ?? defaultMessage;
        throw Exception(errorMessage);
      } catch (e) {
        // Nếu không parse được JSON lỗi, hoặc lỗi khác trong quá trình xử lý error body
        throw Exception('$defaultMessage. Phản hồi lỗi: ${response.body}');
      }
    } else {
      // Các lỗi server khác (5xx) hoặc không xác định
      throw Exception('$defaultMessage. Mã trạng thái: ${response.statusCode}');
    }
  }

  // --- Các phương thức gọi API cho Answer ---

  /// Endpoint: `POST /api/answers`
  /// Tạo một câu trả lời mới.
  /// Yêu cầu quyền ADMIN.
  Future<AnswerResponse> createAnswer(AnswerRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/answers'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) { // HttpStatus.CREATED
      return AnswerResponse.fromJson(json.decode(response.body));
    } else {
      // _handleErrorResponse đã tự throw Exception, không cần rethrow ở đây
      _handleErrorResponse(response, 'Tạo câu trả lời thất bại.');
      // Dòng code dưới đây sẽ không bao giờ được chạy vì _handleErrorResponse đã throw
      // nhưng việc thêm 'return Future.error(...)' là một cách tường minh hơn
      // để đảm bảo hàm luôn trả về một Future khi có lỗi.
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/answers/{answerId}`
  /// Lấy thông tin một câu trả lời theo ID.
  /// Có thể truy cập công khai.
  Future<AnswerResponse> getAnswerById(int answerId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/answers/$answerId'),
      headers: _getAuthHeaders(), // Vẫn cần headers nếu backend yêu cầu token dù là GET công khai
    );

    if (response.statusCode == 200) {
      return AnswerResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải câu trả lời với ID: $answerId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/answers/question/{questionId}/active`
  /// Lấy danh sách các câu trả lời đang hoạt động (active=true) và chưa bị xóa mềm của một câu hỏi.
  /// Dành cho người dùng cuối.
  Future<List<AnswerResponse>> getActiveAnswersByQuestionId(int questionId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/answers/question/$questionId/active'),
      headers: _getAuthHeaders(), // Vẫn cần headers nếu backend yêu cầu token
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => AnswerResponse.fromJson(json)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải các câu trả lời đang hoạt động cho câu hỏi ID: $questionId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/answers/question/{questionId}/admin`
  /// Lấy tất cả các câu trả lời (kể cả không hoạt động nhưng chưa bị xóa mềm) của một câu hỏi.
  /// Yêu cầu quyền ADMIN.
  Future<List<AnswerResponse>> getAllAnswersForAdminByQuestionId(int questionId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/answers/question/$questionId/admin'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => AnswerResponse.fromJson(json)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải tất cả câu trả lời cho admin với câu hỏi ID: $questionId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PUT /api/answers/{answerId}`
  /// Cập nhật thông tin một câu trả lời.
  /// Yêu cầu quyền ADMIN.
  Future<AnswerResponse> updateAnswer(int answerId, AnswerRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/answers/$answerId'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return AnswerResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật câu trả lời thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PATCH /api/answers/{answerId}/status?newStatus={newStatus}`
  /// Thay đổi trạng thái hoạt động (active/inactive) của một câu trả lời.
  /// Yêu cầu quyền ADMIN.
  Future<AnswerResponse> toggleAnswerStatus(int answerId, bool newStatus) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/api/answers/$answerId/status?newStatus=$newStatus'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return AnswerResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Thay đổi trạng thái câu trả lời thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `DELETE /api/answers/{answerId}/soft`
  /// Xóa mềm (soft delete) một câu trả lời.
  /// Yêu cầu quyền ADMIN.
  Future<void> softDeleteAnswer(int answerId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/answers/$answerId/soft'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) { // HttpStatus.NO_CONTENT
      return; // Thành công
    } else {
      _handleErrorResponse(response, 'Xóa mềm câu trả lời thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PATCH /api/answers/{answerId}/restore`
  /// Khôi phục một câu trả lời đã bị xóa mềm.
  /// Yêu cầu quyền ADMIN.
  Future<AnswerResponse> restoreAnswer(int answerId) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/api/answers/$answerId/restore'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return AnswerResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Khôi phục câu trả lời thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `POST /api/answers/search`
  /// Tìm kiếm câu trả lời với các tiêu chí và phân trang.
  /// Yêu cầu quyền ADMIN.
  Future<PaginatedResponse<AnswerResponse>> searchAnswers(AnswerSearchRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/answers/search'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return PaginatedResponse.fromJson(
        json.decode(response.body),
            (jsonMap) => AnswerResponse.fromJson(jsonMap),
      );
    } else {
      _handleErrorResponse(response, 'Tìm kiếm câu trả lời thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}