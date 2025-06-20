import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:app_links/app_links.dart'; // Bỏ comment nếu đã thêm app_links vào pubspec.yaml
// import 'dart:async'; // Bỏ comment nếu dùng AppLinks

import 'auth/screens/home_screen.dart';
import 'auth/screens/learning_screen.dart';
import 'auth/screens/login_screen.dart';
import 'auth/screens/my_courses_screen.dart';
import 'auth/screens/register_screen.dart';
import 'auth/screens/forgot_password_screen.dart';
import 'auth/screens/chatbot.dart';
import 'auth/screens/reset_password_screen.dart'; // Import ResetPasswordScreen

// Đường dẫn chính xác cho MyCoursesScreen.
// Nếu MyCoursesScreen nằm trong thư mục `lib/screens/`, thì import là `package:your_app_name/screens/my_courses_screen.dart`
// hoặc `package:flutter_auth_app/screens/my_courses_screen.dart` (nếu tên app là flutter_auth_app)
// Tôi giả định nó ở `lib/screens/my_courses_screen.dart`

import 'services/auth_service.dart';
import 'services/enrollment_service.dart'; // Import EnrollmentService
import 'models/lesson.dart'; // Import Lesson model for onGenerateRoute

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        Provider(create: (context) => EnrollmentService(Provider.of<AuthService>(context, listen: false))),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Comment hoặc xóa phần AppLinks nếu bạn không sử dụng chúng
  // Nếu có dùng, hãy đảm bảo đã thêm app_links vào pubspec.yaml và `flutter pub get`
  // final _appLinks = AppLinks();
  // StreamSubscription<Uri>? _appLinksSubscription;

  @override
  void initState() {
    super.initState();
    // _initDeepLinks(); // Bỏ comment nếu dùng AppLinks
  }

  @override
  void dispose() {
    // _appLinksSubscription?.cancel(); // Bỏ comment nếu dùng AppLinks
    super.dispose();
  }

  // void _initDeepLinks() async { // Bỏ comment nếu dùng AppLinks
  //   _appLinksSubscription = _appLinks.uriLinkStream.listen((uri) {
  //     _handleDeepLink(uri);
  //   });
  //   final initialUri = await _appLinks.getInitialAppLink();
  //   if (initialUri != null) {
  //     _handleDeepLink(initialUri);
  //   }
  // }

  // void _handleDeepLink(Uri uri) { // Bỏ comment nếu dùng AppLinks
  //   if (uri.host == 'payment' && uri.pathSegments.contains('complete')) {
  //     final paymentId = uri.queryParameters['paymentId'];
  //     final payerId = uri.queryParameters['PayerID'];
  //     if (paymentId != null && payerId != null) {
  //       debugPrint('Deep Link Payment Complete: Payment ID: $paymentId, Payer ID: $payerId');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // Lấy AuthService từ Provider, không phải tạo mới
    final authService = Provider.of<AuthService>(context);

    return MaterialApp(
      title: 'Flutter Auth App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      initialRoute: authService.isAuthenticated ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/chat': (context) => const MyHomePage(),
        '/my-courses': (context) => const MyCoursesScreen(), // Đảm bảo MyCoursesScreen được import đúng
        '/reset-password': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
          final email = args?['email'] ?? '';
          return ResetPasswordScreen(email: email);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/learning') {
          // Đảm bảo Lesson được import và LearningScreen chấp nhận Lesson làm đối số
          final lesson = settings.arguments as Lesson;
          return MaterialPageRoute(builder: (context) => LearningScreen(lesson: lesson));
        }
        return null;
      },
    );
  }
}