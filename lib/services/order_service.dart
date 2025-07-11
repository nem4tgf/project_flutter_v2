import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import './auth_service.dart';

class OrderService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://10.24.26.179:8080';
  final AuthService _authService;

  OrderService(this._authService);

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

  /// Endpoint: `POST /api/orders`
  /// USER và ADMIN
  Future<OrderResponse> createOrder(OrderRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/orders'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return OrderResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tạo đơn hàng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/orders/{id}`
  /// Chỉ ADMIN
  Future<OrderResponse> getOrderById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/orders/$id'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return OrderResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải đơn hàng với ID: $id.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/orders/all`
  /// Chỉ ADMIN
  Future<List<OrderResponse>> getAllOrders() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/orders/all'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => OrderResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách đơn hàng.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/orders/user/{userId}`
  /// USER (chỉ xem của chính mình) và ADMIN
  Future<List<OrderResponse>> getOrdersByUserId(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/orders/user/$userId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => OrderResponse.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải đơn hàng của người dùng ID: $userId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/orders/search`
  /// Chỉ ADMIN
  Future<OrderPageResponse> searchOrders(OrderSearchRequest request) async {
    final queryParams = request.toJson().map((key, value) => MapEntry(key, value.toString()));

    final uri = Uri.parse('$_baseUrl/api/orders/search').replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return OrderPageResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Tìm kiếm đơn hàng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PUT /api/orders/{id}/status`
  /// Chỉ ADMIN
  Future<OrderResponse> updateOrderStatus(int id, OrderStatus newStatus) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/orders/$id/status?status=${newStatus.toString().split('.').last}'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return OrderResponse.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật trạng thái đơn hàng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `DELETE /api/orders/{id}`
  /// Chỉ ADMIN
  Future<void> deleteOrder(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/orders/$id'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa đơn hàng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/order-details/{id}`
  /// Chỉ ADMIN
  Future<OrderDetail> getOrderDetailById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/order-details/$id'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return OrderDetail.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Không thể tải chi tiết đơn hàng với ID: $id.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/order-details/order/{orderId}`
  /// Chỉ ADMIN
  Future<List<OrderDetail>> getOrderDetailsByOrderId(int orderId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/order-details/order/$orderId'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => OrderDetail.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải chi tiết đơn hàng cho đơn hàng ID: $orderId.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `GET /api/order-details`
  /// Chỉ ADMIN
  Future<List<OrderDetail>> getAllOrderDetails() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/order-details'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => OrderDetail.fromJson(e)).toList();
    } else {
      _handleErrorResponse(response, 'Không thể tải danh sách chi tiết đơn hàng.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `PUT /api/order-details/{id}`
  /// Chỉ ADMIN
  Future<OrderDetail> updateOrderDetail(int id, OrderDetail request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/order-details/$id'),
      headers: _getAuthHeaders(),
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return OrderDetail.fromJson(json.decode(response.body));
    } else {
      _handleErrorResponse(response, 'Cập nhật chi tiết đơn hàng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }

  /// Endpoint: `DELETE /api/order-details/{id}`
  /// Chỉ ADMIN
  Future<void> deleteOrderDetail(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/order-details/$id'),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 204) {
      notifyListeners();
      return;
    } else {
      _handleErrorResponse(response, 'Xóa chi tiết đơn hàng thất bại.');
      return Future.error(Exception('Unknown error after _handleErrorResponse'));
    }
  }
}