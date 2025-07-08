// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final String _baseUrl = kIsWeb ? 'http://localhost:8080/api/auth' : 'http://10.0.2.2:8080/api/auth';
  String? _token;
  String? _username;

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  AuthService() {
    _loadAuthDataFromStorage();
  }

  Future<void> _loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _username = prefs.getString('username');
    if (kDebugMode) {
      print('Loaded from storage: token=$_token, username=$_username');
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Login response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng nhập thất bại');
      }

      final data = json.decode(response.body);
      _token = data['token'];
      _username = username;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('username', username);

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      rethrow;
    }
  }

  Future<bool> register(String username, String email, String password, String fullName) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
        }),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Register response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode != 201) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng ký thất bại');
      }

      final data = json.decode(response.body);
      _token = data['token'];
      _username = username;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('username', username);

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Register error: $e');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 30));
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('username');

      _token = null;
      _username = null;
      notifyListeners();
    }
  }

  // Thêm hàm gửi OTP
  Future<void> sendOtpForPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Forgot Password response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Không thể gửi OTP');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Send OTP error: $e');
      }
      rethrow;
    }
  }

  // Thêm hàm đặt lại mật khẩu
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Reset Password response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Không thể đặt lại mật khẩu');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Reset Password error: $e');
      }
      rethrow;
    }
  }
}
