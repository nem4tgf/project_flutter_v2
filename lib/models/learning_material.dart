import 'package:flutter/foundation.dart';

// Enum tương ứng với LearningMaterial.MaterialType của backend
enum MaterialType {
  VIDEO,
  AUDIO,
  TEXT,
}

// Hàm tiện ích để chuyển đổi từ chuỗi sang enum
MaterialType? materialTypeFromString(String? type) {
  if (type == null) return null;
  switch (type.toUpperCase()) {
    case 'VIDEO':
      return MaterialType.VIDEO;
    case 'AUDIO':
      return MaterialType.AUDIO;
    case 'TEXT':
      return MaterialType.TEXT;
    default:
      return null;
  }
}

// --- LearningMaterialRequest DTO ---
// Tương ứng với org.example.projetc_backend.dto.LearningMaterialRequest.java
class LearningMaterialRequest {
  final int lessonId;
  final MaterialType materialType;
  final String materialUrl;
  final String? description;
  final String? transcriptText;

  LearningMaterialRequest({
    required this.lessonId,
    required this.materialType,
    required this.materialUrl,
    this.description,
    this.transcriptText,
  });

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'materialType': materialType.toString().split('.').last,
      'materialUrl': materialUrl,
      'description': description,
      'transcriptText': transcriptText,
    };
  }
}

// --- LearningMaterialResponse DTO ---
// Tương ứng với org.example.projetc_backend.dto.LearningMaterialResponse.java
class LearningMaterialResponse {
  final int? materialId; // Nullable để xử lý lỗi
  final int? lessonId;
  final MaterialType? materialType;
  final String? materialUrl;
  final String? description;
  final String? transcriptText;

  LearningMaterialResponse({
    this.materialId,
    this.lessonId,
    this.materialType,
    this.materialUrl,
    this.description,
    this.transcriptText,
  });

  factory LearningMaterialResponse.fromJson(Map<String, dynamic> json) {
    return LearningMaterialResponse(
      materialId: json['materialId'] as int?,
      lessonId: json['lessonId'] as int?,
      materialType: materialTypeFromString(json['materialType'] as String?),
      materialUrl: json['materialUrl'] as String?,
      description: json['description'] as String?,
      transcriptText: json['transcriptText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'lessonId': lessonId,
      'materialType': materialType?.toString().split('.').last,
      'materialUrl': materialUrl,
      'description': description,
      'transcriptText': transcriptText,
    };
  }

  // Kiểm tra xem response có phải là lỗi không
  bool get isError => materialId == null;
}

// --- LearningMaterialSearchRequest DTO ---
// Tương ứng với org.example.projetc_backend.dto.LearningMaterialSearchRequest.java
class LearningMaterialSearchRequest {
  final int? lessonId;
  final MaterialType? materialType;
  final String? description;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  LearningMaterialSearchRequest({
    this.lessonId,
    this.materialType,
    this.description,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : page = (page == null || page < 0) ? 0 : page,
        size = (size == null || size <= 0) ? 10 : size,
        sortBy = (sortBy == null || sortBy.isEmpty ||
            !(sortBy == 'materialId' ||
                sortBy == 'materialType' ||
                sortBy == 'materialUrl' ||
                sortBy == 'description' ||
                sortBy == 'transcriptText' ||
                sortBy == 'lesson.lessonId'))
            ? 'materialId'
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

    if (lessonId != null) json['lessonId'] = lessonId;
    if (materialType != null) json['materialType'] = materialType.toString().split('.').last;
    if (description != null && description!.isNotEmpty) json['description'] = description;

    return json;
  }
}

// --- PaginatedResponse DTO ---
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