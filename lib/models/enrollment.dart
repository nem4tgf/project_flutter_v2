import 'lesson.dart';
// KHÔNG CẦN import 'user.dart'; nếu bạn không nhúng User object nữa

class Enrollment {
  final int enrollmentId;
  // BỎ TRƯỜNG user: final User user;
  final int userId; // <--- THÊM TRƯỜNG NÀY
  final String userName; // <--- THÊM TRƯỜNG NÀY

  final Lesson lesson;
  final DateTime enrollmentDate;
  final DateTime expiryDate;
  final String status;

  Enrollment({
    required this.enrollmentId,
    // BỎ user: required this.user,
    required this.userId, // <--- THÊM VÀO CONSTRUCTOR
    required this.userName, // <--- THÊM VÀO CONSTRUCTOR
    required this.lesson,
    required this.enrollmentDate,
    required this.expiryDate,
    required this.status,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      enrollmentId: json['enrollmentId'] as int,
      // BỎ user: user: User.fromJson(json['user'] as Map<String, dynamic>),
      userId: json['userId'] as int, // <--- ĐỌC TRỰC TIẾP userId
      userName: json['userName'] as String, // <--- ĐỌC TRỰC TIẾP userName
      lesson: Lesson.fromJson(json['lesson'] as Map<String, dynamic>),
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrollmentId': enrollmentId,
      // BỎ user: 'user': user.toJson(),
      'userId': userId, // <--- THÊM userId VÀO toJson
      'userName': userName, // <--- THÊM userName VÀO toJson
      'lesson': lesson.toJson(),
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'status': status,
    };
  }
}