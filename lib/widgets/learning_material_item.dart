// lib/widgets/learning_material_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/learning_material.dart'; // Đảm bảo đúng đường dẫn

class LearningMaterialItem extends StatelessWidget {
  final LearningMaterial material;
  final Function(double) onOpenMaterial; // Callback khi mở tài liệu
  final bool isSmallScreen;

  const LearningMaterialItem({
    super.key,
    required this.material,
    required this.onOpenMaterial,
    required this.isSmallScreen,
  });

  // Hàm để lấy icon dựa trên loại tài liệu
  IconData _getMaterialIcon(String type) {
    switch (type.toUpperCase()) {
      case 'AUDIO':
        return Icons.audiotrack;
      case 'VIDEO':
        return Icons.videocam;
      case 'TEXT':
        return Icons.description;
      case 'IMAGE':
        return Icons.image;
      case 'PDF':
        return Icons.picture_as_pdf;
      default:
        return AntDesign.file1; // Icon mặc định
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Card đã có padding từ GridView hoặc ListView
      elevation: 6, // Tăng đổ bóng
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // Bo tròn góc
      clipBehavior: Clip.antiAlias, // Cắt nội dung theo bo góc
      child: InkWell(
        onTap: () async {
          final url = Uri.parse(material.materialUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
            onOpenMaterial(10.0); // Gọi callback để cập nhật tiến độ (ví dụ 10% cho mỗi lần mở)
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Không thể mở tài liệu: ${material.materialUrl}', style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều ngang
            children: [
              Icon(
                _getMaterialIcon(material.materialType),
                color: const Color(0xFF4A90E2),
                size: isSmallScreen ? 40 : 50,
              ),
              const SizedBox(height: 10),
              Text(
                material.description,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                'Loại: ${material.materialType}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(), // Đẩy nút/chi tiết khác xuống dưới nếu cần
              Icon(AntDesign.arrowright, color: const Color(0xFF50E3C2), size: isSmallScreen ? 24 : 28),
            ],
          ),
        ),
      ),
    );
  }
}