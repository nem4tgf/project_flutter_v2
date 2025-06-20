import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import '../../models/payment_reponse.dart';
import '../../services/payment_service.dart';
import '../../services/auth_service.dart';
import '../../services/enrollment_service.dart';
import '../../models/payment_request.dart';
import 'lesson_screen.dart';

enum _PaymentState {
  initial,
  initiating,
  awaitingUserAction,
  completing,
  success,
  error,
  canceled,
}

class PaymentScreen extends StatefulWidget {
  final int orderId;
  final Decimal totalAmount;

  const PaymentScreen({super.key, required this.orderId, required this.totalAmount});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? paypalApprovalUrl;
  late PaymentService _paymentService;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _appLinksSubscription;
  _PaymentState _currentState = _PaymentState.initial;
  static const String _appScheme = 'flutterauthapp';
  static const String _appHost = 'payment';

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    final enrollmentService = EnrollmentService(authService);
    _paymentService = PaymentService(authService, enrollmentService);
    _appLinks = AppLinks();
    _initAppLinksListener();
    _initiatePayment();
  }

  @override
  void dispose() {
    _appLinksSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initAppLinksListener() async {
    _appLinksSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == _appScheme && uri.host == _appHost) {
        if (_currentState != _PaymentState.success &&
            _currentState != _PaymentState.error &&
            _currentState != _PaymentState.canceled) {
          _handlePayPalCallback(uri);
        }
      }
    }, onError: (Object err) {
      debugPrint('Error listening to deep links: $err');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi xử lý liên kết: $err')));
        setState(() => _currentState = _PaymentState.error);
      }
    });

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null &&
          initialUri.scheme == _appScheme &&
          initialUri.host == _appHost) {
        if (_currentState != _PaymentState.success &&
            _currentState != _PaymentState.error &&
            _currentState != _PaymentState.canceled) {
          _handlePayPalCallback(initialUri);
        }
      }
    } catch (e) {
      debugPrint('Failed to get initial URI: $e');
    }
  }

  void _handlePayPalCallback(Uri uri) {
    debugPrint('Deep Link received: $uri');

    if (uri.pathSegments.contains('complete')) {
      final paymentId = uri.queryParameters['paymentId'];
      final payerId = uri.queryParameters['PayerID'];

      if (paymentId != null && payerId != null) {
        if (mounted) {
          setState(() => _currentState = _PaymentState.completing);
        }
        _completePayment(paymentId, payerId);
      } else {
        if (mounted) {
          setState(() => _currentState = _PaymentState.error);
        }
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thiếu Payment ID hoặc Payer ID.')));
      }
    } else if (uri.pathSegments.contains('cancel')) {
      if (mounted) {
        setState(() => _currentState = _PaymentState.canceled);
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán đã bị hủy.')));
    } else {
      debugPrint('Unhandled PayPal callback URL path: ${uri.path}');
      if (mounted) {
        setState(() => _currentState = _PaymentState.error);
      }
    }
  }

  Future<void> _initiatePayment() async {
    if (mounted) {
      setState(() => _currentState = _PaymentState.initiating);
    }
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      if (mounted) {
        setState(() => _currentState = _PaymentState.error);
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập trước.')));
      return;
    }

    final String cancelUrl = '$_appScheme://$_appHost/cancel';
    final String successUrl = '$_appScheme://$_appHost/complete';

    final paymentRequest = PaymentRequest(
      userId: currentUser.userId,
      orderId: widget.orderId,
      amount: widget.totalAmount,
      paymentMethod: 'paypal',
      description: 'Thanh toán PayPal cho đơn hàng #${widget.orderId}',
      cancelUrl: cancelUrl,
      successUrl: successUrl,
    );

    try {
      final url = await _paymentService.initiatePayPalPayment(paymentRequest);
      Uri? parsedUri = Uri.tryParse(url);
      if (parsedUri == null) {
        throw Exception('URL PayPal không hợp lệ: $url');
      }

      if (mounted) {
        setState(() {
          paypalApprovalUrl = url;
          _currentState = _PaymentState.awaitingUserAction;
        });
      }

      await _launchPayPal(paypalApprovalUrl!);
    } catch (e) {
      if (mounted) {
        setState(() => _currentState = _PaymentState.error);
      }
      debugPrint('Initiate payment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể khởi tạo thanh toán: $e')));
    }
  }

  Future<void> _launchPayPal(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          setState(() => _currentState = _PaymentState.error);
        }
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể mở URL PayPal: $url')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentState = _PaymentState.error);
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi mở PayPal: $e')));
    }
  }

  Future<void> _completePayment(String paymentId, String payerId) async {
    try {
      final PaymentResponse paymentResponse =
      await _paymentService.completePayPalPayment(paymentId, payerId);

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() => _currentState = _PaymentState.success);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Thanh toán thành công! ID giao dịch: ${paymentResponse.paymentId}',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xff50E3C2),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const LessonScreen()));
        }
      });
    } catch (e) {
      debugPrint('Complete payment error: $e');
      if (mounted) {
        setState(() => _currentState = _PaymentState.error);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thanh toán thất bại: $e',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thanh toán PayPal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff4A90E2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(AntDesign.arrowleft, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffF5F7FA), Color(0xffFFFFFF)],
          ),
        ),
        child: Center(
          child: _buildBodyBasedOnState(isSmallScreen),
        ),
      ),
    );
  }

  Widget _buildBodyBasedOnState(bool isSmallScreen) {
    switch (_currentState) {
      case _PaymentState.initial:
      case _PaymentState.initiating:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xff4A90E2)),
            const SizedBox(height: 16),
            Text(
              'Đang khởi tạo thanh toán...',
              style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Vui lòng chờ trong giây lát.',
              style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16, color: Colors.black54),
            ),
          ],
        );
      case _PaymentState.awaitingUserAction:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AntDesign.wallet, color: const Color(0xff4A90E2), size: 80),
            const SizedBox(height: 20),
            Text(
              'Đang chờ hoàn tất thanh toán...',
              style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Vui lòng chuyển sang PayPal để hoàn tất giao dịch.',
              style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                if (paypalApprovalUrl != null && paypalApprovalUrl!.isNotEmpty) {
                  _launchPayPal(paypalApprovalUrl!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không có URL PayPal.')));
                }
              },
              icon: Icon(AntDesign.arrowright, color: Colors.white),
              label: Text(
                'Mở lại PayPal',
                style: TextStyle(
                    color: Colors.white, fontSize: isSmallScreen ? 16 : 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff50E3C2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 25,
                    vertical: isSmallScreen ? 10 : 12),
              ),
            ),
          ],
        );
      case _PaymentState.completing:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xff50E3C2)),
            const SizedBox(height: 16),
            Text(
              'Đang hoàn tất giao dịch...',
              style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Vui lòng không đóng ứng dụng.',
              style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16, color: Colors.black54),
            ),
          ],
        );
      case _PaymentState.success:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AntDesign.checkcircle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              'Thanh toán thành công!',
              style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Giao dịch của bạn đã được xử lý.',
              style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LessonScreen()));
              },
              icon: Icon(AntDesign.arrowright, color: Colors.white),
              label: Text(
                'Quay lại bài học',
                style: TextStyle(
                    color: Colors.white, fontSize: isSmallScreen ? 16 : 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4A90E2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 25,
                    vertical: isSmallScreen ? 10 : 12),
              ),
            ),
          ],
        );
      case _PaymentState.error:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AntDesign.close, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            Text(
              'Thanh toán thất bại!',
              style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Đã xảy ra lỗi. Vui lòng thử lại.',
              style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _initiatePayment(),
              icon: Icon(AntDesign.reload1, color: Colors.white),
              label: Text(
                'Thử lại',
                style: TextStyle(
                    color: Colors.white, fontSize: isSmallScreen ? 16 : 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 25,
                    vertical: isSmallScreen ? 10 : 12),
              ),
            ),
          ],
        );
      case _PaymentState.canceled:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AntDesign.frown, color: Colors.orange, size: 80),
            const SizedBox(height: 20),
            Text(
              'Thanh toán đã bị hủy!',
              style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Bạn đã hủy giao dịch. Thử lại nếu muốn.',
              style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _initiatePayment(),
              icon: Icon(AntDesign.reload1, color: Colors.white),
              label: Text(
                'Thử lại thanh toán',
                style: TextStyle(
                    color: Colors.white, fontSize: isSmallScreen ? 16 : 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4A90E2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 25,
                    vertical: isSmallScreen ? 10 : 12),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}