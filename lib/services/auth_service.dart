// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Để dùng kIsWeb
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Import các model DTO từ thư mục models
import '../models/user.dart'; // Chứa Role enum
import '../models/auth_models.dart'; // Chứa LoginRequest, LoginResponse, RegisterRequest, ResetPasswordRequest
import '../models/user_response_models.dart'; // Chứa UserResponse (dùng cho _currentUser)

class AuthService extends ChangeNotifier {
  // *******************************************************************
  // * QUAN TRỌNG: VUI LÒNG CẬP NHẬT URL NÀY VỚI URL Ngrok MỚI NHẤT CỦA BẠN! *
  // * URL Ngrok miễn phí thay đổi mỗi khi bạn khởi động lại Ngrok.    *
  // * Hãy kiểm tra terminal Ngrok và dán URL HTTPS mới nhất vào đây.  *
  // *******************************************************************
  // Ví dụ: 'http://localhost:8080' khi chạy web, hoặc địa chỉ IP/Ngrok khi chạy trên thiết bị
  final String _baseUrl = kIsWeb ? 'http://localhost:8080' : 'http://192.168.1.10:8080';

  String? _token;
  UserResponse? _currentUser; // Sử dụng UserResponse từ DTO backend

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  UserResponse? get currentUser => _currentUser;
  int? get userId => _currentUser?.userId;

  AuthService() {
    _loadAuthDataFromStorage();
  }

  // Phương thức để tải dữ liệu xác thực từ SharedPreferences
  Future<void> _loadAuthDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJsonString = prefs.getString('currentUser');
    if (userJsonString != null) {
      try {
        _currentUser = UserResponse.fromJson(json.decode(userJsonString));
      } catch (e) {
        debugPrint('Error decoding stored user: $e');
        _currentUser = null; // Xóa dữ liệu lỗi
        prefs.remove('currentUser');
      }
    }
    notifyListeners(); // Thông báo cho các widget lắng nghe khi dữ liệu đã tải
  }

  // Phương thức private để lưu dữ liệu xác thực vào SharedPreferences
  Future<void> _saveAuthDataToStorage(String token, UserResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('currentUser', json.encode(user.toJson())); // Lưu JSON của UserResponse
    _token = token;
    _currentUser = user;
    // Không notifyListeners() ở đây, vì các phương thức public gọi nó sẽ notify
  }

  // Phương thức private để xóa dữ liệu xác thực khỏi SharedPreferences
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('currentUser');
    _token = null;
    _currentUser = null;
    // notifyListeners() sẽ được gọi từ logout()
  }

  // --- Phương thức công khai để cập nhật thông tin người dùng từ bên ngoài ---
  // (Ví dụ: UserService gọi khi cập nhật thông tin người dùng hiện tại)
  Future<void> updateCurrentUser(UserResponse newUser) async {
    if (_token == null) {
      debugPrint('Error: Cannot update current user when token is null.');
      return;
    }
    await _saveAuthDataToStorage(_token!, newUser); // Gọi phương thức private để lưu
    notifyListeners(); // Thông báo sự thay đổi
  }

  // --- Các phương thức gọi API ---

  // Endpoint: POST /api/auth/login
  Future<void> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(json.decode(response.body));
      await _fetchAndSetCurrentUser(loginResponse.token); // Lấy thông tin user dựa trên token mới
      await _saveAuthDataToStorage(loginResponse.token, _currentUser!); // Lưu token và thông tin user
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Tên đăng nhập hoặc mật khẩu không đúng.');
    } else {
      throw Exception('Đăng nhập thất bại. Vui lòng thử lại sau. Status: ${response.statusCode}');
    }
  }

  // Endpoint: POST /api/auth/register
  Future<void> register(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) { // HttpStatus.CREATED
      final loginResponse = LoginResponse.fromJson(json.decode(response.body));
      await _fetchAndSetCurrentUser(loginResponse.token);
      await _saveAuthDataToStorage(loginResponse.token, _currentUser!);
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Đăng ký thất bại. Vui lòng kiểm tra lại thông tin.');
    } else {
      throw Exception('Đăng ký thất bại. Vui lòng thử lại sau. Status: ${response.statusCode}');
    }
  }

  // Endpoint: GET /api/auth/check-user/{username}
  Future<bool> checkUserExists(String username) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/auth/check-user/$username'));

    if (response.statusCode == 200) {
      return json.decode(response.body) as bool;
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Kiểm tra người dùng thất bại.');
    } else {
      throw Exception('Không thể kiểm tra người dùng. Vui lòng thử lại sau. Status: ${response.statusCode}');
    }
  }

  // Endpoint: POST /api/auth/forgot-password?email={email}
  Future<void> sendOtpForPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/forgot-password?email=$email'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Thành công
    } else if (response.statusCode == 400) {
      throw Exception(response.body); // Backend trả về thông báo lỗi trực tiếp
    } else {
      throw Exception('Gửi OTP thất bại. Vui lòng thử lại sau. Status: ${response.statusCode}');
    }
  }

  // Endpoint: POST /api/auth/reset-password?email={email}&otp={otp}&newPassword={newPassword}
  Future<void> resetPassword(String email, String otp, String newPassword) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/reset-password?email=$email&otp=$otp&newPassword=$newPassword'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Thành công
    } else if (response.statusCode == 400) {
      throw Exception(response.body); // Backend trả về thông báo lỗi trực tiếp
    } else {
      throw Exception('Đặt lại mật khẩu thất bại. Vui lòng thử lại sau. Status: ${response.statusCode}');
    }
  }

  // Phương thức helper để lấy thông tin người dùng hiện tại sau khi có token
  // Endpoint: GET /api/users/current
  Future<void> _fetchAndSetCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/current'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _currentUser = UserResponse.fromJson(json.decode(response.body));
        notifyListeners(); // Thông báo khi currentUser được cập nhật
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await logout(); // Token hết hạn hoặc không hợp lệ
        throw Exception('Phiên đăng nhập đã hết hạn hoặc không có quyền. Vui lòng đăng nhập lại.');
      } else {
        throw Exception('Không thể tải thông tin người dùng hiện tại: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      await logout(); // Đăng xuất nếu có lỗi khi fetch user
      throw Exception('Lỗi khi tải thông tin người dùng: $e');
    }
  }

  // Phương thức đăng xuất
  Future<void> logout() async {
    await _clearAuthData(); // Gọi phương thức private để xóa dữ liệu
    notifyListeners(); // Thông báo trạng thái đăng xuất
  }

  // Helper để lấy headers với token (sử dụng trong nội bộ AuthService nếu cần)
  Map<String, String> _getAuthHeaders() {
    if (_token == null) {
      throw Exception('Không có token xác thực.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }
}