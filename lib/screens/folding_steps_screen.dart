import 'package:flutter/material.dart';
import '../mock_data.dart';
import 'congrats_screen.dart';
import '../utils/settings_manager.dart';
import '../utils/database_helper.dart';
import '../widgets/video_step_player.dart';

class FoldingStepsScreen extends StatefulWidget {
  final OrigamiModel model;

  const FoldingStepsScreen({Key? key, required this.model}) : super(key: key);

  @override
  _FoldingStepsScreenState createState() => _FoldingStepsScreenState();
}

class _FoldingStepsScreenState extends State<FoldingStepsScreen> {
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    // Nếu có tiến trình gấp dở, khôi phục lại bước trước đó
    if (widget.model.currentStep > 0 && !widget.model.isCompleted) {
      _currentStepIndex = widget.model.currentStep - 1;
    }
  }

  void _saveAndExit() async {
    final user = await DatabaseHelper.instance.getCurrentUser();
    if (user != null) {
      final userId = user['id'] as int;
      await DatabaseHelper.instance.updateProgress(userId, widget.model.id, _currentStepIndex + 1, 0);
    }
    widget.model.currentStep = _currentStepIndex + 1;
    widget.model.isCompleted = false;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SettingsManager.translate('save_success')), duration: const Duration(seconds: 1)),
      );
      Navigator.pop(context);
    }
  }

  void _completeFolding() async {
    final user = await DatabaseHelper.instance.getCurrentUser();
    if (user != null) {
      final userId = user['id'] as int;
      await DatabaseHelper.instance.updateProgress(userId, widget.model.id, widget.model.stepsCount, 1);
    }
    widget.model.currentStep = widget.model.stepsCount;
    widget.model.isCompleted = true;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CongratsScreen(model: widget.model),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final isLastStep = _currentStepIndex == model.steps.length - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).appBarTheme.foregroundColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)),
          ),
          onPressed: _saveAndExit,
        ),
        title: Text(
          model.title,
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (model.videoTutorial != null)
            IconButton(
              icon: const Icon(Icons.play_circle_fill, color: Colors.redAccent),
              tooltip: SettingsManager.translate('all') == 'All' ? 'Watch Tutorial Video' : 'Xem Video Hướng Dẫn',
              onPressed: () => _showVideoTutorial(context, model.videoTutorial!, model.title),
            ),
          TextButton(
            onPressed: _saveAndExit,
            child: Text(
              SettingsManager.translate('save_exit'),
              style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chỉ báo bước hiện tại
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${SettingsManager.translate('step_label')} ${_currentStepIndex + 1} / ${model.steps.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.indigo.withOpacity(0.15)
                          : Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${((_currentStepIndex + 1) / model.steps.length * 100).toInt()}% ${SettingsManager.translate('step_completed')}',
                      style: const TextStyle(color: Colors.indigo, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              // Thanh Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentStepIndex + 1) / model.steps.length,
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  color: Colors.indigo,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 24),

              // Khung hiển thị ảnh minh họa hoặc ảnh thật từ assets
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.03,
                        ),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Builder(
                    builder: (context) {
                      final hasImage = _currentStepIndex < model.stepImages.length &&
                          model.stepImages[_currentStepIndex].isNotEmpty;
                      final hasDiagram = model.stepDiagrams.isNotEmpty &&
                          _currentStepIndex < model.stepDiagrams.length &&
                          model.stepDiagrams[_currentStepIndex].isNotEmpty;

                      // Widget con hiển thị ảnh chụp hoặc video
                      Widget buildPhotoOrVideo() {
                        final imagePath = model.stepImages[_currentStepIndex];
                        if (imagePath.endsWith('.mp4')) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: VideoStepPlayer(
                              key: ValueKey(imagePath),
                              assetPath: imagePath,
                              autoPlay: true,
                              looping: true,
                              startMuted: true,
                              showControls: true,
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderStepImage();
                            },
                          ),
                        );
                      }

                      // Widget con hiển thị sơ đồ vẽ
                      Widget buildDiagram() {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            model.stepDiagrams[_currentStepIndex],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderStepImage();
                            },
                          ),
                        );
                      }

                      if (hasImage && hasDiagram) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Khung bên trái: Ảnh / Video thực tế
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFF1E293B)
                                        : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: buildPhotoOrVideo(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Khung bên phải: Sơ đồ vẽ (nền trắng tinh tế giống hướng dẫn gốc)
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.15),
                                      width: 1,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: buildDiagram(),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (hasImage) {
                        return buildPhotoOrVideo();
                      } else if (hasDiagram) {
                        return buildDiagram();
                      } else {
                        return _buildPlaceholderStepImage();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Hướng dẫn văn bản
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.02,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SettingsManager.translate('instruction'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model.steps[_currentStepIndex],
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Các nút bấm điều hướng
              Row(
                children: [
                  // Nút Quay lại
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.indigo),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _currentStepIndex > 0
                          ? () {
                              setState(() {
                                _currentStepIndex--;
                              });
                            }
                          : null,
                      child: Text(
                        SettingsManager.translate('back'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Nút Tiếp theo / Hoàn thành
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: Colors.indigo.withOpacity(0.3),
                      ),
                      onPressed: isLastStep ? _completeFolding : () {
                        setState(() {
                          _currentStepIndex++;
                        });
                      },
                      child: Text(
                        isLastStep ? SettingsManager.translate('finish') : SettingsManager.translate('next'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildPlaceholderStepImage() {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E293B)
          : Colors.indigo.shade50,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.gesture, size: 72, color: Colors.indigo),
          const SizedBox(height: 16),
          Text(
            '${SettingsManager.translate('step_image_placeholder_title')} ${_currentStepIndex + 1}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              SettingsManager.translate('step_image_placeholder_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}
