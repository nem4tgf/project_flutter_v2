import 'package:decimal/decimal.dart';
import 'package:collection/collection.dart';
import 'package:flutter_auth_app/models/user.dart';
import 'lesson.dart';

// --- Enum tương ứng với Order.OrderStatus của backend ---
enum OrderStatus {
  PENDING,
  COMPLETED,
  CANCELLED,
  // Thêm các trạng thái khác nếu backend có bổ sung
}

// Hàm tiện ích để chuyển đổi String sang OrderStatus
OrderStatus? orderStatusFromString(String? status) {
  if (status == null) return null;
  return OrderStatus.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toUpperCase() == status.toUpperCase(),
  );
}

// --- OrderItemRequest DTO ---
// Tương ứng với org.example.projetc_backend.dto.OrderItemRequest.java
class OrderItemRequest {
  final int lessonId;
  final int quantity;

  OrderItemRequest({
    required this.lessonId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'quantity': quantity,
    };
  }
}

// --- OrderRequest DTO ---
// Tương ứng với org.example.projetc_backend.dto.OrderRequest.java
class OrderRequest {
  final int userId;
  final List<OrderItemRequest> items;

  OrderRequest({
    required this.userId,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

// --- OrderDetail DTO ---
// Tương ứng với các trường trong OrderDetailResponse của backend
class OrderDetail {
  final int? orderDetailId; // Nullable để xử lý lỗi
  final int? orderId;
  final LessonResponse? lesson;
  final int? quantity;
  final Decimal? priceAtPurchase;

  OrderDetail({
    this.orderDetailId,
    this.orderId,
    this.lesson,
    this.quantity,
    this.priceAtPurchase,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderDetailId: json['orderDetailId'] as int?,
      orderId: json['orderId'] as int?,
      lesson: json['lesson'] != null ? LessonResponse.fromJson(json['lesson'] as Map<String, dynamic>) : null,
      quantity: json['quantity'] as int?,
      priceAtPurchase: json['priceAtPurchase'] != null ? Decimal.parse(json['priceAtPurchase'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderDetailId': orderDetailId,
      'orderId': orderId,
      'lesson': lesson?.toJson(),
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase?.toString(),
    };
  }

  // Kiểm tra xem response có phải là lỗi không
  bool get isError => orderDetailId == null;
}

// --- OrderResponse DTO ---
// Tương ứng với org.example.projetc_backend.dto.OrderResponse.java
class OrderResponse {
  final int? orderId; // Nullable để xử lý lỗi
  final UserResponse? user; // Sử dụng UserResponse từ user_response_models.dart
  final DateTime? orderDate;
  final Decimal? totalAmount;
  final OrderStatus? status;
  final String? shippingAddress;
  final List<OrderDetail>? items;

  OrderResponse({
    this.orderId,
    this.user,
    this.orderDate,
    this.totalAmount,
    this.status,
    this.shippingAddress,
    this.items,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: json['orderId'] as int?,
      user: json['user'] != null ? UserResponse.fromJson(json['user'] as Map<String, dynamic>) : null,
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate'] as String) : null,
      totalAmount: json['totalAmount'] != null ? Decimal.parse(json['totalAmount'].toString()) : null,
      status: orderStatusFromString(json['status'] as String?),
      shippingAddress: json['shippingAddress'] as String?,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
          .map((itemJson) => OrderDetail.fromJson(itemJson as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'user': user?.toJson(),
      'orderDate': orderDate?.toIso8601String(),
      'totalAmount': totalAmount?.toString(),
      'status': status?.toString().split('.').last,
      'shippingAddress': shippingAddress,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }

  // Kiểm tra xem response có phải là lỗi không
  bool get isError => orderId == null;
}

// --- OrderSearchRequest DTO ---
// Tương ứng với org.example.projetc_backend.dto.OrderSearchRequest.java
class OrderSearchRequest {
  final int? userId;
  final OrderStatus? status;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Decimal? minTotalAmount;
  final Decimal? maxTotalAmount;
  final String? username;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  OrderSearchRequest({
    this.userId,
    this.status,
    this.minDate,
    this.maxDate,
    this.minTotalAmount,
    this.maxTotalAmount,
    this.username,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : page = (page == null || page < 0) ? 0 : page,
        size = (size == null || size <= 0) ? 10 : size,
        sortBy = (sortBy == null || sortBy.isEmpty ||
            !(sortBy == 'orderId' ||
                sortBy == 'orderDate' ||
                sortBy == 'totalAmount' ||
                sortBy == 'status'))
            ? 'orderId'
            : sortBy,
        sortDir = (sortDir == null || sortDir.isEmpty ||
            !(sortDir.toUpperCase() == 'ASC' || sortDir.toUpperCase() == 'DESC'))
            ? 'ASC'
            : sortDir;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    };

    if (userId != null) json['userId'] = userId;
    if (status != null) json['status'] = status.toString().split('.').last;
    final minDate = this.minDate;
    if (minDate != null) json['minDate'] = minDate.toIso8601String();
    final maxDate = this.maxDate;
    if (maxDate != null) json['maxDate'] = maxDate.toIso8601String();
    if (minTotalAmount != null) json['minTotalAmount'] = minTotalAmount.toString();
    if (maxTotalAmount != null) json['maxTotalAmount'] = maxTotalAmount.toString();
    if (username != null && username!.isNotEmpty) json['username'] = username;

    return json;
  }
}

// --- OrderPageResponse DTO ---
// Tương ứng với Page<OrderResponse> của backend
class OrderPageResponse {
  final List<OrderResponse> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  OrderPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory OrderPageResponse.fromJson(Map<String, dynamic> json) {
    return OrderPageResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => OrderResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: json['totalPages'] as int,
      page: json['page'] as int,
      size: json['size'] as int,
    );
  }
}