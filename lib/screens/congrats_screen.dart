import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../utils/settings_manager.dart';

class CongratsScreen extends StatelessWidget {
  final OrigamiModel model;

  const CongratsScreen({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final descColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Ảnh mẫu Origami đã hoàn thành (Complete.png)
              Center(
                child: Container(
                  height: 180,
                  width: 320,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    model.imagePath.replaceAll('Cover.png', 'Complete.png'),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: Colors.amber.shade400,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Congratulations text
              Center(
                child: Text(
                  SettingsManager.translate('congrats_title'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${SettingsManager.translate('congrats_desc')}\n"${model.title}"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  SettingsManager.translate('congrats_record'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: descColor,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),

              // Button to return to Home
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 4,
                  shadowColor: Colors.indigo.withOpacity(0.3),
                ),
                onPressed: () {
                  // Đưa người dùng về màn hình Home
                  Navigator.pop(context);
                },
                child: Text(
                  SettingsManager.translate('congrats_back'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
