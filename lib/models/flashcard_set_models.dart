import 'package:flutter/material.dart';
import 'vocabulary_models.dart';

// --- FlashcardSetRequest DTO ---
// Tương ứng với org.example.projetc_backend.dto.FlashcardSetRequest
class FlashcardSetRequest {
  final String title;
  final String? description;
  final int? creatorUserId;
  final bool isSystemCreated;
  final List<int>? wordIds;

  FlashcardSetRequest({
    required this.title,
    this.description,
    this.creatorUserId,
    required this.isSystemCreated,
    this.wordIds,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    if (creatorUserId != null) 'creatorUserId': creatorUserId,
    'isSystemCreated': isSystemCreated,
    if (wordIds != null) 'wordIds': wordIds,
  };
}

// --- FlashcardSetResponse DTO ---
// Tương ứng với org.example.projetc_backend.dto.FlashcardSetResponse
class FlashcardSetResponse {
  final int setId;
  final String title;
  final String? description;
  final int? creatorUserId;
  final bool isSystemCreated;
  final DateTime createdAt;
  final List<VocabularyResponse> vocabularies;

  FlashcardSetResponse({
    required this.setId,
    required this.title,
    this.description,
    this.creatorUserId,
    required this.isSystemCreated,
    required this.createdAt,
    required this.vocabularies,
  });

  factory FlashcardSetResponse.fromJson(Map<String, dynamic> json) {
    return FlashcardSetResponse(
      setId: json['setId'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      creatorUserId: json['creatorUserId'] as int?,
      isSystemCreated: json['isSystemCreated'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      vocabularies: (json['vocabularies'] as List<dynamic>)
          .map((e) => VocabularyResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// --- FlashcardSetSearchRequest DTO ---
// Tương ứng với org.example.projetc_backend.dto.FlashcardSetSearchRequest
class FlashcardSetSearchRequest {
  final String? title;
  final bool? isSystemCreated;
  final int? creatorUserId;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  FlashcardSetSearchRequest({
    this.title,
    this.isSystemCreated,
    this.creatorUserId,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : page = page ?? 0,
        size = size ?? 10,
        sortBy = sortBy ?? 'setId',
        sortDir = sortDir ?? 'ASC';

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (isSystemCreated != null) 'isSystemCreated': isSystemCreated,
    if (creatorUserId != null) 'creatorUserId': creatorUserId,
    'page': page,
    'size': size,
    'sortBy': sortBy,
    'sortDir': sortDir,
  };
}

// --- FlashcardSetPageResponse DTO ---
// Thêm mới để xử lý phân trang, tương ứng với Page<FlashcardSetResponse> từ backend
class FlashcardSetPageResponse {
  final List<FlashcardSetResponse> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  FlashcardSetPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory FlashcardSetPageResponse.fromJson(Map<String, dynamic> json) {
    return FlashcardSetPageResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => FlashcardSetResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: json['totalPages'] as int,
      page: json['page'] as int,
      size: json['size'] as int,
    );
  }
}