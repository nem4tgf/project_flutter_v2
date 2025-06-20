import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/order.dart';

class OrderService {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080/api/orders' : 'http://10.24.26.179:8080/api/orders';
  final AuthService _authService;

  OrderService(this._authService);

  Future<Order> createOrder(int userId, List<Map<String, dynamic>> items) async {
    try {
      final requestBody = jsonEncode({
        'userId': userId,
        'items': items.map((item) => {'lessonId': item['lessonId'], 'quantity': item['quantity']}).toList(),
      });

      if (kDebugMode) {
        print('POST $_baseUrl: $requestBody');
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Create order response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 201) {
        return Order.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Create order error: $e');
      }
      rethrow;
    }
  }

  Future<Order> getOrderById(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get order response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return Order.fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get order error: $e');
      }
      rethrow;
    }
  }

  Future<List<Order>> getOrdersByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Get orders by user response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get orders by user error: $e');
      }
      rethrow;
    }
  }
}