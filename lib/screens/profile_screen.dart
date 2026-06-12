import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/settings_manager.dart';
import '../utils/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;
  int _completedCount = 0;
  int _inProgressCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = await DatabaseHelper.instance.getCurrentUser();
    if (user != null) {
      final userId = user['id'] as int;
      final completed = await DatabaseHelper.instance.getCompletedCount(userId);
      final inProgress = await DatabaseHelper.instance.getIncompleteProgress(userId);
      setState(() {
        _currentUser = user;
        _nameController.text = user['name'] ?? 'Khách';
        _emailController.text = user['email'] ?? '';
        _completedCount = completed;
        _inProgressCount = inProgress.length;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        if (_currentUser != null) {
          await DatabaseHelper.instance.updateUserAvatar(_currentUser!['email'], base64String);
          setState(() {
            _currentUser!['avatar'] = base64String;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tải ảnh đại diện thành công!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).appBarTheme.foregroundColor ?? textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          SettingsManager.translate('profile_title'),
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor ?? textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.indigo),
            onPressed: () async {
              if (_isEditing) {
                // Lưu thay đổi vào Hive
                if (_currentUser != null) {
                  final newName = _nameController.text.trim();
                  if (newName.isNotEmpty) {
                    await DatabaseHelper.instance.updateUserName(_currentUser!['email'], newName);
                    _currentUser!['name'] = newName;
                  }
                }
                setState(() {
                  _isEditing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(SettingsManager.translate('profile_saved'))),
                );
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Big Avatar with edit camera icon
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : Colors.indigo.shade50,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: (_currentUser != null && _currentUser!['avatar'] != null)
                            ? MemoryImage(base64Decode(_currentUser!['avatar']))
                            : const NetworkImage(
                                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=250',
                              ) as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: CircleAvatar(
                        backgroundColor: Colors.indigo,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          onPressed: _pickAndUploadAvatar,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // User Info details
              Text(
                _currentUser != null ? _currentUser!['name'] : 'Khách',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                _currentUser != null ? _currentUser!['email'] : 'email@example.com',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Achievements statistic card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$_completedCount',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          SettingsManager.translate('completed_stat'),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: Colors.indigo.withOpacity(
                        Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.2,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '$_inProgressCount',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          SettingsManager.translate('in_progress_stat'),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Input fields
              TextField(
                controller: _nameController,
                enabled: _isEditing,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: SettingsManager.translate('display_name'),
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: !_isEditing,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                enabled: false,
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 24),

              // Secondary actions
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Colors.indigo,
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.indigo),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(SettingsManager.translate('reset_link_sent'))),
                  );
                },
                child: Center(
                  child: Text(
                    SettingsManager.translate('change_password'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Danger zone: Logout button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.red.withOpacity(0.15)
                      : Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  await DatabaseHelper.instance.logoutUser();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                child: Center(
                  child: Text(
                    SettingsManager.translate('log_out'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
