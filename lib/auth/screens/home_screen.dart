import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'listening_list_screen.dart';
import 'reading_list_screen.dart';
import 'writing_list_screen.dart';
import 'my_courses_screen.dart';
import 'lesson_screen.dart'; // Import LessonScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Danh sách các trang sẽ được hiển thị khi người dùng chọn tab
  List<Widget> get _pages => [
    _buildLearningPage(),       // Index 0: Trang chủ/Học tập
    _buildPracticePage(),       // Index 1: Luyện tập
    const LessonScreen(),       // Index 2: Tất cả các khóa học (bài học)
    _buildVocabularyPage(),     // Index 3: Từ vựng
    _buildCommunityPage(),      // Index 4: Cộng đồng
    _buildProfilePage(),        // Index 5: Hồ sơ
    // const MyCoursesScreen(), // Nếu bạn muốn MyCoursesScreen riêng biệt
  ];

  // Hàm chuyển trang có hiệu ứng
  void pushWithTransition(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeInOut));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  // --- Các hàm build trang chính (không thay đổi nhiều) ---
  Widget _buildLearningPage() {
    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          _searchField(),
          const SizedBox(height: 40),
          _categoriesSection(context),
          const SizedBox(height: 40),
          _recommendationSection(),
          const SizedBox(height: 40),
          _popularSection(),
        ],
      ),
    );
  }

  Widget _buildPracticePage() {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Luyện tập kỹ năng',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          _buildPracticeCategory('Nghe', MaterialCommunityIcons.headphones, Colors.green[100]!, () {
            pushWithTransition(context, const ListeningListScreen());
          }),
          _buildPracticeCategory('Đọc', AntDesign.book, Colors.blue[100]!, () {
            pushWithTransition(context, const ReadingListScreen());
          }),
          _buildPracticeCategory('Viết', AntDesign.edit, Colors.orange[100]!, () {
            pushWithTransition(context, const WritingListScreen());
          }),
        ],
      ),
    );
  }

  Widget _buildVocabularyPage() {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Học từ vựng',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          _buildVocabularyCard('Từ vựng hàng ngày', 'Học 10 từ mới hôm nay', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển')),
            );
          }),
          _buildVocabularyCard('Từ vựng IELTS', 'Từ thiết yếu cho IELTS', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển')),
            );
          }),
          _buildVocabularyCard('Flashcards', 'Luyện tập với flashcards', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển')),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCommunityPage() {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Tham gia cộng đồng',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          _buildCommunityCard('Diễn đàn thảo luận', 'Chia sẻ và đặt câu hỏi', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển')),
            );
          }),
          _buildCommunityCard('Trò chuyện trực tiếp', 'Nói chuyện với học viên khác', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển')),
            );
          }),
          _buildCommunityCard('Bảng xếp hạng', 'Xem top học viên', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng đang phát triển')),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    final authService = Provider.of<AuthService>(context);
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: authService.currentUser?.avatarUrl != null
                ? NetworkImage(authService.currentUser!.avatarUrl!)
                : null,
            child: authService.currentUser?.avatarUrl == null
                ? const Icon(AntDesign.user, size: 50, color: Colors.white)
                : null,
            backgroundColor: const Color(0xff4A90E2),
          ),
          const SizedBox(height: 20),
          Text(
            authService.currentUser?.fullName ?? 'Hồ sơ người dùng',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(AntDesign.setting),
            title: const Text('Cài đặt'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
          ),
          ListTile(
            leading: const Icon(MaterialCommunityIcons.history),
            title: const Text('Lịch sử học tập'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
          ),
          ListTile(
            leading: const Icon(AntDesign.logout),
            title: const Text('Đăng xuất'),
            onTap: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }

  // --- Các hàm build widget phụ trợ (không thay đổi nhiều) ---
  Widget _buildPracticeCategory(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.white, child: Icon(icon, color: Colors.black87)),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        trailing: const Icon(AntDesign.arrowright, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }

  Widget _buildVocabularyCard(String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: const Icon(AntDesign.book, color: Color(0xff4A90E2)),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        trailing: const Icon(AntDesign.arrowright, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCommunityCard(String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: const Icon(AntDesign.team, color: Colors.purple),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        trailing: const Icon(AntDesign.arrowright, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }

  Widget _searchField() {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1D1617).withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(15),
          hintText: 'Tìm kiếm bài học',
          hintStyle: const TextStyle(color: Color(0xffDDDADA), fontSize: 14),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(AntDesign.search1, color: Colors.grey),
          ),
          suffixIcon: const SizedBox(
            width: 100,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  VerticalDivider(
                    color: Colors.black,
                    indent: 10,
                    endIndent: 10,
                    thickness: 0.1,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(AntDesign.filter, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _categoriesSection(BuildContext context) {
    final categories = [
      {'name': 'Đọc', 'color': Colors.blue[100]!, 'icon': AntDesign.book},
      {'name': 'Nghe', 'color': Colors.green[100]!, 'icon': MaterialCommunityIcons.headphones},
      {'name': 'Viết', 'color': Colors.orange[100]!, 'icon': AntDesign.edit},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Danh mục',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView.separated(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            separatorBuilder: (context, index) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 100,
                decoration: BoxDecoration(
                  color: category['color'] as Color,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: (category['color'] as Color).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: Colors.black87,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category['name'] as String,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _recommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Đề xuất cho bạn',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 200,
          child: ListView.separated(
            itemCount: 5, // Số lượng đề xuất mẫu
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            separatorBuilder: (context, index) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              return Container(
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        AntDesign.star,
                        color: Color(0xff4A90E2),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bài học thú vị',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'Cấp độ trung bình',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _popularSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Phổ biến nhất',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 15),
        ListView.separated(
          itemCount: 3, // Số lượng bài học phổ biến mẫu
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      AntDesign.checkcircleo,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Kỹ năng Giao tiếp',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Cải thiện khả năng nói',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(AntDesign.arrowright, color: Colors.grey),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'English Learning App',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: _pages[_selectedIndex], // Hiển thị trang được chọn
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xff4A90E2),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Đảm bảo các item không bị dịch chuyển
        items: const [
          BottomNavigationBarItem(
            icon: Icon(AntDesign.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(AntDesign.form),
            label: 'Luyện tập',
          ),
          BottomNavigationBarItem(
            icon: Icon(AntDesign.book), // Icon cho "Khóa học"
            label: 'Khóa học', // Label mới cho LessonScreen
          ),
          BottomNavigationBarItem(
            icon: Icon(AntDesign.bulb1),
            label: 'Từ vựng',
          ),
          BottomNavigationBarItem(
            icon: Icon(AntDesign.team),
            label: 'Cộng đồng',
          ),
          BottomNavigationBarItem(
            icon: Icon(AntDesign.user),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}