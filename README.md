# 📄 Ứng Dụng Hướng Dẫn Gấp Giấy Nghệ Thuật (Origami Master)

Chào mừng bạn đến với dự án **Origami Master** - ứng dụng di động được xây dựng bằng **Flutter** nhằm giải quyết bài toán hướng dẫn và hỗ trợ người dùng tự học nghệ thuật gấp giấy Nhật Bản (Origami) một cách trực quan, sinh động và lưu trữ tiến độ dễ dàng.

---

## 🎯 1. Đáp Ứng Yêu Cầu Đề Tài (Yêu cầu của Giảng viên)
Dự án được phát triển và tối ưu hóa để đáp ứng **chính xác 4 tiêu chí cốt lõi** theo yêu cầu của Giảng viên:

| STT | Yêu cầu của Giảng viên | Giải pháp triển khai trong ứng dụng |
|---|---|---|
| **1** | **Danh sách các kiểu gấp giấy** | Màn hình **Danh sách Origami** hiển thị trực quan các mẫu gấp (hình ảnh, tên mẫu, phân loại độ khó từ dễ đến khó, và lọc theo danh mục: Động vật, Hoa, Đồ dùng...). |
| **2** | **Chi tiết các bước thực hiện** | Màn hình **Chi tiết bước gấp** hướng dẫn từng bước (Step-by-step). Mỗi bước có hình ảnh/GIF minh họa cục bộ rõ ràng cùng dòng hướng dẫn văn bản chi tiết. Người dùng có thể bấm "Next" hoặc "Back" chủ động. |
| **3** | **Ghi nhận thành quả bản thân** | Tích hợp **Màn hình Chúc mừng** khi hoàn thành bước gấp cuối cùng. Hệ thống sẽ tự động cập nhật số lượng mẫu gấp thành công và hiển thị thống kê biểu đồ/số liệu trong màn hình **Hồ sơ cá nhân**. |
| **4** | **Cho phép dùng db local, image local** | Ứng dụng chạy offline 100%: <br>- **Database Local:** Sử dụng **SQLite (sqflite)** hoặc **Hive** lưu trữ thông tin tài khoản người dùng, tiến độ gấp dở (bước mấy) và danh sách các mẫu đã gấp thành công. <br>- **Image Local:** Toàn bộ ảnh các bước gấp và ảnh minh họa được cấu hình trực tiếp trong thư mục `assets/` của Flutter. |

---

## 🎯 2. Đặt Vấn Đề (Bài toán gấp giấy Origami)
Gấp giấy nghệ thuật Origami là một hoạt động sáng tạo tuyệt vời giúp rèn luyện sự kiên nhẫn, khéo léo và tư duy không gian. Tuy nhiên, người học thường gặp phải các rào cản lớn:
*   **Sơ đồ tĩnh khó hiểu:** Sách hoặc các sơ đồ vẽ tay với mũi tên ký hiệu thường rất trừu tượng, khiến người mới bắt đầu dễ nản lòng ở những bước phức tạp.
*   **Video dài và bất tiện:** Các video hướng dẫn trên mạng thường diễn ra liên tục, người dùng phải liên tục dừng (pause), tua lại bằng tay khi đang cầm giấy, gây gián đoạn trải nghiệm.
*   **Mất dấu tiến trình:** Người dùng không thể lưu lại trạng thái mình đang gấp dở ở bước nào nếu có việc bận đột xuất phải tắt ứng dụng.

---

## 📂 3. Cấu Trúc Thư Mục Dự Án (Folder Structure)
Dự án được tổ chức theo cấu trúc phẳng, tối giản nhưng khoa học:
```text
lib/
├── main.dart             # Điểm chạy app chính & cấu hình định tuyến (routing)
│
├── screens/              # Chứa toàn bộ các file màn hình ứng dụng (Screens)
│   ├── login_guide_screen.dart      # Màn hình hướng dẫn đăng nhập
│   ├── login_screen.dart            # Màn hình đăng nhập
│   ├── register_screen.dart         # Màn hình đăng ký
│   ├── home_screen.dart             # Màn hình trang chủ chính (Danh sách các mẫu & Tiến độ)
│   └── ... (Các màn hình chi tiết & trình gấp đang phát triển)
│
└── widgets/              # Chứa các thành phần UI nhỏ dùng chung
    ├── custom_button.dart           # Nút bấm thiết kế gradient hiện đại
    └── custom_text_field.dart       # Ô nhập liệu có nút ẩn/hiện mật khẩu
```

---

## 🚀 4. Hướng Dẫn Khởi Chạy Dự Án

### Yêu cầu hệ thống
*   Đã cài đặt Flutter SDK (phiên bản `>= 3.0.0`)
*   Đã cài đặt Android Studio / VS Code (với Flutter extension)

### Các bước khởi chạy
1.  Mở thư mục `PRM392-Project` bằng terminal hoặc VS Code.
2.  Chạy lệnh để tải các package phụ thuộc:
    ```bash
    flutter pub get
    ```
3.  Kết nối thiết bị mô phỏng (Emulator) hoặc thiết bị thật, sau đó chạy lệnh:
    ```bash
    flutter run
    ```
