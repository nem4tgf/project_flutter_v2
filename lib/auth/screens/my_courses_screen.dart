import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart'; // Import icons

import '../../models/enrollment.dart';
import '../../services/auth_service.dart';
import '../../services/enrollment_service.dart';
import 'learning_screen.dart'; // Màn hình học tập bạn đã có

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  _MyCoursesScreenState createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  late Future<List<Enrollment>> _enrollmentsFuture;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final enrollmentService = Provider.of<EnrollmentService>(context, listen: false);

    if (authService.currentUser != null) {
      setState(() {
        _enrollmentsFuture = enrollmentService.getEnrollmentsByUserId(authService.currentUser!.userId);
      });
    } else {
      setState(() {
        _enrollmentsFuture = Future.value([]); // Trả về Future rỗng nếu không có người dùng
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
          'Khóa học của tôi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Color(0xFFFFFFFF)],
          ),
        ),
        child: FutureBuilder<List<Enrollment>>(
          future: _enrollmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)));
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
                      const SizedBox(height: 10),
                      Text(
                        'Lỗi khi tải khóa học: ${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _loadEnrollments,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_outlined, color: Colors.grey[400], size: 80),
                    const SizedBox(height: 10),
                    const Text(
                      'Bạn chưa có khóa học nào đã mua hoặc dữ liệu khóa học bị thiếu.',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Giả định rằng '/home' là route bạn muốn chuyển đến để khám phá
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      icon: const Icon(Icons.explore, color: Colors.white),
                      label: const Text('Khám phá khóa học ngay!', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF50E3C2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Lọc ra các enrollment có lesson là null
            final validEnrollments = snapshot.data!.where((e) => e.lesson != null).toList();

            if (validEnrollments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_outlined, color: Colors.grey[400], size: 80),
                    const SizedBox(height: 10),
                    const Text(
                      'Bạn không có khóa học hợp lệ nào để hiển thị.',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      icon: const Icon(Icons.explore, color: Colors.white),
                      label: const Text('Khám phá khóa học ngay!', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF50E3C2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              );
            }


            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: validEnrollments.length, // Sử dụng danh sách đã lọc
              itemBuilder: (context, index) {
                final enrollment = validEnrollments[index];
                final lesson = enrollment.lesson!; // Giờ đây có thể an toàn sử dụng '!' vì đã lọc null

                // Xác định màu và icon cho trạng thái khóa học
                Color statusColor = enrollment.status == 'ACTIVE' ? Colors.green[700]! : Colors.red[700]!;
                IconData statusIcon = enrollment.status == 'ACTIVE' ? Icons.check_circle : Icons.cancel;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 8, // Tăng đổ bóng
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Bo góc nhiều hơn
                    side: BorderSide(color: Colors.grey[300]!, width: 0.5), // Thêm viền nhẹ
                  ),
                  clipBehavior: Clip.antiAlias, // Đảm bảo nội dung không tràn ra ngoài bo góc
                  child: InkWell(
                    onTap: () {
                      // Chỉ cho phép điều hướng nếu lesson không null (đã được đảm bảo bởi lọc)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LearningScreen(lesson: lesson),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.blue.withOpacity(0.05)], // Gradient nhẹ
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon lớn của kỹ năng
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  _getIconForSkill(lesson.skill), // lesson.skill an toàn
                                  color: const Color(0xFF4A90E2),
                                  size: isSmallScreen ? 36 : 48,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lesson.title, // lesson.title an toàn
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 19 : 22, // Kích thước chữ lớn hơn
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF333333), // Màu chữ tối hơn
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lesson.description, // lesson.description an toàn
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 13 : 15,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: isSmallScreen ? 2 : 3, // Hiển thị nhiều dòng hơn trên màn hình lớn
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Thông tin chi tiết: Cấp độ, Kỹ năng, Ngày đăng ký/hết hạn
                          Wrap(
                            spacing: 12.0, // Khoảng cách giữa các chip/item
                            runSpacing: 8.0, // Khoảng cách giữa các dòng chip
                            children: [
                              _buildInfoChip(
                                icon: AntDesign.dashboard,
                                label: 'Cấp độ: ${lesson.level}', // lesson.level an toàn
                                isSmallScreen: isSmallScreen,
                              ),
                              _buildInfoChip(
                                icon: AntDesign.bulb1,
                                label: 'Kỹ năng: ${lesson.skill}', // lesson.skill an toàn
                                isSmallScreen: isSmallScreen,
                              ),
                              _buildInfoChip(
                                icon: Icons.calendar_today_outlined,
                                label: 'Đăng ký: ${enrollment.enrollmentDate.toLocal().toString().split(' ')[0]}',
                                isSmallScreen: isSmallScreen,
                              ),
                              _buildInfoChip(
                                icon: Icons.event_busy_outlined,
                                label: 'Hết hạn: ${enrollment.expiryDate.toLocal().toString().split(' ')[0]}',
                                isSmallScreen: isSmallScreen,
                                color: Colors.orange[700],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Trạng thái và nút "Bắt đầu học"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(statusIcon, color: statusColor, size: isSmallScreen ? 18 : 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Trạng thái: ${enrollment.status}',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Chỉ cho phép điều hướng nếu lesson không null (đã được đảm bảo bởi lọc)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LearningScreen(lesson: lesson),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                                label: Text(
                                  'Bắt đầu học',
                                  style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 14 : 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF50E3C2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Nút bo tròn
                                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 15 : 20, vertical: isSmallScreen ? 10 : 12),
                                  elevation: 5, // Đổ bóng cho nút
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Widget phụ trợ cho các chip thông tin
  Widget _buildInfoChip({required IconData icon, required String label, required bool isSmallScreen, Color? color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 10, vertical: isSmallScreen ? 4 : 6),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1) ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Đảm bảo kích thước vừa với nội dung
        children: [
          Icon(icon, size: isSmallScreen ? 14 : 16, color: color ?? Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: isSmallScreen ? 11 : 13, color: color ?? Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // Phương thức lấy Icon cho Skill (như đã cập nhật ở LessonScreen)
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
