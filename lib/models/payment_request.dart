import 'package:decimal/decimal.dart';
import 'user.dart';

class PaymentRequest {
  final int userId;
  final int orderId;
  final Decimal amount;
  final String paymentMethod;
  final String description;
  final String cancelUrl;
  final String successUrl;

  PaymentRequest({
    required this.userId,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.description,
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