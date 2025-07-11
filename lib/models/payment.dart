import 'package:decimal/decimal.dart';
import 'package:collection/collection.dart';
import 'package:flutter_auth_app/models/user.dart';

enum PaymentStatus {
  PENDING,
  COMPLETED,
  FAILED,
  REFUNDED,
}

PaymentStatus? paymentStatusFromString(String? status) {
  if (status == null) return null;
  return PaymentStatus.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toUpperCase() == status.toUpperCase(),
  );
}

class PaymentRequest {
  final int userId;
  final int orderId;
  final Decimal amount;
  final String paymentMethod;
  final String? description;
  final String cancelUrl;
  final String successUrl;

  PaymentRequest({
    required this.userId,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    this.description,
    required this.cancelUrl,
    required this.successUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'orderId': orderId,
      'amount': amount.toString(),
      'paymentMethod': paymentMethod,
      'description': description,
      'cancelUrl': cancelUrl,
      'successUrl': successUrl,
    };
  }
}

class PaymentResponse {
  final int? paymentId;
  final UserResponse? user;
  final int? orderId;
  final Decimal? amount;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? transactionId;
  final PaymentStatus? status;
  final String? description;

  PaymentResponse({
    this.paymentId,
    this.user,
    this.orderId,
    this.amount,
    this.paymentDate,
    this.paymentMethod,
    this.transactionId,
    this.status,
    this.description,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      paymentId: json['paymentId'] as int?,
      user: json['user'] != null ? UserResponse.fromJson(json['user'] as Map<String, dynamic>) : null,
      orderId: json['orderId'] as int?,
      amount: json['amount'] != null ? Decimal.parse(json['amount'].toString()) : null,
      paymentDate: json['paymentDate'] != null ? DateTime.parse(json['paymentDate'] as String) : null,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      status: paymentStatusFromString(json['status'] as String?),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'user': user?.toJson(),
      'orderId': orderId,
      'amount': amount?.toString(),
      'paymentDate': paymentDate?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': status?.toString().split('.').last,
      'description': description,
    };
  }

  bool get isError => paymentId == null;
}

class PaymentSearchRequest {
  final int? userId;
  final int? orderId;
  final PaymentStatus? status;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Decimal? minAmount;
  final Decimal? maxAmount;
  final String? paymentMethod;
  final String? transactionId;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  PaymentSearchRequest({
    this.userId,
    this.orderId,
    this.status,
    this.minDate,
    this.maxDate,
    this.minAmount,
    this.maxAmount,
    this.paymentMethod,
    this.transactionId,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : page = page != null && page >= 0 ? page : 0,
        size = size != null && size > 0 ? size : 10,
        sortBy = sortBy != null &&
            ['paymentId', 'userId', 'orderId', 'amount', 'paymentDate', 'status', 'transactionId'].contains(sortBy)
            ? sortBy
            : 'paymentId',
        sortDir = sortDir != null && ['ASC', 'DESC'].contains(sortDir.toUpperCase()) ? sortDir : 'ASC';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    };
    if (userId != null) json['userId'] = userId;
    if (orderId != null) json['orderId'] = orderId;
    if (status != null) json['status'] = status.toString().split('.').last;
    if (minDate != null) json['minDate'] = minDate!.toIso8601String(); // Sửa null safety
    if (maxDate != null) json['maxDate'] = maxDate!.toIso8601String(); // Sửa null safety
    if (minAmount != null) json['minAmount'] = minAmount.toString();
    if (maxAmount != null) json['maxAmount'] = maxAmount.toString();
    if (paymentMethod != null && paymentMethod!.isNotEmpty) json['paymentMethod'] = paymentMethod;
    if (transactionId != null && transactionId!.isNotEmpty) json['transactionId'] = transactionId;
    return json;
  }
}

class PaymentPageResponse {
  final List<PaymentResponse> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  PaymentPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory PaymentPageResponse.fromJson(Map<String, dynamic> json) {
    return PaymentPageResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => PaymentResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: json['totalPages'] as int,
      page: json['page'] as int,
      size: json['size'] as int,
    );
  }
}