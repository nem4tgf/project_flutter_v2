import 'package:decimal/decimal.dart'; // Đảm bảo import Decimal

/// Lớp Lesson đại diện cho một bài học trong ứng dụng.
/// Chứa các thông tin chi tiết về bài học như ID, tiêu đề, mô tả, cấp độ, kỹ năng, giá,
/// thời gian tạo, thời lượng (nếu có), trạng thái truy cập và thông tin đăng ký.
class Lesson {
  final int lessonId;
  final String title;
  final String description;
  final String level; // Sử dụng String để khớp với JSON từ backend
  final String skill; // Sử dụng String để khớp với JSON từ backend
  final Decimal price;
  final DateTime createdAt;
  final int? durationMonths; // Có thể null
  final bool isAccessible; // Trường này được thêm vào frontend để quản lý trạng thái truy cập
  final DateTime? expiryDate; // Có thể null, từ Enrollment
  final int? enrollmentId; // Có thể null, từ Enrollment

  Lesson({
    required this.lessonId,
    required this.title,
    required this.description,
    required this.level,
    required this.skill,
    required this.price,
    required this.createdAt,
    this.durationMonths,
    this.isAccessible = false, // Mặc định là false
    this.expiryDate,
    this.enrollmentId,
  });

  /// Factory constructor để tạo một đối tượng Lesson từ một Map JSON.
  /// Xử lý các trường có thể null và cung cấp giá trị mặc định an toàn.
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lessonId'] as int? ?? 0,
      title: json['title'] as String? ?? 'No title',
      description: json['description'] as String? ?? 'No description',
      level: json['level'] as String? ?? 'UNKNOWN', // Giá trị mặc định hợp lý
      skill: json['skill'] as String? ?? 'UNKNOWN', // Giá trị mặc định hợp lý
      price: Decimal.parse((json['price']?.toString() ?? '0.0')),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      durationMonths: json['durationMonths'] as int?, // Đảm bảo đúng kiểu int?
      // Các trường isAccessible, expiryDate, enrollmentId không trực tiếp từ API Lesson,
      // mà thường được thêm vào khi ghép nối với Enrollment.
      // Tuy nhiên, nếu API Lesson có thể trả về các trường này, bạn có thể uncomment dưới đây:
      // isAccessible: json['isAccessible'] as bool? ?? false,
      // expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate'] as String) : null,
      // enrollmentId: json['enrollmentId'] as int?,
    );
  }

  /// Chuyển đổi đối tượng Lesson thành Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'level': level,
      'skill': skill,
      'price': price.toString(),
      'createdAt': createdAt.toIso8601String(),
      'durationMonths': durationMonths,
      // isAccessible, expiryDate, enrollmentId không được gửi lên nếu không có trong API backend
      // 'isAccessible': isAccessible,
      // 'expiryDate': expiryDate?.toIso8601String(),
      // 'enrollmentId': enrollmentId,
    };
  }
}
