import 'package:flutter_auth_app/models/lesson.dart';

/// Lớp Enrollment đại diện cho một đăng ký khóa học của người dùng.
/// Chứa thông tin về ID đăng ký, người dùng, bài học đã đăng ký,
/// ngày đăng ký, ngày hết hạn và trạng thái.
class Enrollment {
  final int enrollmentId;
  final int userId;
  final String userName;
  final Lesson? lesson; // Đã sửa: Làm cho Lesson có thể null để phù hợp với dữ liệu API
  final DateTime enrollmentDate;
  final DateTime expiryDate;
  final String status;

  Enrollment({
    required this.enrollmentId,
    required this.userId,
    required this.userName,
    this.lesson, // Có thể null
    required this.enrollmentDate,
    required this.expiryDate,
    required this.status,
  });

  /// Factory constructor để tạo một đối tượng Enrollment từ một Map JSON.
  /// Đặc biệt xử lý trường 'lesson' có thể là null.
  factory Enrollment.fromJson(Map<String, dynamic> json) {
    // Debugging print để kiểm tra cấu trúc JSON
    // print('Processing Enrollment JSON: $json');

    // Kiểm tra và xử lý trường 'lesson' có thể là null
    Lesson? parsedLesson;
    if (json['lesson'] != null) {
      try {
        parsedLesson = Lesson.fromJson(json['lesson'] as Map<String, dynamic>);
      } catch (e) {
        // In ra lỗi nếu không thể phân tích Lesson, nhưng vẫn tiếp tục
        // với phần còn lại của Enrollment
        print('Error parsing lesson for enrollment ${json['enrollmentId']}: $e');
        parsedLesson = null; // Gán null nếu có lỗi phân tích
      }
    }

    return Enrollment(
      enrollmentId: json['enrollmentId'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      lesson: parsedLesson, // Sử dụng parsedLesson đã kiểm tra null
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      status: json['status'] as String,
    );
  }

  /// Chuyển đổi đối tượng Enrollment thành Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'enrollmentId': enrollmentId,
      'userId': userId,
      'userName': userName,
      'lesson': lesson?.toJson(), // Sử dụng ?. để tránh lỗi nếu lesson là null
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'status': status,
    };
  }
}
