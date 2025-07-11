import 'package:collection/collection.dart';

enum Role {
  ROLE_USER,
  ROLE_ADMIN,
}

Role? roleFromString(String? role) {
  if (role == null) return null;
  return Role.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toUpperCase() == role.toUpperCase(),
  );
}

class UserResponse {
  final int? userId;
  final String? username;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final Role? role;

  UserResponse({
    this.userId,
    this.username,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.createdAt,
    this.role,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      userId: json['userId'] as int?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      role: roleFromString(json['role'] as String?),
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
      'role': role?.toString().split('.').last,
    };
  }

  bool get isError => userId == null;
}

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
    final Map<String, dynamic> data = {};
    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (fullName != null) data['fullName'] = fullName;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (role != null) data['role'] = role.toString().split('.').last;
    return data;
  }
}

class UserSearchRequest {
  final String? username;
  final String? email;
  final String? fullName;
  final Role? role;
  final int page;
  final int size;
  final String sortBy;
  final String sortDir;

  UserSearchRequest({
    this.username,
    this.email,
    this.fullName,
    this.role,
    int? page,
    int? size,
    String? sortBy,
    String? sortDir,
  })  : page = page != null && page >= 0 ? page : 0,
        size = size != null && size > 0 ? size : 10,
        sortBy = sortBy != null &&
            ['userId', 'username', 'email', 'fullName', 'createdAt', 'role'].contains(sortBy)
            ? sortBy
            : 'userId',
        sortDir = sortDir != null && ['ASC', 'DESC'].contains(sortDir.toUpperCase()) ? sortDir : 'ASC';

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'page': page,
      'size': size,
      'sortBy': sortBy,
      'sortDir': sortDir,
    };
    if (username != null) data['username'] = username;
    if (email != null) data['email'] = email;
    if (fullName != null) data['fullName'] = fullName;
    if (role != null) data['role'] = role.toString().split('.').last;
    return data;
  }
}

class UserPageResponse {
  final List<UserResponse> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  UserPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory UserPageResponse.fromJson(Map<String, dynamic> json) {
    return UserPageResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: json['totalPages'] as int,
      page: json['currentPage'] as int,
      size: json['pageSize'] as int,
    );
  }
}