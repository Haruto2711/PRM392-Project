import 'package:flutter/material.dart';
import '../mock_data.dart';
import 'folding_steps_screen.dart';
import '../utils/settings_manager.dart';
import '../utils/database_helper.dart';

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
                      child: Image.asset(
                        model.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.menu_book,
                              size: 100,
                              color: Colors.indigo,
                            ),
                          );
                        },
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
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: Colors.indigo.withOpacity(0.3),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoldingStepsScreen(model: model),
                          ),
                        );
                        setState(() {}); // Làm mới giao diện khi gấp xong hoặc lưu dở
                      },
                      child: Text(
                        model.currentStep > 0
                            ? SettingsManager.translate('continue_folding')
                            : SettingsManager.translate('start_folding'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
