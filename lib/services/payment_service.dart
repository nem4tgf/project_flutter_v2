import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/payment.dart';
import './auth_service.dart';

class PaymentService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  PaymentService(this._authService);

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

  /// Endpoint: `POST /api/payments`
  /// Chỉ ADMIN
  Future<PaymentResponse> createPayment(PaymentRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/payments'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return PaymentResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tạo thanh toán thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/payments/{id}`
  /// Chỉ ADMIN
  Future<PaymentResponse> getPaymentById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/payments/$id'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return PaymentResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải thanh toán với ID: $id.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/payments`
  /// Chỉ ADMIN
  Future<List<PaymentResponse>> getAllPayments() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/payments'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => PaymentResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách thanh toán.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/payments/user/{userId}`
  /// USER và ADMIN
  Future<List<PaymentResponse>> getPaymentsByUserId(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/payments/user/$userId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => PaymentResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải thanh toán của người dùng ID: $userId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `DELETE /api/payments/{id}`
  /// Chỉ ADMIN
  Future<void> deletePayment(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/payments/$id'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa thanh toán thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `POST /api/payments/search`
  /// Chỉ ADMIN
  Future<PaymentPageResponse> searchPayments(PaymentSearchRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/payments/search'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return PaymentPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm thanh toán thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `POST /api/payments/paypal/initiate`
  /// USER và ADMIN
  Future<String> initiatePayPalPayment(PaymentRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/payments/paypal/initiate'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      _handleErrorResponse(response, 'Khởi tạo thanh toán PayPal thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/payments/paypal/complete`
  Future<PaymentResponse> completePayPalPayment(String paymentId, String payerId) async {
    final queryParams = {
      'paymentId': paymentId,
      'PayerID': payerId,
    };
    final uri = Uri.parse('$_baseUrl/api/payments/paypal/complete').replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _getAuthHeaders(requireAuth: false));

    if (response.statusCode == 200) {
      return PaymentResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Hoàn tất thanh toán PayPal thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/payments/paypal/cancel`
  Future<String> cancelPayPalPayment(String token) async {
    final queryParams = {'token': token};
    final uri = Uri.parse('$_baseUrl/api/payments/paypal/cancel').replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _getAuthHeaders(requireAuth: false));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      _handleErrorResponse(response, 'Hủy thanh toán PayPal thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}