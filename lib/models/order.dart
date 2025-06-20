import 'package:decimal/decimal.dart';
import 'user.dart';
import 'order_detail.dart';

class Order {
  final int orderId;
  final User user;
  final DateTime orderDate;
  final Decimal totalAmount;
  final String status;
  final String? shippingAddress;
  final List<OrderDetail> items;

  Order({
    required this.orderId,
    required this.user,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    this.shippingAddress,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      orderDate: DateTime.parse(json['orderDate'] as String),
      totalAmount: Decimal.parse(json['totalAmount'].toString()),
      status: json['status'] as String,
      shippingAddress: json['shippingAddress'] as String?,
      items: (json['items'] as List)
          .map((itemJson) => OrderDetail.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'user': user.toJson(),
      'orderDate': orderDate.toIso8601String(),
      'totalAmount': totalAmount.toString(),
      'status': status,
      'shippingAddress': shippingAddress,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}