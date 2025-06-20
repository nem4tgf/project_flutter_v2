import 'package:decimal/decimal.dart';
import 'user.dart';

class PaymentResponse {
  final int paymentId;
  final User? user;
  final int orderId;
  final Decimal amount;
  final String paymentMethod;
  final String status;
  final DateTime paymentDate;
  final String transactionId;
  final String? description;

  PaymentResponse({
    required this.paymentId,
    this.user,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.paymentDate,
    required this.transactionId,
    this.description,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      paymentId: json['paymentId'] as int,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      orderId: json['orderId'] as int,
      amount: Decimal.parse(json['amount'].toString()),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      transactionId: json['transactionId'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'user': user?.toJson(),
      'orderId': orderId,
      'amount': amount.toString(),
      'paymentMethod': paymentMethod,
      'status': status,
      'paymentDate': paymentDate.toIso8601String(),
      'transactionId': transactionId,
      'description': description,
    };
  }
}