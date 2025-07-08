// import 'package:decimal/decimal.dart';
// import 'lesson.dart';
// import 'user.dart';
//
// class OrderDetail {
//   final int orderDetailId;
//   final int orderId;
//   final Lesson lesson;
//   final int quantity;
//   final Decimal priceAtPurchase;
//
//   OrderDetail({
//     required this.orderDetailId,
//     required this.orderId,
//     required this.lesson,
//     required this.quantity,
//     required this.priceAtPurchase,
//   });
//
//   factory OrderDetail.fromJson(Map<String, dynamic> json) {
//     return OrderDetail(
//       orderDetailId: json['orderDetailId'] as int,
//       orderId: json['orderId'] as int,
//       lesson: Lesson.fromJson(json['lesson'] as Map<String, dynamic>),
//       quantity: json['quantity'] as int,
//       priceAtPurchase: Decimal.parse(json['priceAtPurchase'].toString()),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'orderDetailId': orderDetailId,
//       'orderId': orderId,
//       'lesson': lesson.toJson(),
//       'quantity': quantity,
//       'priceAtPurchase': priceAtPurchase.toString(),
//     };
//   }
// }