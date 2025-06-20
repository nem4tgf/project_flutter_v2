// lib/models/auth_models.dart
import 'user.dart'; // Để sử dụng enum Role

// LoginRequest tương ứng với LoginRequest.java
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

// LoginResponse tương ứng với LoginResponse.java
class LoginResponse {
  final String token;

  LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
    );
  }
}

// RegisterRequest tương ứng với RegisterRequest.java
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String? fullName;
  final Role? role; // Có thể để null nếu backend tự gán mặc định ROLE_USER

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.fullName,
    this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      'role': role?.toString().split('.').last, // Gửi enum thành String
    };
  }
}

// ResetPasswordRequest tương ứng với ResetPasswordRequest.java
class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    };
  }
}