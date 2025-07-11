import 'package:flutter/material.dart';

// --- UserFlashcardRequest DTO ---
// Tương ứng với org.example.projetc_backend.dto.UserFlashcardRequest
class UserFlashcardRequest {
  final int userId;
  final int wordId;
  final bool isKnown;

  UserFlashcardRequest({
    required this.userId,
    required this.wordId,
    required this.isKnown,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'wordId': wordId,
    'isKnown': isKnown,
  };
}

// --- UserFlashcardResponse DTO ---
// Tương ứng với org.example.projetc_backend.dto.UserFlashcardResponse
class UserFlashcardResponse {
  final int? id;
  final int? userId;
  final int? wordId;
  final bool? isKnown;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final int? reviewIntervalDays;
  final double? easeFactor;

  UserFlashcardResponse({
    this.id,
    this.userId,
    this.wordId,
    this.isKnown,
    this.lastReviewedAt,
    this.nextReviewAt,
    this.reviewIntervalDays,
    this.easeFactor,
  });

  factory UserFlashcardResponse.fromJson(Map<String, dynamic> json) {
    return UserFlashcardResponse(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      wordId: json['wordId'] as int?,
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
    if (id != null) 'id': id,
    if (userId != null) 'userId': userId,
    if (wordId != null) 'wordId': wordId,
    if (isKnown != null) 'isKnown': isKnown,
    if (lastReviewedAt != null)
      'lastReviewedAt': lastReviewedAt!.toIso8601String(),
    if (nextReviewAt != null) 'nextReviewAt': nextReviewAt!.toIso8601String(),
    if (reviewIntervalDays != null) 'reviewIntervalDays': reviewIntervalDays,
    if (easeFactor != null) 'easeFactor': easeFactor,
  };
}