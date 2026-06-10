import 'package:flutter/material.dart';
import '../mock_data.dart';
import 'origami_detail_screen.dart';
import 'folding_steps_screen.dart';
import 'setting_details_screen.dart';
import 'profile_screen.dart';
import '../utils/settings_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'Tất cả';
  String _selectedDifficulty = 'Tất cả';

  // Thống kê số lượng hoàn thành dựa trên MockData
  int get _completedCount {
    return MockData.models.where((m) => m.isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildCurrentTab(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: SettingsManager.translate('tab_home')),
          BottomNavigationBarItem(icon: const Icon(Icons.explore), label: SettingsManager.translate('tab_explore')),
          BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: SettingsManager.translate('tab_favorite')),
          BottomNavigationBarItem(icon: const Icon(Icons.trending_up), label: SettingsManager.translate('tab_progress')),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: SettingsManager.translate('tab_settings')),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildExploreTab();
      case 2:
        return _buildFavoritesTab();
      case 3:
        return _buildProgressTab();
      case 4:
        return _buildSettingsTab();
      default:
        return _buildHomeTab();
    }
  }

  // ================= TAB 0: TRANG CHỦ =================
  Widget _buildHomeTab() {
    final inProgressModels = MockData.models.where((m) => m.currentStep > 0 && !m.isCompleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Chào mừng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SettingsManager.translate('hello_user'),
                    style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nguyễn Văn A',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                  setState(() {}); // Làm mới stats (số mẫu đã hoàn thành) khi quay lại
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Colors.indigo, Colors.purple]),
                  ),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),

          // Banner Thử thách
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.indigo, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SettingsManager.translate('my_achievement'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        SettingsManager.translate('all') == 'All'
                            ? 'Completed: $_completedCount models'
                            : 'Đã hoàn thành: $_completedCount mẫu',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        SettingsManager.translate('all') == 'All'
                            ? 'Keep practicing to level up your skills!'
                            : 'Cùng luyện tập để nâng cao kỹ năng nhé!',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.emoji_events, color: Colors.white, size: 36),
                )
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Mẫu đang gấp dở (Progress Horizontal Card)
          if (inProgressModels.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      SettingsManager.translate('in_progress_title'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.book, color: Colors.indigo, size: 20),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 3; // Chuyển sang tab Tiến độ
                    });
                  },
                  child: Text(
                    SettingsManager.translate('view_all'),
                    style: const TextStyle(color: Colors.indigo),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildProgressItemCard(inProgressModels.first),
            const SizedBox(height: 28),
          ],

          // Mẫu gợi ý (Grid ngắn)
          Row(
            children: [
              Text(
                SettingsManager.translate('all') == 'All' ? 'Popular Folding' : 'Mẫu gấp phổ biến',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.78,
            ),
            itemCount: MockData.models.take(2).length,
            itemBuilder: (context, index) {
              return _buildOrigamiCard(MockData.models[index]);
            },
          ),
        ],
      ),
    );
  }

  // ================= TAB 1: KHÁM PHÁ (DANH SÁCH ORIGAMI) =================
  Widget _buildExploreTab() {
    // Lọc theo bộ lọc danh mục và độ khó
    final filteredModels = MockData.models.where((m) {
      final matchCategory = _selectedCategory == 'Tất cả' || m.category == _selectedCategory;
      final matchDifficulty = _selectedDifficulty == 'Tất cả' ||
          (_selectedDifficulty == 'Dễ' && m.difficulty <= 2) ||
          (_selectedDifficulty == 'Trung bình' && m.difficulty == 3) ||
          (_selectedDifficulty == 'Khó' && m.difficulty >= 4);
      return matchCategory && matchDifficulty;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                SettingsManager.translate('explore_title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.explore, color: Colors.indigo, size: 24),
            ],
          ),
          const SizedBox(height: 16),

          // Chips bộ lọc Danh mục
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Tất cả', 'Động vật', 'Đồ vật', 'Hoa'].map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(_translateChipLabel(category)),
                    selected: isSelected,
                    selectedColor: Colors.indigo.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.indigo : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Chips bộ lọc Độ khó
          Row(
            children: ['Tất cả', 'Dễ', 'Trung bình', 'Khó'].map((diff) {
              final isSelected = _selectedDifficulty == diff;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(_translateChipLabel(diff)),
                  selected: isSelected,
                  selectedColor: Colors.purple.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.purple : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = diff;
                    });
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Lưới các mẫu gấp đã lọc
          Expanded(
            child: filteredModels.isEmpty
                ? const Center(child: Text('Không tìm thấy mẫu phù hợp.'))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: filteredModels.length,
                    itemBuilder: (context, index) {
                      return _buildOrigamiCard(filteredModels[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 2: YÊU THÍCH =================
  Widget _buildFavoritesTab() {
    final favoriteModels = MockData.models.where((m) => m.isFavorite).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                SettingsManager.translate('favorite_title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.favorite, color: Colors.red, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: favoriteModels.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          SettingsManager.translate('favorite_empty'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: favoriteModels.length,
                    itemBuilder: (context, index) {
                      return _buildOrigamiCard(favoriteModels[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 3: TIẾN ĐỘ =================
  Widget _buildProgressTab() {
    final progressModels = MockData.models.where((m) => m.currentStep > 0 && !m.isCompleted).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                SettingsManager.translate('progress_title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.trending_up, color: Colors.indigo, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: progressModels.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.trending_up, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          SettingsManager.translate('progress_empty'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: progressModels.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildProgressItemCard(progressModels[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 4: CÀI ĐẶT (SETTING LIST) =================
  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                SettingsManager.translate('settings_title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.settings, color: Colors.indigo, size: 24),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                _buildSettingRow(
                  icon: Icons.language,
                  color: Colors.blue,
                  title: SettingsManager.translate('language_setting'),
                  onTap: () {
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingDetailsScreen(settingType: 'Ngôn ngữ'),
                      ),
                    );
                    */
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingRow(
                  icon: Icons.dark_mode,
                  color: Colors.purple,
                  title: SettingsManager.translate('theme_setting'),
                  onTap: () {
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingDetailsScreen(settingType: 'Theme'),
                      ),
                    );
                    */
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingRow(
                  icon: Icons.delete_sweep,
                  color: Colors.orange,
                  title: SettingsManager.translate('clear_cache'),
                  onTap: () {
                    /*
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(SettingsManager.translate('cache_cleared'))),
                    );
                    */
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingRow(
                  icon: Icons.info_outline,
                  color: Colors.grey,
                  title: SettingsManager.translate('app_version'),
                  trailing: const Text('v1.0.0', style: TextStyle(color: Colors.grey)),
                  onTap: null,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color color,
    required String title,
    Widget? trailing,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // ================= THÀNH PHẦN CON DÙNG CHUNG TRONG TABS =================

  // Thẻ Card Origami ở tab Trang chủ và Khám phá
  Widget _buildOrigamiCard(OrigamiModel model) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrigamiDetailScreen(model: model),
          ),
        );
        setState(() {}); // Làm mới giao diện khi trở lại
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFEEF2F6),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Hero(
                  tag: 'model-${model.id}',
                  child: Image.asset(
                    model.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.menu_book, size: 48, color: Colors.indigo),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    SettingsManager.translate('all') == 'All' ? 'Category: ${model.category}' : 'Chủ đề: ${model.category}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            size: 11,
                            color: i < model.difficulty ? Colors.amber : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      Text(
                        '${model.stepsCount} bước',
                        style: const TextStyle(color: Colors.indigo, fontSize: 11, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thẻ Card Mẫu gấp dang dở (Tab Trang chủ và Tiến độ)
  Widget _buildProgressItemCard(OrigamiModel model) {
    final double progressPercent = model.currentStep / model.stepsCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              model.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.gesture, size: 28, color: Colors.indigo),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  SettingsManager.translate('all') == 'All'
                      ? 'At step ${model.currentStep}/${model.stepsCount}'
                      : 'Đang ở bước ${model.currentStep}/${model.stepsCount}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    color: Colors.indigo,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoldingStepsScreen(model: model),
                ),
              );
              setState(() {});
            },
            child: Text(
              SettingsManager.translate('continue_btn'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _translateChipLabel(String label) {
    if (SettingsManager.language.value == 'en') {
      switch (label) {
        case 'Tất cả': return 'All';
        case 'Động vật': return 'Animals';
        case 'Đồ vật': return 'Objects';
        case 'Hoa': return 'Flowers';
        case 'Dễ': return 'Easy';
        case 'Trung bình': return 'Medium';
        case 'Khó': return 'Hard';
        default: return label;
      }
    }
    return label;
  }
}
