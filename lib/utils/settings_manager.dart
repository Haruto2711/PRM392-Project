import 'package:flutter/material.dart';

class SettingsManager {
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);
  static final ValueNotifier<String> language = ValueNotifier<String>('vi'); // 'vi' or 'en'

  static String translate(String key) {
    final lang = language.value;
    if (lang == 'en') {
      return _en[key] ?? key;
    }
    return _vi[key] ?? key;
  }

  static const Map<String, String> _vi = {
    // Màn hình Cài đặt
    'settings_title': 'Cài đặt',
    'language_setting': 'Ngôn ngữ',
    'theme_setting': 'Giao diện Sáng/Tối',
    'clear_cache': 'Xóa bộ nhớ đệm',
    'app_version': 'Phiên bản ứng dụng',
    'select_language': 'Chọn Ngôn ngữ',
    'theme_config': 'Cấu hình Giao diện',
    'select_language_desc': 'Chọn ngôn ngữ hiển thị của ứng dụng:',
    'dark_mode_title': 'Chế độ tối (Dark Mode)',
    'dark_mode_desc': 'Tiết kiệm pin và dịu mắt khi sử dụng ban đêm',
    'dark_mode_setting_desc': 'Cài đặt chế độ hiển thị tối:',
    'cache_cleared': 'Đã xoá bộ nhớ đệm cục bộ!',
    'language_changed_to': 'Đã đổi ngôn ngữ sang',
    'dark_mode_on': 'Đã bật Chế độ tối!',
    'dark_mode_off': 'Đã tắt Chế độ tối!',

    // Màn hình Trang chủ & Navigation
    'tab_home': 'Trang chủ',
    'tab_explore': 'Khám phá',
    'tab_favorite': 'Yêu thích',
    'tab_progress': 'Tiến độ',
    'tab_settings': 'Cài đặt',
    'hello_user': 'Xin chào, Origami Fan!',
    'my_achievement': 'THÀNH QUẢ BẢN THÂN',
    'completed': 'Đã hoàn thành',
    'origami_models': 'Mẫu Origami',
    'in_progress_title': 'Mẫu đang gấp dở',
    'view_all': 'Xem toàn bộ',
    'folding_at_step': 'Đang ở bước',
    'continue_btn': 'Gấp tiếp',

    // Màn hình Khám phá
    'explore_title': 'Khám phá',
    'search_hint': 'Tìm kiếm mẫu gấp...',
    'filter_category': 'Chủ đề',
    'filter_difficulty': 'Độ khó',
    'all': 'Tất cả',

    // Màn hình Chi tiết
    'difficulty': 'Độ khó',
    'steps_count': 'Số bước',
    'time_estimate': 'Thời gian',
    'detail_desc': 'Mô tả chi tiết',
    'start_folding': 'Bắt đầu gấp',
    'continue_folding': 'Tiếp tục gấp',
    'favorite_added': 'Đã thêm vào danh sách yêu thích!',
    'favorite_removed': 'Đã xóa khỏi danh sách yêu thích.',

    // Màn hình Tiến trình
    'progress_title': 'Tiến độ gấp',
    'progress_empty': 'Chưa có tiến trình nào.',
    'progress_empty_desc': 'Bắt đầu gấp mẫu để theo dõi tiến độ tại đây!',

    // Màn hình Yêu thích
    'favorite_title': 'Yêu thích',
    'favorite_empty': 'Chưa có mẫu yêu thích nào.',
    'favorite_empty_desc': 'Hãy khám phá và thả tim mẫu bạn thích nhé!',

    // Màn hình Hồ sơ
    'profile_title': 'Hồ sơ người dùng',
    'completed_stat': 'Đã hoàn thành',
    'in_progress_stat': 'Đang làm dở',
    'display_name': 'Tên hiển thị',
    'phone_number': 'Số điện thoại',
    'change_password': 'Đổi mật khẩu',
    'log_out': 'Đăng xuất',
    'profile_saved': 'Đã lưu thay đổi hồ sơ!',
    'reset_link_sent': 'Đã gửi liên kết đổi mật khẩu tới email của bạn!',
    'avatar_feature_dev': 'Tính năng tải ảnh đại diện đang phát triển',

    // Gấp giấy & Chúc mừng
    'step_label': 'BƯỚC',
    'step_completed': 'Hoàn thành',
    'save_exit': 'Lưu & Thoát',
    'save_success': 'Đã lưu tiến trình gấp giấy!',
    'next': 'Tiếp theo',
    'back': 'Quay lại',
    'finish': 'Hoàn thành',
    'congrats_title': 'XUẤT SẮC!',
    'congrats_desc': 'Bạn đã hoàn thành mẫu gấp giấy:',
    'congrats_record': 'Thành quả này đã được ghi nhận vào\nHồ sơ cá nhân và bảng thành tích của bạn!',
    'instruction': 'Hướng dẫn:',
    'step_image_placeholder_title': 'Hình ảnh bước',
    'step_image_placeholder_desc': 'Hình ảnh minh họa đang được cập nhật',
    'congrats_back': 'Quay về trang chủ',
    'security_tips': 'Mẹo bảo mật:',
    'security_tip_1': '• Không chia sẻ mật khẩu của bạn cho bất kỳ ai',
    'security_tip_2': '• Sử dụng mật khẩu mạnh (ít nhất 8 ký tự)',
    'security_tip_3': '• Đăng xuất khi sử dụng trên máy tính công cộng',
    'login_guide_title': 'Hướng dẫn đăng nhập',
    'login_guide_step_1_title': 'Nhập Email hoặc Tên đăng nhập',
    'login_guide_step_1_desc': 'Sử dụng email hoặc tên đăng nhập mà bạn đã đăng ký.',
    'login_guide_step_2_title': 'Nhập Mật khẩu',
    'login_guide_step_2_desc': 'Nhập mật khẩu chính xác. Nếu quên mật khẩu, vui lòng nhấp vào "Quên mật khẩu?"',
    'login_guide_step_3_title': 'Quản lý tài khoản',
    'login_guide_step_3_desc': 'Sau khi đăng nhập thành công, bạn có thể quản lý thông tin cá nhân và cài đặt trong phần "Hồ sơ".',
  };

  static const Map<String, String> _en = {
    // Settings Screen
    'settings_title': 'Settings',
    'language_setting': 'Language',
    'theme_setting': 'Light/Dark Theme',
    'clear_cache': 'Clear Cache',
    'app_version': 'App Version',
    'select_language': 'Select Language',
    'theme_config': 'Theme Settings',
    'select_language_desc': 'Select the application\'s display language:',
    'dark_mode_title': 'Dark Mode',
    'dark_mode_desc': 'Save battery and ease eyes when using at night',
    'dark_mode_setting_desc': 'Dark theme configuration:',
    'cache_cleared': 'Local cache has been cleared!',
    'language_changed_to': 'Language changed to',
    'dark_mode_on': 'Dark Mode turned on!',
    'dark_mode_off': 'Dark Mode turned off!',

    // Home Screen & Navigation
    'tab_home': 'Home',
    'tab_explore': 'Explore',
    'tab_favorite': 'Favorites',
    'tab_progress': 'Progress',
    'tab_settings': 'Settings',
    'hello_user': 'Welcome, Origami Fan!',
    'my_achievement': 'MY ACHIEVEMENTS',
    'completed': 'Completed',
    'origami_models': 'Origami Models',
    'in_progress_title': 'In Progress Models',
    'view_all': 'View All',
    'folding_at_step': 'At step',
    'continue_btn': 'Continue',

    // Explore Screen
    'explore_title': 'Explore',
    'search_hint': 'Search origami models...',
    'filter_category': 'Category',
    'filter_difficulty': 'Difficulty',
    'all': 'All',

    // Detail Screen
    'difficulty': 'Difficulty',
    'steps_count': 'Steps',
    'time_estimate': 'Time',
    'detail_desc': 'Detailed Description',
    'start_folding': 'Start Folding',
    'continue_folding': 'Continue Folding',
    'favorite_added': 'Added to favorites list!',
    'favorite_removed': 'Removed from favorites list.',

    // Progress Screen
    'progress_title': 'Folding Progress',
    'progress_empty': 'No progress recorded yet.',
    'progress_empty_desc': 'Start folding a model to track progress here!',

    // Favorite Screen
    'favorite_title': 'Favorites',
    'favorite_empty': 'No favorites added yet.',
    'favorite_empty_desc': 'Explore and heart the models you like!',

    // Profile Screen
    'profile_title': 'User Profile',
    'completed_stat': 'Completed',
    'in_progress_stat': 'In Progress',
    'display_name': 'Display Name',
    'phone_number': 'Phone Number',
    'change_password': 'Change Password',
    'log_out': 'Log Out',
    'profile_saved': 'Profile changes saved!',
    'reset_link_sent': 'Password reset link sent to your email!',
    'avatar_feature_dev': 'Avatar upload feature is under development',

    // Folding & Congrats
    'step_label': 'STEP',
    'step_completed': 'Completed',
    'save_exit': 'Save & Exit',
    'save_success': 'Folding progress saved!',
    'next': 'Next',
    'back': 'Back',
    'finish': 'Finish',
    'congrats_title': 'EXCELLENT!',
    'congrats_desc': 'You have completed the model:',
    'congrats_record': 'This achievement has been recorded in\nyour personal profile and scoreboard!',
    'instruction': 'Instructions:',
    'step_image_placeholder_title': 'Image for step',
    'step_image_placeholder_desc': 'Illustration is being updated',
    'congrats_back': 'Back to home',
    'security_tips': 'Security tips:',
    'security_tip_1': '• Do not share your password with anyone',
    'security_tip_2': '• Use a strong password (at least 8 characters)',
    'security_tip_3': '• Log out when using public computers',
    'login_guide_title': 'Login Guide',
    'login_guide_step_1_title': 'Enter Email or Username',
    'login_guide_step_1_desc': 'Use the email or username you registered with.',
    'login_guide_step_2_title': 'Enter Password',
    'login_guide_step_2_desc': 'Enter the correct password. If you forgot it, tap "Forgot Password?"',
    'login_guide_step_3_title': 'Manage Account',
    'login_guide_step_3_desc': 'After logging in, you can manage personal info and settings in "Profile".',
  };
}
