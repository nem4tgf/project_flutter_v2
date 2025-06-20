import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart'; // Import this for deep collection comparison if needed for debugging

import '../services/auth_service.dart';
import '../models/enrollment.dart';

class EnrollmentService {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080/api/enrollments' : 'http://10.24.26.179:8080/api/enrollments';
  final AuthService _authService;

  EnrollmentService(this._authService);

  Future<Enrollment> enrollUser(int userId, int lessonId) async {
    try {
      final body = jsonEncode({
        'userId': userId,
        'lessonId': lessonId,
      });

      if (kDebugMode) {
        print('POST $_baseUrl/enroll: $body');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/enroll'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Enroll user response: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
      }

      if (response.statusCode == 200) {
        // Đảm bảo giải mã UTF-8 trước khi parse JSON
        return Enrollment.fromJson(json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
      } else {
        String errorMessage = 'Không thể đăng ký người dùng: ${response.statusCode}.';
        if (response.bodyBytes.isNotEmpty) {
          try {
            final errorData = json.decode(utf8.decode(response.bodyBytes));
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          } catch (e) {
            errorMessage += ' Phản hồi lỗi không phải JSON hợp lệ.';
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi đăng ký người dùng: $e');
      }
      rethrow;
    }
  }

  Future<List<Enrollment>> getEnrollmentsByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get enrollments by user ID response: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}');
      }

      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) { // Kiểm tra bodyBytes thay vì body
          return []; // Trả về danh sách rỗng nếu không có dữ liệu
        }
        // Đảm bảo giải mã UTF-8 trước khi parse JSON
        final decodedBody = json.decode(utf8.decode(response.bodyBytes));
        if (decodedBody is List) {
          return decodedBody
              .map((e) => Enrollment.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Định dạng phản hồi không hợp lệ: Không phải danh sách.');
        }
      } else {
        String errorMessage = 'Không thể tải danh sách đăng ký: ${response.statusCode}.';
        if (response.bodyBytes.isNotEmpty) {
          try {
            final errorData = json.decode(utf8.decode(response.bodyBytes));
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          } catch (e) {
            errorMessage += ' Phản hồi lỗi không phải JSON hợp lệ.';
          }
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('Lỗi kết nối HTTP khi lấy danh sách đăng ký: $e');
      }
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng hoặc thử lại sau.');
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tải danh sách đăng ký: $e');
      }
      rethrow;
    }
  }
}