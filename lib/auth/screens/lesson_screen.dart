import 'package:flutter/material.dart';
import 'package:flutter_auth_app/auth/screens/progress_tab.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';

// Import các models và services cần thiết
import '../../models/lesson.dart';
import '../../models/enrollment.dart';
import '../../models/learning_material.dart';
import '../../models/flashcard.dart';
import '../../models/progress.dart';
import '../../services/auth_service.dart';
import '../../services/lesson_service.dart';
import '../../services/enrollment_service.dart';
import '../../services/learning_material_service.dart';
import '../../services/quiz_service.dart';
import '../../services/flashcard_service.dart';
import '../../services/progress_service.dart';
import 'cart_screen.dart';
import 'learning_screen.dart';
import 'flashcards_tab.dart';
import 'quiz_results_tab.dart';
import 'package:decimal/decimal.dart';
import 'package:collection/collection.dart'; // Import for firstWhereOrNull

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> with TickerProviderStateMixin {
  late Future<List<Lesson>> _lessonsFuture;
  late Future<List<Enrollment>> _enrollmentsFuture;
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final authService = Provider.of<AuthService>(context, listen: false);
    final lessonService = LessonService(authService);
    final enrollmentService = EnrollmentService(authService);

    _lessonsFuture = lessonService.fetchLessons();
    // Đảm bảo chỉ gọi getEnrollmentsByUserId nếu currentUser không null
    _enrollmentsFuture = authService.currentUser != null
        ? enrollmentService.getEnrollmentsByUserId(authService.currentUser!.userId)
        : Future.value([]); // Trả về Future rỗng nếu không có người dùng

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.95).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addToCart(int lessonId, String title, Decimal price) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm bài học "$title" vào giỏ hàng',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF50E3C2),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          initialCartItems: [
            {'lessonId': lessonId, 'title': title, 'price': price, 'quantity': 1}
          ],
        ),
      ),
    );
  }

  void _startLearning(Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LearningScreen(lesson: lesson),
      ),
    );
  }

  bool _isLessonAccessible(Lesson lesson, List<Enrollment> enrollments) {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser == null) return false;

    // Sử dụng firstWhereOrNull để tìm kiếm và tránh lỗi nếu không tìm thấy
    final activeEnrollment = enrollments.firstWhereOrNull(
          (e) => e.lesson?.lessonId == lesson.lessonId && e.status == 'ACTIVE' && (e.expiryDate?.isAfter(DateTime.now()) ?? false),
    );
    return activeEnrollment != null;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, mediaQuery.padding.top + 20, 20, 0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(AntDesign.book, color: Colors.white, size: isSmallScreen ? 28 : 32),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Danh sách bài học',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(AntDesign.shoppingcart, color: Colors.white),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const CartScreen()));
                        },
                        tooltip: 'Xem giỏ hàng',
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.7),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(text: 'Khóa học của tôi'),
                        Tab(text: 'Khóa học khác'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLessonList(context, true),
                  _buildLessonList(context, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonList(BuildContext context, bool showAccessibleLessons) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.width < 600;

    return FutureBuilder<List<Lesson>>(
      future: _lessonsFuture,
      builder: (context, lessonSnapshot) {
        if (lessonSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)));
        } else if (lessonSnapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Lỗi khi tải bài học: ${lessonSnapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
          );
        } else if (!lessonSnapshot.hasData || lessonSnapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Không có bài học nào',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          );
        }

        final allLessons = lessonSnapshot.data!;
        return FutureBuilder<List<Enrollment>>(
          future: _enrollmentsFuture,
          builder: (context, enrollmentSnapshot) {
            if (enrollmentSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)));
            }
            // Đảm bảo enrollments không bao giờ là null
            final enrollments = enrollmentSnapshot.data ?? [];

            final filteredLessons = allLessons.where((lesson) {
              final isAccessible = _isLessonAccessible(lesson, enrollments);
              return showAccessibleLessons ? isAccessible : !isAccessible;
            }).toList();

            if (filteredLessons.isEmpty) {
              return Center(
                child: Text(
                  showAccessibleLessons
                      ? 'Bạn chưa có khóa học nào đang học.'
                      : 'Không có khóa học nào để mua thêm.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmallScreen ? 2 : 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: isSmallScreen ? 0.8 : 0.9,
              ),
              itemCount: filteredLessons.length,
              itemBuilder: (context, index) {
                final lesson = filteredLessons[index];
                final isAccessible = _isLessonAccessible(lesson, enrollments);

                // Lấy enrollment hiện tại nếu có
                final currentEnrollment = enrollments.firstWhereOrNull(
                      (e) => e.lesson?.lessonId == lesson.lessonId && e.status == 'ACTIVE' && (e.expiryDate?.isAfter(DateTime.now()) ?? false),
                );

                return GestureDetector(
                  onTapDown: (_) => _animationController.forward(),
                  onTapUp: (_) => _animationController.reverse(),
                  onTapCancel: () => _animationController.reverse(),
                  onTap: () {
                    _animationController.forward().then((_) {
                      _animationController.reverse();
                      if (isAccessible) {
                        _startLearning(lesson);
                      } else {
                        _addToCart(lesson.lessonId, lesson.title, lesson.price);
                      }
                    });
                  },
                  child: Transform.scale(
                    scale: _animation.value,
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIconForSkill(lesson.skill),
                                  color: const Color(0xFF4A90E2),
                                  size: isSmallScreen ? 24 : 28,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              lesson.title,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Level: ${lesson.level} | Skill: ${lesson.skill}',
                              style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 12,
                                  color: Colors.black54),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (lesson.durationMonths != null)
                              Text(
                                'Thời hạn: ${lesson.durationMonths} tháng',
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 12,
                                    color: Colors.black54),
                              ),
                            // Chỉ hiển thị ngày hết hạn nếu có và bài học có thể truy cập
                            if (isAccessible && currentEnrollment != null && currentEnrollment.expiryDate != null)
                              Text(
                                'Hết hạn: ${currentEnrollment.expiryDate!.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 12,
                                    color: Colors.redAccent),
                              ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${lesson.price.toStringAsFixed(0)} VNĐ',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: const Color(0xFF50E3C2),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Icon(
                                  isAccessible
                                      ? AntDesign.playcircleo
                                      : AntDesign.shoppingcart,
                                  color: isAccessible
                                      ? Colors.green
                                      : const Color(0xFF4A90E2),
                                  size: isSmallScreen ? 20 : 24,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  IconData _getIconForSkill(String skill) {
    switch (skill.toLowerCase()) {
      case 'listening':
        return MaterialCommunityIcons.headphones;
      case 'speaking':
        return AntDesign.message1;
      case 'reading':
        return AntDesign.book;
      case 'writing':
        return AntDesign.edit;
      case 'vocabulary':
        return AntDesign.bulb1;
      case 'grammar':
        return AntDesign.form;
      default:
        return AntDesign.book;
    }
  }
}
