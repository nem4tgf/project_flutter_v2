import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  // *******************************************************************
  // * QUAN TRỌNG: VUI LÒNG CẬP NHẬT URL NÀY VỚI URL NGrok MỚI NHẤT CỦA BẠN! *
  // * URL Ngrok miễn phí thay đổi mỗi khi bạn khởi động lại Ngrok.    *
  // * Hãy kiểm tra terminal Ngrok và dán URL HTTPS mới nhất vào đây.  *
  // *******************************************************************
  final String _authBaseUrl = kIsWeb ? 'http://localhost:8080/api/auth' : 'http://192.168.2.8:8080/api/auth';
  final String _userBaseUrl = kIsWeb ? 'http://localhost:8080/api/users' : 'http://192.168.2.8:8080/api/users';

  String? _token;
  User? _currentUser;

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  User? get currentUser => _currentUser;
  int? get userId => _currentUser?.userId;

  AuthService() {
    _loadAuthDataFromStorage();
  }

  Future<void> _loadAuthDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJsonString = prefs.getString('currentUser');

    if (userJsonString != null && userJsonString.isNotEmpty) {
      try {
        _currentUser = User.fromJson(json.decode(userJsonString) as Map<String, dynamic>);
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding currentUser from storage: $e');
        }
        _currentUser = null;
      }
    }

    if (kDebugMode) {
      print('Loaded from storage: token=${_token != null ? 'Exists' : 'Null'}, currentUser=${_currentUser?.username}');
    }
    notifyListeners();
  }

  Future<void> _saveAuthDataToStorage(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('currentUser', json.encode(user.toJson()));
    if (kDebugMode) {
      print('Saved to storage: token=$token, currentUser=${user.username}');
    }
  }

  Future<void> _clearAuthDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('currentUser');
    if (kDebugMode) {
      print('Cleared auth data from storage');
    }
  }

  Future<User> _fetchUserByUsername(String username, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_userBaseUrl/username/$username'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('Fetch User response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body) as Map<String, dynamic>);
      }
      String errorMessage = 'Không thể lấy thông tin người dùng.';
      if (response.body.isNotEmpty) {
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Lỗi phản hồi từ server: ${response.body}';
        }
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lấy thông tin người dùng: $e');
      }
      rethrow;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_authBaseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Login response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'] as String;
        _currentUser = await _fetchUserByUsername(username, _token!);
        await _saveAuthDataToStorage(_token!, _currentUser!);
        notifyListeners();
        return true;
      } else {
        String errorMessage = 'Đăng nhập thất bại.';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          } catch (e) {
            errorMessage = 'Lỗi phản hồi từ server (${response.statusCode}): ${response.body.substring(0, min(response.body.length, 100))}...';
          }
        } else {
          errorMessage = 'Đăng nhập thất bại. Server không phản hồi thông báo lỗi (Status: ${response.statusCode}).';
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('Lỗi kết nối HTTP: $e');
      }
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng hoặc thử lại sau.');
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Lỗi đăng nhập: $e');
      }
      rethrow;
    }
  }

  Future<bool> register(String username, String email, String password, String fullName) async {
    try {
      final response = await http.post(
        Uri.parse('$_authBaseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': 'ROLE_USER',
        }),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Register response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'] as String;
        _currentUser = await _fetchUserByUsername(username, _token!);
        await _saveAuthDataToStorage(_token!, _currentUser!);
        notifyListeners();
        return true;
      } else {
        String errorMessage = 'Đăng ký thất bại.';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          } catch (e) {
            errorMessage = 'Lỗi phản hồi từ server (${response.statusCode}): ${response.body.substring(0, min(response.body.length, 100))}...';
          }
        } else {
          errorMessage = 'Đăng ký thất bại. Server không phản hồi thông báo lỗi (Status: ${response.statusCode}).';
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('Lỗi kết nối HTTP: $e');
      }
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng hoặc thử lại sau.');
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Lỗi đăng ký: $e');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      if (kDebugMode) {
        print('Thực hiện đăng xuất phía client. Không có endpoint /logout ở backend.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi đăng xuất (phía client): $e');
      }
    } finally {
      await _clearAuthDataFromStorage();
      _token = null;
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> sendOtpForPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_authBaseUrl/forgot-password?email=$email'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Forgot Password response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return;
      } else {
        String errorMessage = 'Không thể gửi OTP.';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          } catch (e) {
            errorMessage = 'Lỗi phản hồi từ server (${response.statusCode}): ${response.body.substring(0, min(response.body.length, 100))}...';
          }
        } else {
          errorMessage = 'Không thể gửi OTP. Server không phản hồi thông báo lỗi (Status: ${response.statusCode}).';
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('Lỗi kết nối HTTP: $e');
      }
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng hoặc thử lại sau.');
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Lỗi gửi OTP: $e');
      }
      rethrow;
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_authBaseUrl/reset-password?email=$email&otp=$otp&newPassword=$newPassword'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Reset Password response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return;
      } else {
        String errorMessage = 'Không thể đặt lại mật khẩu.';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          } catch (e) {
            errorMessage = 'Lỗi phản hồi từ server (${response.statusCode}): ${response.body.substring(0, min(response.body.length, 100))}...';
          }
        } else {
          errorMessage = 'Không thể đặt lại mật khẩu. Server không phản hồi thông báo lỗi (Status: ${response.statusCode}).';
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('Lỗi kết nối HTTP: $e');
      }
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng hoặc thử lại sau.');
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Lỗi đặt lại mật khẩu: $e');
      }
      rethrow;
    }
  }
}
