import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../utils/settings_manager.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isEmailVerified = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return SettingsManager.translate('all') == 'All'
          ? 'Please enter your registered email'
          : 'Vui lòng nhập email đã đăng ký';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return SettingsManager.translate('all') == 'All'
          ? 'Invalid email format'
          : 'Email không đúng định dạng';
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

  void _verifyEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final exists = await DatabaseHelper.instance.checkEmailExists(email);
      if (!exists) {
        throw Exception(SettingsManager.translate('all') == 'All'
            ? 'This email is not registered in our system!'
            : 'Email này chưa được đăng ký trong hệ thống!');
      }

      setState(() {
        _isEmailVerified = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SettingsManager.translate('all') == 'All'
                ? 'Email verified! Please enter your new password.'
                : 'Xác minh email thành công! Vui lòng nhập mật khẩu mới.'),
          ),
        );
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

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final newPassword = _newPasswordController.text;

      await DatabaseHelper.instance.updateUserPassword(email, newPassword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(SettingsManager.translate('all') == 'All'
                ? 'Password reset successful! Please log in.'
                : 'Đặt lại mật khẩu thành công! Vui lòng đăng nhập.'),
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
          SettingsManager.translate('all') == 'All' ? 'Forgot Password' : 'Quên Mật Khẩu',
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
                        _isEmailVerified
                            ? (SettingsManager.translate('all') == 'All' ? 'Create New Password' : 'Tạo mật khẩu mới')
                            : (SettingsManager.translate('all') == 'All' ? 'Verify Registered Email' : 'Xác minh Email đã đăng ký'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEmailVerified
                            ? (SettingsManager.translate('all') == 'All'
                                ? 'Please enter a strong password containing at least 6 characters, uppercase and numbers.'
                                : 'Mật khẩu mới cần tối thiểu 6 ký tự, gồm chữ in hoa và chữ số.')
                            : (SettingsManager.translate('all') == 'All'
                                ? 'Enter your registered account email. The system will verify its existence for password recovery.'
                                : 'Nhập địa chỉ email tài khoản của bạn. Hệ thống sẽ xác minh để tiến hành đặt lại mật khẩu.'),
                        style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 32),
                      if (!_isEmailVerified) ...[
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: SettingsManager.translate('all') == 'All' ? 'Enter email address' : 'Nhập địa chỉ email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: SettingsManager.translate('all') == 'All' ? 'Verify Email' : 'Xác minh Email',
                          onPressed: _verifyEmail,
                        ),
                      ] else ...[
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
                          text: SettingsManager.translate('all') == 'All' ? 'Reset Password' : 'Đặt lại mật khẩu',
                          onPressed: _resetPassword,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
