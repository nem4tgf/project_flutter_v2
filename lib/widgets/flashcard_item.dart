import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:audioplayers/audioplayers.dart'; // Đảm bảo đã thêm vào pubspec.yaml
import '../../models/flashcard.dart'; // Đảm bảo đúng đường dẫn

class FlashcardItem extends StatefulWidget {
  final FlashcardResponse flashcard;
  final Function(int wordId, bool isKnown) onMarkToggle; // Callback khi đánh dấu
  final bool isSmallScreen;

  const FlashcardItem({
    super.key,
    required this.flashcard,
    required this.onMarkToggle,
    required this.isSmallScreen,
  });

  @override
  State<FlashcardItem> createState() => _FlashcardItemState();
}

class _FlashcardItemState extends State<FlashcardItem> {
  bool _isFlipped = false;
  late bool _currentIsKnown; // Trạng thái "đã biết" cục bộ để UI phản hồi nhanh
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _currentIsKnown = widget.flashcard.isKnown;
  }

  // Cập nhật trạng thái _currentIsKnown nếu flashcard từ bên ngoài thay đổi (sau khi service cập nhật)
  @override
  void didUpdateWidget(covariant FlashcardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flashcard.isKnown != oldWidget.flashcard.isKnown) {
      _currentIsKnown = widget.flashcard.isKnown;
    }
  }

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  Future<void> _playAudio() async {
    if (widget.flashcard.audioUrl != null && widget.flashcard.audioUrl!.isNotEmpty) {
      try {
        await _audioPlayer.play(UrlSource(widget.flashcard.audioUrl!));
      } catch (e) {
        // Hiển thị thông báo lỗi thân thiện nếu không phát được âm thanh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể phát âm thanh: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có liên kết âm thanh cho từ này.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  // Hàm để lấy màu sắc dựa trên độ khó
  Color _getDifficultyColor(String level) {
    switch (level.toUpperCase()) {
      case 'EASY':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HARD':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Giải phóng tài nguyên audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Card đã có padding từ GridView
      elevation: 6, // Tăng đổ bóng để trông nổi bật hơn
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // Bo tròn góc
      clipBehavior: Clip.antiAlias, // Cắt nội dung theo bo góc
      child: InkWell(
        onTap: _toggleFlip, // Lật thẻ khi chạm vào bất kỳ đâu trên thẻ
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400), // Thời gian animation lật
          transitionBuilder: (Widget child, Animation<double> animation) {
            final rotate = Tween(begin: 1.0, end: 0.0).animate(animation);
            return AnimatedBuilder(
              animation: rotate,
              child: child,
              builder: (context, child) {
                // Đảm bảo key để AnimatedSwitcher biết khi nào một widget mới được thay thế
                final isFront = child!.key == const ValueKey('front');
                final angle = isFront ? rotate.value * -3.14159 : rotate.value * 3.14159;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Thêm hiệu ứng 3D (perspective)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: child,
                );
              },
            );
          },
          // Hiển thị mặt trước hoặc mặt sau tùy thuộc vào trạng thái _isFlipped
          child: _isFlipped ? _buildBack() : _buildFront(),
        ),
      ),
    );
  }

  // Xây dựng giao diện mặt trước của flashcard (từ vựng)
  Widget _buildFront() {
    return Container(
      key: const ValueKey('front'), // Key cho AnimatedSwitcher
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue.shade50.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa nội dung theo chiều ngang
        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung theo chiều dọc
        children: [
          // Từ vựng và nút phát âm
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible( // Dùng Flexible để từ dài không bị tràn
                child: Text(
                  widget.flashcard.word,
                  style: TextStyle(
                    fontSize: widget.isSmallScreen ? 24 : 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.flashcard.audioUrl != null && widget.flashcard.audioUrl!.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.volume_up, color: Colors.blueAccent, size: widget.isSmallScreen ? 24 : 28),
                  onPressed: _playAudio, // Gọi hàm phát âm thanh
                  tooltip: 'Nghe phát âm',
                ),
            ],
          ),
          // Phát âm (IPA)
          if (widget.flashcard.pronunciation != null && widget.flashcard.pronunciation!.isNotEmpty)
            Text(
              '/${widget.flashcard.pronunciation}/',
              style: TextStyle(
                fontSize: widget.isSmallScreen ? 16 : 18,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 10),
          // Mức độ khó
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getDifficultyColor(widget.flashcard.difficultyLevel).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Độ khó: ${widget.flashcard.difficultyLevel}',
              style: TextStyle(
                fontSize: widget.isSmallScreen ? 12 : 14,
                color: _getDifficultyColor(widget.flashcard.difficultyLevel),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(), // Đẩy các phần tử lên trên và nút xuống dưới
          // Nút đánh dấu đã biết/chưa biết
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentIsKnown = !_currentIsKnown; // Thay đổi trạng thái cục bộ ngay lập tức
              });
              widget.onMarkToggle(widget.flashcard.wordId, _currentIsKnown); // Gọi callback để cập nhật lên service
            },
            icon: Icon(
              _currentIsKnown ? Icons.check_circle_outline : Icons.help_outline,
              color: Colors.white,
              size: widget.isSmallScreen ? 18 : 22,
            ),
            label: Text(
              _currentIsKnown ? 'Đã biết' : 'Chưa biết',
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentIsKnown ? Colors.green.shade600 : Colors.orange.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.symmetric(horizontal: widget.isSmallScreen ? 15 : 20, vertical: widget.isSmallScreen ? 8 : 10),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng giao diện mặt sau của flashcard (nghĩa, ví dụ, gợi ý)
  Widget _buildBack() {
    return Container(
      key: const ValueKey('back'), // Key cho AnimatedSwitcher
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50.withOpacity(0.8), Colors.white],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nghĩa:',
            style: TextStyle(
              fontSize: widget.isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade700,
            ),
          ),
          const SizedBox(height: 5),
          Flexible( // Dùng Flexible để nghĩa dài không bị tràn
            child: Text(
              widget.flashcard.meaning,
              style: TextStyle(
                fontSize: widget.isSmallScreen ? 18 : 22,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Ví dụ câu (nếu có)
          if (widget.flashcard.exampleSentence != null && widget.flashcard.exampleSentence!.isNotEmpty) ...[
            const SizedBox(height: 15),
            Text(
              'Ví dụ:',
              style: TextStyle(
                fontSize: widget.isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
            const SizedBox(height: 5),
            Flexible(
              child: Text(
                widget.flashcard.exampleSentence!,
                style: TextStyle(
                  fontSize: widget.isSmallScreen ? 14 : 16,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          // Gợi ý viết (nếu có)
          if (widget.flashcard.writingPrompt != null && widget.flashcard.writingPrompt!.isNotEmpty) ...[
            const SizedBox(height: 15),
            Text(
              'Gợi ý viết:',
              style: TextStyle(
                fontSize: widget.isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
            const SizedBox(height: 5),
            Flexible(
              child: Text(
                widget.flashcard.writingPrompt!,
                style: TextStyle(
                  fontSize: widget.isSmallScreen ? 14 : 16,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
          const Spacer(), // Đẩy nút "Xem Từ" xuống dưới cùng
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton.icon(
              onPressed: _toggleFlip, // Lật lại mặt trước
              icon: Icon(Icons.rotate_right, size: widget.isSmallScreen ? 18 : 22, color: Colors.blueGrey),
              label: Text(
                'Xem Từ',
                style: TextStyle(fontSize: widget.isSmallScreen ? 14 : 16, color: Colors.blueGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}