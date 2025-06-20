import 'package:decimal/decimal.dart';
import 'user.dart';

class Lesson {
  final int lessonId;
  final String title;
  final String description;
  final String level;
  final String skill;
  final Decimal price;
  final DateTime createdAt;
  final int? durationMonths;
  final bool isAccessible;
  final DateTime? expiryDate;
  final int? enrollmentId;

  Lesson({
    required this.lessonId,
    required this.title,
    required this.description,
    required this.level,
    required this.skill,
    required this.price,
    required this.createdAt,
    this.durationMonths,
    this.isAccessible = false,
    this.expiryDate,
    this.enrollmentId,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lessonId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      skill: json['skill'] as String,
      price: Decimal.parse(json['price'].toString()),
      createdAt: DateTime.parse(json['createdAt'] as String),
      durationMonths: json['durationMonths'] as int?,
      isAccessible: json['isAccessible'] as bool? ?? false,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : null,
      enrollmentId: json['enrollmentId'] as int?,
    );
  }

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
      'isAccessible': isAccessible,
      'expiryDate': expiryDate?.toIso8601String(),
      'enrollmentId': enrollmentId,
    };
  }
}