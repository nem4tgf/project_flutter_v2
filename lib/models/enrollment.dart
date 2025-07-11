import 'package:flutter/foundation.dart';

import 'lesson.dart';

/// --- EnrollmentRequest DTO ---
/// Tương ứng với `org.example.projetc_backend.dto.EnrollmentRequest.java`
class EnrollmentRequest {
  final int userId;
  final int lessonId;

  EnrollmentRequest({
    required this.userId,
    required this.lessonId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lessonId': lessonId,
    };
  }
}

/// --- EnrollmentResponse DTO ---
/// Tương ứng với `org.example.projetc_backend.dto.EnrollmentResponse.java`
class EnrollmentResponse {
  final int? enrollmentId; // Nullable để xử lý lỗi
  final int? userId;
  final String? userName;
  final LessonResponse? lesson;
  final DateTime? enrollmentDate;
  final DateTime? expiryDate; // Ngày hết hạn
  final String? status; // ACTIVE, EXPIRED, hoặc thông báo lỗi

  EnrollmentResponse({
    this.enrollmentId,
    this.userId,
    this.userName,
    this.lesson,
    this.enrollmentDate,
    this.expiryDate,
    this.status,
  });

  factory EnrollmentResponse.fromJson(Map<String, dynamic> json) {
    return EnrollmentResponse(
      enrollmentId: json['enrollmentId'] as int?,
      userId: json['userId'] as int?,
      userName: json['userName'] as String?,
      lesson: json['lesson'] != null
          ? LessonResponse.fromJson(json['lesson'] as Map<String, dynamic>)
          : null,
      enrollmentDate: json['enrollmentDate'] != null
          ? DateTime.parse(json['enrollmentDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrollmentId': enrollmentId,
      'userId': userId,
      'userName': userName,
      'lesson': lesson?.toJson(),
      'enrollmentDate': enrollmentDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'status': status,
    };
  }

  // Kiểm tra xem response có phải là lỗi không
  bool get isError => enrollmentId == null && status != null && status != 'ACTIVE' && status != 'EXPIRED';
}

/// --- EnrollmentSearchRequest DTO ---
/// Tương ứng với `org.example.projetc_backend.dto.EnrollmentSearchRequest.java`
class EnrollmentSearchRequest {
  final int? userId;
  final int? lessonId;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  EnrollmentSearchRequest({
    this.userId,
    this.lessonId,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : page = (page == null || page < 0) ? 0 : page,
        size = (size == null || size <= 0) ? 10 : size,
        sortBy = (sortBy == null || sortBy.isEmpty ||
            !(sortBy == 'enrollmentId' ||
                sortBy == 'enrollmentDate' ||
                sortBy == 'user.userId' || // Khớp với backend
                sortBy == 'lesson.lessonId'))
            ? 'enrollmentId'
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
    if (lessonId != null) json['lessonId'] = lessonId;

    return json;
  }
}

/// --- PaginatedResponse DTO ---
class PaginatedResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;

  PaginatedResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return PaginatedResponse(
      content: (json['content'] as List<dynamic>).map((item) => fromJsonT(item)).toList(),
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      size: json['size'] as int,
      number: json['number'] as int,
    );
  }
}