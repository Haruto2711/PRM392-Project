import 'package:flutter/material.dart';
import '../mock_data.dart';
import 'folding_steps_screen.dart';
import '../utils/settings_manager.dart';
import '../utils/database_helper.dart';
import '../widgets/video_step_player.dart';
import '../widgets/origami_cover_image.dart';

class OrigamiDetailScreen extends StatefulWidget {
  final OrigamiModel model;

  const OrigamiDetailScreen({Key? key, required this.model}) : super(key: key);

  @override
  _OrigamiDetailScreenState createState() => _OrigamiDetailScreenState();
}

class _OrigamiDetailScreenState extends State<OrigamiDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final model = widget.model;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Body Content
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Media Area
                  Container(
                    height: 260,
                    width: double.infinity,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFEEF2F6),
                    child: Hero(
                      tag: 'model-${model.id}',
                      child: OrigamiCoverImage(
                        imagePath: model.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Detail Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            model.category,
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          model.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Specs/Params Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSpecItem(Icons.star, Colors.amber, '${model.difficulty}/5', SettingsManager.translate('difficulty')),
                            _buildSpecItem(
                              Icons.grid_view,
                              Colors.blue,
                              SettingsManager.translate('all') == 'All' ? '${model.stepsCount} steps' : '${model.stepsCount} bước',
                              SettingsManager.translate('steps_count'),
                            ),
                            _buildSpecItem(
                              Icons.access_time,
                              Colors.green,
                              model.timeEstimate.replaceAll('phút', SettingsManager.translate('all') == 'All' ? 'mins' : 'phút'),
                              SettingsManager.translate('time_estimate'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Description
                        Text(
                          SettingsManager.translate('detail_desc'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          model.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF64748B),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Top Actions Bar (Float)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B), size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B).withOpacity(0.9) : Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: Icon(
                        model.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: model.isFavorite ? Colors.red : (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)),
                      ),
                      onPressed: () async {
                        final user = await DatabaseHelper.instance.getCurrentUser();
                        if (user != null) {
                          final userId = user['id'] as int;
                          await DatabaseHelper.instance.toggleFavorite(userId, model.id);
                          setState(() {
                            model.isFavorite = !model.isFavorite;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(model.isFavorite
                                  ? SettingsManager.translate('favorite_added')
                                  : SettingsManager.translate('favorite_removed')),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Bottom CTA Buttons
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480), // Giới hạn chiều rộng tối đa để cân đối trên Web/Tablet
                  child: Row(
                    children: [
                      if (model.videoTutorial != null) ...[
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.red.withOpacity(0.15)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.red.withOpacity(0.3)
                                  : const Color(0xFFFEE2E2),
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showVideoTutorial(context, model.videoTutorial!, model.title),
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Color(0xFFEF4444),
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoldingStepsScreen(model: model),
                                  ),
                                );
                                setState(() {}); // Làm mới giao diện khi gấp xong hoặc lưu dở
                              },
                              child: Center(
                                child: Text(
                                  model.currentStep > 0
                                      ? SettingsManager.translate('continue_folding')
                                      : SettingsManager.translate('start_folding'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoTutorial(BuildContext context, String videoPath, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false, // Vô hiệu hóa kéo để tránh xung đột cử chỉ tua video
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF3B4252), // Beautiful dark slate color matching the screenshot
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Playful Title Text
              Center(
                child: Text(
                  SettingsManager.translate('all') == 'All'
                      ? 'Watch the $title Video Tutorial'
                      : 'Xem Video Hướng Dẫn $title',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Video Player Frame
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.black,
                    child: VideoStepPlayer(
                      assetPath: videoPath,
                      startMuted: false,
                      showControls: true,
                      looping: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Close Button
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: Text(
                    SettingsManager.translate('all') == 'All' ? 'Close' : 'Đóng',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecItem(IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
