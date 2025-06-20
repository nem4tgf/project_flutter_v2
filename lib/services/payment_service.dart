import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/payment_reponse.dart';
import '../services/auth_service.dart';
import '../services/enrollment_service.dart';
import '../models/payment_request.dart';
import '../models/order_detail.dart';

class PaymentService {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080/api/payments' : 'http://10.24.26.179:8080/api/payments';
  final String _orderDetailsUrl = kIsWeb ? 'http://localhost:8080/api/order-details' : 'http://10.24.26.179:8080/api/order-details';
  final AuthService _authService;
  final EnrollmentService _enrollmentService;

  PaymentService(this._authService, this._enrollmentService);

  Future<String> initiatePayPalPayment(PaymentRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl/paypal/initiate');
      final body = json.encode(request.toJson());

      if (kDebugMode) {
        print('POST $url: $body');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Initiate PayPal response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return response.body;
      }
      throw Exception('Không thể khởi tạo thanh toán PayPal: ${response.statusCode} - ${response.body}');
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khởi tạo PayPal: $e');
      }
      rethrow;
    }
  }

  Future<PaymentResponse> completePayPalPayment(String paymentId, String payerId) async {
    try {
      final url = Uri.parse('$_baseUrl/paypal/complete?paymentId=$paymentId&PayerID=$payerId');

      if (kDebugMode) {
        print('GET $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Complete PayPal response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        final paymentResponse = PaymentResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
        await _checkEnrollment(paymentResponse.orderId);
        return paymentResponse;
      }
      throw Exception('Không thể hoàn tất thanh toán PayPal: ${response.statusCode} - ${response.body}');
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi hoàn tất PayPal: $e');
      }
      rethrow;
    }
  }

  Future<void> _checkEnrollment(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_orderDetailsUrl/order/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Check order details response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        final orderDetails = (json.decode(response.body) as List<dynamic>)
            .map((e) => OrderDetail.fromJson(e as Map<String, dynamic>))
            .toList();
        for (var detail in orderDetails) {
          await _enrollmentService.enrollUser(_authService.userId!, detail.lesson.lessonId);
        }
      } else {
        throw Exception('Không thể kiểm tra chi tiết đơn hàng: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi kiểm tra đăng ký: $e');
      }
      rethrow;
    }
  }

  Future<PaymentResponse> getPaymentById(int paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get payment response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return PaymentResponse.fromJson(json.decode(response.body) as Map<String, dynamic>);
      }
      throw Exception('Không thể tải thông tin thanh toán: ${response.statusCode} - ${response.body}');
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tải thanh toán: $e');
      }
      rethrow;
    }
  }

  Future<List<PaymentResponse>> getPaymentsByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get payments by user response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => PaymentResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Không thể tải danh sách thanh toán: ${response.statusCode} - ${response.body}');
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tải danh sách thanh toán: $e');
      }
      rethrow;
    }
  }
}