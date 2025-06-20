// lib/models/user_response_models.dart
import 'user.dart'; // Để sử dụng User và Role (quan trọng!)

// UserResponse tương ứng với UserResponse.java
class UserResponse {
  final int userId;
  final String username;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final Role role;

  UserResponse({
    required this.userId,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.createdAt,
    required this.role,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      userId: json['userId'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      role: Role.values.firstWhere(
            (e) => e.toString().split('.').last == json['role'] as String,
        orElse: () => Role.ROLE_USER,
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
      'role': role.toString().split('.').last,
    };
  }
}

// UserPageResponse tương ứng với UserPageResponse.java
class UserPageResponse {
  final List<UserResponse> content;
  final int totalElements; // Đã sửa thành int
  final int totalPages;
  final int currentPage;
  final int pageSize;

  UserPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory UserPageResponse.fromJson(Map<String, dynamic> json) {
    var contentList = json['content'] as List;
    List<UserResponse> users = contentList
        .map((i) => UserResponse.fromJson(i as Map<String, dynamic>))
        .toList();

    return UserPageResponse(
      content: users,
      totalElements: json['totalElements'] as int, // Đã sửa thành int
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
      pageSize: json['pageSize'] as int,
    );
  }
}

// UserSearchRequest tương ứng với UserSearchRequest.java
class UserSearchRequest {
  final String? username;
  final String? email;
  final String? fullName;
  final Role? role;
  final int? page;
  final int? size;
  final String? sortBy;
  final String? sortDir;

  UserSearchRequest({
    this.username,
    this.email,
    this.fullName,
    this.role,
    this.page = 0,
    this.size = 10,
    this.sortBy = "userId",
    this.sortDir = "ASC",
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'fullName': fullName,
      'role': role?.toString().split('.').last,
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    }..removeWhere((key, value) => value == null);
  }
}

// UserUpdateRequest tương ứng với UserUpdateRequest.java
class UserUpdateRequest {
  final String? username;
  final String? email;
  final String? password;
  final String? fullName;
  final String? avatarUrl;
  final Role? role;

  UserUpdateRequest({
    this.username,
    this.email,
    this.password,
    this.fullName,
    this.avatarUrl,
    this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'role': role?.toString().split('.').last,
    }..removeWhere((key, value) => value == null);
  }
}