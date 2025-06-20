import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/learning_material.dart';
import '../../services/auth_service.dart';
import '../../services/progress_service.dart'; // Import ProgressService
import '../../models/progress.dart'; // Import Progress models

class MaterialsTab extends StatefulWidget {
  final Future<List<LearningMaterial>> materialsFuture;
  final Function() updateProgress; // CHANGED: Callback now takes no arguments
  final int userId; // ADDED: Required for progress update
  final int lessonId; // ADDED: Required for progress update

  const MaterialsTab({
    super.key,
    required this.materialsFuture,
    required this.updateProgress,
    required this.userId,
    required this.lessonId,
  });

  @override
  State<MaterialsTab> createState() => _MaterialsTabState();
}

class _MaterialsTabState extends State<MaterialsTab> {
  List<LearningMaterial> _materials = [];
  bool _isLoading = true;
  String? _error;
  late ProgressService _progressService; // Declare ProgressService

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _progressService = ProgressService(authService); // Initialize ProgressService
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    try {
      final data = await widget.materialsFuture;
      setState(() {
        _materials = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Error loading materials: $e');
    }
  }

  // Example: How to update progress when a material is 'completed'
  // This logic depends on how you define completion for a material.
  // For simplicity, let's say tapping on a material marks it as 100% complete.
  Future<void> _markMaterialAsCompleted(LearningMaterial material) async {
    try {
      final progressRequest = ProgressRequest(
        userId: widget.userId,
        lessonId: widget.lessonId,
        activityType: _mapMaterialTypeToActivityType(material.materialType), // Map type to ActivityType
        status: 'COMPLETED',
        completionPercentage: 100,
      );
      await _progressService.updateProgress(progressRequest);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã đánh dấu tài liệu "${material.description ?? material.materialType}" là hoàn thành!')),
      );
      widget.updateProgress(); // Notify parent to refresh overall progress
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật tiến độ: $e')),
      );
    }
  }

  // Helper function to map MaterialType to ActivityType
  String _mapMaterialTypeToActivityType(String materialType) {
    switch (materialType) {
      case 'TEXT':
        return 'READING_MATERIAL';
      case 'AUDIO':
        return 'LISTENING_PRACTICE'; // Or another suitable activity type
      case 'VIDEO':
        return 'LISTENING_PRACTICE'; // Or another suitable activity type
      default:
        return 'OTHER_MATERIAL'; // Fallback or add more specific types
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)));
    } else if (_error != null) {
      return Center(
        child: Text(
          'Lỗi khi tải tài liệu: $_error',
          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_materials.isEmpty) {
      return const Center(
        child: Text(
          'Không có tài liệu học tập nào.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _materials.length,
      itemBuilder: (context, index) {
        final material = _materials[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            // Simulate marking as complete when tapped
            onTap: () => _markMaterialAsCompleted(material),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.materialType,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    material.description ?? 'Không có mô tả',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    material.materialUrl,
                    style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(Icons.check_circle_outline, color: Colors.green.shade400),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
