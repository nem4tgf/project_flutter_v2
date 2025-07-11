import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'vocabulary_models.dart';

// --- FlashcardResponse DTO ---
// Tương ứng với org.example.projetc_backend.dto.FlashcardResponse
class FlashcardResponse {
  final int userFlashcardId;
  final int userId;
  final int wordId;
  final String word;
  final String meaning;
  final String? exampleSentence;
  final String? pronunciation;
  final String? audioUrl;
  final String? imageUrl;
  final String? writingPrompt;
  final DifficultyLevel? difficultyLevel;
  final bool? isKnown;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final int? reviewIntervalDays;
  final double? easeFactor;

  FlashcardResponse({
    required this.userFlashcardId,
    required this.userId,
    required this.wordId,
    required this.word,
    required this.meaning,
    this.exampleSentence,
    this.pronunciation,
    this.audioUrl,
    this.imageUrl,
    this.writingPrompt,
    this.difficultyLevel,
    this.isKnown,
    this.lastReviewedAt,
    this.nextReviewAt,
    this.reviewIntervalDays,
    this.easeFactor,
  });

  factory FlashcardResponse.fromJson(Map<String, dynamic> json) {
    return FlashcardResponse(
      userFlashcardId: json['userFlashcardId'] as int,
      userId: json['userId'] as int,
      wordId: json['wordId'] as int,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      exampleSentence: json['exampleSentence'] as String?,
      pronunciation: json['pronunciation'] as String?,
      audioUrl: json['audioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      writingPrompt: json['writingPrompt'] as String?,
      difficultyLevel: json['difficultyLevel'] != null
          ? DifficultyLevel.values.firstWhereOrNull(
              (e) => e.toString().split('.').last == json['difficultyLevel'])
          : null,
      isKnown: json['isKnown'] as bool?,
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.parse(json['lastReviewedAt'] as String)
          : null,
      nextReviewAt: json['nextReviewAt'] != null
          ? DateTime.parse(json['nextReviewAt'] as String)
          : null,
      reviewIntervalDays: json['reviewIntervalDays'] as int?,
      easeFactor: (json['easeFactor'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userFlashcardId': userFlashcardId,
    'userId': userId,
    'wordId': wordId,
    'word': word,
    'meaning': meaning,
    if (exampleSentence != null) 'exampleSentence': exampleSentence,
    if (pronunciation != null) 'pronunciation': pronunciation,
    if (audioUrl != null) 'audioUrl': audioUrl,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (writingPrompt != null) 'writingPrompt': writingPrompt,
    if (difficultyLevel != null)
      'difficultyLevel': difficultyLevel!.toString().split('.').last,
    if (isKnown != null) 'isKnown': isKnown,
    if (lastReviewedAt != null)
      'lastReviewedAt': lastReviewedAt!.toIso8601String(),
    if (nextReviewAt != null) 'nextReviewAt': nextReviewAt!.toIso8601String(),
    if (reviewIntervalDays != null) 'reviewIntervalDays': reviewIntervalDays,
    if (easeFactor != null) 'easeFactor': easeFactor,
  };
}

// --- FlashcardSearchRequest DTO ---
// Tương ứng với org.example.projetc_backend.dto.FlashcardSearchRequest
class FlashcardSearchRequest {
  final int? userId;
  final int? wordId;
  final int? setId;
  final String? word;
  final String? meaning;
  final bool? isKnown;
  final DifficultyLevel? difficultyLevel;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  FlashcardSearchRequest({
    this.userId,
    this.wordId,
    this.setId,
    this.word,
    this.meaning,
    this.isKnown,
    this.difficultyLevel,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : page = page ?? 0,
        size = size ?? 10,
        sortBy = sortBy ?? 'wordId',
        sortDir = sortDir ?? 'ASC';

  Map<String, dynamic> toJson() => {
    if (userId != null) 'userId': userId,
    if (wordId != null) 'wordId': wordId,
    if (setId != null) 'setId': setId,
    if (word != null) 'word': word,
    if (meaning != null) 'meaning': meaning,
    if (isKnown != null) 'isKnown': isKnown,
    if (difficultyLevel != null)
      'difficultyLevel': difficultyLevel!.toString().split('.').last,
    'page': page,
    'size': size,
    'sortBy': sortBy,
    'sortDir': sortDir,
  };
}

// --- FlashcardPageResponse DTO ---
// Tương ứng với org.example.projetc_backend.dto.FlashcardPageResponse
class FlashcardPageResponse {
  final List<FlashcardResponse> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  FlashcardPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory FlashcardPageResponse.fromJson(Map<String, dynamic> json) {
    return FlashcardPageResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => FlashcardResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: json['totalPages'] as int,
      page: json['page'] as int,
      size: json['size'] as int,
    );
  }
}