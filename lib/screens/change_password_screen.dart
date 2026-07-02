import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../utils/settings_manager.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return SettingsManager.translate('all') == 'All'
          ? 'Please enter your old password'
          : 'Vui lòng nhập mật khẩu cũ';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return SettingsManager.translate('all') == 'All'
          ? 'Please enter your new password'
          : 'Vui lòng nhập mật khẩu mới';
    }
    if (value.length < 6) {
      return SettingsManager.translate('all') == 'All'
          ? 'Password must be at least 6 characters'
          : 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return SettingsManager.translate('all') == 'All'
          ? 'Password must contain at least 1 uppercase letter'
          : 'Mật khẩu phải chứa ít nhất 1 chữ cái hoa';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return SettingsManager.translate('all') == 'All'
          ? 'Password must contain at least 1 digit'
          : 'Mật khẩu phải chứa ít nhất 1 chữ số';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return SettingsManager.translate('all') == 'All'
          ? 'Please confirm your new password'
          : 'Vui lòng xác nhận mật khẩu mới';
    }
    if (value != _newPasswordController.text) {
      return SettingsManager.translate('all') == 'All'
          ? 'Confirm password does not match'
          : 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  void _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await DatabaseHelper.instance.getCurrentUser();
      if (user == null) {
        throw Exception(SettingsManager.translate('all') == 'All'
            ? 'User session not found!'
            : 'Không tìm thấy phiên làm việc!');
      }

      final email = user['email'] as String;
      final currentDbUser = await DatabaseHelper.instance.loginUser(email, _oldPasswordController.text);
      if (currentDbUser == null) {
        throw Exception(SettingsManager.translate('all') == 'All'
            ? 'Incorrect old password!'
            : 'Mật khẩu cũ không chính xác!');
      }

      final newPassword = _newPasswordController.text;
      if (newPassword == _oldPasswordController.text) {
        throw Exception(SettingsManager.translate('all') == 'All'
            ? 'New password cannot be the same as old password!'
            : 'Mật khẩu mới không được trùng mật khẩu cũ!');
      }

      await DatabaseHelper.instance.updateUserPassword(email, newPassword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SettingsManager.translate('all') == 'All'
                ? 'Password changed successfully!'
                : 'Thay đổi mật khẩu thành công!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          SettingsManager.translate('all') == 'All' ? 'Change Password' : 'Đổi Mật Khẩu',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        SettingsManager.translate('all') == 'All'
                            ? 'Update Password'
                            : 'Cập Nhật Mật Khẩu',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        SettingsManager.translate('all') == 'All'
                            ? 'Please choose a strong password with at least 6 characters, uppercase and numbers.'
                            : 'Mật khẩu mới cần tối thiểu 6 ký tự, gồm chữ hoa và chữ số.',
                        style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        controller: _oldPasswordController,
                        labelText: SettingsManager.translate('all') == 'All' ? 'Old Password' : 'Mật khẩu cũ',
                        hintText: SettingsManager.translate('all') == 'All' ? 'Enter old password' : 'Nhập mật khẩu cũ',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        validator: _validateOldPassword,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _newPasswordController,
                        labelText: SettingsManager.translate('all') == 'All' ? 'New Password' : 'Mật khẩu mới',
                        hintText: SettingsManager.translate('all') == 'All' ? 'Enter new password' : 'Nhập mật khẩu mới',
                        prefixIcon: Icons.lock_reset,
                        isPassword: true,
                        validator: _validateNewPassword,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        labelText: SettingsManager.translate('all') == 'All' ? 'Confirm New Password' : 'Xác nhận mật khẩu mới',
                        hintText: SettingsManager.translate('all') == 'All' ? 'Confirm new password' : 'Nhập lại mật khẩu mới',
                        prefixIcon: Icons.vpn_key_outlined,
                        isPassword: true,
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: SettingsManager.translate('all') == 'All' ? 'Save Password' : 'Lưu mật khẩu',
                        onPressed: _changePassword,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
