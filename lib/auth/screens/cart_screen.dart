import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:decimal/decimal.dart';
import 'dart:convert';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';
import '../../services/lesson_service.dart';
import '../../models/lesson.dart';
import '../../models/order.dart';
import 'payment_screen.dart';
import 'lesson_screen.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? initialCartItems;

  const CartScreen({super.key, this.initialCartItems});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  Decimal totalAmount = Decimal.zero;
  late OrderService _orderService;
  late LessonService _lessonService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _orderService = OrderService(authService);
    _lessonService = LessonService(authService);
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCart = prefs.getString('cartItems');
    setState(() {
      _isLoading = true;
    });

    if (widget.initialCartItems != null && widget.initialCartItems!.isNotEmpty) {
      cartItems = [...cartItems];
      for (var newItem in widget.initialCartItems!) {
        bool found = false;
        for (int i = 0; i < cartItems.length; i++) {
          if (cartItems[i]['lessonId'] == newItem['lessonId']) {
            cartItems[i]['quantity'] += newItem['quantity'] as int;
            found = true;
            break;
          }
        }
        if (!found) {
          cartItems.add(newItem);
        }
      }
    } else if (savedCart != null) {
      cartItems = (jsonDecode(savedCart) as List<dynamic>)
          .cast<Map<String, dynamic>>();
    }

    await _fetchLessonDetails();
    await _saveCartItems();
    setState(() {
      _isLoading = false;
      _calculateTotalAmount();
    });
  }

  Future<void> _fetchLessonDetails() async {
    for (var item in cartItems) {
      try {
        final lesson = await _lessonService.getLessonById(item['lessonId']);
        item['title'] = lesson.title;
        item['price'] = lesson.price;
      } catch (e) {
        debugPrint('Error fetching lesson ${item['lessonId']}: $e');
      }
    }
  }

  Future<void> _saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cartItems', jsonEncode(cartItems));
  }

  void _calculateTotalAmount() {
    setState(() {
      totalAmount = cartItems.fold(
          Decimal.zero,
              (sum, item) =>
          sum +
              (item['price'] as Decimal) *
                  Decimal.fromInt(item['quantity'] as int));
    });
  }

  void _updateQuantity(int index, int delta) async {
    setState(() {
      cartItems[index]['quantity'] += delta;
      if (cartItems[index]['quantity'] <= 0) {
        cartItems.removeAt(index);
      }
      _calculateTotalAmount();
    });
    await _saveCartItems();
  }

  void _removeItem(int index) async {
    setState(() {
      cartItems.removeAt(index);
      _calculateTotalAmount();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xóa bài học khỏi giỏ hàng',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    });
    await _saveCartItems();
  }

  Future<void> _createOrder() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng đăng nhập trước',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Giỏ hàng trống, vui lòng thêm bài học để thanh toán',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final orderItems = cartItems
          .map((item) => {
        'lessonId': item['lessonId'],
        'quantity': item['quantity'],
      })
          .toList();

      final Order createdOrder =
      await _orderService.createOrder(currentUser.userId, orderItems);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cartItems'); // Xóa giỏ hàng sau khi tạo đơn
      setState(() {
        cartItems = [];
        _calculateTotalAmount();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Đơn hàng đã tạo thành công với ID: ${createdOrder.orderId}',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xff50E3C2),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
              orderId: createdOrder.orderId,
              totalAmount: createdOrder.totalAmount),
        ),
      );
    } catch (e) {
      debugPrint('Create order error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tạo đơn hàng: $e',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng của bạn',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff4A90E2),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(AntDesign.book, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LessonScreen()));
            },
            tooltip: 'Quay lại danh sách bài học',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff4A90E2)))
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffF5F7FA), Color(0xffFFFFFF)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: cartItems.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AntDesign.shoppingcart,
                        size: isSmallScreen ? 80 : 100,
                        color: Colors.grey[400]),
                    SizedBox(height: 20),
                    Text(
                      'Giỏ hàng trống!',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 24,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Hãy thêm một vài bài học để bắt đầu.',
                      style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const LessonScreen()));
                      },
                      icon: Icon(AntDesign.pluscircleo,
                          size: 20, color: Colors.white),
                      label: Text(
                        'Thêm bài học',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 16 : 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4A90E2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 25 : 30,
                            vertical: isSmallScreen ? 12 : 15),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 4),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            width: isSmallScreen ? 60 : 80,
                            height: isSmallScreen ? 60 : 80,
                            decoration: BoxDecoration(
                              color: const Color(0xff4A90E2)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xff4A90E2),
                                  width: 0.5),
                            ),
                            child: Icon(AntDesign.book,
                                size: isSmallScreen ? 30 : 40,
                                color: const Color(0xff4A90E2)),
                          ),
                          SizedBox(width: isSmallScreen ? 10 : 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] ?? 'Untitled Lesson',
                                  style: TextStyle(
                                    fontSize:
                                    isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                    height: isSmallScreen ? 4 : 6),
                                Text(
                                  '${(item['price'] as Decimal).toStringAsFixed(2)} USD',
                                  style: TextStyle(
                                    fontSize:
                                    isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff50E3C2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(AntDesign.pluscircleo,
                                    color: const Color(0xff50E3C2),
                                    size: isSmallScreen ? 20 : 24),
                                onPressed: () =>
                                    _updateQuantity(index, 1),
                                tooltip: 'Thêm số lượng',
                              ),
                              Text(
                                '${item['quantity']}',
                                style: TextStyle(
                                    fontSize:
                                    isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(AntDesign.minuscircleo,
                                    color: Colors.orange,
                                    size: isSmallScreen ? 20 : 24),
                                onPressed: () =>
                                    _updateQuantity(index, -1),
                                tooltip: 'Giảm số lượng',
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(AntDesign.delete,
                                color: Colors.redAccent,
                                size: isSmallScreen ? 22 : 26),
                            onPressed: () => _removeItem(index),
                            tooltip: 'Xóa khỏi giỏ hàng',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tổng cộng:',
                        style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      Text(
                        '${totalAmount.toStringAsFixed(2)} USD',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff4A90E2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createOrder,
                      icon: Icon(AntDesign.creditcard,
                          color: Colors.white,
                          size: isSmallScreen ? 20 : 24),
                      label: Text(
                        'Tiến hành thanh toán',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff50E3C2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 15 : 18),
                        elevation: 7,
                        shadowColor:
                        const Color(0xff50E3C2).withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}