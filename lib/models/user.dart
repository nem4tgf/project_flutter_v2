// lib/models/user.dart
import 'package:flutter/foundation.dart';

// Enum tương ứng với User.Role trong Java
enum Role {
  ROLE_ADMIN,
  ROLE_USER,
}

class User {
  final int userId;
  final String username;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final Role role; // Sử dụng enum Role đã định nghĩa

  User({
    required this.userId,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.createdAt,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      // Chuyển đổi String role từ JSON thành enum Role
      role: Role.values.firstWhere(
            (e) => e.toString().split('.').last == json['role'] as String,
        orElse: () => Role.ROLE_USER, // Mặc định nếu không tìm thấy
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt?.toIso8601String(),
      'role': role.toString().split('.').last, // Chuyển enum thành String để gửi đi
    };
  }

  @override
  String toString() {
    return 'User(userId: $userId, username: $username, email: $email, role: $role)';
  }
}