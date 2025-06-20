// lib/models/progress.dart
import 'package:flutter/material.dart'; // Thường không cần nhưng để đảm bảo

/// Represents the response structure for progress information from the backend.
/// Now uses 'activityType' instead of 'skill'.
class ProgressResponse {
  final int progressId;
  final int userId;
  final int lessonId;
  final String activityType; // CHANGED: Now 'activityType'
  final String status;
  final int completionPercentage;
  final DateTime? lastUpdated; // Changed to nullable DateTime

  ProgressResponse({
    required this.progressId,
    required this.userId,
    required this.lessonId,
    required this.activityType, // CHANGED: Constructor uses 'activityType'
    required this.status,
    required this.completionPercentage,
    this.lastUpdated, // Changed to nullable
  });

  /// Factory constructor to create a ProgressResponse from a JSON map.
  factory ProgressResponse.fromJson(Map<String, dynamic> json) {
    return ProgressResponse(
      // progressId might be null for 'OVERALL_LESSON' responses
      progressId: json['progressId'] as int? ?? -1, // Use -1 or other default if null
      userId: json['userId'] as int,
      lessonId: json['lessonId'] as int,
      activityType: json['activityType'] as String, // CHANGED: Get 'activityType'
      status: json['status'] as String,
      completionPercentage: json['completionPercentage'] as int,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null, // Handle null lastUpdated for OVERALL_LESSON
    );
  }

  /// Converts the ProgressResponse object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'progressId': progressId,
      'userId': userId,
      'lessonId': lessonId,
      'activityType': activityType, // CHANGED: Use 'activityType'
      'status': status,
      'completionPercentage': completionPercentage,
      'lastUpdated': lastUpdated?.toIso8601String(), // Handle nullable
    };
  }
}

/// Represents the request structure for updating progress to the backend.
/// Now uses 'activityType' instead of 'skill'.
class ProgressRequest {
  final int userId;
  final int lessonId;
  final String activityType; // CHANGED: Now 'activityType'
  final String status;
  final int completionPercentage;

  ProgressRequest({
    required this.userId,
    required this.lessonId,
    required this.activityType, // CHANGED: Constructor uses 'activityType'
    required this.status,
    required this.completionPercentage,
  });

  /// Converts the ProgressRequest object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lessonId': lessonId,
      'activityType': activityType, // CHANGED: Use 'activityType'
      'status': status,
      'completionPercentage': completionPercentage,
    };
  }
}
